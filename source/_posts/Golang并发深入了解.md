---
title: Golang并发深入了解
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-12-06 10:46:37
---
## 协程控制需要

重学编程之Golang的plan中的上一篇文章我向大家介绍了，`并发编程基础`，`goroutine的创建`，`channel`，正由于go语言的简洁性,我们可以简易快速的创建任意个协程。同时也留下了许多隐患，如果没有更加深入的学习，其实很难直接将其运用到实际项目中，实际生活中。为什么呢？并发的场景许许多多，但一味的只知道其创建，是很难有效的解决问题。例如以下场景-资源竞争
<!--more-->
```go
package main

import (
	"fmt"
	"time"
)
// 公共资源
var sum = 0
func add(i int) {
	sum += i
}
func main() {
	//开启1000个协程让sum+1
	for i := 0; i < 1000; i++ {
		go add(1)
	}
	//防止提前退出
	time.Sleep(2 * time.Second)
	fmt.Println("和为:", sum)
}
```

也许你的期望值是1000,可惜结果总会差强人意，造成其终究原因是资源竞争，也就是当`goroutine1`与`goroutineN`多次执行了同一步骤

<img src="https://tva1.sinaimg.cn/large/0081Kckwgy1gldr8ifn5pj31aa0ti7al.jpg" style="zoom:25%;" /><img src="https://tva1.sinaimg.cn/large/0081Kckwgy1gldr9uujd0j31dn0u0n4z.jpg" style="zoom:25%;" />

## 协程控制原理与实现

协程的控制原理基本是就是加各种锁，防止`意外`发送，牺牲无序的高速，带来相对有序正确执行。例如`互斥锁、读写锁、等等`

### 同任务唯一执行-互斥锁

**互斥锁**（英语：Mutual exclusion，缩写 Mutex）是一种用于[多线程](https://bk.tw.lvfukeji.com/baike-多线程)[编程](https://bk.tw.lvfukeji.com/baike-编程)中，防止两条[线程](https://bk.tw.lvfukeji.com/baike-线程)同时对同一公共资源（比如[全局变量](https://bk.tw.lvfukeji.com/baike-全域變數)）进行读写的机制。该目的通过将代码切片成一个一个的[临界区域](https://bk.tw.lvfukeji.com/baike-临界区域)（critical section）达成。临界区域指的是一块对公共资源进行访问的代码，并非一种机制或是算法。一个程序、进程、线程可以拥有多个临界区域，但是并不一定会应用互斥锁。

例如：一段代码（甲）正在分步修改一块数据。这时，另一条线程（乙）由于一些原因被唤醒。如果乙此时去读取甲正在修改的数据，而甲碰巧还没有完成整个修改过程，这个时候这块数据的状态就处在极大的不确定状态中，读取到的数据当然也是有问题的。更严重的情况是乙也往这块地方写数据，这样的一来，后果将变得不可收拾。因此，多个线程间共享的数据必须被保护。达到这个目的的方法，就是确保同一时间只有一个临界区域处于运行状态，而其他的临界区域，无论是读是写，都必须被挂起并且不能获得运行机会。

在golang里面实现互斥锁也非常的粗暴，简单可分为三步，声明互斥锁，加锁、执行业务代码、释放锁、下一次执行步骤。更深入理解可参考[wiki互斥锁](https://bk.tw.lvfukeji.com/wiki/%E4%BA%92%E6%96%A5%E9%94%81)，示例如下

示例一：

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

var (
	sum int		// 全局资源sum
	mutex sync.Mutex		// 互斥锁
)

func add(i int) {
	mutex.Lock()		// 加锁
	sum += i				// 执行业务代码
	mutex.Unlock()	// 释放锁，进行下一步骤
}
func main() {
	//开启1000个协程让sum+1
	for i := 0; i < 1000; i++ {
		go add(1)
	}
	//防止提前退出
	time.Sleep(2 * time.Second)
	fmt.Println("和为:", sum)
}
```

示例二：当我们的业务代码不再是如此简单，可能会忘记释放互斥锁，而造成BUG，我们可以借助`defer`关键字，以免忘记

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

var (
	sum int		// 全局资源sum
	mutex sync.Mutex		// 互斥锁
)

func add(i int) {
	mutex.Lock()
	defer mutex.Unlock()
	sum += i
}

func main() {
	//开启1000个协程让sum+1
	for i := 0; i < 1000; i++ {
		go add(1)
	}
	//防止提前退出
	time.Sleep(2 * time.Second)
	fmt.Println("和为:", sum)
}
```

使用互斥锁能够保证同一时间有且只有一个`goroutine`进入临界区，其他的`goroutine`则在等待锁；当互斥锁释放后，等待的`goroutine`才可以获取锁进入临界区，多个`goroutine`同时等待一个锁时，**唤醒的策略是随机的**。

### 读多写少、读少写多-读写锁

现在我们解决了多个 goroutine 同时读写的资源竞争问题，但是又遇到另外一个问题——性能。因为每次读写共享资源都要加锁，所以性能低下。

这个特殊场景的出现，有以下几种情况：

1. 写的时候不能同时读，因为这个时候读取的话可能读到脏数据（不正确的数据）；
2. 读的时候不能同时写，因为也可能产生不可预料的结果；
3. 读的时候可以同时读，因为数据不会改变，所以不管多少个 goroutine 读都是并发安全的。

所以就可以通过读写锁 sync.RWMutex 来优化这段代码，提升性能。现在我将以上示例改为读写锁，来实现我们想要的结果，如下所示：

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

var (
	sum int // 全局资源sum
	mutex sync.Mutex		// 互斥锁
	mutexRW sync.RWMutex // 读写锁
)

// 此处为写
func add(i int) {
	// 互斥锁
	mutex.Lock()
	defer mutex.Unlock()
	sum += i
}

//增加了一个读取的函数，便于演示并发读业务场景
func readSum() int {
	//只获取读锁
	mutexRW.RLock()
	defer mutexRW.RUnlock()
	b := sum
	return b
}
func main() {
	// 开启 1000个
	for i := 0; i < 10000; i++ {
		go add(1)
	}
	for i := 0; i < 10; i++ {
		go fmt.Println("和为:", readSum())
	}
	// 防止提前退出
	time.Sleep(5 * time.Second)
}
```

### 高效率决策完成时间-WaitGroup

相信你注意到了这段 time.Sleep(2 * time.Second) 代码，这是为了防止主函数 main 返回使用，一旦 main 函数返回了，程序也就退出了。因为我们不知道 10000 个执行 add 的协程和 10 个执行 readSum 的协程什么时候完全执行完毕，所以设置了一个比较长的等待时间。

但在实际的项目，如果运行一个较大的业务，需要运行的时间，我们无法预估，且并不合理。那我们该如何解决它？其实我们可以使用`WaitGroup`来进行阻塞主程序，防止退出。在这里相当实现了一个`生产者`与`消费者`模型

示例如下

```go
package main

import (
	"fmt"
	"math"
	"sync"
)

var (
	sum     int          // 全局资源sum
	mutex   sync.Mutex   // 互斥锁
	mutexRW sync.RWMutex // 读写锁
	round =  int(math.Pow(100, 2)) + 100
)

func add(i int) {
	// 互斥锁
	mutex.Lock()
	defer mutex.Unlock()
	sum += i
}

func readSum() int {
	//只获取读锁
	mutexRW.RLock()
	defer mutexRW.RUnlock()
	b := sum
	return b
}

func run() {
	var wg sync.WaitGroup
	//因为要监控110个协程，所以设置计数器为110
	//round =  int(math.Pow(100, 2)) + 100
	wg.Add(round)
	for i := 0; i < 100; i++ {
		go func() {
			//计数器值减1
			defer wg.Done()
			add(10)
		}()
	}
	for i := 0; i < int(math.Pow(100, 2)); i++ {
		go func() {
			//计数器值减1
			defer wg.Done()
			fmt.Println("和为:", readSum())
		}()
	}
	//一直等待，直到计数器值为0
	wg.Wait()
}

func main() {
	run()
}
```

> 注意
>
> - 在这里的生产者`round`与总消费者的和必须相等。
>
> - `sync.WaitGroup`是一个结构体，传递的时候要传递指针。

### 执行且只执行一次协程单例-sync.Once

在编程的很多场景下我们需要确保某些操作在高并发的场景下只执行一次，例如只加载一次配置文件、只关闭一次通道等。

Go语言中的`sync`包中提供了一个针对只执行一次场景的解决方案–`sync.Once`。

`sync.Once`只有一个`Do`方法，其签名如下：

```go
func (o *Once) Do(f func()) {}
// *备注：如果要执行的函数`f`需要传递参数就需要搭配闭包来使用。*
```

#### 加载配置文件示例

延迟一个开销很大的初始化操作到真正用到它的时候再执行是一个很好的实践。因为预先初始化一个变量（比如在init函数中完成初始化）会增加程序的启动耗时，而且有可能实际执行过程中这个变量没有用上，那么这个初始化操作就不是必须要做的。我们来看一个例子：

```go
var icons map[string]image.Image

func loadIcons() {
	icons = map[string]image.Image{
		"left":  loadIcon("left.png"),
		"up":    loadIcon("up.png"),
		"right": loadIcon("right.png"),
		"down":  loadIcon("down.png"),
	}
}

// Icon 被多个goroutine调用时不是并发安全的
func Icon(name string) image.Image {
	if icons == nil {
		loadIcons()
	}
	return icons[name]
}
```

多个`goroutine`并发调用Icon函数时不是并发安全的，现代的编译器和CPU可能会在保证每个`goroutine`都满足串行一致的基础上自由地重排访问内存的顺序。loadIcons函数可能会被重排为以下结果：

```go
func loadIcons() {
	icons = make(map[string]image.Image)
	icons["left"] = loadIcon("left.png")
	icons["up"] = loadIcon("up.png")
	icons["right"] = loadIcon("right.png")
	icons["down"] = loadIcon("down.png")
}
```

在这种情况下就会出现即使判断了`icons`不是nil也不意味着变量初始化完成了。考虑到这种情况，我们能想到的办法就是添加互斥锁，保证初始化`icons`的时候不会被其他的`goroutine`操作，但是这样做又会引发性能问题。

使用`sync.Once`改造的示例代码如下：

```go
var （
	icons map[string]image.Image 
	loadIconsOnce sync.Once
)

func loadIcons() {
	icons = map[string]image.Image{
		"left":  loadIcon("left.png"),
		"up":    loadIcon("up.png"),
		"right": loadIcon("right.png"),
		"down":  loadIcon("down.png"),
	}
}

// Icon 是并发安全的
func Icon(name string) image.Image {
	loadIconsOnce.Do(loadIcons)
	return icons[name]
}
```

#### 并发安全的单例

```go
package main

import (
	"fmt"
	"sync"
)

func doOnce() {
	// 声明协程单例
	var once sync.Once
	onceBody := func() {
		fmt.Println("Only Once Do")
	}

	// 建立搞并发场景
	for i := 0; i < 100; i++ {
		go func() {
			// 实现仅实现一次
			once.Do(onceBody)
		}()
	}

}

func main() {
	doOnce()
}
```

### 协控制随心所欲-sync.Cond

在 Go 语言中，sync.WaitGroup 用于最终完成的场景，关键点在于一定要等待所有协程都执行完毕。

而 sync.Cond 可以用于发号施令，一声令下所有协程都可以开始执行，关键点在于协程开始的时候是等待的，要等待 sync.Cond 唤醒才能执行。

sync.Cond 从字面意思看是条件变量，它具有阻塞协程和唤醒协程的功能，所以可以在满足一定条件的情况下唤醒协程，但条件变量只是它的一种使用场景。

sync.Cond 有三个方法，它们分别是：

1. **Wait**，阻塞当前协程，直到被其他协程调用 Broadcast 或者 Signal 方法唤醒，使用的时候需要加锁，使用 sync.Cond 中的锁即可，也就是 L 字段。
2. **Signal**，唤醒一个等待时间最长的协程。
3. **Broadcast**，唤醒所有等待的协程。

> 在调用 Signal 或者 Broadcast 之前，要确保目标协程处于 Wait 阻塞状态，不然会出现死锁问题。

下面我们以 10 个人赛跑为例来演示 sync.Cond 的用法。在这个示例中有一个裁判，裁判要先等这 10 个人准备就绪，然后一声发令枪响，这 10 个人就可以开始跑了，如下所示：

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

//10个人赛跑，1个裁判发号施令
func race(){
	cond :=sync.NewCond(&sync.Mutex{})
	var wg sync.WaitGroup
	wg.Add(11)
	for i:=0;i<10; i++ {
		go func(num int) {
			defer  wg.Done()
			fmt.Println(num,"号已经就位")
			cond.L.Lock()
			cond.Wait()//等待发令枪响
			fmt.Println(num,"号开始跑……")
			cond.L.Unlock()
		}(i)
	}
	//等待所有goroutine都进入wait状态
	time.Sleep(2*time.Second)
	go func() {
		defer  wg.Done()
		fmt.Println("裁判已经就位，准备发令枪")
		fmt.Println("比赛开始～")
		cond.Broadcast()//发令枪响
	}()
	//防止函数提前返回退出
	wg.Wait()
}

func main() {
	race()
}
```

### sync.Map

Go语言中内置的map不是并发安全的。请看下面的示例：

```go
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

上面的代码开启少量几个`goroutine`的时候可能没什么问题，当并发多了之后执行上面的代码就会报`fatal error: concurrent map writes`错误。

像这种场景下就需要为map加锁来保证并发的安全性了，Go语言的`sync`包中提供了一个开箱即用的并发安全版map–`sync.Map`。开箱即用表示不用像内置的map一样使用make函数初始化就能直接使用。同时`sync.Map`内置了诸如`Store`、`Load`、`LoadOrStore`、`Delete`、`Range`等操作方法。

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

