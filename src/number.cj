/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * 
 * When t is an int related type, there are the following extension methods
 */
package cache
import std.sync.*

public interface Add<T> {
    operator func +(right: T): T
    operator func -(right: T): T
}

// extend basic number type
extend UInt8 <: Add<UInt8>{}
extend UInt16 <: Add<UInt16>{}
extend UInt32 <: Add<UInt32>{}
extend UInt64 <: Add<UInt64>{}
extend Int8 <: Add<Int8>{}
extend Int16 <: Add<Int16>{}
extend Int32 <: Add<Int32>{}
extend Int64 <: Add<Int64>{}

extend<T> Cache<T> where T <: Add<T> {
    /**
     * Int8 auto increment
     *
     * @param k key
     * @param n Increment number
     *
     * @return Option<T> Return result
     * @since 0.28.4
     */
    public func Increment(k:String, n:T):Option<T> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return None
                }
                let num:T = item.Data + n
                this.items[k] = Item<T>(num, item.Expiration)
                return num
            } else {
                return None
            }
        }
    }
    /**
     * Int8 auto decrement
     *
     * @param k key
     * @param n Increment number
     *
     * @return Option<T> Return result
     * @since 0.28.4
     */
    public func Decrement(k:String, n:T):Option<T> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return None
                }
                let num:T = item.Data - n
                this.items[k] = Item<T>(num, item.Expiration)
                return num
            } else {
                return None
            }
        }
    }
}