package cache
from std import time.*
from std import collection.HashMap, collection.Buffer
from std import sync.Mutex

let NoExpiration = Duration.nanosecond(-1)
let DefaultExpiration = Duration.nanosecond(0)

public record Item<T>{
    var Data:T
    var Expiration:Int64 = 0
    init(data:T) {
        this.Data = data
    }

    init(data:T, expiration:Int64) {
        this.Data = data
        this.Expiration = expiration
    }

    func Expired(): Bool {
        if (this.Expiration == 0) {
            return false
        }
        return Time.now().unixNano() > this.Expiration
    }
}

public class Cache<T> {
    private var defaultExpiration:Duration
    private var items:HashMap<String, Item<T>>
    private var mu:Mutex
    private var onEvicted:Option<(String, T) -> Unit>

    init(defaultExpiration:Duration, cleanupInterval:Duration, items:HashMap<String, Item<T>>) {
        this.defaultExpiration = defaultExpiration
        this.items = items
        this.mu = Mutex()
        this.onEvicted = None
    }
    init(defaultExpiration:Duration, cleanupInterval:Duration) {
        this.defaultExpiration = defaultExpiration
        this.items = HashMap()
        this.mu = Mutex()
        this.onEvicted = None
    }

    func Set(k:String,v:T, d!:Duration = DefaultExpiration) {
        var e:Int64 = d.microseconds()
        if (d == DefaultExpiration) {
            e = this.defaultExpiration.microseconds()
        }
        this.mu.lock()
        this.items.put(k, Item(v, e))
        this.mu.unlock()
    }

    private func set(k:String,v:T, d!:Duration = DefaultExpiration) {
        var e:Int64 = d.nanoseconds()
        if (d == DefaultExpiration) {
            e = this.defaultExpiration.microseconds()
        }
        this.items.put(k, Item(v, e))
    }

    func SetDefault(k:String,v:T) {
        this.Set(k, v)
    }

    private func l_get(k:String):Option<T> {
        let item = this.items.get(k)
        match (item) {
            case $None => return None
            case Some(v) => 
             if (v.Expiration > 0 && Time.now().unixNano() > v.Expiration) {
                return None
             }
             return v.Data
        }
    }
}

public record KeyValue<T> {
    var key:String
    var value:T
    init(key:String, value:T) {
        this.key = key
        this.value = value
    }
}
