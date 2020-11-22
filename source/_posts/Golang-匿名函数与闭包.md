---
title: Golang-匿名函数与闭包
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:37:44
---
## 匿名函数

### 什么是匿名函数

没有名字的函数，由于函数中不可定义`有名字`的函数，所有出现匿名函数，匿名函数常使用于函数中定义函数
<!--more-->
### 匿名函数的定义

```go
func(参数) (返回值){
    函数体
}
```

> 其中参数、返回值视情况酌情加入

简单的示例

```go
package main

import "fmt"

func f1(x, y int) int {
	return x + y
}

var f2 = func(x, y int) int {
	return x * y
}

func main() {
	fmt.Println(f1(2, 2))   // 4
	fmt.Println(f2(2, 2))   // 4
}
```

> f1:普通的函数有参数、返回值。直接使用`f1()`调用即可
>
> f2:匿名函数，有参数，有返回值。变量f2,为函数类型，使用`f2()`可调用

## 闭包

闭包指的是一个函数和与其相关的引用环境组合而成的实体。`闭包=函数+引用环境`。 示例如下

```go
package main

import "fmt"

func main() {
	fmt.Println(f1()(1, 2)) 
}

func f1() func(x int, y int) int {
	return func(x, y int) int{
		return x + y
	}
}
// 3
```

> 可以简单理解为函数里面包含函数(多为匿名函数)

### 深入理解闭包

闭包常常与作用域之间的关系慎密，首先让我们回顾一下作用域，作用域的范围由上到下分为这几种：

- 全局：即全局均可调用，当在函数中调用修改后并不会直接影响
- 函数作用域：仅在此函数中进行有效
- 代码块作用域：仅在此代码块中有效，用完即释放。且外部访问不到此变量(常量)

> 除全局外，二者均是相对的概念，不必过于拘泥。

### 生命周期

一旦进行嵌套的，很多朋友就会懵，那么我们进行几个case来尝试一下。如下

```go
package main

import "fmt"

func f1() func(int) int {
	var x int
	return func(y int) int {
		x += y
		return x
	}
}

func main() {
	f := f1()
	fmt.Println(f(11))
	fmt.Println(f(22))
	fmt.Println(f(33))
	fmt.Println(f(44))
	fmt.Println(f(55))
}

// 11,33,66,110,165
```

> 变量`f`是一个函数并且它引用了其外部作用域中的`x`变量，此时`f`就是一个闭包。 在`f`的生命周期内，变量`x`也一直有效。

```go
package main

import "fmt"

func f2(x int) func(int) int {
	return func(y int) int {
		x += y
		return x
	}
}
func main() {
	f := f2(20)
	fmt.Println(f(21))
	fmt.Println(f(22))
	fmt.Println(f(23))
	fmt.Println(f(24))
}

```

> 变量`f`是一个函数并且它引用了其外部作用域中的`x`变量，此时`f`就是一个闭包。 在`f`的生命周期内，变量`x`也一直有效。



### 装饰器函数

学其他语言的同学，一定听说过甚至使用过`装饰器`。那让我们使用golang来实现装饰器的这个功能，如下：

```go
package main

import (
	"fmt"
	"time"
)

func Decorator(f func()) {
	fmt.Printf("The start Time: %s\n", time.Now())
	f()
	fmt.Printf("The end Time: %s\n", time.Now())
}
func Hw() {
	fmt.Println("HelloWorld")
	time.Sleep(20 * time.Second)
}
func main() {
	//fmt.Println(f1()(1, 2))
	Decorator(Hw)
}

```

> 输入效果如下：
>
> The start Time: 2020-11-17 19:24:23.969042 +0800 CST m=+0.000082415
> helloWorld
> The end Time: 2020-11-17 19:24:43.974545 +0800 CST m=+20.005388822

闭包其实并不复杂，只要牢记`闭包=函数+引用环境(变量作用域)`

