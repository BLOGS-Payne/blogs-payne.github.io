---
title: 盘点go并发那些事儿之二-并发控制得心应手
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2021-02-04 22:27:25
---
## 盘点Golang并发那些事儿之二

上一节提到，golang中直接使用关键字`go`创建`goroutine`,无法满足我们的需求。主要问题如下

- 无法有效的并发执行完成
- 无法有效的控制并发

首先我们再来看看下面这个栗子，代码如下
<!--more-->
```go
// example-goroutine anonymous

package main

import (
	"fmt"
	"time"
)

func anonymous1() {
	startTime := time.Now()
	// 创建十个goroutine
	for i := 0; i < 10; i++ {
		go func() {
			fmt.Println("HelloWord~, stamp is", i)
		}()
	}
	fmt.Println("Main~")
	spendTime := time.Since(startTime)
	fmt.Println("Spend Time:", spendTime)
	// 防止goroutine提前退出
	// time.Sleep(time.Second)
}

// goroutine anonymous
func main() {
	anonymous2()
}
```

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnbcfbzjn2j31890u0wgd.jpg" style="zoom:25%;" />

此时你会发现有些任务被多次执行了，但有些任务却又没有被执行。以上例子虽加速了运行，但带来的损失却也是巨大的。例如银行转账等，一旦出现以上情况多次付款也随之而来了。弊大于利

首先我们来分析以上代码，为什么会出现此种情况？虽然是个废品，但也是俺辛辛苦苦的写的不是，让俺做个明白鬼。

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnbcxvhqt1j30oc0s0q33.jpg" style="zoom:50%;" />

我们从里面往外分析`anonymous1`首先他是个匿名函数 + 立即执行函数，且变量`i`并不是传递的参数，而是外部循环带进来的。由上图，我们知道，执行流程为先创建goroutine，执行逻辑，返回结果。

> 请思考：
>
> goroutine，越多越好么？为什么
>
> 如何避免以上情景？如何避免提前退出？

## 信道-Channel

信道的英文是channel，在golang当中的关键字是chan。它的用途是用来**在goroutine之间传输数据**，这里你可能要问了，为什么一定得是goroutine之间传输数据呢，函数之间传递不行吗？

因为正常的传输数据直接以参数的形式传递就可以了，只有在并发场景当中，多个线程彼此隔离的情况下，才需要一个特殊的结构传输数据。

Go语言的并发模型是`CSP（Communicating Sequential Processes）`，提倡**通过通信共享内存**而不是**通过共享内存而实现通信**。

如果说`goroutine`是Go程序并发的执行体，`channel`就是它们之间的连接。`channel`是可以让一个`goroutine`发送特定值到另一个`goroutine`的通信机制。

Go 语言中的通道（channel）是一种特殊的类型。通道像一个传送带或者队列，总是遵循先入先出（First In First Out）的规则，保证收发数据的顺序。每一个通道都是一个具体类型的导管，也就是声明channel的时候需要为其指定元素类型。

> channel底层的实现为互斥锁

### example

```go
var 变量 chan 元素类型
// example-var
// 只声明
var a chan int
var b chan string
var c chan byte
var d chan []string
var e chan []int
// 实例化
a = make(chan []int)

//example-2(推荐使用)
管道名称 := make(chan 数据类型 [缓冲区size])
```

### 无缓冲channel

示例代码如下

```go
package main

import (
	"fmt"
	"time"
)

func hello(intCh <-chan int) {
	fmt.Println("Hello, Gopher. I am stamp[Id]", <-intCh)
	time.Sleep(time.Second * 2)
}

func main() {
	startTime := time.Now()
	const jobNumber = 100 * 100
	// create chan
	intCh := make(chan int)
	for i := 0; i <= jobNumber; i++ {
		// create goroutine same number for jobNumber
		go hello(intCh)
		intCh <- i
	}
	fmt.Println("Completed, Spend Time :", time.Since(startTime))
}
```

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnbiwoqycdj312e0u0mzi.jpg" style="zoom:50%;" />

这速度可谓是非常的快啊

### 带缓冲Channel

带缓冲的 channel(buffered channel) 是一种在被接收前能存储一个或者多个值的通道。这种类型的通道并不强制要求 goroutine 之间必须同时完成发送和接收。通道会阻塞发送和接收动作的条件也会不同。只有在通道中没有要接收的值时，接收动作才会阻塞。只有在通道没有可用缓冲区容纳被发送的值时，发送动作才会阻塞。这导致有缓冲的通道和无缓冲的通道之间的一个很大的不同：

**无缓冲的通道保证进行发送和接收的 goroutine 会在同一时间进行数据交换；有缓冲的通道没有这种保证**

来段代码压压惊

```go
package main

import (
	"fmt"
	"time"
)

func hello(intCh <-chan int) {
	fmt.Println("Hello, Gopher. I am stamp[Id]", <-intCh)
	time.Sleep(time.Second * 2)
}

func hello1(intCh <-chan int) {
	fmt.Println("Hello, Gopher1. I am stamp[Id]", <-intCh)
	time.Sleep(time.Second * 2)
}

func main() {
	startTime := time.Now()
	const jobNumber = 100 * 100
	// create chan
	intCh := make(chan int, 100)
	for i := 0; i <= jobNumber; i++ {
		// create goroutine same number for jobNumber
		go hello(intCh)
		go hello1(intCh)
		intCh <- i
	}
	fmt.Println("Completed, Spend Time :", time.Since(startTime))
}

```

运行效果如下

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnbjwzeu0mj31bn0u0q55.jpg" style="zoom:50%;" />

这速度杠杠滴哈，别急，同时也让我和你说执行流程，老规矩，上图



<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnbk988aw2j30o00oajrf.jpg" style="zoom:50%;" />

首先开始执行把需要传递的数据打到channle里面，然后goroutine去取，执行。那么有留下几个问题

> 还可以加速么？
>
> 加速的方法？
>
> 可能带来什么新的问题？
>
> 如何解决？



### 单向 channel

有时候，我们有一些特殊的业务需求，比如限制一个 channel 只可以接收但是不能发送，或者限制一个 channel 只能发送但不能接收，这种 channel 称为单向 channel。

单向 channel 的声明也很简单，只需要在声明的时候带上 <- 操作符即可，如下面的代码所示：

```go
onlySend := make(chan<- int)
onlyReceive:=make(<-chan int)
```

使用单向 channel 的较多场景一般在函数参数中使用较多，这样可以防止一些操作影响了 channel。

```go
//example channel
onlySend := make(chan<- int)
onlyReceive:=make(<-chan int)

//example function
package main

import "fmt"

func exs(accept <-chan int, recipient chan<- int) {
	for result := range accept {
		fmt.Println("Received only sent channel a:", result)
		recipient <- result + 2
	}

	//fmt.Println("Send Only", recipient)
}

func main() {
	const processNumber = 100
	sender := make(chan int, processNumber)
	recipient := make(chan int, processNumber)
	for e := 0; e < 10; e++ {
		go exs(sender, recipient)
	}

	for s := 0; s < processNumber; s++ {
		sender <- s
	}
	for r := 0; r < processNumber; r++ {
		//<-recipient
		fmt.Println("recipient", <-recipient)
	}
}
```



> 小技巧：箭头该谁指谁?这可把我整的不好了，别慌，我告诉你，到底该谁指谁。其实很简单
>
> 箭头一致向左指
>
> ```
> a <- chan <- b
> 
> // 存入
> chan <- b
> 
> // 取出
> a := <- chan 
> ```
>
> Chan其实就是起到一个中间人的作用，箭头指向chan，那就是放入，chan指出去 就是拿出来。
>
> 相信你应该记住了吧，反正我记住了



### 多路复用Channel

假设要从网上下载一个文件，启动了 5个 goroutine 进行下载，并把结果发送到 5 个 channel 中。其中，哪个先下载好，就会使用哪个 channel 的结果。

在这种情况下，如果我们尝试获取第一个 channel 的结果，程序就会被阻塞，无法获取剩下4个 channel 的结果，也无法判断哪个先下载好。这个时候就需要用到多路复用操作了，在 Go 语言中，通过 select 语句可以实现多路复用，其语句格式如下：

```go
select{
    case <-ch1:
        ...
    case data := <-ch2:
        ...
    case ch3<-data:
        ...
    default:
        默认操作
}
```

整体结构和 switch 非常像，都有 case 和 default，只不过 select 的 case 是一个个可以操作的 channel。

> 小提示：多路复用可以简单地理解为，N 个 channel 中，任意一个 channel 有数据产生，select 都可以监听到，然后执行相应的分
>
> 支，接收数据并处理。
>
> 使用`select`语句能提高代码的可读性。
>
> - 可处理一个或多个channel的发送/接收操作。
> - 如果多个`case`同时满足，`select`会随机选择一个。
> - 对于没有`case`的`select{}`会一直等待，可用于阻塞main函数。

```go
// example select
package main

import (
    "fmt"
    "time"
)

func main() {

    c1 := make(chan string)
    c2 := make(chan string)

    go func() {
        time.Sleep(1 * time.Second)
        c1 <- "one"
    }()
    go func() {
        time.Sleep(2 * time.Second)
        c2 <- "two"
    }()

    for i := 0; i < 2; i++ {
        select {
        case msg1 := <-c1:
            fmt.Println("received", msg1)
        case msg2 := <-c2:
            fmt.Println("received", msg2)
        }
    }
}
```

小结：关于数据流动、传递等情况的优先使用`channle`， 它是并发安全的，且性能优异



## Sync深入并发控制

### sync.waitGroup

在此之前我们先去，解决一个开启`goroutine`，提前退出的例子

示例代码如下

```
package main

import (
	"fmt"
	"sync"
	//"time"
)

var wg sync.WaitGroup
func main() {
	for i := 0; i < 10 ; i++ {
		go exampleOut(i)
	}
}

func exampleOut(i int)  {
	fmt.Println("Hello, Gopher, I am [Id]", i)
}
```

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnbroyfdoyj319q0u00ue.jpg" style="zoom:50%;" />

仔细看，你会发现根本就没有输出，原因是它开启`goroutine`，也需要时间。main函数并会等待，当然我们也可以手动添加一个停止，但这个并不能有效的阻止(你我都知道需要多久才能把`goroutine`执行完成),那有没有办法。。。

答案当然是有滴，它就是`sync.WaitGroup`

> WaitGroup等待goroutine的集合完成。主goroutine调用添加以设置要等待的goroutine的数量。然后，每个goroutine都会运行并在完成后调用Done。同时，可以使用Wait来阻塞，直到所有goroutine完成。
>
> 你可以理解为计数器

```go
// `sync.WaitGroup`一共有三个方法,他们分别是：
Add(delta int)
//Add将可能为负数的增量添加到WaitGroup计数器中。如果计数器为零，则释放等待时阻塞的所有goroutine
Done()
// 完成将WaitGroup计数器减一。
 Wait()
// 等待块，直到WaitGroup计数器为零。
```

example

```go
// WaitGroup
package main

import (
	"fmt"
	"sync"
)

// 声明WaitGroup
var wg sync.WaitGroup

func main() {
	for i := 0; i < 10; i++ {
		// WaitGroup 计数器 + 1
		// 其delta为你开启的`groutine`数量
		wg.Add(1)
		go exampleOut(i)
	}
	// 等待 WaitGroup 计数器为0
	wg.Wait()
}

func exampleOut(i int) {
	// WaitGroup 计数器 - 1
	wg.Done()
	fmt.Println("Hello, Gopher, I am [Id]", i)
}
```

### sync.Mutex

无论是前面的`channle`还是sync都是为了干一件事，那就是并发控制，也许你也和我一样有以下几个问题

- 我们为什么需要并发控制，不要可以么？
- 并发控制到底是控制什么？
- 并发控制有哪几种方案，他们分别适用于哪种场景？
- 如何做好并发控制呢？

以上几点就是我们此节需要了解、以及解决的问题

首先解决我们一起探究第一个问题，为什么需要并发控制？

首先有这么一个问题、以及相关的解决措施，绝对不是脱裤子放屁，多此一举。需要并发控制的原因有很多，总结一句话那就是资源竞争

> 资源竞争
>
> 在一个 goroutine 中，如果分配的内存没有被其他 goroutine 访问，只在该 goroutine 中被使用，那么不存在资源竞争的问题。
>
> 但如果同一块内存被多个 goroutine 同时访问，就会产生不知道谁先访问也无法预料最后结果的情况。这就是资源竞争，这块内存可以称为共享的资源
>
> 还记得在channel中，我讲到 Go语言的并发模型是`CSP（Communicating Sequential Processes）`，提倡**通过通信共享内存**而不是**通过共享内存而实现通信**，这点尤为重要需要我们去记住与掌握

首先我们来看一个累加求和的例子，代码如下所示

```go
package main

import (
	"fmt"
	"sync"
)

var (
	x int64
	wg sync.WaitGroup
)

func add() {
	for i := 0; i < 5000; i++ {
		x = x + 1
	}
	wg.Done()
}
func main() {
	wg.Add(5)
	go add()
	go add()
	go add()
	go add()
	go add()
	wg.Wait()
	fmt.Println(x)
}

```

期待输出值为`25000`，sum + 10 加和 5000次,执行五次，我们口算答案是`5000`,可输出结果却是`3048`,而且每次答案还不一样。好家伙

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnbt36anhqj319i0u0q43.jpg" style="zoom:50%;" />

这是为什么呢?,靓仔疑惑～

其根本的原因就是资源恶意竞争

> 精囊妙计：
>
> 使用 go build、go run、go test 这些 Go 语言工具链提供的命令时，添加 -race 标识可以帮你检查 Go 语言代码是否存在资源竞争。
>
> ```go
> // example
> go run -race demo3.go
> ```

那么该怎么解决呢？

`sync.Mutex`互斥锁，顾名思义，指的是在同一时刻只有一个`goroutine`执行某段代码，其他`goroutine`都要等待该`goroutine`执行完毕后才能继续执行。

在下面的示例中，我声明了一个互斥锁 mutex，然后修改 add 函数，对 sum+=i 这段代码加锁保护。这样这段访问共享资源的代码片段就并发安全了，可以得到正确的结果

`sync.Mutex`为我们提供了两个方法，加锁与解锁,修改时先获取锁，修改后释放锁





代码修改如下

```go
package main

import (
	"fmt"
	"sync"
)

var (
	x    int64
	lock sync.Mutex
	wg   sync.WaitGroup
)

func add() {
	for i := 0; i < 1000; i++ {
		lock.Lock() // 加锁
		x += 1
		lock.Unlock() // 解锁
	}
	wg.Done()
}
func main() {
	wg.Add(5)
	go add()
	go add()
	go add()
	go add()
	go add()
	wg.Wait()
	fmt.Println(x)
}

```

女少啊～

> 在以上示例代码中`x += 1`，部分被称之为临界区
>
> 在同步的程序设计中，临界区段指的是一个访问共享资源的程序片段，而这些共享资源又有无法同时被多个`goroutine`访问的特性。 当有协程进入临界区段时，其他协程必须等待，这样就保证了临界区的并发安全。

### sync.RWMutex

互斥锁是完全互斥的，但是有很多实际的场景下是读多写少的，当我们并发的去读取一个资源不涉及资源修改的时候是没有必要加锁的，这种场景下使用读写锁是更好的一种选择。读写锁在Go语言中使用`sync`包中的`RWMutex`类型。

读写锁分为两种：读锁和写锁。当一个goroutine获取读锁之后，其他的`goroutine`如果是获取读锁会继续获得锁，如果是获取写锁就会等待；当一个`goroutine`获取写锁之后，其他的`goroutine`无论是获取读锁还是写锁都会等待。

```go
var (
	x      int64
	wg     sync.WaitGroup
	lock   sync.Mutex
	rwlock sync.RWMutex
)

func write() {
	// lock.Lock()   											// 加互斥锁
	rwlock.Lock() 												// 加写锁
	x = x + 1
	time.Sleep(10 * time.Millisecond) 		// 假设读操作耗时10毫秒
	rwlock.Unlock()                   		// 解写锁
	// lock.Unlock()                      // 解互斥锁
	wg.Done()
}

func read() {
	// lock.Lock()                  			// 加互斥锁
	rwlock.RLock()               					// 加读锁
	time.Sleep(1) 												// 假设读操作耗时1秒
	rwlock.RUnlock()             					// 解读锁
	// lock.Unlock()                			// 解互斥锁
	wg.Done()
}

func main() {
	start := time.Now()
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go write()
	}

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go read()
	}

	wg.Wait()
	end := time.Now()
	fmt.Println(end.Sub(start))
}
```

现在我们解决了多个 goroutine 同时读写的资源竞争问题，但是又遇到另外一个问题——性能。因为每次读写共享资源都要加锁，所以性能低下，这该怎么解决呢？

现在我们分析读写这个特殊场景，有以下几种情况：

1. 写的时候不能同时读，因为这个时候读取的话可能读到脏数据（不正确的数据）；
2. 读的时候不能同时写，因为也可能产生不可预料的结果；
3. 读的时候可以同时读，因为数据不会改变，所以不管多少个 goroutine 读都是并发安全的。

所以就可以通过读写锁 sync.RWMutex 来优化这段代码，提升性能。

### sync.Once

在实际的工作中，你可能会有这样的需求：让代码只执行一次，哪怕是在高并发的情况下，比如创建一个单例。

针对这种情形，Go 语言为我们提供了 sync.Once 来保证代码只执行一次，例如只加载一次配置文件、只关闭一次通道等。

Go语言中的`sync`包中提供了一个针对只执行一次场景的解决方案–`sync.Once`。

`sync.Once`只有一个`Do`方法，其签名如下：

```go
func (o *Once) Do(f func()) {}
// 如果要执行的函数f需要传递参数就需要搭配闭包来使用。
```

这是 Go 语言自带的一个示例，虽然启动了 10 个`goroutine`来执行 onceBody 函数，但是因为用了 once.Do 方法，所以函数 onceBody 只会被执行一次。也就是说在高并发的情况下，sync.Once 也会保证 onceBody 函数只执行一次。

sync.Once 适用于创建某个对象的单例、只加载一次的资源等只执行一次的场景。

```
// example
func main() {
   doOnce()
}
func doOnce() {
   var once sync.Once
   onceBody := func() {
      fmt.Println("Only once")
   }
   //用于等待`goroutine`执行完毕
   done := make(chan bool)
   //启动10个协程执行once.Do(onceBody)
   for i := 0; i < 10; i++ {
      go func() {
         //把要执行的函数(方法)作为参数传给once.Do方法即可
         once.Do(onceBody)
         done <- true
      }()
   }
   for i := 0; i < 10; i++ {
      <-done
   }
}
```

### sync.Map

```
var m = make(map[string]int)

func get(key string) int {
	return m[key]
}

func set(key string, value int) {
	m[key] = value
}

func main() {
	wg := sync.WaitGroup{}
	for i := 0; i < 20; i++ {
		wg.Add(1)
		go func(n int) {
			key := strconv.Itoa(n)
			set(key, n)
			fmt.Printf("k=:%v,v:=%v\n", key, get(key))
			wg.Done()
		}(i)
	}
	wg.Wait()
}
```

上面的代码开启少量几个`goroutine`的时候可能没什么问题，当并发多了之后执行上面的代码就会报错误。

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnbtrqdjtaj31ak0u0gng.jpg)

像这种场景下就需要为map加锁来保证并发的安全性了，Go语言的`sync`包中提供了一个开箱即用的并发安全版map–`sync.Map`。开箱即用表示不用像内置的map一样使用make函数初始化就能直接使用。同时`sync.Map`内置了诸如`Store`、`Load`、`LoadOrStore`、`Delete`、`Range`等操作方法。

一个简单的例子

```go
var m = sync.Map{}

func main() {
	wg := sync.WaitGroup{}
	for i := 0; i < 20; i++ {
		wg.Add(1)
		go func(n int) {
			key := strconv.Itoa(n)
			m.Store(key, n)
			value, _ := m.Load(key)
			fmt.Printf("k=:%v,v:=%v\n", key, value)
			wg.Done()
		}(i)
	}
	wg.Wait()
}
```

### 原子操作

代码中的加锁操作因为涉及内核态的上下文切换会比较耗时、代价比较高。针对基本数据类型我们还可以使用原子操作来保证并发安全，因为原子操作是Go语言提供的方法它在用户态就可以完成，因此性能比加锁操作更好。Go语言中原子操作由内置的标准库`sync/atomic`提供。

#### atomic包

|                             方法                             |      解释      |
| :----------------------------------------------------------: | :------------: |
| func LoadInt32(addr *int32) (val int32) func LoadInt64(addr *int64) (val int64) func LoadUint32(addr *uint32) (val uint32) func LoadUint64(addr *uint64) (val uint64) func LoadUintptr(addr *uintptr) (val uintptr) func LoadPointer(addr *unsafe.Pointer) (val unsafe.Pointer) |    读取操作    |
| func StoreInt32(addr *int32, val int32) func StoreInt64(addr *int64, val int64) func StoreUint32(addr *uint32, val uint32) func StoreUint64(addr *uint64, val uint64) func StoreUintptr(addr *uintptr, val uintptr) func StorePointer(addr *unsafe.Pointer, val unsafe.Pointer) |    写入操作    |
| func AddInt32(addr *int32, delta int32) (new int32) func AddInt64(addr *int64, delta int64) (new int64) func AddUint32(addr *uint32, delta uint32) (new uint32) func AddUint64(addr *uint64, delta uint64) (new uint64) func AddUintptr(addr *uintptr, delta uintptr) (new uintptr) |    修改操作    |
| func SwapInt32(addr *int32, new int32) (old int32) func SwapInt64(addr *int64, new int64) (old int64) func SwapUint32(addr *uint32, new uint32) (old uint32) func SwapUint64(addr *uint64, new uint64) (old uint64) func SwapUintptr(addr *uintptr, new uintptr) (old uintptr) func SwapPointer(addr *unsafe.Pointer, new unsafe.Pointer) (old unsafe.Pointer) |    交换操作    |
| func CompareAndSwapInt32(addr *int32, old, new int32) (swapped bool) func CompareAndSwapInt64(addr *int64, old, new int64) (swapped bool) func CompareAndSwapUint32(addr *uint32, old, new uint32) (swapped bool) func CompareAndSwapUint64(addr *uint64, old, new uint64) (swapped bool) func CompareAndSwapUintptr(addr *uintptr, old, new uintptr) (swapped bool) func CompareAndSwapPointer(addr *unsafe.Pointer, old, new unsafe.Pointer) (swapped bool) | 比较并交换操作 |

#### 示例

我们填写一个示例来比较下互斥锁和原子操作的性能。

```go
package main

import (
	"fmt"
	"sync"
	"sync/atomic"
	"time"
)

type Counter interface {
	Inc()
	Load() int64
}

// 普通版
type CommonCounter struct {
	counter int64
}

func (c CommonCounter) Inc() {
	c.counter++
}

func (c CommonCounter) Load() int64 {
	return c.counter
}

// 互斥锁版
type MutexCounter struct {
	counter int64
	lock    sync.Mutex
}

func (m *MutexCounter) Inc() {
	m.lock.Lock()
	defer m.lock.Unlock()
	m.counter++
}

func (m *MutexCounter) Load() int64 {
	m.lock.Lock()
	defer m.lock.Unlock()
	return m.counter
}

// 原子操作版
type AtomicCounter struct {
	counter int64
}

func (a *AtomicCounter) Inc() {
	atomic.AddInt64(&a.counter, 1)
}

func (a *AtomicCounter) Load() int64 {
	return atomic.LoadInt64(&a.counter)
}

func test(c Counter) {
	var wg sync.WaitGroup
	start := time.Now()
	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			c.Inc()
			wg.Done()
		}()
	}
	wg.Wait()
	end := time.Now()
	fmt.Println(c.Load(), end.Sub(start))
}

func main() {
	c1 := CommonCounter{} // 非并发安全
	test(c1)
	c2 := MutexCounter{} // 使用互斥锁实现并发安全
	test(&c2)
	c3 := AtomicCounter{} // 并发安全且比互斥锁效率更高
	test(&c3)
}
```

`atomic`包提供了底层的原子级内存操作，对于同步算法的实现很有用。这些函数必须谨慎地保证正确使用。除了某些特殊的底层应用，使用通道或者sync包的函数/类型实现同步更好。



### sync.Cond

> Cond实现了一个条件变量，它是goroutines等待或宣布事件发生的集合点。每个Cond都有一个关联的Locker L（通常是Mutex或RWMutex），在更改条件和调用Wait方法时必须将其保留。第一次使用后，不得复制条件

在 Go 语言中，sync.WaitGroup 用于最终完成的场景，关键点在于一定要等待所有`goroutine`都执行完毕。

而 sync.Cond 可以用于发号施令，一声令下所有`goroutine`都可以开始执行，关键点在于`goroutine`开始的时候是等待的，要等待 sync.Cond 唤醒才能执行。

sync.Cond 从字面意思看是条件变量，它具有阻塞协程和唤醒协程的功能，所以可以在满足一定条件的情况下唤醒协程，但条件变量只是它的一种使用场景。

sync.Cond 有三个方法，它们分别是：

1. **Wait**，Wait原子地解锁c.L并中止调用goroutine的执行。稍后恢复执行后，等待锁定c.L才返回。与其他系统不同，等待不会返回，除非被广播或信号唤醒。
2. **Signal**，信号唤醒一个等待在c的goroutin
3. **Broadcast**，唤醒所有等待c的goroutine

示例

```
package main

import (
	"fmt"
	"sync"
	"time"
)

//10个人赛跑，1个裁判发号施令
func race() {
	cond := sync.NewCond(&sync.Mutex{})
	var wg sync.WaitGroup
	wg.Add(11)
	for i := 0; i < 10; i++ {
		go func(num int) {
			defer wg.Done()
			fmt.Println(num, "号已经就位")
			cond.L.Lock()
			cond.Wait() //等待发令枪响
			fmt.Println(num, "号开始跑……")
			cond.L.Unlock()
		}(i)
	}
	//等待所有goroutine都进入wait状态
	time.Sleep(2 * time.Second)
	go func() {
		defer wg.Done()
		fmt.Println("裁判已经就位，准备发令枪")
		fmt.Println("比赛开始，大家准备跑")
		cond.Broadcast() //发令枪响
	}()
	//防止函数提前返回退出
	wg.Wait()
}
```

## 总结

这一节我们巴拉巴拉搞了很多，到底什么情况用哪个。相信你也可能和我一样半懵半醒，那么我们来总结一下。他们的使用场景,啥是啥？

需知：**goroutine与线程**

- Go语言的并发模型是`CSP（Communicating Sequential Processes）`，提倡**通过通信共享内存**而不是**通过共享内存而实现通信**。

```
可增长的栈
OS线程（操作系统线程）一般都有固定的栈内存（通常为2MB）,一个goroutine的栈在其生命周期开始时只有很小的栈（典型情况下2KB），goroutine的栈不是固定的，他可以按需增大和缩小，goroutine的栈大小限制可以达到1GB，虽然极少会用到这么大。所以在Go语言中一次创建十万左右的goroutine也是可以的。

goroutine调度
GPM是Go语言运行时（runtime）层面的实现，是go语言自己实现的一套调度系统。区别于操作系统调度OS线程。

G很好理解，就是个goroutine的，里面除了存放本goroutine信息外 还有与所在P的绑定等信息。
P管理着一组goroutine队列，P里面会存储当前goroutine运行的上下文环境（函数指针，堆栈地址及地址边界），P会对自己管理的goroutine队列做一些调度（比如把占用CPU时间较长的goroutine暂停、运行后续的goroutine等等）当自己的队列消费完了就去全局队列里取，如果全局队列里也消费完了会去其他P的队列里抢任务。
M（machine）是Go运行时（runtime）对操作系统内核线程的虚拟， M与内核线程一般是一一映射的关系， 一个groutine最终是要放到M上执行的；
P与M一般也是一一对应的。他们关系是： P管理着一组G挂载在M上运行。当一个G长久阻塞在一个M上时，runtime会新建一个M，阻塞G所在的P会把其他的G 挂载在新建的M上。当旧的G阻塞完成或者认为其已经死掉时 回收旧的M。

P的个数是通过runtime.GOMAXPROCS设定（最大256），Go1.5版本之后默认为物理线程数。 在并发量大的时候会增加一些P和M，但不会太多，切换太频繁的话得不偿失。
```

**使用场景**

- Channel:关于数据流动、传递等情况的优先使用`channle`， 它是并发安全的，且性能优异, channel底层的实现为互斥锁
- sync.Once：让代码只执行一次，哪怕是在高并发的情况下，比如创建一个单例。

- Sync.WaitGroup:用于最终完成的场景，关键点在于一定要等待所有协程都执行完毕。有了它我们再也不用为了等待协程执行完成而添加`time.sleep`了
- Sync.Mutew: 当资源发现竞争时，我们可以使用`Sync.Mutew`，加互斥锁保证并发安全
- Sync.RWMutew: `Sync.Mutew`进阶使用，当读多写少的时候，可以使用读写锁来保证并发安全，同时也提高了并发效率
- sync.Map:高并发的情况下，原始的map并不安全，使用sync.Map可用让我们的map在并发情况下也保证安全
- sync.Cond:sync.Cond 可以用于发号施令，一声令下所有`goroutine`都可以开始执行，关键点在于`goroutine`开始的时候是等待的，要等待 sync.Cond 唤醒才能执行。



说了这么多，这么多花里胡哨的，注意一点，Sync.Mutew，互斥锁，所有的锁的爸爸，原子操作。互斥锁的叔叔。



感谢您的阅读，如果感觉不错。也可以点赞、收藏、在读、当然推荐给身边的哥们也是不错的选择，同时欢迎关注我。一起从0到1



期待下一章节，铁索连环-context

以及下下章节：并发模式

我会在`并发模式`中与你探讨：

`channle`缓存区多大比较合适,

Goroutine Work Pool，减少`Goroutine`过多重复的创建与销毁

Pipeline 模式：流水线工作模式，对任务中的部分进行剖析

扇出和扇入模式：对流水线工作模式进行优化，实现更高效的`扇出和扇入模式`

Futures 模式:未来模式，主协程不用等待子协程返回的结果，可以先去做其他事情，等未来需要子协程结果的时候再来取

同时再一次去搞一下，到底什么是可异步、并发的代码，并加以分析与优化



未来已来。Let‘s Go～


