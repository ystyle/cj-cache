from std import collection.HashMap
from std import json.*
from std import time.*
import cache.*

func main():Unit {
    println("hello world")
    
    let de = Duration.minute(5)
    let ci = Duration.second(10)
    let cache = Cache<Int64>(de , ci)
    cache.Add("1", 1)
    cache.Add("1", 1)
    cache.Add("2", 1)
    cache.Set("1", 1)
    cache.Increment("1", 2)

    let i = cache.Get("1")??0
    println("i: ${i}")
    sleep(1000*1000*1000 * 60 *5)
}