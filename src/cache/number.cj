/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * 
 * When t is an int related type, there are the following extension methods
 */
package cache
from std import sync.*

extend Cache<T> where T <: Int8 {
    /**
     * Int8 auto increment
     *
     * @param k key
     * @param n Increment number
     *
     * @return Option<T> Return result
     * @since 0.28.4
     */
    public func IncrementInt8(k:String, n:T):Option<T> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return None
                }
                let num:Int8 = item.Data + n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return x
            } else {
                return None
            }
        }
    }
}

extend Cache<T> where T <: Int16 {
    /**
     * Int16 auto increment
     *
     * @param k key
     * @param n Increment number
     *
     * @return Option<T> Return result
     * @since 0.28.4
     */
    public func IncrementInt16(k:String, n:T):Option<T> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return None
                }
                let num:Int16 = item.Data + n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return x
            } else {
                return None
            }
        }
    }
}

extend Cache<T> where T <: Int32 {
    /**
     * Int32 auto increment
     *
     * @param k key
     * @param n Increment number
     *
     * @return Option<T> Return result
     * @since 0.28.4
     */
    public func IncrementInt32(k:String, n:T):Option<T> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return None
                }
                let num:Int32 = item.Data + n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return x
            } else {
                return None
            }
        }
    }
}

extend Cache<T> where T <: Int64 {
    /**
     * Int64 auto increment
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
                let num:Int64 = item.Data + n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return x
            } else {
                return None
            }
        }
    }
}

extend Cache<T> where T <: Int8 {
    /**
     * Int8 auto decrement
     *
     * @param k key
     * @param n Increment number
     *
     * @return Option<T> Return result
     * @since 0.28.4
     */
    public func DecrementInt8(k:String, n:T):Option<T> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return None
                }
                let num:Int8 = item.Data - n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return x
            } else {
                return None
            }
        }
    }
}

extend Cache<T> where T <: Int16 {
    /**
     * Int16 auto decrement
     *
     * @param k key
     * @param n Increment number
     *
     * @return Option<T> Return result
     * @since 0.28.4
     */
    public func DecrementInt16(k:String, n:T):Option<T> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return None
                }
                let num:Int16 = item.Data - n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return x
            } else {
                return None
            }
        }
    }
}

extend Cache<T> where T <: Int32 {
    /**
     * Int32 auto decrement
     *
     * @param k key
     * @param n Increment number
     *
     * @return Option<T> Return result
     * @since 0.28.4
     */
    public func DecrementInt32(k:String, n:T):Option<T> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return None
                }
                let num:Int32 = item.Data - n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return x
            } else {
                return None
            }
        }
    }
}

extend Cache<T> where T <: Int64 {
    /**
     * Int64 auto decrement
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
                let num:Int64 = item.Data - n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return x
            } else {
                return None
            }
        }
    }
}