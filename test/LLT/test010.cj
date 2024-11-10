// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
import std.time.*

main() {
    let c = Cache<Int64>(Duration.minute*5 , Duration.minute*10)
    c.Set("1", 1, d: Duration.minute * 0)
    try {
        let result = c.GetWithExpiration("2").getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) // NoneValueException
    }

}