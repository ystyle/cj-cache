// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from cj_cache import cache.*
from std import time.*

main() {
    let c = Cache<Int64>(Duration.minute*5 , Duration.minute*10)
    c.Set("1", 1)
    c.SetDefault("1", 2)
    c.SetDefault("2", 3)
    let i1 = c.Get("1")??0
    let i2 = c.Get("2")??0
    println("i1: ${i1}") // 2
    println("i2: ${i2}") // 3
    if( i1 != 2 || i2 != 3) {
        return 1
    }
    return 0
}