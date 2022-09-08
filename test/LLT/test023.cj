// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
from std import time.*
from std import collection.HashMap


main() {
    let c = Cache<Int32>(Duration.minute(5) , Duration.minute(10))
    c.Set("1", 1)
    try{
        c.IncrementInt32("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }
    return 0
}
