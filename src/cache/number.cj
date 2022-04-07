package cache
from std import sync.*

// extend Cache<T> where T <: Int64 {
//     public func Increment(k:String, n:T):Result<Unit> {
//         synchronized(this.mu) {
//             if (this.items.contains(k)) {
//                 var v = this.items[k]
//                 if (v.Expired()) {
//                     return Err(Exception("Item ${k} not found"))
//                 }
//                 let num2:Int64 = v.Data + n
//                 this.items[k] = Item(num2, v.Expiration)
//                 return Ok(())
//             } else {
//                 return Err(Exception("Item ${k} not found"))
//             }
//         }
//     }
// }