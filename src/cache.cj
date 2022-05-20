/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * 
 * Create cache instance and operation
 */
package cache
from std import time.*
from std import collection.HashMap, collection.ArrayList
from std import sync.Mutex
from std import io.WriteStream,io.FileStream, io.ReadStream, io.SeekOrigin
from serialization import serialization.*
from encoding import json.*

let NoExpiration = Duration.nanosecond(-1)
let DefaultExpiration = Duration.nanosecond(0)

/*
 * Item Cache item definition
 * 
 * @author @ystyle
 * @since 0.28.4
 */
public record Item<T> <: Serializable<Item<T>> where T <: Serializable<T> {
    var Data:T
    var Expiration:Int64 = 0

    /*
     * Item initialization
     *
     * @param data Cache data
     *
     * @since 0.28.4
     */
    public init(data:T) {
        this.Data = data
    }

    /*
     * Item initialization
     *
     * @param data Cache data
     * @param expiration Expiration value
     *
     * @since 0.28.4
     */
    public init(data:T, expiration:Int64) {
        this.Data = data
        this.Expiration = expiration
    }

    /*
     * Determine whether it is expired
     *
     * @return Bool 
     * @since 0.28.4
     */
    public func Expired(): Bool {
        if (this.Expiration == 0) {
            return false
        }
        return Time.now().unixNano() > this.Expiration
    }

    /**
     * Change the data serialization
     *
     * @return DataModel The return type of DataModel
     * @since 0.28.4
     */
    public func serialize(): DataModel {
        return DataModelStruct().add(field<T>("data", this.Data)).add(field<Int64>("expiration", this.Expiration))
    }
    /**
     * DataModel deserialize
     *
     * @param dm DataModel
     *
     * @return Item The return type of Item<T>
     * @since 0.28.4
     */
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

/*
 * Cache
 * 
 * @author @ystyle
 * @since 0.28.4
 */
public class Cache<T> where T <: Serializable<T> {
    /* Default expiration time */
    protected var defaultExpiration:Duration
    /* item */
    protected var items:HashMap<String, Item<T>>
    /* lock */
    protected var mu:Mutex
    /* Callback method when deleting an item */
    protected var onEvicted:Option<(String, T) -> Unit>
    /* Manage and delete expired items */
    private var janitor:?Janitor<T> = None
    
    /**
     * Create cache instance
     *
     * @param defaultExpiration Default expiration time
     * @param cleanupInterval Time to automatically clear cache
     *                        Greater than 0 is required to perform automatic cleanup
     * @param items Set initial cache entry
     *
     * @since 0.28.4
     */
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

    /**
     * Create cache instance
     *
     * @param defaultExpiration Default expiration time
     * @param cleanupInterval Time to automatically clear cache
     *                        Greater than 0 is required to perform automatic cleanup
     *
     * @since 0.28.4
     */
    public init(defaultExpiration:Duration, cleanupInterval:Duration) {
        this(defaultExpiration, cleanupInterval, HashMap())
    }

    /**
     * Set the value without checking whether it already exists
     *
     * @param k Set the value
     * @param v String value
     * @param d Set defaultExpiration if not filled in
     *
     * @since 0.28.4
     */
    public func Set(k:String,v:T, d!:Duration = DefaultExpiration) {
        var d1 = d
        var e:Int64 = 0
        if (d1 == DefaultExpiration) {
            d1 = this.defaultExpiration
        }
        if (d1 > Duration.nanosecond(0)) {
            e = (Time.now() + d1).unixNano()
        }
        synchronized(this.mu) {
            this.items.put(k, Item<T>(v, e))
        }
    }

    private func set(k:String,v:T, d!:Duration = DefaultExpiration) {
        var d1 = d
        var e:Int64 = 0
        if (d1 == DefaultExpiration) {
            d1 = this.defaultExpiration
        }
        if (d1 > Duration.nanosecond(0)) {
            e = (Time.now() + d1).unixNano()
        }
        this.items.put(k, Item<T>(v, e))
    }

    /**
     * Add items to the cache using the default expiration time, replacing any existing items.
     *
     * @param k Set the value
     * @param v String value
     *
     * @since 0.28.4
     */
    public func SetDefault(k:String,v:T) {
        this.Set(k, v)
    }

    //private func get(k:String):Option<T> {
    //    if (this.items.contains(k)) {
    //        let v = this.items[k]
    //        if (v.Expiration > 0) {
    //            if (Time.now().unixNano() > v.Expiration) {
    //                return None
    //            }
    //         }
    //         return v.Data
    //    } else {
    //        return None
    //    }
    //}

    /**
     * Adding a value will check whether the value exists. If it exists, an error will be returned
     *
     * @param k Set the value
     * @param v String value
     * @param d Set defaultExpiration if not filled in
     *
     * @since 0.28.4
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
     * Replace cached values
     *
     * @param k Set the value
     * @param v String value
     * @param d Set defaultExpiration if not filled in
     *
     * @since 0.28.4
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

    /**
     * Get a value
     *
     * @param k The value
     *
     * @return Option<T> The return type of Option<T>
     * @since 0.28.4
     */
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

    /**
     * Get value and expiration time
     *
     * @param k The value
     *
     * @return Option<T*Int64> The return type of Option<T>
     * @since 0.28.4
     */
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

    /**
     * Delete an item
     *
     * @param k The value
     *
     * @since 0.28.4
     */
    public func Delete(k:String) {
        synchronized(this.mu) {
            this.delete(k)
        }
    }

    /**
     * Delete all expired items
     *
     * @since 0.28.4
     */
    public func DeleteExpired() {
        var evictedItems = ArrayList<KeyValue<T>>()
        let now = Time.now().unixNano()
        synchronized(this.mu) {
            var keys = ArrayList<String>()
            for ((k, item) in this.items) {
                if (item.Expiration > 0 && now > item.Expiration) {
                    keys.add(k)
                }
            }
            for (key in keys) {
                let r = this.delete(key)
                match (r) {
                    case None => ()
                    case Some(ov) => 
                        evictedItems.add(KeyValue<T>(key, ov))
                }       
            }
        }
        for (item in evictedItems) {
            this.onEvicted?(item.key, item.value)
        }
    }

    /**
     * Set a callback. When deleting a key, it will call the set method for notification
     *
     * @param fn Callback
     *
     * @since 0.28.4
     */
    public func OnEvicted(fn: (String, T) -> Unit) {
        synchronized (this.mu) {
            this.onEvicted = fn
        }
    }

    /**
     * Get all cached items
     *
     * @return HashMap<String, Item<T>> cached items
     * @since 0.28.4
     */
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

    /**
     * Get the number of cached items
     *
     * @return Int64 Number
     * @since 0.28.4
     */
    public func ItemCount():Int64 {
        var n:Int64
        synchronized(this.mu) {
            n = this.items.size()
        }
        return n
    }

    /**
     * Clear all cached items
     *
     * @since 0.28.4
     */
    public func Flush() {
        synchronized(this.mu) {
            this.items.clear()
        }
    }

    /**
     * Write cache to writestream
     *
     * @param w Writestream
     *
     * @since 0.28.4
     */
    public func Save (w:WriteStream) {
        synchronized(this.mu) {
            let m: DataModel = this.items.serialize()
            w. write(m.toJson().toString().toUtf8Array())
        }
    }

    /**
     * Write cache to file
     *
     * @param filename File name
     *
     * @since 0.28.4
     */
    public func SaveFile(filename:String) {
        var fs = FileStream(filename)
        fs.openFile()
        this.Save(fs)
        fs.flush()
        fs.close()
    }

    /**
     * Read cache from readstream
     *
     * @param r ReadStream
     *
     * @since 0.28.4
     */
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

    /**
     * Read cache from file
     *
     * @param filename File name
     *
     * @since 0.28.4
     */
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

/*
 * The class is Janitor<T> where T inherited from Serializable<T>
 * @author @ystyle
 * @since 0.28.4
 */
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
