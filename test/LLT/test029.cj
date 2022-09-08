// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from cj_cache import cache.*
from std import time.*
from std import collection.HashMap


main() { 
    var item = Item<Int64>(11)
    var it: Item<Int64> = Item<Int64>.deserialize(item.serialize())
    
    println(it.serialize().toJson().toString())  // {"data":11,"expiration":0}
}
