package cache

from std import unittest.*
from std import unittest.testmacro.*

func testCache() {
    print("testCache: ")
    let tc = Cache<String>(Duration.minute(5), Duration.second(0))
    match(tc.Get("a")) {
        case None => ()
        case Some(v) => throw Exception("Getting A found value that shouldn't exist: ${v}")
    }
    tc.Set("a", "1")
    match(tc.Get("a")) {
        case None => throw Exception("a was not found while getting a2")
        case Some(x) => 
            if (x == "") {
                throw Exception("x for a is nil")
            }
    }
    println("passed.")
}
