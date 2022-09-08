// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
from std import time.*

main() {
    let c = Cache<Int64>(Duration.minute(5) , Duration.minute(10))
    c.Set("1", 1, d: Duration.minute(15))
    let result = c.GetWithExpiration("1").getOrThrow()
    println(result[0]) //1
    println(result[1]) // 过期时间每次执行都不一样
    if (result[0] != 1 ) {
        return 1
    }
    return 0
}