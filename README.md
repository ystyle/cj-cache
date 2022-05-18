### cj-cache
> 基于内存的key value缓存， 适合单机程序。 go-cache的仓颉实现。

### 使用
- 下载代码并创建cpm项目， cj-cache和需要使用的项目目录平级(否则自行修改依赖的path字段)
```shell
$ cd ~/CodeToCangjie
$ git clone https://gitee.com/HW-PLLab/cj-cache.git
$ mkdir cjcache-demo
$ cd cjcache-demo
$ cpm new test demo
```
- 在`cjcache-demo/module.json`添加`requires`
```json
"requires": {
	"cj_cache": {
		"organization": "ystyle",
		"version":"1.0.0",
		"path": "../cj-cache"
	  }
}
```
- 导入包
```cj
from cj_cache import cache.*
```

### 示例
```
from cj_cache import cache.*
from std import time.*

func main() {
    let c = Cache<Int64>(Duration.minute(5) , Duration.minute(10))
    c.Set("1", 1)
    let i = c.Get("1")??0
    println("i: ${i}")
}
```

### api
- `Cache<T>(defaultExpiration:Duration,cleanupInterval:Duration)` 创建缓存实例，defaultExpiration为过期时间， cleanupInterval为自动清除缓存的时间，需要大于0才会执行自动清理
- `Cache<T>(defaultExpiration:Duration,cleanupInterval:Duration，items:HashMap<String, Item<T>)` 创建缓存实例，items： 设置初始的缓存项目
- `Add(k:string, v:T, d!:Duration)` 添加一个值，会检查值是否存在，存在时则返回错误
- `Set(k:string, v:T, d!:Duration)` 设置值，不检查是否存在
- `SetDefault(k:String, v:T)` 使用默认过期时间将项目添加到缓存，替换任何现有项目。
- `Get(k:String):Option<T>` 获取一个值
- `GetWithExpiration(k:String):Option<T*Int64>`  获取值和过期时间
- `Items():HashMap<String, Item<T>>` 获取所有缓存的项目
- `Replace(k:String,v:T, d!:Duration = DefaultExpiration):Result<Unit>` 替换缓存的值
- `Delete(k:String)` 删除一个项目
- `DeleteExpired()` 删除所有已过期的项目
- `ItemCount():Int64` 获取缓存项目数量
- `Flush()` 清除掉所有缓存的项目
- `Save(w:WriteStream)` 把缓存写入WriteStream
- `SaveFile(filename:String)` 把缓存写入文件
- `Load(r:ReadStream)` 从ReadStream读取缓存
- `LoadFile(filename:String)` 从文件读取缓存
- 当T为Int相关类型时有以下扩展方法
  - `IncrementInt8(k:String, n:T):Result<Unit>` Int8自增
  - `IncrementInt16(k:String, n:T):Result<Unit>` Int16自增
  - `IncrementInt32(k:String, n:T):Result<Unit>` Int32自增
  - `IncrementInt(k:String, n:T):Result<Unit>` Int64自增
  - `DecrementInt8(k:String, n:T):Result<Unit>` Int8自减
  - `DecrementInt16(k:String, n:T):Result<Unit>` Int16自减
  - `DecrementInt32(k:String, n:T):Result<Unit>` Int32自减
  - `DecrementInt(k:String, n:T):Result<Unit>` Int64自减