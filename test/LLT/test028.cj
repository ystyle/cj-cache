// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
import std.time.*
import std.collection.HashMap
from encoding import json.*

main():Int64 { 
    var item1 = Item<Int64>(11)
    var item2 = Item<Int64>(22)
    var item3 = Item<Int64>(33)
    var items: HashMap<String, Item<Int64>> = HashMap<String, Item<Int64>>([("1", item1), ("2", item2), ("3", item3)])
    var c = Cache<Int64>(Duration.minute*10, Duration.minute*10, items)
    var result = c.Items()
    // println(result.serialize().toJson().toString()) 
    // {"1":{"data":11,"expiration":0},"2":{"data":22,"expiration":0},"3":{"data":33,"expiration":0}}
    
    
    return 0
}
