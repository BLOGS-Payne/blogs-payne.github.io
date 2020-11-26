---
title: Golang-接口(interface)
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-26 21:57:37
---

**接口是一种类型**

最初的`int`、`string`、`bool`,再到稍微复杂的`Array`、`Map`、`Slice`。他们都称之为基础数据类型，以及到多维度符合类型的`结构体`。以及今日咱们所需要学习的`接口`。

在Go语言编程中，Go(强类型语言)，也就是说必须是一种具体的类型，当我们需要只关注能调用它的什么方法，而不关注它是什么类型,该怎么办呢？

Go语言中为了解决类似上面的问题，就设计了接口这个概念。接口区别于我们之前所有的具体类型，接口是一种抽象的类型。当你看到一个接口类型的值时，你不知道它是什么，唯一知道的是通过它的方法能做什么。
<a id="jump_1">

#### 疑问：只关心调用的函数，而不关注其类型
</a>
<!--more-->
```go
package main

import (
	"fmt"
)

type person struct{}
type dog struct{}

func (p person) speak() {
	fmt.Println("shit~")
}

func (d dog) speak() {
	fmt.Println("汪汪汪~")
}

func do() {
	// 接受一个参数，进来什么，什么就要speak
	x.speak()
}
func main() {

}
```



### 接口的定义

```go
type 接口类型名 interface{
    方法名1( 参数列表1，参数列表2 ... ) (返回值列表1,返回值列表2 ...)
    方法名2( 参数列表1，参数列表2 ...) (返回值列表1,返回值列表2 ...)
   	... ...
}
```

> - 接口名：使用`type`将接口定义为自定义的类型名。Go语言的接口在命名时，一般会在单词后面添加`er`，如有写操作的接口叫`Writer`，有字符串功能的接口叫`Stringer`等。接口名最好要能突出该接口的类型含义。
> - 方法名：当方法名首字母是大写且这个接口类型名首字母也是大写时，这个方法可以被接口所在的包（package）之外的代码访问。
> - 参数列表、返回值列表：参数列表和返回值列表中的参数变量名可以省略。

那么为了解决以上[问题](#jump_1)，我们可以定义接口。实现如下

```go
package main

import (
	"fmt"
)

// 接口
type speak interface {
	speak()
}

// 结构体
type person struct{}
type dog struct{}

// 结构体person的实现
func (p person) speak() {
	fmt.Println("shit~")
}

// 结构体dog 实现
func (d dog) speak() {
	fmt.Println("汪汪汪~")
}

func do(s speak) {
	// 接受一个参数，进来什么，什么就调用它的speak
	s.speak()
}
func main() {
	var p1 person
	var d1 dog

	do(p1)
	do(d1)
}
// shit~
// 汪汪汪~
```

### 实现接口的条件

一个变量如果实现了接口中全部的方法，那么此变量就实现了这个接口。

接口是一个**需要实现的类型(方法列表)**。

```go
package main

import (
	"fmt"
)

// 接口
type speak interface {
	speak()
}

// 结构体
type person struct{}
type dog struct{}

// 结构体person的实现
func (p person) speak() {
	fmt.Println("shit~")
}

// 结构体dog 实现
func (d dog) speak() {
	fmt.Println("汪汪汪~")
}

func do(s speak) {
	// 接受一个参数，进来什么，什么就调用它的speak
	s.speak()
}
func main() {
	var p1 person
	var d1 dog

	// 定义一个接口类型：speak的变量speaks
	var speaks speak
	speaks = d1
	speaks = p1
	fmt.Print(speaks)
}
// {}
```



### 接口类型变量

接口类型变量能够存储所有实现了该接口的实例。

```go
package main

import "fmt"

type say interface {
	say()
}

type cats struct{}
type dogs struct{}

func (c cats) say() {
	fmt.Println("Fish~")
}
func (d dogs) say() {
	fmt.Print("Shit~")
}
func sayer(s say) {
	// 接受一个参数，进来什么，什么就调用它的speak
	s.say()
}
func main() {
	var x say
	a := cats{}
	b := dogs{}
	x = a
	x.say()
	x = b
	x.say()
}

```

### 值的接受者与指针接收者实现接口

#### 值的接受者实现接口

```go
package main

import "fmt"

type moving interface {
	move()
}
type dog struct{}
type cat struct{}

func (d dog) move() {
	fmt.Println("丁丁～")
}

func (c cat) move() {
	fmt.Println("喵呜～")
}
func move(m moving) {
	// 接受一个参数，进来什么，什么就调用它的speak
	m.move()
}
func main() {
	var x moving
	a := dog{}
	b := &cat{}
	x = a
	x.move()
	x = b
	x.move()
}
```

从上面的代码中我们可以发现，使用值接收者实现接口之后，不管是dog结构体还是结构体指针*dog类型的变量都可以赋值给该接口变量。因为Go语言中有对指针类型变量求值的语法糖，cat指针`x`内部会自动求值`(* ** x)`

#### 指针接收者实现接口

同样的代码我们再来测试一下使用指针接收者有什么区别：

```go
package main

import "fmt"

type moving interface {
	move()
}
type dog struct{}
type cat struct{}

func (d dog) move() {
	fmt.Println("丁丁～")
}

func (c *cat) move() {
	fmt.Println("喵呜～")
}
func move(m moving) {
	// 接受一个参数，进来什么，什么就调用它的speak
	m.move()
}
func main() {
	var x moving
	a := dog{} // a是dog类型
	x = a      // 可以接收dog类型
	x.move()
	b := cat{}
	x = b // 不可以接受指针类型
	x.move()
}
// # command-line-arguments
// ./pointer.go:28:4: cannot use b (type cat) as type moving in assignment:
// cat does not implement moving (move method has pointer receiver)
```
