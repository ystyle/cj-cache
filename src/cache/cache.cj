package cache
from std import time.*
from std import collection.HashMap, collection.ArrayList
from std import sync.Mutex
from std import io.WriteStream,io.FileStream, io.ReadStream, io.SeekOrigin
from serialization import serialization.*
from encoding import json.*

let NoExpiration = Duration.nanosecond(-1)
let DefaultExpiration = Duration.nanosecond(0)

/**
  * Item 缓存项定义
  */
public record Item<T> <: Serializable<Item<T>> where T <: Serializable<T> {
    var Data:T
    var Expiration:Int64 = 0
    public init(data:T) {
        this.Data = data
    }

    public init(data:T, expiration:Int64) {
        this.Data = data
        this.Expiration = expiration
    }

    /**
      * 判断是否过期
      */
    public func Expired(): Bool {
        if (this.Expiration == 0) {
            return false
        }
        return Time.now().unixNano() > this.Expiration
    }

    public func serialize(): DataModel {
        return DataModelStruct().add(field<T>("data", this.Data)).add(field<Int64>("expiration", this.Expiration))
    }
    public static func deserialize(dm: DataModel): Item<T> {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let expiration = Int64.deserialize(dms.get("expiration"))
        let data = T.deserialize(dms.get("data"))
        return Item(data, expiration)
    }
}

/**
  * 缓存
  */
public class Cache<T> where T <: Serializable<T> {
    protected var defaultExpiration:Duration // 默认过期时间
    protected var items:HashMap<String, Item<T>> // 项目
    protected var mu:Mutex // 锁
    protected var onEvicted:Option<(String, T) -> Unit> // 删除项目时的回调方法
    private var janitor:?Janitor<T> = None // 管理并删除过期的项目
    
    public init(defaultExpiration:Duration, cleanupInterval:Duration, items:HashMap<String, Item<T>>) {
        this(defaultExpiration, cleanupInterval)
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
            this.items.put(k, Item<T>(v, e))
        }
    }

    private func set(k:String,v:T, d!:Duration = DefaultExpiration) {
        var e:Int64 = d.nanoseconds()
        if (d == DefaultExpiration) {
            e = this.defaultExpiration.microseconds()
        }
        this.items.put(k, Item<T>(v, e))
    }

    /**
      * 使用默认过期时间添加一个项目
      */
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

    /**
      * 添加一个项目
      */
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

    /**
      * 替代项目
      */
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
        synchronized (this.mu) {
            if (this.items.contains(k)) {
                let v = this.items[k]
                if (v.Expiration >0) {
                    if (Time.now().unixNano() > v.Expiration) {
                        return None
                    }
                }
                return v.Data
            } else {
                return None
            }
        }
    }

    public func GetWithExpiration(k:String):Option<T*Int64> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                let v = this.items[k]
                if (v.Expiration > 0) {
                    if (Time.now().unixNano() > v.Expiration) {
                        return None
                    }
                    return (v.Data, v.Expiration)
                }
                return (v.Data, 0)
            } else {
                return None
            }
        }
    }

    private func delete(k:String): Option<T> {
        if (this.items.contains(k)) {
            let v = this.items[k]
            this.items.remove(k)
            this.onEvicted?(k, v.Data)
            return v.Data
        } else {
            return None
        }
    }

    public func Delete(k:String) {
        var r:Option<T>
        synchronized(this.mu) {
            r = this.delete(k)
        }
        match (r) {
            case None => ()
            case Some(v) => this.onEvicted?(k, v)
        }
    }

    public func DeleteExpired() {
        var evictedItems = ArrayList<KeyValue<T>>()
        let now = Time.now().unixNano()
        synchronized(this.mu) {
            for ((k, item) in this.items) {
                if (item.Expiration > 0 && now > item.Expiration) {
                    let r = this.delete(k)
                    match (r) {
                        case None => ()
                        case Some(ov) => 
                            evictedItems.add(KeyValue<T>(k, ov))
                    }           
                }
            }
        }
        for (item in evictedItems) {
            this.onEvicted?(item.key, item.value)
        }
    }

    public func OnEvicted(fn: (String, T) -> Unit) {
        synchronized (this.mu) {
            this.onEvicted = fn
        }
    }

    public func Items():HashMap<String, Item<T>> {
        let m = HashMap<String, Item<T>>(this.items.size())
        let now = Time.now().unixNano()
        synchronized(this.mu) {
            for ((key, item) in this.items) {
                if (item.Expiration > 0) {
                    if (now > item.Expiration) {
                        continue
                    }
                }
                m.put(key, item)
            }
        }
        return m
    }

    public func ItemCount():Int64 {
        var n:Int64
        synchronized(this.mu) {
            n = this.items.size()
        }
        return n
    }

    public func Flush() {
        synchronized(this.mu) {
            this.items.clear()
        }
    }

    public func Save (w:WriteStream) {
        synchronized(this.mu) {
            let m: DataModel = this.items.serialize()
            w. write(m.toJson().toString().toUtf8Array())
        }
    }

    public func SaveFile(filename:String) {
        var fs = FileStream(filename)
        fs.openFile()
        this.Save(fs)
        fs.flush()
        fs.close()
    }

    public func Load(r:ReadStream) {
        r.seek(0, SeekOrigin.BeginPos)
        let b = ArrayList<UInt8>()
        while (true) {
            let bs = Array<UInt8>(512, item: 0)
            let n = r.read(bs)
            b.addAll(bs[0..n])
            if (n ==0 || n < 512) {
                break
            }
        }
        let json = String.fromUtf8(Array<UInt8>(b))
        let itemm = HashMap<String, Item<T>>.deserialize(DataModel.fromJson(JsonValue.fromStr(json)))
        this.items = items
        synchronized(this.mu) {
            for ((k, v) in itemm) {
                if (!this.items.contains(k)) {
                    this.items[k] = v
                }
            }
        }
    }

    public func Loadfile(filename:String) {
         var fs = FileStream(filename)
        fs.openFile()
        this.Load(fs)
        fs.flush()
        fs.close()
    }
}

public record KeyValue<T> where T <: Serializable<T> {
    var key:String
    var value:T
    init(key:String, value:T) {
        this.key = key
        this.value = value
    }
}

class Janitor<T> where T <: Serializable<T> {
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
