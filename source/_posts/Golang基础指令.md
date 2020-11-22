---
title: Golang基础指令
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:13:59
---

无论多么复杂的程序，多么复杂的逻辑。基本是由以下三种构成(当然除非其原本业务逻辑客观复杂)

大道至简、速归同途，找到这种感觉。come on～

## 条件分支语句

### if 条件分支语句

Golang条件语句是通过一条或多条语句的执行结果（True或者False）来决定是否执行的代码块。

Golang程序语言指定任何非0和非空（null）值为true，0 或者 null为false。

Golang 编程中 if 语句用于控制程序的执行，基本形式为：
<!--more-->
```go
func main() {
    i:= 3
    if i >3 {
        fmt.Println("i>3")
    } else {
        fmt.Println("i<=3")
    }
}

// i<=3

func main() {
	i := 3
	if i < 3 {
		fmt.Println("i < 3")
	} else if i == 3 {
		fmt.Println("i == 3")
	} else {
		fmt.Println("i > 3")
	}
}
// i == 3
```

> 关于 if 条件语句的使用规则：
>
> - if 后面的条件表达式不需要使用 ()
>
> - 每个条件分支（if 或者 else）中的大括号是必需的，哪怕大括号里只有一行代码（
>
> - if 紧跟的大括号 { 不能独占一行，else 前的大括号 } 也不能独占一行，否则会编译不通过。
>
> - 在 if……else 条件语句中还可以增加多个 else if，增加更多的条件分支

### switch 选择语句

if 条件语句比较适合分支较少的情况，如果有很多分支的话，选择 switch 会更方便，比如以上示例，使用 switch 改造后的代码如下：

```go
func main() {
	switch i:=7;{
	case i>10:
		fmt.Println("i>10")
	case i>5 && i<=10:
		fmt.Println("5<i<=10")
	default:
		fmt.Println("i<=5")
	}
}
// 5<i<=10
```

> switch 语句同样也可以用一个简单的语句来做初始化，同样也是用分号 ; 分隔。每一个 case 就是一个分支，分支条件为 true 该分支才会执行，而且 case 分支后的条件表达式也不用小括号 () 包裹。
>
> 在 Go 语言中，switch 的 case 从上到下逐一进行判断，一旦满足条件，立即执行对应的分支并返回，其余分支不再做判断。也就是说 Go 语言的 switch 在默认情况下，case 最后自带 break。这和其他编程语言不一样，比如 C 语言在 case 分支里必须要有明确的 break 才能退出一个 case。Go 语言的这种设计就是为了防止忘记写 break 时，下一个 case 被执行。
>

那么如果你真的有需要，的确需要执行下一个紧跟的 case 怎么办呢？Go 语言也考虑到了，提供了 fallthrough 关键字。现在看个例子，如下面的代码所示：

```go
func main() {
	switch j := 1; j {
	case 1:
    fallthrough	 // 执行下一个case(即case2)
	case 2:
		fmt.Println("1")
	default:
		fmt.Println("没有匹配")
	}
  // 1
```

## for 循环语句

循环，顾名思义，就是遵循一定规则循环往复的执行，golang中语法循环如下

```go
for 初始值；运行范围；表达式 {
		执行语句
}

 // for循环示例1
func main() {
	for i := 1; i < 10; i ++ {
		fmt.Printf("%d ", i)
	}
}
//1 2 3 4 5 6 7 8 9
 // for循环示例2
func main() {
	var i int
	for ;i < 10; i ++ {
		fmt.Printf("%d ", i)
	}
}
//1 2 3 4 5 6 7 8 9

// 请思考两个示例有何不同？提示：作用域
```

下面是一个经典的 for 循环示例，从这个示例中，我们可以分析出 for 循环由三部分组成，其中，需要使用两个 ; 分隔，如下所示：

```go
func main() {
	sum:=0
	for i:=1;i<=100;i++ {
		sum+=i
	}
	fmt.Println("The sum is",sum)
} 
// The sum is 5050
```

### 高级for循环

如果你以前学过其他编程语言，可能会见到 while 这样的循环语句，在 Go 语言中没有 while 循环，但是可以通过 for 达到 while 的效果，如以下代码所示：

```go
sum:=0
i:=1
for i<=100 {
    sum+=i
    i++
}
fmt.Println("The sum is",sum)
// The sum is 5050

// 错误示例
	var i int
	for ;i < 10; i ++ {
		fmt.Println(i)
	}
```

> 在写循环时，一定需要先树立终止条件。避免写成死循环。他较于其他编程语言更能Kill掉你的电脑

## continue or break

> break:用于终止
>
> continue:跳过
>
> 二者仅且适用于if或者for
>
> 场景一：打印1-9，当值为6点时打印并退出(这个可能会有点牵强，主要用于理解break)
>
> 场景2: 打印1-9，其中不输出7

```go
// 场景一：
func main() {
   for i := 1; i < 10; i ++ {
      if i == 6 {
        break
      }
      fmt.Println(i)
   }
}
// 场景二：
func main() {
	for i := 1; i < 10; i ++ {
		if i == 7 {
			continue
		}
		fmt.Println(i)
	}
}
```



## swith

if 条件语句比较适合分支较少的情况，如果有很多分支的话，选择 switch 会更方便，比如以上示例，使用 switch 改造后的代码如下：

```go
package main

import "fmt"

func main() {
	switch i := 20; {
	case i > 10:
		fmt.Println("i>10")
	case i > 5 && i <= 10:
		fmt.Println("5<i<=10")
	default:
		fmt.Println("i<=5")
	}
}

// i>10
```

switch 语句同样也可以用一个简单的语句来做初始化，同样也用分号 ; 分隔。每一个 case 就是一个分支，分支条件为 true 该分支才会执行，而且 case 分支后的条件表达式也不用小括号 () 包裹。

在 Go 语言中，switch 的 case 从上到下逐一进行判断，一旦满足条件，立即执行对应的分支并返回，其余分支不再做判断。也就是说 Go 语言的 switch 在默认情况下，case 最后自带 break。这和其他编程语言不一样，比如 C 语言在 case 分支里必须要有明确的 break 才能退出一个 case。Go 语言的这种设计就是为了防止忘记写 break 时，下一个 case 被执行。那么如果你真的有需要，的确需要执行下一个紧跟的 case 怎么办呢？Go 语言也考虑到了，提供了 fallthrough 关键字。如下所示：

```go
package main

import "fmt"

func main() {
	switch i:=1;i {
	case 1:
		fallthrough
	case 2:
		fmt.Println("1")
	default:
		fmt.Println("没有匹配")
	}
}

```

以上示例运行会输出 1，如果省略 case 1: 后面的 fallthrough，则不会有任何输出。

不知道你是否可以发现，和上一个例子对比，这个例子的 switch 后面是有表达式的，也就是输入了 ;j，而上一个例子的 switch 后只有一个用于初始化的简单语句。

当 switch 之后有表达式时，case 后的值就要和这个表达式的结果类型相同，比如这里的 j 是 int 类型，那么 case 后就只能使用 int 类型，如示例中的 case 1、case 2。如果是其他类型，比如使用 case "a" ，会提示类型不匹配，无法编译通过。

而对于 switch 后省略表达式的情况，整个 switch 结构就和 if……else 条件语句等同了。

switch 后的表达式也没有太多限制，是一个合法的表达式即可，也不用一定要求是常量或者整数。你甚至可以像如下代码一样，直接把比较表达式放在 switch 之后：

```go
package main

import "fmt"

func main() {

	switch 2 < 1 {
	case true:
		fmt.Println("2>1")
	case false:
		fmt.Println("2<=1")
	}
}


// 2<=1
```
