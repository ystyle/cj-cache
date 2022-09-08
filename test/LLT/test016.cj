// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
from std import time.*
from std import collection.HashMap

public func test(a: String, b: Int64): Unit {
    println("error")
}
main() {
    let c = Cache<Int64>(Duration.minute(1) , Duration.minute(10))
    c.Set("1", 1)
    c.Set("2", 2)
    c.Flush()
    println(c.ItemCount()) // 0
    return 0
}
