// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from cj_cache import cache.*
from std import time.*

main() {
    let c = Cache<Int64>(Duration.minute*5 , Duration.minute*10)
    c.Set("1", 1, d: Duration.minute*15)
    c.Set("2", 2, d: Duration.minute*10)
    c.Replace("1", 3)
    c.Replace("2", 4, d: Duration.minute*20)
    let i1 = c.Get("1")??0
    let i2 = c.Get("2")??0
    println("i1: ${i1}") // 3
    println("i2: ${i2}") // 4
    if( i1 != 3 || i2 != 4) {
        return 1
    }
    return 0
}