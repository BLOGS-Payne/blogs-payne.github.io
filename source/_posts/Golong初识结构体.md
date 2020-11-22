---
title: Golong初识结构体
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:43:30
---
## 结构体

Go语言中的基础数据类型可以表示一些事物的基本属性，但是当我们想表达一个事物的全部或部分属性时，这时候再用单一的基本数据类型明显就无法满足需求了，Go语言提供了一种自定义数据类型，可以封装多个基本数据类型，这种数据类型叫结构体，英文名称`struct`。 也就是我们可以通过`struct`来定义自己的类型了。

Go语言中通过`struct`来实现`面向对象`的相关概念。
<!--more-->
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

通过以上示例我们知道，它是通过`.`，来一个一个的进行赋值

当然我们也是可以通过键值对对形式，从而进行批量赋值的，如下

```go
	p1 := Person1{
		name: "a",
		age:  20,
		sex:  "male",
	}
	fmt.Printf("type: %T, value:%#v", p1, p1)
```



#### 匿名结构体

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

### 指针类型结构体

通过使用`new`关键字堆结构体初始化，得到的是结构体的地址值

```go
package main

import "fmt"

type person3 struct {
	name   string
	gender string
	hobby  string
	age    int
}

func main() {
	var p3 = new(person3)
	fmt.Printf("Type:%T, Vlue:%v", p3, p3)
}
```

既然是地址值，那么我们也是可以使用`&`对他进行运算等操作的，相当于new

```go
package main

type person3 struct {
	name   string
	gender string
	hobby  []string
	age    int
}

func main() {
	p3 := &person3{}
	p3.name = "payne"
	p3.gender = "sex"
	p3.hobby = []string{"a", "b"}
	p3.age = 20
	
}
```

> `p3.name = "payne"`其实在底层是`(*p3).name = "payne"`，这是Go语言帮我们实现的语法糖。

### 构造函数

Go语言的结构体没有构造函数，我们可以自己实现。 例如，下方的代码就实现了一个`person`的构造函数。 因为`struct`是值类型，如果结构体比较复杂的话，值拷贝性能开销会比较大，所以该构造函数返回的是结构体指针类型

借用结构体构造函数，实现`类`的概念，如下

```go
package main

import "fmt"

type person5 struct {
	name string
	age  int
}

func newClass(name string, age int) *person5 {
	return &person5{
		name: name,
		age:  age,
	}
}

func main() {
	p5 := newClass("payne", 10)
	fmt.Printf("value:%#v", p5)
}
```

Go语言中的`方法（Method）`是一种作用于特定类型变量的函数。这种特定类型变量叫做`接收者（Receiver）`。接收者的概念就类似于其他语言中的`this`或者 `self`。

方法的定义格式如下：

```go
func (接收者变量 接收者类型) 方法名(参数列表) (返回参数) {
    函数体
}

func (谁能调用我？-接收者) 方法名(参数列表) (返回类型) {
  函数体
}
```

其中，

- 接收者变量：接收者中的参数变量名在命名时，官方建议使用接收者类型名称首字母的小写，而不是`self`、`this`之类的命名。例如，`Person`类型的接收者变量应该命名为 `p`，`Connector`类型的接收者变量应该命名为`c`等。
- 接收者类型：接收者类型和参数类似，可以是指针类型和非指针类型。
- 方法名、参数列表、返回参数：具体格式与函数定义相同。

举个例子：

```go
//Person 结构体
type Person struct {
	name string
	age  int8
}

//NewPerson 构造函数
func NewPerson(name string, age int8) *Person {
	return &Person{
		name: name,
		age:  age,
	}
}

//Dream Person做梦的方法
func (p Person) Dream() {
	fmt.Printf("%s的梦想是学好Go语言！\n", p.name)
}

func main() {
	p1 := NewPerson("Payne", 25)
	p1.Dream()
}
```

方法与函数的区别是，函数不属于任何类型，方法属于特定的类型。
### 值类型的接收者

当方法作用于值类型接收者时，Go语言会在代码运行时将接收者的值复制一份。在值类型接收者的方法中可以获取接收者的成员值，但修改操作只是针对副本，无法修改接收者变量本身。

```go
// SetAge2 设置p的年龄
// 使用值接收者
func (p Person) SetAge2(newAge int8) {
	p.age = newAge
}

func main() {
	p1 := NewPerson("Payne", 25)
	p1.Dream()
	fmt.Println(p1.age) // 25
	p1.SetAge2(30) // (*p1).SetAge2(30)
	fmt.Println(p1.age) // 25
}
```



### 指针类型的接收者

指针类型的接收者由一个结构体的指针组成，由于指针的特性，调用方法时修改接收者指针的任意成员变量，在方法结束后，修改都是有效的。这种方式就十分接近于其他语言中面向对象中的`this`或者`self`。 例如我们为`Person`添加一个`SetAge`方法，来修改实例变量的年龄。

```go
// SetAge 设置p的年龄
// 使用指针接收者
func (p *Person) SetAge(newAge int8) {
	p.age = newAge
}
```

调用该方法：

```go
func main() {
	p1 := NewPerson("Payne", 25)
	fmt.Println(p1.age) // 25
	p1.SetAge(30)
	fmt.Println(p1.age) // 30
}
```


### 什么时候应该使用指针类型接收者

1. 需要修改接收者中的值
2. 接收者是拷贝代价比较大的大对象
3. 保证一致性，如果有某个方法使用了指针接收者，那么其他的方法也应该使用指针接收者。

## 结构体的“继承”

Go语言中使用结构体也可以实现其他编程语言中面向对象的继承。

```go
//Animal 动物
type Animal struct {
	name string
}

func (a *Animal) move() {
	fmt.Printf("%s会动！\n", a.name)
}

//Dog 狗
type Dog struct {
	Feet    int8
	*Animal //通过嵌套匿名结构体实现继承
}

func (d *Dog) wang() {
	fmt.Printf("%s会汪汪汪~\n", d.name)
}

func main() {
	d1 := &Dog{
		Feet: 4,
		Animal: &Animal{ //注意嵌套的是结构体指针
			name: "aw",
		},
	}
	d1.wang() //aw会汪汪汪~
	d1.move() //aw会动！
}
```

## 注意点

1. Golang传递参数，永远是拷贝。也就是说，在函数内部改变其值，仅仅在内部生效。若想在某一函数中改变其全局的值。需要使用指针
