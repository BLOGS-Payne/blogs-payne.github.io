---
title: Golang-Map
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:13:59
---
Go语言中提供的映射关系容器为`map`，其内部使用`散列表（hash）`实现map

map是一种无序的基于`key-value`的数据结构，Go语言中的map是`引用类型`，必须`初始化`才能使用。
<!--more-->
## 定义Map

```go
// 初始化定义
map[KeyType]ValueType

// KeyType:表示键的类型。map可以嵌套map，可以是key 也是是value

// ValueType:表示键对应的值的类型。

map类型的变量默认初始值为nil，需要使用make()函数来分配内存。语法为：

make(map[KeyType]ValueType, [cap])

// 赋值定义

map[KeyType]ValueType{
  key1:value1
  key2:value2
  key4:value3
}
```

### 示例

```go
package main

import "fmt"

func main() {
a := make(map[string]string)
a["name"] = "Payne"
a["sex"] = "male"
a["year"] = "20"
fmt.Println("a:", a)               // a: map[name:Payne sex:male year:20]
fmt.Println("a['sex']:", a["sex"]) // a['sex']: male
fmt.Printf("Type of a:%T\n", a)      // Type of a:map[string]string

b := map[string]string{
    "Name": "Tim",
    "Sex":  "male",
    "Year": "20",
    }
    fmt.Println("b:", b)               // b: map[Name:Tim Sex:male Year:20]
    fmt.Println("b['sex']:", b["Sex"]) // b['sex']: male
    fmt.Printf("Type of b:%T", b)   // Type of b:map[string]string
}

```

## 判断某个键是否存在

Go语言中有个判断map中键是否存在的特殊写法，格式如下:

```go
value, ok := map[key]

// 其中 value可以为任意接受值。而 ok 必须写
```

### 示例

```go
package main

import "fmt"

func main() {
c := map[string]string{
"name1": "Tom",
"name2": "Tim",
"name3": "Payne",
"name4": "John",
}
// 如果key存在ok为true,v为对应的值；不存在ok为false,v为值类型的零值
value, ok := c["name1"]
fmt.Println(value, ok)     // Tom true

value, ok := c["name5"]
fmt.Println(value, ok)     // false
  
  if ok {
    fmt.Println(value) // Tom
  } else {
fmt.Println("nil")
}
}
```

## map遍历

Go语言中使用`for range`遍历map。

### 示例

```go
// 遍历
d := map[string]string{
"name1": "Tom",
"name2": "Tim",
"name3": "Payne",
"name4": "John",
}
// 只遍历key
for d := range d {
fmt.Print(d + ",")  // name1,name2,name3,name4,
}
fmt.Printf("\n")
// 只遍历value
for _, v := range d {
fmt.Print(v + ",")  // Tom,Tim,Payne,John,
}
fmt.Printf("\n")
// 遍历key value
for k, v := range d {
fmt.Print(k, ":", v, " ")   // name2:Tim name3:Payne name4:John name1:Tom
}
```

## 删除key

使用`delete()`内建函数从map中删除一组键值对，`delete()`函数的格式如下：

```go
delete(map, key)
// map:表示要删除键值对的map
// key:表示要删除的键值对
```

### 示例

```go
f := map[string]string{
"name1": "Tom",
"name2": "Tim",
"name3": "Payne",
"name4": "John",
}
v1, ok := f["name1"]
fmt.Println(v1, ok)  // Tom true
delete(f, "name1")
v2, ok := f["name1"]
fmt.Println(v2, ok)  // false
```

## 元素为map类型的切片

下面的代码演示了切片中的元素为map类型时的操作：

```go
func main() {
  mapSlice := make([]map[string]string, 3)
  for index, value := range mapSlice {
  fmt.Printf("index:%d value:%v\n", index, value)
 }
 fmt.Println("after init")
 // 对切片中的map元素进行初始化
 mapSlice[0] = make(map[string]string, 10)
 mapSlice[0]["name"] = "payne"
 mapSlice[0]["password"] = "123456"
 mapSlice[0]["address"] = "cs"
 for index, value := range mapSlice {
 fmt.Printf("index:%d value:%v\n", index, value)
 }
}

// index:0 value:map[]
// index:1 value:map[]
// index:2 value:map[]
// after init
// index:0 value:map[address:cs name:payne password:123456]
// index:1 value:map[]
// index:2 value:map[]
```

## 值为切片类型的map

下面的代码演示了map中值为切片类型的操作：

```go
func main() {
  sliceMap := make(map[string][]string, 3)
 fmt.Println(sliceMap)
 fmt.Println("after init")
key := "中国"
value, ok := sliceMap[key]
if !ok {
value = make([]string, 0, 2)
 }
 value = append(value, "北京", "上海")
 sliceMap[key] = value
fmt.Println(sliceMap)
}
// map[]
// after init
// map[中国:[北京 上海]]
```

## 总结

可以map理解为key-value的容器，里面可包含基本数据类型\Map,不包含Array。包含sclice
