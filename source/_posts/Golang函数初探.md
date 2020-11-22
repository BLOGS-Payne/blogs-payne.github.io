---
title: Golang函数初探
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:36:08
---

本节将探讨golang 的函数部分

- 函数的结构分析函数的定义
- 函数的层次
- 函数的作用域
- 匿名函数
- 立即执行函数
- 闭包

## 函数存在的意义

- 函数是一段代码的封装
- 使用函数可以使结构更加清晰与简洁
<!--more-->
### 代码重用

函数存在的一个非常明显的作用和意义就是代码重用。没有代码重用，编程人员会被活活累死，费尽千辛万苦写出来的代码只能使用一次，有类似的功能需要完成时，不得不重头开始写起。

### 有助于我们思考

在函数设计上有一个原则，叫做单一职能原则，意思是说，一个函数只完成一个特定的功能。我以冒泡排序来向你解释什么叫做到单一职能原则，并向你展示函数是如何帮助我们思考问题的。





## 初探Golang函数

不知道你是否还记得我们写的第一个代码`HelloWorld`，来我们对他进行分析一下

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello，World")
}

```

它由以下几部分构成：

- 任何一个函数的定义，都有一个 func 关键字，用于声明一个函数，就像使用 var 关键字声明一个变量一样。

- 紧跟的 main 是函数的名字，命名符合 Go 语言的规范即可，不能以数字开头。

- main 函数名字后面的一对括号 () 是不能省略的，括号里可以定义函数使用的参数，这里的 main 函数没有参数，所以是空括号 () 。

- 括号 () 后还可以有函数的返回值，因为 main 函数没有返回值，所以这里没有定义。

-  {} 函数体，你可以在函数体里书写代码，写该函数自己的业务逻辑。

```go
package main		// 主函数入口，表面可执行文件。若不是main，则只能被调用

import "fmt"		// 导包

// func 关键字定义函数，与Python中的def效果一致
func main() {		 // main函数名（主函数）入口，括号中为形参。没有可不写
// 业务代码
}
```

> 形参：即形式参数，只与内部调用有关。
>
> 当调用函数的时候，为位置为准，对应对应

## 初探函数

### 常见函数

```go
package main

import "fmt"

// 无参数、无返回值
func t1() {
	fmt.Println("你好，我叫Payne") // 你好，我叫Payne
}

// 无参数，有返回值（有返回值必须在后面写上返回值类型

// 返回值，则需要多个类型参数
func t2() int {

	return 3
}

// 有参数，有返回值。同一类型可使用逗号隔开在最后写类型
func t3(x, y int) int {
	return x + y
}

// 匿名函数:最显著的特征是没有函数名，可以使用变量来接受它

// # 在main 中使用a()即可调用此韩素
var a  = func() int{
	return 10
}

// 立即执行函数
func() {
		fmt.Println("a")
	}()

func main() {
	t1() // 调用函数
	// 返回值需要我们打印，才能显示出来
	fmt.Println(t2()) // 3
}


```

### 函数结构分析

由于main函数的定义并不利于理解golang的函数，那么我们自定义一个函数。如下：

```go
package main

import "fmt"

func main() {
  // num(1,2) 调用函数
	fmt.Println(num(1, 2))		// 调用函数，并打印 2，1
}

func num(i, j int) (int, int) {
	j, i = i, j
	return i, j
}

// 定义多个参数与返回值的函数
package main

import "fmt"

func main() {
	fmt.Println(sum(1, 2, 3, 4, 5))
}

func sum(params ...int) int {
	sum := 0
	for _, i := range params {
		sum += i
	}
	return sum
}
// 多个参数,多个参数的内部其实就是切片类型[...]int
```

> 注意，如果定义的函数需要传递的参数既有普通参数，也有可变参数，那么可变参数一定要放在参数列表的最后一个，比如 sum1(tip string,params …int) ，params 可变参数一定要放在最末尾。

### 函数进阶

全局与局部：（变量与常量）

> 全局：故名思义，全局均可访问的函数
>
> 局部：故名思义，仅有局部才可访问的变量
>
> 代码块作用域：仅在此代码块中
>
> 二则的区分：全局变量常常直接在代码的函数部分的上面定义，而局部变量仅在函数中定义。且不可被函数外部的访问

golang的寻找变量的方式体现可简单理解为`就近原则`；示例如下

```go
package main

import "fmt"

var aA = 1

func f1() {
	aA := 2
	fmt.Println(aA)
}

func f2() {
	fmt.Println(aA)
}

func main() {
	f1()    // 2
	f2()    // 1
}
```

> 在函数f1中对变量`aA`，进行修改。而不影响全局的`aA`.且调用时先从函数内寻找，没有则往上。
>
> 不仅函数中有全局、局部的概念，例如循环中也有此概念

```
package main

import "fmt"

func f1() {
	for i := 0; i < 10; i++ {
		fmt.Print(i)
	}
	fmt.Println()
}

func f2() {
	j := 0
	for ; j < 10; j++ {
		fmt.Print(j)
	}
}

func main() {
	f1() 
	f2() 
}
```

> 二者的区别为，变量`i`使用完成后会立马销毁，释放内存。而变量`j`，则会一直存在

### 函数类型与变量

#### 定义函数类型

我们可以使用`type`关键字来定义一个函数类型，具体格式如下：

```go
type calculation func(int, int) int
```

上面语句定义了一个`calculation`类型，它是一种函数类型，这种函数接收两个int类型的参数并且返回一个int类型的返回值。

简单来说，凡是满足这个条件的函数都是calculation类型的函数，例如下面的add和sub是calculation类型。

```go
func add(x, y int) int {
	return x + y
}

func sub(x, y int) int {
	return x - y
}
```

add和sub都能赋值给calculation类型的变量。

```go
var c calculation
c = add
```

#### 函数类型变量

我们可以声明函数类型的变量并且为该变量赋值：

```go
func main() {
	var c calculation               // 声明一个calculation类型的变量c
	c = add                         // 把add赋值给c
	fmt.Printf("type of c:%T\n", c) // type of c:main.calculation
	fmt.Println(c(1, 2))            // 像调用add一样调用c

	f := add                        // 将函数add赋值给变量f1
	fmt.Printf("type of f:%T\n", f) // type of f:func(int, int) int
	fmt.Println(f(10, 20))          // 像调用add一样调用f
}
```
