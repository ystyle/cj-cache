package cache
from std import time.*
from std import collection.HashMap, collection.Buffer
from std import sync.Mutex

let NoExpiration = Duration.second(-1)
let DefaultExpiration = Duration.second(0)

public record Item<T>{
    var Data:T
    var Expiration:Int64 = 0
    public init(data:T) {
        this.Data = data
    }

    public init(data:T, expiration:Int64) {
        this.Data = data
        this.Expiration = expiration
    }

    public func Expired(): Bool {
        if (this.Expiration == 0) {
            return false
        }
        return Time.now().unixNano() > this.Expiration
    }
}

public class Cache<T> {
    protected var defaultExpiration:Duration
    protected var items:HashMap<String, Item<T>>
    protected var mu:Mutex
    protected var onEvicted:Option<(String, T) -> Unit>
    private var janitor:?Janitor<T> = None
    
    public init(defaultExpiration:Duration, cleanupInterval:Duration, items:HashMap<String, Item<T>>) {
        this.defaultExpiration = defaultExpiration
        this.items = items
        this.mu = Mutex()
        this.onEvicted = None
        if (cleanupInterval.nanoseconds() > 0) {
            this.janitor = Janitor<T>(cleanupInterval)
            this.janitor?.run(this)
        }
    }
    public init(defaultExpiration:Duration, cleanupInterval:Duration) {
        this.defaultExpiration = defaultExpiration
        this.items = HashMap()
        this.mu = Mutex()
        this.onEvicted = None
        if (cleanupInterval.nanoseconds() > 0) {
            this.janitor = Janitor<T>(cleanupInterval)
            this.janitor?.run(this)
        }
    }

    /**
     * 设置值, 不检查是否已存在
     * @param k:String key
     * @param v:String value
     * @param d!:Duration 不填写时不过期
     */
    public func Set(k:String,v:T, d!:Duration = NoExpiration) {
        var e:Int64 = d.microseconds()
        if (d == DefaultExpiration) {
            e = this.defaultExpiration.microseconds()
        }
        synchronized(this.mu) {
            this.items.put(k, Item(v, e))
        }
    }

    private func set(k:String,v:T, d!:Duration = DefaultExpiration) {
        var e:Int64 = d.microseconds()
        if (d == DefaultExpiration) {
            e = this.defaultExpiration.microseconds()
        }
        this.items.put(k, Item(v, e))
    }

    public func SetDefault(k:String,v:T) {
        this.Set(k, v)
    }

    private func get(k:String):Option<T> {
        if (this.items.contains(k)) {
            let v = this.items[k]
            if (v.Expiration > 0) {
                if (Time.now().unixNano() > v.Expiration) {
                    return None
                }
             }
             return v.Data
        } else {
            return None
        }
    }

    public func Add(k:String,v:T, d!:Duration = DefaultExpiration):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                return Err(Exception("Item ${k} already exists"))
            } else  {
                this.set(k, v, d:d)
                return Ok(())
            }
        }
    }

    public func Replace(k:String,v:T, d!:Duration = DefaultExpiration):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                this.set(k, v, d:d)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} doesn't exist"))
            }
        }
    }

    public func Get(k:String):Option<T> {
        this.mu.lock()
        if (this.items.contains(k)) {
            let v = this.items[k]
            if (v.Expiration >0) {
                if (Time.now().unixNano() > v.Expiration) {
                    return None
                }
            }
            this.mu.unlock()
            return v.Data
        } else {
            this.mu.unlock()
            return None
        }
    }

    public func GetWithExpiration(k:String):Option<T*Int64> {
        this.mu.lock()
        if (this.items.contains(k)) {
            let v = this.items[k]
            if (v.Expiration > 0) {
                if (Time.now().unixNano() > v.Expiration) {
                    this.mu.unlock()
                    return None
                }
                this.mu.unlock()
                return (v.Data, v.Expiration)
            }
            return (v.Data, 0)
        } else {
            this.mu.unlock()
            return None
        }
    }

    private func delete(k:String): Option<T> {
        this.mu.lock()
        if (this.items.contains(k)) {
            let v = this.items[k]
            this.items.remove(k)
            this.onEvicted?(k, v.Data)
            this.mu.unlock()
            return v.Data
        } else {
            this.mu.unlock()
            return None
        }
    }

    public func Delete(k:String) {
        this.mu.lock()
        let r = this.delete(k)
        this.mu.unlock()
        match (r) {
            case None => ()
            case Some(v) => this.onEvicted?(k, v)
        }
    }

    public func DeleteExpired() {
        var evictedItems = Buffer<KeyValue<T>>()
        let now = Time.now().unixNano()
        this.mu.lock()
        for ((k, item) in this.items) {
            if (item.Expiration > 0 && now > item.Expiration) {
                let r = this.delete(k)
                match (r) {
                    case None => ()
                    case Some(ov) => 
                        evictedItems.add(KeyValue(k, ov))
                }           
            }
        }
        this.mu.unlock()
        for (item in evictedItems) {
            this.onEvicted?(item.key, item.value)
        }
    }

    public func OnEvicted(fn: (String, T) -> Unit) {
        this.mu.lock()
        this.onEvicted = fn
        this.mu.unlock()
    }

    public func Items():HashMap<String, Item<T>> {
        this.mu.lock()
        let m = HashMap<String, Item<T>>(this.items.size())
        let now = Time.now().unixNano()
        for ((key, item) in this.items) {
            if (item.Expiration > 0) {
                if (now > item.Expiration) {
                    continue
                }
            }
            m.put(key, item)
        }
        return m
    }

    public func ItemCount():Int64 {
        this.mu.lock()
        let n = this.items.size()
        this.mu.unlock()
        return n
    }

    func Flush() {
        this.mu.lock()
        this.items.clear()
        this.mu.unlock()
    }
}

record KeyValue<T> {
    var key:String
    var value:T
    init(key:String, value:T) {
        this.key = key
        this.value = value
    }
}

class Janitor<T> {
    let Interval:Duration
    init(interval:Duration) {
        this.Interval = interval
    }
    func run(c:Cache<T>) {
        var ticker = Ticker(this.Interval, { 
            let count = c.ItemCount()
            c.DeleteExpired()
            let currCount = c.ItemCount()
            println("clean expired item, count: ${count} => ${currCount}")
        })
    }
}
