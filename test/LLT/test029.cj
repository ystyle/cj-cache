// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
import std.time.*
import std.collection.HashMap
from encoding import json.*

main() { 
    var item = Item<Int64>(11)
    var it: Item<Int64> = Item<Int64>.deserialize(item.serialize())
    println(it.serialize().toJson().toString())  // {"data":11,"expiration":0}
}
