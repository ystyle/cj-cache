// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
import std.time.*
import std.collection.HashMap

public func test(a: String, b: Int64): Unit {
    println("error")
}
main():Int64 {
    let c = Cache<Int64>(Duration.minute*5 , Duration.minute*10)
    c.Set("1", 1)
    let f = {k: String, v: Int64 => 
        println("delete key ${k}") // delete key 1
    }
    c.OnEvicted(f)
    c.Delete("1")
    return 0
}
