---
title: Golang内置包之time
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-12-01 23:55:27
---

## GoLang内置包之time

一寸光阴一寸金，寸金难买寸光阴

时间离我们仅在咫尺，无论是在编程中时间还是日常生活中对于时间的
记述都是离我们最近的，那么让我们一起来学习一下GoLang中内置包time。
<!--more-->
Let's Go

### time包源码怎么说

```go
const (
	Nanosecond  Duration = 1
	Microsecond          = 1000 * Nanosecond
	Millisecond          = 1000 * Microsecond
	Second               = 1000 * Millisecond
	Minute               = 60 * Second
	Hour                 = 60 * Minute
)
time.Duration是time包定义的一个类型，
它代表两个时间点之间经过的时间，以纳秒为单位。time.Duration表示一段时间间隔，可表示的最长时间段大约290年。

例如：time.Duration表示1纳秒，time.Second表示1秒。
```

### 基本使用
打印显示出现在的时间，基本示例如下。
其中now为`time.Time`类型,Month 为`time.Month`类型

```go
func timeDemo() {
	now := time.Now() //获取当前时间
	// current time:2020-12-01 22:24:30.85736 +0800 CST m=+0.000096031
	fmt.Printf("current time:%v\n", now)

	year := now.Year()     //年
	month := now.Month()   //月
	day := now.Day()       //日
	hour := now.Hour()     //小时
	minute := now.Minute() //分钟
	second := now.Second() //秒
	fmt.Printf("%d-%02d-%02d %02d:%02d:%02d\n", year, month, day, hour, minute, second)
	fmt.Printf("%T,%T,%T,%T,%T,%T,%T\n", now, year, month, day, hour, minute, second)
	// time.Time,int,time.Month,int,int,int,int
}
```
### 时间戳
在编程中对于时间戳的应用也尤为广泛,例如在Web开发中做cookies有效期，接口加密，
Redis中的key有效期等等，大部分都是使用到了时间戳。

时间戳是自1970年1月1日（08:00:00GMT）至当前时间的总毫秒数。它也被称为Unix时间戳（UnixTimestamp）。
在GoLang中,获取时间戳的操作如下
```go
func timeStamp() {
	now := time.Now()
	// 当前时间戳 TimeStamp type:int64, TimeStamp:1606832965
	fmt.Printf("TimeStamp type:%T, TimeStamp:%v", now.Unix(), now.Unix())
}
```
除此之外还有纳秒时间戳，我们可以使用`time.Now().UnixNano()`来获取它
```go
func timeStamp() {
	now := time.Now()
	// 纳秒级时间戳TimeStamp type:int64, TimeStamp:1606833059999670000
	fmt.Printf("TimeStamp type:%T, TimeStamp:%v\n", now.UnixNano(), now.UnixNano())
}
```
那么基本的时间戳的先暂且为止了，那该如何由时间戳转化为普通的时间格式呢？

当然也是有方法滴，莫急莫急，请听我一一道来，嘴比较笨就直接用代码吧，嘻嘻

在`go`语言中可以`time.Unix`来直接将时间戳转化为当前时间格式，实现瞬间替换。

```go
func timeStampToTime() {
	timestamp := time.Now().Unix()
	timeObj := time.Unix(timestamp, 0) //将时间戳转为时间格式
	fmt.Println(timeObj)
	year := timeObj.Year()     //年
	month := timeObj.Month()   //月
	day := timeObj.Day()       //日
	hour := timeObj.Hour()     //小时
	minute := timeObj.Minute() //分钟
	second := timeObj.Second() //秒
	fmt.Printf("%d-%02d-%02d %02d:%02d:%02d\n", year, month, day, hour, minute, second)
}
```
这样我们就可以简单的将时间戳转化为时间格式，是不是很Nice

基本的定义查看就以及搞完了，那咱们整一下高级一点的东西，时间的操作

### 操作时间

#### ADD

在原本的时间基础上在增加h时m分钟s秒，其增加的部分源码如下

```go
// type Duration int64
func (t Time) Add(d Duration) Time {
	dsec := int64(d / 1e9)
	nsec := t.nsec() + int32(d%1e9)
	if nsec >= 1e9 {
		dsec++
		nsec -= 1e9
	} else if nsec < 0 {
		dsec--
		nsec += 1e9
	}
	t.wall = t.wall&^nsecMask | uint64(nsec) // update nsec
	t.addSec(dsec)
	if t.wall&hasMonotonic != 0 {
		te := t.ext + int64(d)
		if d < 0 && te > t.ext || d > 0 && te < t.ext {
			// Monotonic clock reading now out of range; degrade to wall-only.
			t.stripMono()
		} else {
			t.ext = te
		}
	}
	return t
}
```

首先如果要增加的话那么数据的类型必须是一致的，这个在强类型语言go中这个是一定的。

从上面的源码中函数定义的这个变量名`Add(d Duration)`发现，其参数d为Duration类型，那么我们直接拿过来用即可，实现代码如下:

```
package main

import (
	"fmt"
	"time"
)

func operating(h, m, s, mls, msc, ns time.Duration) {
	now := time.Now()
	fmt.Println(now.Add(time.Hour*h + time.Minute*m + time.Second*s + time.Millisecond*mls + time.Microsecond*msc + time.Nanosecond*ns))
}

func main() {
	//timeDemo()
	//timeStamp()
	//timeStampToTime()
	operating(3, 4, 5, 6, 7, 8)

}

```

注意在这里并不能增加年\月\日，仅能增加时分秒,也就是以下的才被允许

```go
const (
	Nanosecond  Duration = 1
	Microsecond          = 1000 * Nanosecond
	Millisecond          = 1000 * Microsecond
	Second               = 1000 * Millisecond
	Minute               = 60 * Second
	Hour                 = 60 * Minute
)
```

#### Sub

```
func operating() {
	now := time.Now()
	targetTime := now.Add(time.Hour)
	// 目标时间与此时相比相差1h0m0s
	fmt.Println(targetTime.Sub(now))
}
```

> 谁的sub谁为参照时间

#### Equal

```go
func (t Time) Equal(u Time) bool
```

判断两个时间是否相同，会考虑时区的影响，因此不同时区标准的时间也可以正确比较。本方法和用t==u不同，这种方法还会比较地点和时区信息。

#### Before

```go
func (t Time) Before(u Time) bool
```

如果t代表的时间点在u之前，返回真；否则返回假。

#### After

```go
func (t Time) After(u Time) bool
```

如果t代表的时间点在u之后，返回真；否则返回假。

#### 定时器

使用`time.Tick(时间间隔)`来设置定时器，定时器的本质上是一个通道（channel）。

```go
func tickDemo() {
	ticker := time.Tick(time.Second) //定义一个1秒间隔的定时器
	for i := range ticker {
		fmt.Println(i)//每秒都会执行的任务
	}
}
```

### 时间格式化

时间类型有一个自带的方法`Format`进行格式化，需要注意的是Go语言中格式化时间模板不是常见的`Y-m-d H:M:S`而是使用Go的诞生时间2006年1月2号15点04分（记忆口诀为2006 1 2 3 4）

```go
func formatDemo() {
	now := time.Now()
	// 格式化的模板为Go的出生时间2006年1月2号15点04分 Mon Jan
	// 24小时制
	fmt.Println(now.Format("2006-01-02 15:04:05.000 Mon Jan"))
	// 12小时制
	fmt.Println(now.Format("2006-01-02 03:04:05.000 PM Mon Jan"))
	fmt.Println(now.Format("2006/01/02 15:04"))
	fmt.Println(now.Format("15:04 2006/01/02"))
	fmt.Println(now.Format("2006/01/02"))
}
```

补充：如果想格式化为12小时方式，需指定`PM`。

#### 解析字符串格式的时间

```go
now := time.Now()
fmt.Println(now)
// 加载时区
loc, err := time.LoadLocation("Asia/Shanghai")
if err != nil {
	fmt.Println(err)
	return
}
// 按照指定时区和指定格式解析字符串时间
timeObj, err := time.ParseInLocation("2006/01/02 15:04:05", "2019/08/04 14:15:20", loc)
if err != nil {
	fmt.Println(err)
	return
}
fmt.Println(timeObj)
fmt.Println(timeObj.Sub(now))
```
