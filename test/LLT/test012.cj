// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from cj_cache import cache.*
from std import time.*
from std import collection.HashMap

main() {
    var time = (Time.now() + Duration.second(50)).unixNano()
    var item1 = Item<Int64>(11, time)
    var item2 = Item<Int64>(22, time)
    var item3 = Item<Int64>(33, time)
    let items: HashMap<String, Item<Int64>> = HashMap<String, Item<Int64>>([("1", item1), ("2", item2), ("3", item3)])
    let c = Cache<Int64>(Duration.minute(5), Duration.minute(10), items)
    let d1 = c.Delete("2").getOrThrow()
    if(d1 != 22) {
        return 1
    }
    try {
        c.Delete("5").getOrThrow()
    }catch(e: Exception) {
        println(e.toString()) // NoneValueException
    }
    return 0
}