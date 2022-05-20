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

    c.SaveFile("/home/gtt/cangjie/cj-cache/test/LLT/file.txt") 

    var c1 = Cache<Int64>(Duration.minute(10), Duration.minute(10), items)
    c1.Loadfile("/home/gtt/cangjie/cj-cache/test/LLT/file.txt")
    var result = c.ItemCount()
    println(result) 
    return 0 
} 
