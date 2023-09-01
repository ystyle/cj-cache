// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from cj_cache import cache.*
from std import time.*
from std import collection.HashMap


main():Int64 {
    let c = Cache<Int64>(Duration.minute*5, Duration.minute*10)
    c.Set("1", 1)
    try{
        c.Increment("2", 5).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Item 2 not found
    }
    return 0
}
