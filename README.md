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
func main() {
    let c = Cache<Int64>(Duration.minute(5) , Duration.minute(10))
    c.Set("1", 1)
    let i = c.Get("1")??0
    println("i: ${i}")
}
```

### api
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