// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import cache.*
import std.time.*

main(): Int64 {
    let c = Cache<Int64>(Duration.minute * 0, Duration.minute * 0)
    c.Set("1", 1, d: Duration.minute * 0)
    let result = c.GetWithExpiration("1").getOrThrow()
    println(result[0]) //1
    println(result[1]) // 0
    if (result[0] != 1 || result[1] != 0) {
        return 1
    }
    return 0
}
