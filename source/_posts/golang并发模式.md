---
title: golang并发模式
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2021-02-12 23:31:07
---

并发模式并不是一种函数的运用、亦或者实际存在的东西。他是前人对于并发场景的运用总结与经验。他与23中设计模式一样。好啦，话不多说。开干

无论是如何厉害的架构还是编程方式，我始终相信都是从零开始，不断的抽象，不断的迭代的。抽象思维对于我们尤为重要。那么我们也带着这样的一个疑问。思考到底什么是抽象

首先我们将要学习的是`work pool`模式
<!--more-->
## work pool

不知道大家是否在go并发的时候遇见过以下几个问题或者想法

- goroutine的数量控制可能并不是那么称心如意
  - goroutine，创造过多，造成资源浪费。且并发效果也并非那么好。他正如正态分布那样。到达某个极点所带来的收益将会下降
- goroutine复用的问题，往往一个goroutine都只处理了一个任务。不断的创建与删除
- 甚至更多。。。

workpool，首先分析以上问题，我个人总结都以上其实是一个问题，groutine与任务死死的绑定，并没有进行解耦。比如像这样。

```go
// example
package main

import (
	"fmt"
	"time"
)

func exs(accept <-chan int, recipient chan<- int) {
	for result := range accept {
		fmt.Println("Received only sent channel a:", result)
		recipient <- result + 2
	}

	//fmt.Println("Send Only", recipient)
}

func main() {
	startTime := time.Now()
	ch := make(chan int, 10)
	for i := 0; i < 100; i++ {
		go func(ch <-chan int) {
			time.Sleep(time.Second * 5)
			fmt.Println(<-ch)
		}(ch)
		ch <- i
	}
```

那么我们来改造一下，然后进行代码剖析。代码如下

```
package main

import (
	"fmt"
	"time"
)

func work(id int, jobs <-chan int, result chan<- int) {
	for j := range jobs {
		fmt.Println("Worker [ID]", id, "Start Process JoB [Id]", j)
		time.Sleep(time.Second * 2)
		//fmt.Println("Working, will Spend 2 s")
		fmt.Println("Worker [ID]", id, "Carry Process JoB [Id]", j)
		result <- j * 2
	}

}

func main() {
	const jobNumber = 1000
	const workerNumber = 100

	jobs := make(chan int, workerNumber)
	result := make(chan int, jobNumber)

	// Create Worker(start Goroutines)
	for w := 0; w <= workerNumber; w++ {
		go work(w, jobs, result)
	}

	// arrange work
	for j := 0; j <= jobNumber; j ++ {
		jobs <- j
	}

	// 获取结果
	for r := 0; r <= jobNumber; r ++ {
		<- result
	}
}
```

work pool的精髓在于将任务，与groutine进行分离。只关心初始的任务与结果。是不是与函数式编程很像呢？我也这么觉得，嘻嘻

来吧，我们剖析一下代码

1. 首先我们定义了两个常量（建议是常量），`jobNum`与`workerNumber`，故名思义他们分别是任务数量，以及工人数量。你可以将他们看出生产者与消费者。
2. 我们定义了两个channel，他们作为我们发送指令与获取结果的通道。记得加缓存哦，否则将造成死锁
3. 最后就是分别定义消费者-`groutine`，生产者jobNumber，然后传递任务进入goroutine。然后我们就只需要得到结果就好啦

nice，虽然很简单。但也有无限的可能性哦。你还可以进一步抽象，变成一个通用的goroutine pool。

## Pipeline 模式

Pipeline 模式也称为流水线模式，模拟的就是现实世界中的流水线生产。

从技术上看，每一道工序的输出，就是下一道工序的输入，在工序之间传递的东西就是数据，这种模式称为流水线模式，而传递的数据称为数据流。下面我们用代码模拟`柴火烧饭的`过程

```
package main

import "fmt"

func main() {
	combust := wash(10)
	rice := combustion(combust)
	packs := open(rice)
	//输出测试，看看效果
	for p := range packs {
		fmt.Println(p)
	}
}

func wash(n int) <-chan string {
	out := make(chan string)
	go func() {
		defer close(out)
		for i := 1; i <= n; i++ {
			out <- fmt.Sprint("洗米", i)
		}
	}()
	return out
}
func combustion(in <-chan string) <-chan string {
	out := make(chan string)
	go func() {
		defer close(out)
		for c := range in {
			out <- "烧饭(" + c + ")"
		}
	}()
	return out
}

func open(in <-chan string) <-chan string {
	out := make(chan string)
	go func() {
		defer close(out)
		for c := range in {
			out <- "开锅(" + c + ")"
		}
	}()
	return out
}

```

> 开锅(烧饭(洗米1))
> 开锅(烧饭(洗米2))
> 开锅(烧饭(洗米3))
> 开锅(烧饭(洗米4))
> 开锅(烧饭(洗米5))
> 开锅(烧饭(洗米6))
> 开锅(烧饭(洗米7))
> 开锅(烧饭(洗米8))
> 开锅(烧饭(洗米9))
> 开锅(烧饭(洗米10))

首先，我为什么一定强调是柴火烧饭呢，难道柴火香一点？那可不，必须的。

其实再这里，我们需要思考一个问题，什么是可异步的，什么是不可异步的？

> 拓展：
>
> 可异步：例如网络请求，发送网络请求后，立马发送下一个。尽量减少网络io阻塞，从而提高效率。可前提是，网络io阻塞可以不用等待
>
> 不可异步：也就是说我们每一步都必须参与其中，计算机它无法独自去完成。例如柴火烧饭，没柴火咋烧饭，魔法么。当然你硬要说火烧一次就一直可以不需要人去干预，那咱也没办法了不是

在这里，生产者与消费者可能并不像之前那么分的那么开了，首先 

洗米（生产者）

烧饭（消费者、生产者）

开锅（消费者）

这种模式称为流水线模式，而传递的数据称为数据流

## 分治模式

就像前面所说那样，每一道必须依靠前面完成了才能进行下一步，但我们发现其中烧饭或者太慢了，我们可以分而治之，然后合并。也可以达到我们需要的效果。

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

func main() {
	combust := wash(10)
	rice1 := combustion(combust)
	rice2 := combustion(combust)
	rice3 := combustion(combust)
	rice := merge(rice1, rice2, rice3)
	packs := open(rice)
	//输出测试，看看效果
	for p := range packs {
		fmt.Println(p)
	}
}

func wash(n int) <-chan string {
	out := make(chan string)
	go func() {
		defer close(out)
		for i := 1; i <= n; i++ {
			out <- fmt.Sprint("洗米", i)
		}
	}()
	return out
}
func combustion(in <-chan string) <-chan string {
	out := make(chan string)
	go func() {
		defer close(out)
		time.Sleep(2)
		for c := range in {
			out <- "烧饭(" + c + ")"
		}
	}()
	return out
}

func open(in <-chan string) <-chan string {
	out := make(chan string)
	go func() {
		defer close(out)
		for c := range in {
			out <- "开锅(" + c + ")"
		}
	}()
	return out
}

func merge(ins ...<-chan string) <-chan string {
	var wg sync.WaitGroup
	out := make(chan string)
	//把一个channel中的数据发送到out中
	p := func(in <-chan string) {
		defer wg.Done()
		for c := range in {
			out <- c
		}
	}
	wg.Add(len(ins))
	//扇入，需要启动多个goroutine用于处于多个channel中的数据
	for _, cs := range ins {
		go p(cs)
	}
	//等待所有输入的数据ins处理完，再关闭输出out
	go func() {
		wg.Wait()
		close(out)
	}()
	return out
}
```

## Futures 模式

Pipeline 流水线模式中的工序是相互依赖的，上一道工序做完，下一道工序才能开始。但是在我们的实际需求中，也有大量的任务之间相互独立、没有依赖，所以为了提高性能，这些独立的任务就可以并发执行。

举个例子，比如我打算自己做顿火锅吃，那么就需要洗菜、烧水。洗菜、烧水这两个步骤相互之间没有依赖关系，是独立的，那么就可以同时做，但是最后做火锅这个步骤就需要洗好菜、烧好水之后才能进行。这个做火锅的场景就适用 Futures 模式。

Futures 模式可以理解为未来模式，主协程不用等待子协程返回的结果，可以先去做其他事情，等未来需要子协程结果的时候再来取，如果子协程还没有返回结果，就一直等待

Futures 模式下的协程和普通协程最大的区别是可以返回结果，而这个结果会在未来的某个时间点使用。所以在未来获取这个结果的操作必须是一个阻塞的操作，要一直等到获取结果为止。

如果你的大任务可以拆解为一个个独立并发执行的小任务，并且可以通过这些小任务的结果得出最终大任务的结果，就可以使用 Futures 模式。

## Referer

22讲通关go语言-飞雪无情


