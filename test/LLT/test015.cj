// EXEC: cjc lib.o %f -o a.out
// EXEC: ./a.out

import cache.*
from std import time.*
from std import collection.HashMap

public func test(a: String, b: Int64): Unit {
    println("error")
}
main() {
    var item1 = Item<Int64>(11, 1)
    var item2 = Item<Int64>(22, 3)
    var item3 = Item<Int64>(33, 5)
    var items: HashMap<String, Item<Int64>> = HashMap<String, Item<Int64>>([("1", item1), ("2", item2), ("3", item3)])
    var c = Cache<Int64>(Duration.minute(10), Duration.minute(10), items)
    c.DeleteExpired()
    println(c.ItemCount()) // 
    return 0
}
