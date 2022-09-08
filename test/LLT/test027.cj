// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
from std import time.*
from std import collection.HashMap


main() {
    let c = Cache<Int8>(Duration.minute(5) , Duration.minute(10))
    c.Set("1", 1)
    try{
        c.DecrementInt8("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }

    let c2 = Cache<Int16>(Duration.minute(5) , Duration.minute(10))
    c2.Set("1", 1)
    try{
        c2.DecrementInt16("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }

    let c3 = Cache<Int32>(Duration.minute(5) , Duration.minute(10))
    c3.Set("1", 1)
    try{
        c3.DecrementInt32("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }

    let c4 = Cache<Int64>(Duration.minute(5) , Duration.minute(10))
    c4.Set("1", 1)
    try{
        c4.Decrement("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }
    return 0
}
