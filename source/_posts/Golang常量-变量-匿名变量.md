---
title: Golang常量-变量-匿名变量
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:13:59
---

> 常量：一旦声明即不可被改变
>
> 变量：声明后可以发生改变。若初始化后未赋值则为初始值
>
> 例如：
>
> int -> 0
>
> Bool -> false
>
> String -> 空

## 关键字与保留字

关键字是指编程语言中预先定义好的具有特殊含义的标识符。 关键字和保留字都不建议用作变量名。
<!--more-->
关键字

```go
 break        default      func         interface    select
    case         defer        go           map          struct
    chan         else         goto         package      switch
    const        fallthrough  if           range        type
    continue     for          import       return       var
```

保留字

```go
    Constants:    true  false  iota  nil

        Types:    int  int8  int16  int32  int64  
                  uint  uint8  uint16  uint32  uint64  uintptr
                  float32  float64  complex128  complex64
                  bool  byte  rune  string  error

    Functions:   make  len  cap  new  append  copy  close  delete
                 complex  real  imag
                 panic  recover
```

## 变量

### 变量的来历

程序运行过程中的数据都是保存在内存中，我们想要在代码中操作某个数据时就需要去内存上找到这个变量，但是如果我们直接在代码中通过内存地址去操作变量的话，代码的可读性会非常差而且还容易出错，所以我们就利用变量将这个数据的内存地址保存起来，以后直接通过这个变量就能找到内存上对应的数据了。

> 相当于开辟相对应的内存，并对此内存取了个别名。
>
> ```go
> // 例如：
> var a string = "hello"
> // 申请一块内存，把字符串hello放进去
> 并它的地址为指向变量名 a
> ```

### 变量类型

变量（Variable）的功能是存储数据。不同的变量保存的数据类型可能会不一样。经过半个多世纪的发展，编程语言已经基本形成了一套固定的类型，常见变量的数据类型有：整型、浮点型、布尔型等。

Go语言中的每一个变量都有自己的类型，并且变量必须经过声明才能开始使用。

### 变量声明

Go语言中的变量需要声明后才能使用，同一作用域内不支持重复声明。 并且Go语言的变量声明后必须使用。

```go
// 标准声明
var 变量名 类型
// 类型推到声明，必须有初始值， 否则声明失败
var 变量名 = 值
// 简短声明（必须在函数中）
变量名 := 值

// 批量声明(多用于全局变量声明)，类型为必须
var (
 	变量名 类型
  	变量名 类型
  	变量名 类型
  。。。
)
// 同类型批量声明
var 变量名1，变量名2，变量名3 类型
或
var (
	变量名1,
	变量名2, 
	变量名3 string 
)

// 简短批量声明 注意必须在函数中
变量名1,变量名2, 变量名3 := 值1，值2， 值3 
```

 ```go
package main

import (
	"fmt"
)

// 标准声明
var name string = "Payne"

// 类型推到声明
var age = 20

//批量声明
var (
	x string
	y string
	j bool
	k byte
	z int
	
)
// 同类型批量声明
var a, b, c, d int



func main() {
	// 简短声明
	hobby := "programming"

	//测试输入
	fmt.Println("Name is :", name) // Name is : Payne
	fmt.Println("Age is :", age)	// Age is : 20
	fmt.Println("hobby ", hobby)	// hobby  programming
	fmt.Print(a)	// 0 声明未赋值采用初始值。int 类型初始值为0
	// 批量简短声明
	a, b := 1, "string"
	fmt.Print(a, b)
}
 ```

### 匿名变量

> 匿名变量不占用命名空间，不会分配内存，所以匿名变量之间不存在重复声明。 (在`Lua`等编程语言里，匿名变量也被叫做哑元变量。)

在使用多重赋值时，如果想要忽略某个值，可以使用`匿名变量（anonymous variable）`。 匿名变量用一个下划线`_`表示，例如：

```go
// 这里可能会有点绕，仅仅是为了使用“_”，而使用_
func foo() (string, int) {
	return  "payne", 20
}
func main() {
	name, _ := foo()
	_, age := foo()
	fmt.Println("name=", name) //name= payne
	fmt.Println("age=", age)	//age= 20
}
```

> 注意事项：
>
> 1. 函数外的每个语句都必须以关键字开始（var、const、func等）
> 2. `_`多用于占位，表示忽略值。

## 常量

常量与变量的声明基本一致，类型一致。若有声明变化的话那就是将关键字`var`， 替换成了`const`.增加了`iota`，减少了简短声明

```go
// 常量声明声明时必须给值，否则则定义失败

// 标准声明
const 变量名 类型 = 值
// 类型推导
const 变量名  = 值
```

```go
package main

import (
	"fmt"
)

const a int = 1
const b = "2"

func main() {
	fmt.Println(a) // 1
	fmt.Println(b) // 2
}
```

### Iota

`iota`是go语言的常量计数器，只能在常量的表达式中使用。

`iota`在const关键字出现时将被重置为0。const中每新增一行常量声明将使`iota`计数一次(iota可理解为const语句块中的行索引)。 使用iota能简化定义，在定义枚举时很有用。

```go
// `iota`在const关键字出现时将被重置为0,请牢记！！
const (
		n1 = iota //0
		n2        //1
		n3        //2
		n4        //3
	)
	
	// 使用_跳过某些值
	const (
		n1 = iota //0
		n2        //1
		_
		n4        //3
	)
// iota声明中间插队
const (
		n1 = iota //0
		n2 = 100  //100
		n3 = iota //2
		n4        //3
	)
	const n5 = iota // 0
```

## 补充

### 常量与变量的对比示例

```go
// 主要体现为 变量可以被修改
package main

import (
	"fmt"
)

func main() {
	var a = 1
	fmt.Println(a)	// 1
	a = 2
	fmt.Println(a)	// 2
	const b = 3
	fmt.Println(b) // 3
	b = 4
	fmt.Print(b)	// Error: cannot assign to b
	
}
```

### 函数的初探

```go
//  函数的定义
func 函数名(形参) (返回值类型) {
	表达式
}
// 调用函数
函数名(实参)

// 另一种方式（匿名函数）
var 函数名 = func () {
	表达式
}
// 调用函数
函数名(实参)


// 匿名立即执行函数
var 函数名 = func () {
	表达式
}()
// 此时的函数为结果的值
```

### 函数的调用的顺序

```go
var a = 1

func main() {
	a = 2
	fmt.Print(a) //  2
}
```

> 思考：
>
> 为什么打印的是2？
>
> 原因为`函数`参数的调用采用`就近的原则`
