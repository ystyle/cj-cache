// EXEC: cjc lib.o %f -o a.out
// EXEC: ./a.out

import cache.*
from std import time.*
from std import collection.HashMap


main() { 
    var item = Item<Int64>(11)
    var it: Item<Int64> = Item<Int64>.deserialize(item.serialize())
    
    println(it.serialize().toJson().toString())  // {"data":11,"expiration":0}
}
