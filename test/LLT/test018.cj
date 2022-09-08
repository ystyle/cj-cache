// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import cache.*
from std import time.*
from std import collection.HashMap


main() {
    let c = Cache<Int8>(Duration.minute(5) , Duration.minute(10))
    c.Set("1", 1)
    c.IncrementInt8("1", 5)
    let i = c.Get("1")??0
    println("i: ${i}") // 6
   
    
    return 0
}
