package cache
from std import sync.*

extend Cache<T> where T <: Int64 {
    public func Increment(k:String, n:T):Result<Unit> {
        synchronized(this.mu) {
            if (this.items.contains(k)) {
                var v = this.items[k]
                if (v.Expired()) {
                    return Err(Exception("Item ${k} not found"))
                }
                // 1. 可以编译通过
                v.Data += n
                // 2. 编译失败， Item构造函数找不到
                // let num2:Int64 = v.Data + n
                // this.items[k] = Item(num2, v.Expiration)
                // 3. 编译失败，put方法找不到
                // let item = Item(num2, v.Expiration)
                // this.items.put(k, item)
                return Ok(())
            } else {
                return Err(Exception("Item ${k} not found"))
            }
        }
    }
}