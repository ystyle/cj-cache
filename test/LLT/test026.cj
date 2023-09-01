// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from cj_cache import cache.*
from std import time.*
from std import collection.HashMap


main() {
    let c = Cache<Int8>(Duration.minute*5 , Duration.minute*10)
    c.Set("1", 10)
    c.DecrementInt8("1", 5)
    let i = c.Get("1")??0
    println("i: ${i}") // 6

    let c2 = Cache<Int16>(Duration.minute*5 , Duration.minute*10)
    c2.Set("1", 10)
    c2.DecrementInt16("1", 5)
    let i2 = c2.Get("1")??0
    println("i2: ${i2}") // 6
   
    let c3 = Cache<Int32>(Duration.minute*5 , Duration.minute*10)
    c3.Set("1", 10)
    c3.DecrementInt32("1", 5)
    let i3 = c3.Get("1")??0
    println("i3: ${i3}") // 6

    let c4 = Cache<Int64>(Duration.minute*5 , Duration.minute*10)
    c4.Set("1", 10)
    c4.Decrement("1", 5)
    let i4 = c4.Get("1")??0
    println("i4: ${i4}") // 6
    return 0
}
