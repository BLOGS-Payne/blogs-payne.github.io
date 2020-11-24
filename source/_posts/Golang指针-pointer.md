---
title: Golang指针-pointer
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:13:59
---
区别于C/C++中的指针，Go语言中的指针不能进行偏移和运算，是安全指针。

要搞明白Go语言中的指针需要先知道3个概念：指针地址、指针类型和指针取值。
<!--more-->
## Go语言中的指针

> 任何程序数据载入内存后，在内存都有他们的地址，这就是指针。而为了保存一个数据在内存中的地址，我们就需要指针变量。
>
> 比如，“永远不要高估自己”这句话，我想把它写入程序中，程序一启动这句话是要加载到内存（假设内存地址0x123456），我在程序中把这段话赋值给变量`A`，把内存地址赋值给变量`B`。这时候变量`B`就是一个指针变量。通过变量`A`和变量`B`都能找到我的座右铭。
>
> Go语言中的指针不能进行偏移和运算，因此Go语言中的指针操作非常简单，我们只需要记住两个符号：`&`（取地址）和`*`（根据地址取值）。
>
> 每个变量在运行时都拥有一个地址，这个地址代表变量在内存中的位置。Go语言中使用`&`字符放在变量前面对变量进行“取地址”操作。 Go语言中的值类型（int、float、bool、string、array、struct）都有对应的指针类型，如：`*int`、`*int64`、`*string`等。

取变量指针的语法如下：

```go
ptr := &v    // v的类型为T
```

> - v:代表被取地址的变量，类型为`T`
> - ptr:用于接收地址的变量，ptr的类型就为`*T`，称做T的指针类型。*代表指针。

注意：`&`仅对基本类型适用基本类型(包含int\bool\string，不包含数组、切片等),`fmt.printf(%p)`使用于所有类型。


示例如下：

```go
package main

import (
	"fmt"
	"reflect"
)

func main() {
	a := 10
	b := &a     // & 取地址值操作
	c := *b     // * 根据地址值取值操作
	fmt.Println(a, reflect.TypeOf(a))  // 10 int
	// 每次的地址值不一定，若打印出0x开头的即成功获取到该变量地址值
	fmt.Println(b, reflect.TypeOf(b))  // 0xc000014080 *int
	fmt.Println(c, reflect.TypeOf(c))  // 10 int
}
```

> **总结：** 取地址操作符`&`和取值操作符`*`是一对互补操作符，`&`取出地址，`*`根据地址取出地址指向的值。
>
> 变量、指针地址、指针变量、取地址、取值的相互关系和特性如下：
>
> - 对变量进行取地址（&）操作，可以获得这个变量的指针变量。
> - 指针变量的值是指针地址。
> - 对指针变量进行取值（*）操作，可以获得指针变量指向的原变量的值。

## Make or New

导入

> ```go
> var a *int
> *a = 10
> fmt.Println(*a)
> 
> var b map[string]int
> b["Payne"] = 10
> fmt.Println(b)
> // runtime error: invalid memory address or nil pointer dereference
> ```
>
> 执行上面的代码会引发panic，为什么呢？ 
>
> 在Go语言中对于引用类型的变量，我们在使用的时候不仅要声明它，还要为它分配内存空间，否则我们的值就没办法存储。
>
> 而对于值类型的声明不需要分配内存空间，是因为它们在声明的时候已经默认分配好了内存空间。要分配内存，就引出来今天的new和make。 Go语言中new和make是内建的两个函数，主要用来分配内存。

### new

new是一个内置的函数，它的函数签名如下：

```go
func new(Type) *Type

// Type表示类型，new函数只接受一个参数，这个参数是一个类型
// *Type表示类型指针，new函数返回一个指向该类型内存地址的指针。
```

```go
func main() {
	a := new(int)
	b := new(bool)
	fmt.Printf("%T\n", a) // *int
	fmt.Printf("%T\n", b) // *bool
	fmt.Println(*a)       // 0
	fmt.Println(*b)       // false
}	
```

> 示例代码中`var a *int`只是声明了一个指针变量a但是没有初始化，指针作为引用类型需要初始化后才会拥有内存空间，才可以给它赋值。应该按照如下方式使用内置的new函数对a进行初始化之后就可以正常对其赋值了

```go
func main() {
		var a *int
		a = new(int)
		*a = 10
		fmt.Println(*a)  // 10
}
```

### make

make也是用于内存分配的，区别于new，它只用于slice、map以及chan的内存创建，而且它返回的类型就是这三个类型本身，而不是他们的指针类型，因为这三种类型就是引用类型，所以就没有必要返回他们的指针了。make函数的函数签名如下：

```go
func make(t Type, size ...IntegerType) Type
```

> make函数是无可替代的，我们在使用slice、map以及channel的时候，都需要使用make进行初始化，然后才可以对它们进行操作。

### new与make的同与异

1. 二者都是用来做内存分配的。
2. make只用于slice、map以及channel的初始化，返回的还是这三个引用类型本身；
3. 而new用于类型的内存分配，并且内存对应的值为类型零值，返回的是指向类型的指针。
