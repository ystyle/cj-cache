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
	"cjCache": {
		"organization": "ystyle",
		"version":"1.0.0",
		"path": "../cj-cache"
	  }
}
```
- 导入包
```cj
from cjCache import cache.*
```

### 示例
```
func main() {
    let c = Cache<Int64>(Duration.minute(5) , Duration.minute(10))
    cache.Set("1", 1)
    let i = c.Get("1")??0
    println("i: ${i}")
}
```