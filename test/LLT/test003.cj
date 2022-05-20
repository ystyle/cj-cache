// EXEC: cjc lib.o %f -o a.out
// EXEC: ./a.out

import cache.*
from std import time.*

main() {
    let c = Cache<Int64>(Duration.minute(5) , Duration.minute(10))
    c.Set("1", 1, d: Duration.minute(5))
    let i = c.Get("1")??0
    println("i: ${i}") // 1 
    if( i != 1) {
        return 1
    }
    return 0
}