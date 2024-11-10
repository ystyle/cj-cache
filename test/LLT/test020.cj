// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
import std.time.*
import std.collection.HashMap


main():Int64 {
    let c = Cache<Int16>(Duration.minute*5 , Duration.minute*10)
    c.Set("1", 1)
    c.IncrementInt16("1", 5)
    let i = c.Get("1")??0
    println("i: ${i}") // 6
   
    
    return 0
}
