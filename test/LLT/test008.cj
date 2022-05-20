// EXEC: cjc lib.o %f -o a.out
// EXEC: ./a.out

import cache.*
from std import time.*

main() {
    let c = Cache<Int64>(Duration.minute(5), Duration.minute(10))
    c.Add("1", 1)
    c.Add("2", 2)
    try {
        c.Add("2", 3).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Exception: Item 2 already exists
    }
    
}