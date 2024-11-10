// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
import std.time.*

main():Int64 {
    let c = Cache<Int64>(Duration.minute*5 , Duration.minute*10)
    c.Set("1", 1, d: Duration.minute*5)
    let i = c.Get("1")??0
    println("i: ${i}") // 1 
    if( i != 1) {
        return 1
    }
    return 0
}