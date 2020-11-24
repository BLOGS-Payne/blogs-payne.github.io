---
title: Golang-Defer详解
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:39:13
---
## defer触发时机

> A "defer" statement invokes a function whose execution is deferred to the moment the surrounding function returns, either because the surrounding function executed a return statement, reached the end of its function body, or because the corresponding goroutine is panicking.

Go官方文档中对defer的执行时机做了阐述，分别是。

- 包裹defer的函数返回时
- 包裹defer的函数执行到末尾时        
- 所在的goroutine发生panic时
<!--more-->
## defer执行顺序

当一个方法中有多个defer时， defer会将要延迟执行的方法“压栈”，当defer被触发时，将所有“压栈”的方法“出栈”并执行。所以defer的执行顺序是LIFO的。

执行顺序如下

```sh
# 常规执行

语句1 -> 语句2 -> 语句3 -> 语句4

# 在语句2，语句3中添加defer后执行顺序如下

语句1 -> 语句4 -> 语句3(带defer) -> 语句2(带defer) 
```

## defer示例

```go
package main

import "fmt"

func main() {
	d()
}

func d() {
	fmt.Print("start" + "  ")
	fmt.Print("processing1" + "  ")
	fmt.Print("processing2" + "  ")
	fmt.Print("end" + "  ")
}
```

- 没有defer：start  -> processing1  ->  processing2  -> end 
- processing1、processing2 加入defer：start  -> end  -> processing2  -> processing1

## defer使用规则

### defer会实时解析参数

```go
package main

import "fmt"

func main() {
	i := 0
	defer fmt.Println(i)
	i ++
	return
}
// 0
```

> 这是因为虽然我们在defer后面定义的是一个带变量的函数: fmt.Println(i). 但这个变量(i)在defer被声明的时候，就已经确定其确定的值了

### defer的类栈执行

> 栈：先入后出

```go
package main

import "fmt"

func f1()  {
	fmt.Println(1)
}

func f2()  {
	fmt.Println(2)
}
func main() {
	defer f1()
	f2()
}

// 2\1
```

### defer可以读取有名返回值

```go
func c() (i int) {
   defer func() { i++ }()
   return 1
}

func main()  {
   fmt.Println(c())
}
// 2
```

> 在开头的时候，我们说过defer是在return调用之后才执行的。 这里需要明确的是defer代码块的作用域仍然在函数之内，结合上面的函数也就是说，defer的作用域仍然在c函数之内。因此defer仍然可以读取c函数内的变量(如果无法读取函数内变量，那又如何进行变量清除呢…)。
> 当执行return 1 之后，i的值就是1. 此时此刻，defer代码块开始执行，对i进行自增操作。 因此输出2.
