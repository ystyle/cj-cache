package cache
from std import sync.*

extend Cache<T> where T <: Int64 {
    func Increment(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var v = this.items[k]
                if (v.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                println(v.Data)
                v.Data += n
                println(v.Data)
                this.items[k] = Item(v.Data, v.Expiration)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}