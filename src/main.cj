from std import collection.HashMap
from std import json.*
from std import time.*
import cache.*

func main() {
    let de = Duration.minute(5)
    let ci = Duration.minute(10)
    let cache = Cache<Int64>(de , ci)
    cache.Set("1", 1)

    let i = cache.Get("1")??0
    println("i: ${i}")
}