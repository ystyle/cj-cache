package cache
from std import sync.*

extend Cache<T> where T <: Int8 {
    public func IncrementInt8(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                let num:Int8 = item.Data + n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}

extend Cache<T> where T <: Int16 {
    public func IncrementInt16(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                let num:Int16 = item.Data + n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}

extend Cache<T> where T <: Int32 {
    public func IncrementInt32(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                let num:Int32 = item.Data + n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}

extend Cache<T> where T <: Int64 {
    public func Increment(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                let num:Int64 = item.Data + n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}

extend Cache<T> where T <: Int8 {
    public func DecrementInt8(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                let num:Int8 = item.Data - n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}

extend Cache<T> where T <: Int16 {
    public func DecrementInt16(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                let num:Int16 = item.Data - n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}

extend Cache<T> where T <: Int32 {
    public func DecrementInt32(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                let num:Int32 = item.Data - n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}

extend Cache<T> where T <: Int64 {
    public func Decrement(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var item = this.items[k]
                if (item.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                let num:Int64 = item.Data - n
                let x :?T =num as T 
                this.items[k] = Item<T>(x??n, item.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}