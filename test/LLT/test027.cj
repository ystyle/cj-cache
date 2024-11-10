// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
import std.time.*
import std.collection.HashMap


main():Int64 {
    let five = Duration.minute * 5
    let ten = Duration.minute * 10
    let c = Cache<Int8>(five, ten)
    c.Set("1", 1)
    try{
        c.DecrementInt8("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }

    let c2 = Cache<Int16>(five, ten)
    c2.Set("1", 1)
    try{
        c2.DecrementInt16("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }

    let c3 = Cache<Int32>(five, ten)
    c3.Set("1", 1)
    try{
        c3.DecrementInt32("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }

    let c4 = Cache<Int64>(five, ten)
    c4.Set("1", 1)
    try{
        c4.Decrement("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }
    return 0
}
