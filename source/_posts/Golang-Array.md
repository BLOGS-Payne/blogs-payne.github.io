---
title: Golang-Array
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:13:59
---
## Array(数组)的介绍

数组是同一种数据类型元素的集合。 在Go语言中，数组从声明时就确定，使用时可以修改数组成员，但是数组大小不可变化。 基本语法：
<!--more-->
> ```go
> var 数组变量名 [数组数量]数组类型
> ```
>
> //数组的长度必须是常量，并且长度是数组类型的一部分。
> // 一旦定义，长度不能变。 [1]int和[2]int是不同的两种类型。
> 数组可以通过下标进行访问，下标是从0开始，最后一个元素下标是：len-1，访问越界（下标在合法范围之外），则触发访问越界，会panic。
>
> 例如：
>
> ```go
> 	var a [1]int
> 	var b [2]int
> 	a = b 
> //  cannot use b (type [2]int) as type [1]int in assignment
> //不可以这样做，因为此时a和b是不同的类型
> ```

## Array(数组)的定义

```go
package main

import "fmt"

func main() {
	definitionPart1()
	definitionPart2()
	definitionPart3()
}

// 初始化列表来设置数组元素的值。
func definitionPart1() {
	var testArray [3]int                        //数组会初始化为int类型的零值
	var numArray = [3]int{1, 2, 3}              //使用指定的初始值完成初始化
	var cityArray = [3]string{"北京", "上海", "深圳"} //使用指定的初始值完成初始化
	fmt.Println(testArray)                      //[0 0 0]
	fmt.Println(numArray)                       //[1 2 0]
	fmt.Println(cityArray)                      //[北京 上海 深圳]
}
// 按照上面的方法每次都要确保提供的初始值和数组长度一致，一般情况下我们可以让编译器根据初始值的个数自行推断数组的长度，
func definitionPart2() {
	var testArray [3]int
	var numArray = [3]int{1, 2, 3}
	var cityArray = [...]string{"北京", "上海", "深圳"}
	fmt.Println(testArray)                          //[0 0 0]
	fmt.Println(numArray)                           //[1 2]
	fmt.Printf("type of numArray:%T\n", numArray)   //type of numArray:[2]int
	fmt.Println(cityArray)                          //[北京 上海 深圳]
	fmt.Printf("type of cityArray:%T\n", cityArray) //type of cityArray:[3]string
}

// 使用指定索引值的方式来初始化数组
func definitionPart3() () {
	a := [...]int{1: 1, 3: 5}
	fmt.Println(a)                  // [0 1 0 5]
	fmt.Printf("type of a:%T\n", a) //type of a:[4]int
}
```

## Array(数组)的定义遍历

```go
func main() {
	var a = [...]string{"北京", "上海", "广州", "深圳"}
	// 方法1：for循环遍历
	for i := 0; i < len(a); i++ {
		fmt.Println(a[i])
	}

	// 方法2：for range遍历
	for index, value := range a {
		fmt.Println(index, value)
	}
}
```

## 多维数组(嵌套数组)

```go
func main() {
	a := [4][2]string{
    "长沙",
		{"北京", "上海"},
		{"广州", "深圳"},
		{"成都", "重庆"},
	}
	fmt.Println(a) //[[北京 上海] [广州 深圳] [成都 重庆]]
	fmt.Println(a[2][1]) //支持索引取值:重庆
}
```

## 数组是值类型

数组是值类型，赋值和传参会复制整个数组。因此改变副本的值，不会改变本身的值。

```go
func modifyArray(x [3]int) {
	x[0] = 100
}

func modifyArray2(x [3][2]int) {
	x[2][0] = 100
}
func main() {
	a := [3]int{10, 20, 30}
	modifyArray(a) //在modify中修改的是a的副本x
	fmt.Println(a) //[10 20 30]
	b := [3][2]int{
		{1, 1},
		{1, 1},
		{1, 1},
	}
	modifyArray2(b) //在modify中修改的是b的副本x
	fmt.Println(b)  //[[1 1] [1 1] [1 1]]
}
```

**注意：**

1. 数组支持 “==“、”!=” 操作符，因为内存总是被初始化过的。
2. `[n]*T`表示指针数组，`*[n]T`表示数组指针