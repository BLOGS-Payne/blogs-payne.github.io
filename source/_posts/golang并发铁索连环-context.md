---
title: golang并发铁索连环-context
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2021-02-12 23:31:00
---

首先要和大家说声抱歉哈，由于工作上、生活上的某些琐事，以至于造成本节的断更。不过请不要悲伤。因为我在这期间也是做过详细的复习的。我相信一定会让你有更加深入的理解，同时也欢迎你向我提出不足。我们共同进步。话不多说，我相信你已经迫不及待了。还在等什么？let‘s GO

在本文中，我首先会介绍context是什么，它有什么作用，以及如何使用，其中还会参杂一点个人的理解，以及部分源码的了解。What are you waiting for?
<!--more-->
## Context：

> 来自官方文档

Context包定义了上下文类型，该类型在API边界之间以及进程之间传递截止日期，取消信号和其他请求范围的值

对服务器的传入请求应创建一个Context，而对服务器的传出调用应接受一个Context。

它们之间的函数调用链必须传播Context，可以选择将其替换为使用WithCancel，WithDeadline，WithTimeout或WithValue创建的派生Context。取消上下文后，从该上下文派生的所有上下文也会被取消。

WithCancel，WithDeadline和WithTimeout函数采用Context（父级）并返回派生的Context（子级）和CancelFunc。调用CancelFunc会取消该子代及其子代，删除父代对该子代的引用，并停止所有关联的计时器。未能调用CancelFunc会使子代及其子代泄漏，直到父代被取消或计时器触发。审核工具检查所有控制流路径上是否都使用了CancelFuncs。

使用上下文的程序应遵循以下规则，以使各个包之间的接口保持一致，并使静态分析工具可以检查上下文传播：

不要将上下文存储在结构类型中；而是将上下文明确传递给需要它的每个函数。 Context应该是第一个参数，通常命名为ctx：

```go
func DoSomething(ctx context.Context, arg Arg) error {
//  ... use ctx ...
}
```

即使函数允许，也不要传递nil Context。如果不确定使用哪个上下文，请传递context.TODO

仅将上下文值用于传递过程和API的请求范围数据，而不用于将可选参数传递给函数。

可以将相同的上下文传递给在不同goroutine中运行的函数。上下文可以安全地被多个goroutine同时使用



巴拉巴拉，说了一大堆，反正我一句没懂，当然我知道context是干嘛的，（尬～，不小心暴露了，学渣的本质），说说我的理解以及使用建议

- 对服务器的传入请求应创建一个Context，而对服务器的传出响应也应接受一个Context。
- 函数调用链必须传播Context，也可以选择将其替换为使用WithCancel，WithDeadline，WithTimeout或WithValue创建的派生Context(也就是子类context)。取消上下文后，从该上下文派生的所有上下文也会被取消

- Context 不要放在结构体中，要以参数的方式传递。
- Context 作为函数的参数时，要放在第一位，也就是第一个参数。
- 要使用 context.Background 函数生成根节点的 Context，也就是最顶层的 Context。
- Context 传值要传递必须的值，而且要尽可能地少，不要什么都传。
- **Context 多协程安全，可以在多个协程中放心使用。**

### go Context定义

Context 是Go 1.7 标准库引入 的标准库，中文译作“上下文”，准确说它是 goroutine 的上下文，包含 goroutine 的运行状态、环境、现场等信息。

使用context，我们可以轻松优雅的做到`取消goroutine`，`超时时间`,`运行截止时间`，`k-v`存储等。**它是并发安全的**

随着 context 包的引入，标准库中很多接口因此加上了 context 参数，例如 database/sql 包。context 几乎成为了并发控制和超时控制的标准做法。

> context.Context 类型的值可以协调多个 groutine 中的代码执行“取消”操作，并且可以存储键值对。最重要的是它是并发安全的。
> 与它协作的 API 都可以由外部控制执行“取消”操作，例如：取消一个 HTTP 请求的执行。

止于这些么？当然 不止,还有更多的骚操作，接下来让我们一起拿下它吧。



## 引入

> 为什么需要使用context，理由一
>
> 一个协程启动后，大部分情况需要等待里面的代码执行完毕，然后协程会自行退出。但需要让协程提前退出怎么办呢？

下面我们以一个小的示例，来逐渐了解context的妙用之一吧

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

func monitor(name string) {
	//开启for select循环，j进行后台监控
	for {
		select {
		default:
			fmt.Printf("Time: %v 监控者:%s, 正在监控...\n", time.Now().Unix(), name)
		}
		// sleep 1 second
		time.Sleep(time.Second * 5)
		fmt.Printf("%s 监控完成，一切正常，请指示 over...\n", name)
	}
}

func main() {
	var wg sync.WaitGroup
	// Define waiting group
	wg.Add(1)
	go func() {
		// Execution complete
		defer wg.Done()
		monitor("天眼")
	}()
	//Exit after waiting
	wg.Wait()
}
```

我们在这里实现了一个基本的groutine执行的case

> 我们定义了等待组`wait group`,防止协程提前退出。关于`wait group `可参考上一篇文章，golang并发控制的心应手。

他会周期性的运行，不断打印监控信息，例如

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnhog0u2cbj30iy06eq33.jpg" style="zoom:50%;" />

那么我们完成上述的那个需求`提前退出`,那么该怎么办呢？其中一个方法就是定义一个全局的sign，其他地方可以通过修改这个sign发出停止监控的指令。然后在协程中先检查这个变量，如果发现被通知关闭就停止监控，退出当前协程。从而实现可控制提前退出。示例代码如下

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

func monitor1(signCh chan bool, MonitoringPeriod time.Duration, name string, ) {
	//开启for select循环，一直后台监控
	for {
		select {
		case <-signCh:
			fmt.Println(name, "停止指令已收到，停止...")
			return
		default:
			fmt.Printf("Time: %v [监控者]:%s, 正在监控...\n", time.Now().Unix(), name)
		}
		time.Sleep(MonitoringPeriod * time.Second)
	}
}
func main() {
	var wg sync.WaitGroup
	signCh := make(chan bool) //sign 用来停止监控
	const MonitoringTime, MonitoringPeriod = 20, 2
	wg.Add(1)
	go func() {
		defer wg.Done()
		monitor1(signCh, MonitoringPeriod, "天眼")
	}()
	time.Sleep(MonitoringTime * time.Second) //实施监控时间
	signCh <- true                           //发停止指令
	wg.Wait()
}

```

这样我们就实现了，可控制话的groutine退出，但如果在新增几个定期的任务功能，那该如何是好？

管他的，我们先把这个弄懂了先。老夫先干为敬。首先我们先看程序运行图，如下

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnhpa8zjtfj315k0tsmxg.jpg" style="zoom:50%;" />

这个示例是使用 select+channel 的方式改造，实现了通过 channel 发送指令让监控狗停止，进而达到协程退出的目的。

首先我们定义了sync.WaitGroup，防止gorontine提前退出。signCh，他是一个bool值类型channel，用于发送sign后续的退出。

MonitoringTime，MonitoringPeriod，监控时间与监控周期。second。

然后创建goroutine执行select+channel。

## Go Context 初试体验

为 函数增加 signCh 参数，用于接收停止指令；

在 main 函数中，声明用于停止的 signCh，传递给 monitor1 函数，然后通过 signCh<-true 发送停止指令让协程退出。

通过 select+channel 让协程退出的方式比较优雅，以下几个问题也随之凸显

但如果我们希望做到同时取消很多个协程呢？

如果是定时取消协程又该怎么办？

这时候 select+channel 的局限性就凸现出来了，即使定义了多个 channel 解决问题，当然这个方式是可行的，但代码逻辑也会非常复杂、难以维护。

要解决这种复杂的协程问题，必须有一种可以跟踪协程的方案，只有跟踪到每个协程，才能更好地控制它们，这种方案就是 Go 语言标准库为我们提供的 Context，接下来我们体验一下它的强大之处吧。

```go
package main

import (
	"context"
	"fmt"
	"sync"
	"time"
)

func main() {
	var wg sync.WaitGroup
	const MonitoringTime, MonitoringPeriod = 20, 2
	wg.Add(1)
	// 定义一个等待的 `context`
	ctx, stop := context.WithCancel(context.Background())
	go func() {
		defer wg.Done()
		monitor2(ctx, MonitoringPeriod, "天眼")
	}()
	time.Sleep(MonitoringTime * time.Second) //先监控5秒
	stop()                                   //发停止指令
	wg.Wait()
}
func monitor2(ctx context.Context, MonitoringPeriod time.Duration, name string, ) {
	//开启for select循环，一直后台监控
	for {
		select {
		case <-ctx.Done():
			fmt.Println(name, "停止指令已收到，停止...")
			return
		default:
			fmt.Printf("Time: %v [监控者]:%s, 正在监控...\n", time.Now().Unix(), name)
		}
		time.Sleep(MonitoringPeriod * time.Second)
	}
}
```

是不是很优雅呢？确实如此，那么为什么也可以达到上面使用`channel`，的效果呢。那么我们去看一下它的具体实现部分呢，

### `WithCancel`

以下是WithCancel：具体实现部分代码

> WithCancel:返回具有新的“完成”通道的父级副本。当调用返回的cancel函数或关闭父上下文的Done通道时（以先发生的为准），将关闭返回的上下文的Done通道。取消此上下文将释放与其关联的资源，因此在此上下文中运行的操作完成后，代码应立即调用cancel。

```go
func WithCancel(parent Context) (ctx Context, cancel CancelFunc) {
	if parent == nil {
		panic("cannot create context from nil parent")
	}
	c := newCancelCtx(parent)
	propagateCancel(parent, &c)
	return &c, func() { c.cancel(true, Canceled) }
}
```

除了WithCancel，之外还有`WithDeadline`,`WithTimeout`,`WithValue`,首先我们来继续看看`WithDeadline`具体实现，以及使用技巧吧

### `WithTimeout`

```go
func WithDeadline(parent Context, d time.Time) (Context, CancelFunc) {
	if parent == nil {
		panic("cannot create context from nil parent")
	}
	if cur, ok := parent.Deadline(); ok && cur.Before(d) {
		// The current deadline is already sooner than the new one.
		return WithCancel(parent)
	}
	c := &timerCtx{
		cancelCtx: newCancelCtx(parent),
		deadline:  d,
	}
	propagateCancel(parent, c)
	dur := time.Until(d)
	if dur <= 0 {
		c.cancel(true, DeadlineExceeded) // deadline has already passed
		return c, func() { c.cancel(false, Canceled) }
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.err == nil {
		c.timer = time.AfterFunc(dur, func() {
			c.cancel(true, DeadlineExceeded)
		})
	}
	return c, func() { c.cancel(true, Canceled) }
}

func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc) {
	return WithDeadline(parent, time.Now().Add(timeout))
}
```

> 取消此上下文将释放与之关联的资源，因此在此上下文中运行的操作完成后，代码应立即调用cancel：

来看一下具体如何使用吧，示例如下

```
package main

import (
	"context"
	"fmt"
	"time"
)

func main() {
	// 创建一个子节点的context,3秒后自动超时
	const MonitoringTime, MonitoringPeriod = 20, 2
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
	go func() {
		monitor4(ctx, MonitoringPeriod, "天眼")
		fmt.Println("退出时间",time.Now().Unix())
	}()
	time.Sleep(MonitoringTime * time.Second)
	cancel()
}

func monitor4(ctx context.Context, MonitoringPeriod time.Duration, name string, ) {
	//开启for select循环，一直后台监控
	for {
		select {
		case <-ctx.Done():
			fmt.Println(name, "停止指令已收到，停止...")
			return
		default:
			fmt.Printf("Time: %v [监控者]:%s, 正在监控...\n", time.Now().Unix(), name)
			time.Sleep(MonitoringPeriod * time.Second)
		}
	}
}
```

> 以上会有两种情况发生退出，
>
> 一、程序main退出，全局退出
>
> 二、我们定义的timeout退出

他们的基本性质与使用我们就简单的过了一遍，下面让我们来个小结。

WithCancel(parent Context)：生成一个可取消的 Context。

WithDeadline(parent Context, d time.Time)：生成一个可定时取消的 Context，**参数 d 为定时取消的具体时间。**

WithTimeout(parent Context, timeout time.Duration)：生成一个可超时取消的 Context，**参数 timeout 用于设置多久后取消**

WithValue(parent Context, key, val interface{})：生成一个可携带 key-value 键值对的 Context。

是不是发现，其实也没有那么难呢？当然，它本来就很简单，接下来我们来点更刺激的，同时取消多goroutine，啥也不说了，上～

```
package main

import (
	"context"
	"fmt"
	"strconv"
	"sync"
	"time"
)

var wg sync.WaitGroup

func main() {
	const MonitoringTime, MonitoringPeriod = 20, 2
	wg.Add(1)
	ctx, stop := context.WithCancel(context.Background())
	for i := 0; i < 3; i++ {
		go monitor6(ctx, MonitoringPeriod, strconv.Itoa(i))
	}
	time.Sleep(MonitoringTime * time.Second) //先监控5秒
	stop()                                   //发停止指令
	wg.Wait()
}
func monitor6(ctx context.Context, MonitoringPeriod time.Duration, name string, ) {
	defer wg.Done()
	//开启for select循环，一直后台监控
	for {
		select {
		case <-ctx.Done():
			fmt.Println(name, "停止指令已收到，停止...")
			return
		default:
			fmt.Printf("Time: %v [监控者]:天眼%s, 正在监控...\n", time.Now().Unix(), name)
		}
		time.Sleep(MonitoringPeriod * time.Second)
	}
}
```

> Time: 1612948086 [监控者]:天眼0, 正在监控...
> Time: 1612948086 [监控者]:天眼1, 正在监控...
> Time: 1612948086 [监控者]:天眼2, 正在监控...
> ... ...
> Time: 1612948104 [监控者]:天眼2, 正在监控...
> Time: 1612948104 [监控者]:天眼0, 正在监控...
> Time: 1612948104 [监控者]:天眼1, 正在监控...
> 2 停止指令已收到，停止...
> 1 停止指令已收到，停止...
> 0 停止指令已收到，停止...

你以为这样就完了么，这只是一个小的case，它还可以管理子节点。其管理与树形结构十分的相似。

除此之外还可以传递值，接下来让我们来看看吧

```go
package main

import (
	"context"
	"fmt"
	"sync"
	"time"
)

func main() {
	var wg sync.WaitGroup
	ctx, stop := context.WithCancel(context.Background())
	ctxVal := context.WithValue(ctx, "user", "payne")
	wg.Add(1)
	go func() {
		defer wg.Done()
		getValue(ctxVal)
	}()
	time.Sleep(3)
	stop()
	wg.Wait()
}

func getValue(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			fmt.Println("exit")
			return
		default:
			user := ctx.Value("user")
			fmt.Println("【获取用户】", "用户为：", user)
			time.Sleep(1 * time.Second)
		}
	}
}
```

输出如下

> 【获取用户】 用户为： payne
> exit...

总结：

Context为我们主要定义四种方法`WithDeadline`,`WithTimeout`,`WithValue`,`WithCancel`,从而达到控制goroutine的目的，但却不仅限于我们以上介绍的那样(只介绍了一层，其实可以是多层。形成多对多的关系)，它更深层次的使用你可以想象成多叉树的情况。



context，这一篇就暂且完成啦，期待下一篇。并发模式

并发模式，故名思义。他与设计模式一样，即使用goroutine并发的一些总结。

我将与你探讨

- `Goroutine WorkPool`:让我们随影所欲的控制创建gototine的数量，且复用。
- Pipeline 模式，他像工厂流水线一般，我们将是这将其拆分归并
- 扇出扇入模式，在pipline的基础上对耗时较长的进行处理
- Futures 模式，Pipeline 流水线模式中的工序是相互依赖的，但是在我们的实际需求中，也有大量的任务之间相互独立、没有依赖，所以为了提高性能，这些独立的任务就可以并发执行。

期待～