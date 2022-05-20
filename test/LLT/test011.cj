// EXEC: cjc lib.o %f -o a.out
// EXEC: ./a.out

import cache.*
from std import time.*

main() {
    let c = Cache<Int64>(Duration.minute(0) , Duration.minute(0))
    c.Set("1", 1, d: Duration.minute(0))
    let result = c.GetWithExpiration("1").getOrThrow()
    println(result[0]) //1
    println(result[1]) // 0
    if (result[0] != 1 || result[1] !=0 ) {
        return 1
    }
    return 0
}