---
title: Golang-自定义类型
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:41:10
---

在Go语言中没有`类`，也没有相关于`类`的继承、多态的实现。却有一种"新的概念"--结构体

Go语言中通过结构体的内嵌再配合接口比面向对象具有更高的扩展性和灵活性。

那么，接下来就让我们推开Go语言进阶部分内容的大门，Let's Go

在学习`结构体`之前我们先预热一下，先了解Golang 的自定义类型
<!--more-->
- 自定义类型: 当现有类型不足以满足需求的时候, 自己创建的类型
- 类型别名: 仅存在于编写过程, 提高代码可读性 ( byte 是 uint8 的别名; rune 是 uint16 的别名 )

## 类型别名

***类型别名*** 是 Go 1.9 版本添加的新功能。主要应用于代码升级、工程重构、迁移中类型的兼容性问题。C/C++ 语言中，代码的重构升级可以使用宏快速定义新的代码。Go 语言中并未选择通过宏，而是选择通过类型别名解决重构中最复杂的类型名变更问题

## 区分类型别名与类型定义

类型别名规定：Type Alias只是Type 的别名，本质上Type Alias 与Type是同一个类型，即基本数据类型是一致的。好比如我们小时家里人给我们起的小名，上学后英语老师给起的英文名字，但是这个名字都是指的我们自己。

表面上看类型别名与类型定义只有一个等号的差异（"="）

```go
// 这个叫自定义类型
type MyInt int

// 这个叫类型别名
type YourInt = int
```

我们继续深入探究他们二者究竟有什么不同。如下代码所示

```
package main

import "fmt"

// type 后面的是类型
type MyInt int     // 自定义类型
type YourInt = int // 类型别名

func main() {
	var m MyInt
	var y YourInt
	m = 10
	y = 20
	fmt.Printf("m 的类型是：%T, \n", m)
	fmt.Printf("y 的类型是：%T, \n", y)

}
```

> m 的类型是：main.MyInt, 
> y 的类型是：int, 

如上述代码，我们可以知道`自定义类型`是定义了一种新的类型，而类型别名是基于原始的类型的昵称而已。

相信你这时会想自定义类型有什么用？

既然可以自定义类型，那么我们是可以定制我们的类型的，例如，int是单纯的数字类型，如果我们可以自定义类型，我们是不是可以基于int把字符串里面的数字也包含进去呢？答案当然是可以的。如果有感兴趣的同学，可以自己去尝试一下。

预热完毕，那么让我们进入真正的操作环节，Go，Go，Go～

## 结构体

Go语言中的基础数据类型可以表示一些事物的基本属性，但是当我们想表达一个事物的全部或部分属性时，这时候再用单一的基本数据类型明显就无法满足需求了，Go语言提供了一种自定义数据类型，可以封装多个基本数据类型，这种数据类型叫结构体，英文名称`struct`。 也就是我们可以通过`struct`来定义自己的类型了。

Go语言中通过`struct`来实现`面向对象`的相关概念。

### 结构体的定义

```go
// 使用type和struct关键字来定义结构体
type 类型名 struct {
    字段名 字段类型
    字段名 字段类型
    …
}
```

结构体定义需注意

- 类型名：标识自定义结构体的名称，在同一个包内不能重复。
- 字段名：表示结构体字段名。结构体中的字段名必须唯一。
- 字段类型：表示结构体字段的具体类型

具体定义如下所示

```go
type Person struct {
	name string
	age int
	male string
}


// 当有相同类型的时候，我们还可以将相同类型的变量名使用“,”分割，写在一起。如下
type Person1 struct {
	name,male string
	age int
}
```

这样我们就拥有了一个的自定义类型`person`，它有`name`、`male`、`age`三个字段，分别表示姓名、性别和年龄。这样我们使用这个`person`结构体就能够很方便的在程序中表示和存储人信息了。

语言内置的基础数据类型是用来描述一个值的，而结构体是用来描述一组值的。比如一个人有名字、年龄和性别等，本质上是一种聚合型的数据类型

将前面的融汇贯通，整点复合型的东东，搞起

```go
type MyString string
type MyInt=int

type Person struct {
	name MyString
	age MyInt
	male string
}
```

结构体定义了之后，咱们还需要进行初始化，才能使用。

### 结构体初始化与基本使用

```go
package main

import "fmt"

type MyString string
type MyInt = int

type Person struct {
	name MyString
	age  MyInt
	sex  string
}

type Person1 struct {
	name, sex string
	age       int
}

func main() {
	var p Person
	var p1 Person1
	p.name = "Payne"
	p.sex = "male"
	p.age = 20

	p1.name = "Tim"
	p1.sex = "female"
	p1.age = 23
	fmt.Printf("Type:%T,value:%v\n", p, p)
	fmt.Printf("%#v\n", p)
	fmt.Printf("Type:%T,value:%v\n", p1, p1)
	fmt.Printf("%#v", p1)
}

```

> Type:main.Person,value:{Payne 20 male}
> main.Person{name:"Payne", age:20, sex:"male"}
> Type:main.Person1,value:{Tim female 23}
> main.Person1{name:"Tim", sex:"female", age:23}

### 匿名结构体

在定义一些临时数据结构等场景下还可以使用匿名结构体。如下

```go
package main

import "fmt"

func main() {
	var person2 struct {
		name string
		age  int
		sex  string
	}
	person2.name = "Payne"
	person2.age = 20
	person2.sex = "male"
	fmt.Printf("Type:%T,value:%v\n", person2, person2)
	fmt.Printf("%#v\n", person2)
}

// Type:struct { name string; age int; sex string },value:{Payne 20 male}
// struct { name string; age int; sex string }{name:"Payne", age:20, sex:"male"}

```
