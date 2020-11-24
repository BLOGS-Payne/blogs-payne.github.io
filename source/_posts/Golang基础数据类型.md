---
title: Golang基础数据类型
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:13:59
---
Go语言中有丰富的数据类型，除了基本的整型、浮点型、布尔型、字符串外，还有数组、切片、结构体、函数、map、通道（channel）等。Go 语言的基本类型和其他语言大同小异。
<!--more-->
## 基本数据类型

### 整形

整型分为以下两个大类：

> 按长度分为：int8、int16、int32、int64
> 无符号整型：uint8、uint16、uint32、uint64
>
> - `uint8`就是我们熟知的`byte`型
> - `int16`对应C语言中的`short`型，
> - `int64`对应C语言中的`long`型。

取值范围如下所示：

|  类型  |                           取值范围                           |
| :----: | :----------------------------------------------------------: |
|  int   |  取值范围为您操作系统的位数字，如果是64位操作系统。为int64   |
|  int8  |        有符号 8位整型 ( 2^8 + 1 到 2^8 -1)[-255, 255]        |
| int16  |     有符号 16位整型 ( 2^16 + 1 到 2^16 -1)[-65535, 6535]     |
| int32  | 有符号 16位整型 ( 2^32 + 1 到 2^32 -1)[-4294967295, 4294967295] |
| int64  | 有符号 16位整型 ( 2^64 + 1 到 2^64 -1)[-18446744073709551615, 18446744073709551615] |
|  uint  |  取值范围为您操作系统的位数字，如果是64位操作系统。为int64   |
| uint8  |                  无符号 8位整型 (0 到 255)                   |
| uint16 |                 无符号 16位整型 (0 到 65535)                 |
| uint32 |              无符号 32位整型 (0 到 4294967295)               |
| uint64 |         无符号 64位整型 (0 到 18446744073709551615)          |

特殊整形

```sh
uintptr	# 无符号整型，用于存放一个指针
```

> **注意：** 在使用`int`和 `uint`类型时，不能假定它是32位或64位的整型，而是考虑`int`和`uint`可能在不同平台上的差异。
>
> **注意事项** 获取对象的长度的内建`len()`函数返回的长度可以根据不同平台的字节长度进行变化。实际使用中，切片或 map 的元素数量等都可以用`int`来表示。在涉及到二进制传输、读写文件的结构描述时，为了保持文件的结构不会受到不同编译目标平台字节长度的影响，不要使用`int`和 `uint`。

数字字面量语法（Number literals syntax

> Go1.13版本之后引入了数字字面量语法，这样便于开发者以二进制、八进制或十六进制浮点数的格式定义数字，例如：
>
> - `v := 0b00101101`， 代表二进制的 101101，相当于十进制的 45。 
>
> - `v := 0o377`，代表八进制的 377，相当于十进制的 255。 
>
> - `v := 0x1p-2`，代表十六进制的 1 除以 2²，也就是 0.25。
>
> 我们可以用 `_` 来分隔数字，比如说： `v := 123_456` 表示 v 的值等于 123456。

```go
package main
 
import "fmt"
 
func main(){
	// 十进制
	var a int = 10
	fmt.Printf("%d \n", a)  // 10
	fmt.Printf("%b \n", a)  // 1010  占位符%b表示二进制
 
	// 八进制  以0开头
	var b int = 077
	fmt.Printf("%o \n", b)  // 77
 
	// 十六进制  以0x开头
	var c int = 0xff
	fmt.Printf("%x \n", c)  // ff
	fmt.Printf("%X \n", c)  // FF
}
```

### 浮点型

Go语言支持两种浮点型数：`float32`和`float64`。

这两种浮点型数据格式遵循`IEEE 754`标准： 

`float32` 的浮点数的最大范围约为 `3.4e38`，可以使用常量定义：`math.MaxFloat32`。

 `float64` 的浮点数的最大范围约为 `1.8e308`，可以使用一个常量定义：`math.MaxFloat64`。

```go
package main
import (
        "fmt"
        "math"
)
func main()  {
	fmt.Printf("%f\n", math.Pi)	// 3.141593
	fmt.Printf("%.2f\n", math.Pi)	// 3.14
}
```

### 复数

complex64和complex128

```go
package main

import "fmt"

func main()  {
	var c1 complex64
	c1 = 1 + 2i
	var c2 complex128
	c2 = 2 + 3i
	fmt.Println(c1)
	fmt.Println(c2)
}
// 复数有实部和虚部，complex64的实部和虚部为32位，complex128的实部和虚部为64位。
```

### 布尔值

Go语言中以`bool`类型进行声明布尔型数据

布尔型数据只有`true（真）`和`false（假）`两个值。

**注意：**

- 布尔类型变量的默认值为`false`。

- Go 语言中不允许将整型强制转换为布尔型.

- 布尔型无法参与数值运算，也无法与其他类型进行转换。

### 字符串

> Go语言中的字符串以原生数据类型出现，使用字符串就像使用其他原生数据类型（int、bool、float32、float64 等）一样。
>
>  Go 语言里的字符串的内部实现使用`UTF-8`编码。 

字符串的值为`双引号("")`中的内容，可以在Go语言的源码中直接添加非ASCII码字符，例如：

```go
var a string = "你好,nihao"
var b string = "Hello，你好"
```

### byte和rune类型

组成每个字符串的元素叫做“字符”，可以通过遍历或者单个获取字符串元素获得字符。 字符用单引号（' '）包裹起来，如：

```
var a := '一'
var b := 'x'
```

Go 语言的字符有以下两种：

1. `uint8`类型，或者叫 byte 型，代表了`ASCII码`的一个字符。
2. `rune`类型，代表一个 `UTF-8字符`。

当需要处理中文、日文或者其他复合字符时，则需要用到`rune`类型。`rune`类型实际是一个`int32`。

Go 使用了特殊的 rune 类型来处理 Unicode，让基于 Unicode 的文本处理更为方便，也可以使用 byte 型进行默认字符串处理，性能和扩展性都有照顾。

```go
package main

import "fmt"

func main() {
	s := "hello,世界"
	for i := 0; i < len(s); i++ { //byte
		fmt.Printf("%v(%c) ", s[i], s[i])
	}
	fmt.Println()
	for _, r := range s { //rune
		fmt.Printf("%v(%c) ", r, r)
	}
	fmt.Println()
}

//104(h) 101(e) 108(l) 108(l) 111(o) 44(,) 228(ä) 184(¸) 150() 231(ç) 149() 140() 


//104(h) 101(e) 108(l) 108(l) 111(o) 44(,) 19990(世) 30028(界) 
```

> 因为UTF8编码下一个中文汉字由3~4个字节组成，所以我们不能简单的按照字节去遍历一个包含中文的字符串，否则就会出现上面输出中第一行的结果。
>
> 字符串底层是一个byte数组，所以可以和`[]byte`类型相互转换。字符串是不能修改的 字符串是由byte字节组成，所以字符串的长度是byte字节的长度。 rune类型用来表示utf8字符，一个rune字符由一个或多个byte组成。

### 修改字符串

要修改字符串，需要先将其转换成`[]rune`或`[]byte`，完成后再转换为`string`。无论哪种转换，都会重新分配内存，并复制字节数组。

```go
func changeString() {
	s1 := "big"
	// 强制类型转换
	byteS1 := []byte(s1)
	byteS1[0] = 'p'
	fmt.Println(string(byteS1))

	s2 := "白萝卜"
	runeS2 := []rune(s2)
	runeS2[0] = '红'
	fmt.Println(string(runeS2))
}
```


## 类型检查

```go
package main

import (
	"fmt"
	// "math"
	"reflect"		// 内建包，提供类型检查函数
)

func main() {
	var a int64 = 1
	fmt.Println(reflect.TypeOf(a))	// int64
	fmt.Printf("%T", a) // int64
	var b = "a"
	fmt.Println(reflect.TypeOf(b)) // string
	fmt.Printf("%T", b)            // string
}

// reflect.TypeOf()	源码示例
// TypeOf returns the reflection Type that represents the dynamic type of i.
// If i is a nil interface value, TypeOf returns nil.
func TypeOf(i interface{}) Type {
	eface := *(*emptyInterface)(unsafe.Pointer(&i))
	return toType(eface.typ)
}
```



## 类型转换

Go语言中只有强制类型转换，没有隐式类型转换。该语法只能在两个类型之间支持相互转换的时候使用。

强制类型转换的基本语法如下：

```bash
Type(表达式)

# Type表示目标转换类型。表达式包括变量、复杂算子和函数返回值等.
```

比如计算直角三角形的斜边长时使用math包的Sqrt()函数，该函数接收的是float64类型的参数，而变量a和b都是int类型的，这个时候就需要将a和b强制类型转换为float64类型。

```go
func sqrtDemo() {
	var a, b = 3, 4
	var c int
	// math.Sqrt()接收的参数是float64类型，需要强制转换
	c = int(math.Sqrt(float64(a*a + b*b)))
	fmt.Println(c)
}
```

对于数字类型之间，可以通过强制转换的方式，如以下代码所示：

```
package main

import "fmt"

func main() {

	i := 10
	f64 := 10.102
	i2f:=float64(i)
	f2i:=int(f64)
	f3 := float64(f2i)
	fmt.Println(i2f,f2i, f3) // 10 10 10

}

```

这种使用方式比简单，采用“类型（要转换的变量）”格式即可。采用强制转换的方式转换数字类型，可能会丢失一些精度，比如浮点型转为整型时，小数点部分会全部丢失.

把变量转换为相应的类型后，就可以对相同类型的变量进行各种表达式运算和赋值了。

#### 字符串和数字互转

Go 语言是强类型的语言，也就是说不同类型的变量是无法相互使用和计算的，这也是为了保证Go 程序的健壮性，所以不同类型的变量在进行赋值或者计算前，需要先进行类型转换。涉及类型转换的知识点非常多，这里我先介绍这些基础类型之间的转换

以字符串和数字互转这种最常见的情况为例，如下面的代码所示：

```go
package main

import (
	"fmt"
	"strconv"
)

type Human struct {
	Age       int
	Name, sex string
}

func main() {
	i := 10
	// 通过包 strconv 的 Itoa 函数可以把一个 int 类型转为 string，Atoi 函数则用来把 string 转为 int。
	i2s:=strconv.Itoa(i)

	s2i,err:=strconv.Atoi(i2s)

	//fmt.Println(i2s,s2i,err)
	fmt.Printf("i2s: type:%T, value:%v\n", i2s, i2s)  // i2s: type:string, value:10
	fmt.Printf("s2i: type:%T, value:%v, err:%v", s2i, s2i, err)  // s2i: type:int, value:10, <nil>


}

```



## 补充

### 占位的相关用法

golang 的fmt 包实现了格式化I/O函数，类似于C的 printf 和 scanf。Python中的print等

#### 普通占位符

| 占位符          |              说明              |
| :-------------- | :----------------------------: |
| %v              |       相应值的默认格式。       |
| %+v             |   打印结构体时，会添加字段名   |
| %#v             |       相应值的Go语法表示       |
| %T              |    相应值的类型的Go语法表示    |
| %%              | 字面上的百分号，并非值的占位符 |
| 布尔占位符 (%t) |         true 或 false          |

```go
package main

import "fmt"

// 自定义类型
type Human struct {
	Age       int
	Name, sex string
}

func main() {
	people := Human{Name: "Payne", Age: 20, sex: "male"}
	fmt.Printf("%v", people)  // {20 Payne male}
	fmt.Printf("%+v", people) // {20 Payne male}{Age:20 Name:Payne sex:male}
	fmt.Printf("%#v", people) // {20 Payne male}{Age:20 Name:Payne sex:male}main.Human{Age:20, Name:"Payne", sex:"male"}
	fmt.Printf("%T", people)  // main.Human
	//fmt.Printf("%%")  // main.Humanß
}

```

#### 整数占位符

| 占位符 |                    说明                    |
| :----: | :----------------------------------------: |
|   %b   |                 二进制表示                 |
|   %o   |                 八进制表示                 |
|   %d   |                 十进制表示                 |
|   %x   |             十六进制表示(小写)             |
|   %X   |             十六进制表示(大写)             |
|   %f   |    有小数点而无指数，例如 123.456浮点数    |
|   %c   |        相应Unicode码点所表示的字符         |
|   %q   | 单引号围绕的字符字面值，由Go语法安全地转义 |
|   %U   |    Unicode格式：U+1234，等同于 "U+%04X"    |

```go
package main

import "fmt"

func main() {
	// 定义十进制变量a
	//a := 542
	// 数字
	//fmt.Printf(" Binary: %d,\n Octal: %o,\n Decimal:%d,\n Hex: %x,\n Uppercase_hexadecimal:%X", a, a, a, a, a)
	/*
	 Binary: 542,
	 Octal: 1036,
	 Decimal:542,
	 Hex: 21e,
	 Uppercase_hexadecimal:21E
	*/
	fmt.Printf("%c", 0x3E2E) // 㸮
	fmt.Printf("%q", 0x3E2E) // '㸮'
  fmt.Printf("%f\n", 100.1000201)     // 100.100020
	fmt.Printf("%.1f\n", 100.1000201)   // 100.1
	fmt.Printf("%.2f\n", 100.1000201)   // 100.10
	fmt.Printf("%.3f\n", 100.1000201)   // 100.100
	fmt.Printf("%.4f\n", 100.1000201)   // 100.1000

}
```

#### 浮点数和复数的组成部分（实部和虚部）

| 占位符 |                         说明                          |
| :----: | :---------------------------------------------------: |
|   %e   |            科学计数法，例如 -1234.456e+78             |
|   %E   |            科学计数法，例如 -1234.456E+78             |
|   %g   | 根据情况选择 %e 或 %f 以产生更紧凑的（无末尾的0）输出 |
|   %G   | 根据情况选择 %E 或 %f 以产生更紧凑的（无末尾的0）输出 |

```go
package main

import (
	"fmt"
	"math"
)

func main() {
	a := math.Pow(20, 3) // 8000
	fmt.Printf("%e\n", a) // 8.000000e+03
	fmt.Printf("%E\n", a) // 8.000000E+03
	fmt.Printf("%g\n", 10.20)    // 10.2
	fmt.Printf("%G\n", 10.20+2i) // (10.2+2i)
}

```



#### 字符串与字节切片

| 占位符 |                  说明                  |              举例              |     输出     |
| :----- | :------------------------------------: | :----------------------------: | :----------: |
| %s     |  输出字符串表示（string类型或[]byte)   | Printf("%s", []byte("Go语言")) |    Go语言    |
| %q     | 双引号围绕的字符串，由Go语法安全地转义 |     Printf("%q", "Go语言")     |   "Go语言"   |
| %x     |   十六进制，小写字母，每字节两个字符   |     Printf("%x", "golang")     | 676f6c616e67 |
| %X     |   十六进制，大写字母，每字节两个字符   |     Printf("%X", "golang")     | 676F6C616E67 |

```
package main

import "fmt"

func main() {
	//a := "golang编程语言"
	fmt.Printf("%s\n", []byte(a))     // golang编程语言
	fmt.Printf("%q\n", []byte(a))     // golang编程语言
	fmt.Printf("%x\n", []byte(a))     // 676f6c616e67e7bc96e7a88be8afade8a880
	fmt.Printf("%X\n", []byte(a))     // 676F6C616E67E7BC96E7A88BE8AFADE8A880
}

```



#### 6)指针

| 占位符 |         说明          |         举例          |   输出   |
| :----- | :-------------------: | :-------------------: | :------: |
| %p     | 十六进制表示，前缀 0x | Printf("%p", &people) | 0x4f57f0 |

```go
package main

import "fmt"


func main() {
	// 地址值
	a := 10
	var b []int
	fmt.Printf("%p\n", &a)    // 0xc000014080
	fmt.Printf("%p\n", &b)    // 0xc0000a6020
}

```

### Strings

Strings 包
讲到基础类型，尤其是字符串，不得不提 Go SDK 为我们提供的一个标准包 strings。它是用于处理字符串的工具包，里面有很多常用的函数，帮助我们对字符串进行操作，比如查找字符串、去除字符串的空格、拆分字符串、判断字符串是否有某个前缀或者后缀等。掌握好它，有利于我们的高效编程。

以下代码是我写的关于 strings 包的一些例子，你自己可以根据[strings 文档](https://golang.google.cn/pkg/strings/)或者$GOPATH/src/stringls.go.以及自己写一些示例，多练习熟悉它们。

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World"
	//判断s1的前缀是否是H
	fmt.Println(strings.HasPrefix(s1,"H")) // true
	//在s1中查找字符串o
	fmt.Println(strings.Index(s1,"o"))     // 4
	//把s1全部转为大写
	fmt.Println(strings.ToUpper(s1))              // HELLO WORLD

	// s1 中是否包含某一个或一段字符串
	fmt.Println(strings.Contains(s1, "ee ")) // false
	fmt.Println(strings.Contins(s1, "e"))   // true
}

```
