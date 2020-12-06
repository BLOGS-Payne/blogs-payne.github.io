---
title: Golang并发编程
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-12-06 10:46:03
---
## 单个goroutine

Go语言中使用`goroutine`非常简单，只需要在调用函数的时候在前面加上`go`关键字，就可以为一个函数创建一个`goroutine`。
<!--more-->
一个`goroutine`必定对应一个函数，可以创建多个`goroutine`去执行相同的函数。开启一个goroutine，示例如下

```go
go funciton()
```

是不是很简单呢？那我们在实际中使用一下，示例如下：

```go
package main

import (
	"fmt"
	"time"
)

func demo1()  {
	fmt.Println("我是 demo goroutine")
}

func main() {
	go demo1()
	fmt.Println("我是 main goroutine")
	time.Sleep(time.Second)
}
// 我是 demo goroutine
// 我是 main goroutine
```

> 细心的伙伴坑定发现了`	time.Sleep(time.Second)`，在这里并不仅仅是为睡一秒，还有进类似于等待执行的作用。如果没有	time.Sleep(time.Second)，你会发现 **我是 demo goroutine**，将不会被打印。
>
> 首先为什么会先打印`我是 main goroutine`，这是因为我们在创建新的goroutine的时候需要花费一些时间，而此时main函数所在的`goroutine`是继续执行的。

### Channel

多个goroutine的时候该怎么办呢？难道是这样？

```go
package main

import (
	"fmt"
	"time"
)

func demo1()  {
	fmt.Println("我是 demo goroutine")
}

func main() {
	for i := 0; i < 10; i++ {
		go demo1()
	}
	fmt.Println("我是 main goroutine")
	time.Sleep(time.Second)
}
```

没错，这样确实可行的，但之间的相互通信，以及	time.Sleep(time.Second)该怎么去掉，不可能为了这个所为的并发而强制去睡一秒吧，这也并不现实。其实我们可以使用channel（通道）来解决这个问题

### channel的定义

在 Go 语言中，声明一个 channel 非常简单，使用内置的 make 函数即可，如下所示：

> 无缓冲 channel,使用 make 创建的 chan 就是一个无缓冲 channel，它的容量是 0，不能存储任何数据。所以无缓冲 channel 只起到传输数据的作用，数据并不会在 channel 中做任何停留。这也意味着，无缓冲 channel 的发送和接收操作是同时进行的，它也可以称为同步 channel。

其中 chan 是一个关键字，表示是 channel 类型。后面的 string 表示 channel 里的数据是 string 类型。通过 channel 的声明也可以看到，chan 是一个集合类型。

```
ch:=make(chan type)
// type 为传递的类型，由传递值的类型决定
```

定义好 chan 后就可以使用了，一个 chan 的操作只有两种：发送和接收。

接收：获取 chan 中的值，操作符为 <- chan。

发送：向 chan 发送值，把值放在 chan 中，操作符为 chan <-。

#### channel

```go
package main

import "fmt"

func main() {
	ch := make(chan string)
	go func() {
		ch <- "goroutine 执行完成"
	}()
	v := <-ch
	fmt.Printf("管道ch接受到的值为%v, 类型为%T", v, v)
}

// 管道ch接受到的值为goroutine 执行完成, 类型为string
```

> 这里注意发送和接收的操作符，都是 <- ，只不过位置不同。接收的 <- 操作符在 chan 的左侧，发送的 <- 操作符在 chan 的右侧。

这样我就实现了最基本的协程

#### 有缓冲 channel

有缓冲 channel 类似一个可阻塞的队列，内部的元素先进先出。通过 make 函数的第二个参数可以指定 channel 容量的大小，进而创建一个有缓冲 channel，如下面的代码所示：

```
ChCache:=make(chan int,10)
```

在这里我们创建了一个容量为 10 的 channel，内部的元素类型是 int，也就是说这个 channel 内部最多可以存放 10个类型为 int 的元素

有缓冲 channel 具备以下特点：

- 有缓冲 channel 的内部有一个缓冲队列；

- 发送操作是向队列的尾部插入元素，如果队列已满，则阻塞等待，直到另一个 goroutine 执行，接收操作释放队列的空间；

- 接收操作是从队列的头部获取元素并把它从队列中删除，如果队列为空，则阻塞等待，直到另一个 goroutine 执行，发送操作插入新的元素。

我创建了一个容量为 5 的 channel，内部的元素类型是 int，也就是说这个 channel 内部最多可以存放 5 个类型为 int 的元素





```go
package main

import "fmt"


func main() {
	ch := make(chan int, 10)
	go func() {
		for i := 0; i < 10; i++ {
			ch <- i
		}
	}()

	for i := 0; i < 10; i++ {
		value := <-ch
		fmt.Printf("这次接受ch的值为:%v, 第%d接收\n", value, i+1)
	}
}
// 这次接受ch的值为:0, 第1接收
// 这次接受ch的值为:1, 第2接收
// 这次接受ch的值为:2, 第3接收
// 这次接受ch的值为:3, 第4接收
// 这次接受ch的值为:4, 第5接收
// 这次接受ch的值为:5, 第6接收
// 这次接受ch的值为:6, 第7接收
// 这次接受ch的值为:7, 第8接收
// 这次接受ch的值为:8, 第9接收
// 这次接受ch的值为:9, 第10接收
```

通过内置函数 cap 可以获取 channel 的容量，也就是最大能存放多少个元素，通过内置函数 len 可以获取 channel 中元素的个数

```go
fmt.Println("ch的容量:", cap(ch), "ch长度为:", len(ch))
```

以上我们都是定义的双向chan，可以取也可以存。那让我们继续深入学习

#### 单向channel

单向 channel 的声明也很简单，只需要在声明的时候带上 <- 操作符即可，如下面的代码所示：

```
// 单向channel(只存)
onlySendChan := make(chan<- int)
// 单向channel(只取)
onlyReceiveChan:=make(<-chan int)
```

#### 关闭channel

当我们需要关闭channel的时候，我们可以使用内置的Close函数即可关闭

```go
Close(channel)
```

如果一个 channel 被关闭了，就不能向里面发送数据了，如果发送的话，会引起 painc 异常。但是还可以接收 channel 里的数据，如果 channel 里没有数据的话，接收的数据是元素类型的零值。

不难看出channel的坑比较多，一不小心就会写出一个bug。常见情况总结如下

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glaz73x65uj31bs0iiqfn.jpg)


### 多协程-worker pool（goroutine池）
在工作中我们通常会使用可以指定启动的goroutine数量–worker pool模式，控制goroutine的数量，防止goroutine泄漏和暴涨。

一个简易的work pool示例代码如下：
```go
func worker(id int, jobs <-chan int, results chan<- int) {
	for j := range jobs {
		fmt.Printf("worker:%d start job:%d\n", id, j)
		time.Sleep(time.Second)
		fmt.Printf("worker:%d end job:%d\n", id, j)
		results <- j * 2
	}
}


func main() {
	jobs := make(chan int, 100)
	results := make(chan int, 100)
	// 开启3个goroutine
	for w := 1; w <= 3; w++ {
		go worker(w, jobs, results)
	}
	// 5个任务
	for j := 1; j <= 5; j++ {
		jobs <- j
	}
	close(jobs)
	// 输出结果
	for a := 1; a <= 5; a++ {
		<-results
	}
}
```
### 多路复用

假设要从网上下载一个文件，启动 3 个 goroutine 进行下载，并把结果发送到 3 个 channel 中。哪个先下载好，就会使用哪个 channel 的结果。

在这种情况下，如果我们尝试获取第一个 channel 的结果，程序就会被阻塞，无法获取剩下两个 channel 的结果，也无法判断哪个先下载好。这个时候就需要用到多路复用操作了，在 Go 语言中，通过 select 语句可以实现多路复用，其语句格式如下：

```go
select {

case i1 = <-c1:
				//todo  1
case i2 <- c2:
				//todo	2
default:
				// default todo
}
```

整体结构和 switch 非常像，都有 case 和 default，只不过 select 的 case 是一个个可以操作的 channel。

> 多路复用可以简单地理解为，N 个 channel 中，任意一个 channel 有数据产生，select 都可以监听到，然后执行相应的分支，接收数据并处理。

```go
package main

import (
	"fmt"
	"time"
)

func downloadFile(chanName string) string {
	//随机time.Sleep,模拟下载文件
	time.Sleep(time.Second * 1)
	return chanName + ":filePath"
}
func main() {
	//声明三个存放结果的channel
	//firstCh := make(chan string)
	//secondCh := make(chan string)
	//threeCh := make(chan string)
	firstCh, secondCh, threeCh := make(chan string), make(chan string), make(chan string)
	//同时开启3个goroutine下载
	go func() {
		firstCh <- downloadFile("firstCh")
	}()
	go func() {
		secondCh <- downloadFile("secondCh")
	}()
	go func() {
		threeCh <- downloadFile("threeCh")
	}()
	//开始select多路复用，哪个channel能获取到值，
	//就说明哪个最先下载好，就用哪个。
	select {
	case filePath := <-firstCh:
		fmt.Println(filePath)
	case filePath := <-secondCh:
		fmt.Println(filePath)
	case filePath := <-threeCh:
		fmt.Println(filePath)
	}
}
```

