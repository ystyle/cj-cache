// EXEC: cjc lib.o %f -o a.out
// EXEC: ./a.out

import cache.*
from std import time.*

main() {
    let c = Cache<Int64>(Duration.minute(5) , Duration.minute(10))
    c.Set("1", 1, d: Duration.minute(15))
    try {
        c.Replace("4", 3).getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) //Exception: Item 4 doesn't exist
    }
}