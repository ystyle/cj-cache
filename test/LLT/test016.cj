// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from cj_cache import cache.*
from std import time.*
from std import collection.HashMap

main() {
    let c = Cache<Int64>(Duration.minute , Duration.minute*10)
    c.Set("1", 1)
    c.Set("2", 2)
    c.Flush()
    println(c.ItemCount()) // 0
    return 0
}
