---
title: Golang并发编程初探
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-12-03 22:05:09
---

## 基本概念了解：

### 并发与并行：(略偏向于多线 / 进程方面)

- 并发： 指在同一时刻只能有一条指令执行，但多个进程指令被快速的轮换执行，使得在宏观上具有多个进程同时执行的效果，但在微观上并不是同时执行的，只是把时间分成若干段，使多个进程快速交替的执行
- 并行： 指在同一时刻，有多条指令在多个处理器上同时执行。所以无论从微观还是从宏观来看，二者都是一起执行的
<!--more-->
### 阻塞与非阻塞：（略偏向于协程 / 异步方向）


- 阻塞：阻塞状态指程序未得到所需计算资源时被挂起的状态。程序在等待某个操作完成期间，自身无法继续处理其他的事情，则称该程序在该操作上是阻塞的。

- 非阻塞：程序在等待某操作过程中，自身不被阻塞，可以继续处理其他的事情，则称该程序在该操作上是非阻塞的


### 同步与异步：

- 同步：不同程序单元为了完成某个任务，在执行过程中需靠某种通信方式以协调一致，我们称这些程序单元是同步执行的。
- 异步：为完成某个任务，不同程序单元之间过程中无需通信协调，也能完成任务的方式，不相关的程序单元之间可以是异步的。



- **多线程（英语：multithreading）**：指从软件或者硬件上实现多个线程并发执行的技术。具有多线程能力的计算机因有硬件支持而能够在同一时间执行多于一个线程，进而提升整体处理性能。具有这种能力的系统包括对称多处理机、多核心处理器以及芯片级多处理（Chip-level multithreading）或同时多线程（Simultaneous multithreading）处理器。在一个程序中，这些独立运行的程序片段叫作 “线程”（Thread），利用它编程的概念就叫作 “多线程处理（Multithreading）”
- **多进程 (Multiprocessing):** 每个正在系统上运行的程序都是一个进程。每个进程包含一到多个线程。进程也可能是整个程序或者是部分程序的动态执行。线程是一组指令的集合，或者是程序的特殊段，它可以在程序里独立执行。也可以把它理解为代码运行的上下文。所以线程基本上是轻量级的进程，它负责在单个程序里执行多任务。通常由操作系统负责多个线程的调度和执行。线程是程序中一个单一的顺序控制流程。在单个程序中同时运行多个线程完成不同的工作，称为多线程.
- **二者的区别：**线程和进程的区别在于，子进程和父进程有不同的代码和数据空间，而多个线程则共享数据空间，每个线程有自己的执行堆栈和程序计数器为其执行上下文。多线程主要是为了节约 CPU 时间，发挥利用，根据具体[情况](https://baike.baidu.com/item/情况)而定。线程的运行中需要使用计算机的[内存](https://baike.baidu.com/item/内存)资源和 CPU。
- **协程 (Coroutine):** 又称微线程、纤程，协程是一种用户态的轻量级线程。 协程看上去也是子程序，但执行过程中，在子程序内部可中断，然后转而执行别的子程序，在适当的时候再返回来接着执行。

## Go并发编程

Go 语言中没有线程的概念，只有协程，也称为 goroutine。相比线程来说，协程更加轻量，一个程序可以随意启动成千上万个 goroutine。

Go语言中的`goroutine`就是这样一种机制，`goroutine`的概念类似于线程，但 `goroutine`是由Go的运行时（runtime）调度和管理的。Go程序会智能地将 goroutine 中的任务合理地分配给每个CPU。Go语言之所以被称为现代化的编程语言，就是因为它在语言层面已经内置了调度和上下文切换的机制。

在Go语言编程中你不需要去自己写进程、线程、协程，你的技能包里只有一个技能–`goroutine`，当你需要让某个任务并发执行的时候，你只需要把这个任务包装成一个函数，开启一个`goroutine`去执行这个函数就可以了，就是这么简单粗暴。

### goroutine与线程

#### 可增长的栈

OS线程（操作系统线程）一般都有固定的栈内存（通常为2MB）,一个`goroutine`的栈在其生命周期开始时只有很小的栈（典型情况下2KB），`goroutine`的栈不是固定的，他可以按需增大和缩小，`goroutine`的栈大小限制可以达到1GB，虽然极少会用到这么大。所以在Go语言中一次创建十万左右的`goroutine`也是可以的。

#### goroutine调度

`GPM`是Go语言运行时（runtime）层面的实现，是go语言自己实现的一套调度系统。区别于操作系统调度OS线程。

- `G`很好理解，就是个goroutine的，里面除了存放本goroutine信息外 还有与所在P的绑定等信息。
- `P`管理着一组goroutine队列，P里面会存储当前goroutine运行的上下文环境（函数指针，堆栈地址及地址边界），P会对自己管理的goroutine队列做一些调度（比如把占用CPU时间较长的goroutine暂停、运行后续的goroutine等等）当自己的队列消费完了就去全局队列里取，如果全局队列里也消费完了会去其他P的队列里抢任务。
- `M（machine）`是Go运行时（runtime）对操作系统内核线程的虚拟， M与内核线程一般是一一映射的关系， 一个groutine最终是要放到M上执行的；

P与M一般也是一一对应的。他们关系是： P管理着一组G挂载在M上运行。当一个G长久阻塞在一个M上时，runtime会新建一个M，阻塞G所在的P会把其他的G 挂载在新建的M上。当旧的G阻塞完成或者认为其已经死掉时 回收旧的M。

P的个数是通过`runtime.GOMAXPROCS`设定（最大256），Go1.5版本之后默认为物理线程数。 在并发量大的时候会增加一些P和M，但不会太多，切换太频繁的话得不偿失。

单从线程调度讲，Go语言相比起其他语言的优势在于OS线程是由OS内核来调度的，`goroutine`则是由Go运行时（runtime）自己的调度器调度的，这个调度器使用一个称为m:n调度的技术（复用/调度m个goroutine到n个OS线程）。 其一大特点是goroutine的调度是在用户态下完成的， 不涉及内核态与用户态之间的频繁切换，包括内存的分配与释放，都是在用户态维护着一块大的内存池， 不直接调用系统的malloc函数（除非内存池需要改变），成本比调度OS线程低很多。 另一方面充分利用了多核的硬件资源，近似的把若干goroutine均分在物理线程上， 再加上本身goroutine的超轻量，以上种种保证了go调度方面的性能。

### 单个goroutine

Go语言中使用`goroutine`非常简单，只需要在调用函数的时候在前面加上`go`关键字，就可以为一个函数创建一个`goroutine`。

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

#### channel的定义

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

#### channel的基本使用

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


