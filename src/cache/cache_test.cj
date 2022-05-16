package cache

from std import unittest.*
from std import unittest.testmacro.*

from std import time.*

@Test
func testCache():Unit {
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
}

@Test
func testIncrCache():Unit {
    let tc = Cache<Int64>(Duration.minute(5), Duration.second(0))
    match(tc.Get("a")) {
        case None => ()
        case Some(v) => throw Exception("Getting A found value that shouldn't exist: ${v}")
    }
    tc.Set("a", 1)
    var a = tc.Get("a") ?? 0
    if (a == 0) {
        throw Exception("a was not found while getting a2")
    } else if (a != 1) {
        throw Exception("a should be 1")
    }
    tc.Increment("a", 1)
    let a1 = tc.Get("a") ?? 0
    println(a1)
    if (a1 == 0) {
        throw Exception("a was not found while getting a2")
    } else if (a1 != 2) {
        throw Exception("a should be 2")
    }
}
