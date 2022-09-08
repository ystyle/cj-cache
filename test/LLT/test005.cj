// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
from std import time.*

main() {
    let c = Cache<Int64>(Duration.minute(5), Duration.minute(10))
    c.Add("1", 1)
    c.Add("2", 2)
    let i1 = c.Get("1")??0
    let i2 = c.Get("2")??0
    println("i1: ${i1}") // 1
    println("i2: ${i2}") // 2
    if( i1 != 1 || i2 != 2) {
        return 1
    }
    return 0
}