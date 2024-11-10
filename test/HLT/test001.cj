package test.HLT

import std.time.Duration
import cache.*

main():Unit {
    let a = Cache<UInt64>(Duration.minute*5, Duration.second*0)
    a.Set("d", 1)
    a.Increment("d", 1)
    println(a.Get("d"))
}