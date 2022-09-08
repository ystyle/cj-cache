// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
from std import time.*
from std import collection.HashMap

public func test(a: String, b: Int64): Unit {
    println("error")
}
main() {
    var time = (Time.now() + Duration.second(50)).unixNano()
    var item1 = Item<Int64>(11, time)
    var item2 = Item<Int64>(22, time)
    var item3 = Item<Int64>(33, time)
    var items: HashMap<String, Item<Int64>> = HashMap<String, Item<Int64>>([("1", item1), ("2", item2), ("3", item3)])
    var c = Cache<Int64>(Duration.minute(10), Duration.minute(10), items)
    var result = c.Items()
    println(result.serialize().toJson().toString()) 
    // {"1":{"data":11,"expiration":1653036705204106587},"2":{"data":22,"expiration":1653036705204106587},"3":{"data":33,"expiration":1653036705204106587}}
    
    
    return 0
}
