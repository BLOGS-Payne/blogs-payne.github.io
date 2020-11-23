---
title: Golang-结构体实现学生管理系统
auhtor: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-23 23:45:57
---
## 基于“结构体”实现简易版学生管理系统

首先咱们在做项目之前，需要对项目进行分析。切记不可贪功冒进，从而导致无用功

### 分析

1. 学生类
2. 管理者类
3. 菜单栏
4. 基于管理类实现功能
   1. 查看
   2. 添加
   3. 修改
   4. 删除
   5. 退出
<!--more-->
结构图如下:

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkzgz3v3vuj30gc0c4dhc.jpg)

采用`自顶向下`的编程思维对以上分析进行复述，先整体、后细节(先全局、后详细)实现如上结构

### 定义全局的学生类

在定义学生类之前，我们需了解学生类包含的字段。这里我只定义了Id、姓名。其中id为唯一，姓名可重复。代码如下所示

```go
type student struct {
	id   int64
	name string
}
```

### 定义全局的管理(即操作类)

由于学号为唯一，且其对照关系，非常适合使用Map的`Key-value`格式。在这里仅做定义及声明并不做初始化，代码如下所示

```go
type studentMgr struct {
	allStudent map[int64]student
}
```

> 借用好的数据结构，会让您的编程效率，编码思维，事半功倍

### 定义菜单栏

定义菜单栏，以供使用者选择所对应的功能。根据其功能展示。并根据相对功能，定义应函数。如下

```go
func showMenu() {
	fmt.Printf("Welcome student Manage System, TimeNow:%v", time.Now())
	fmt.Println(
		` 
			1: 查看学生
			2: 增加学生
			3: 修改学生
			4: 删除学生
			5: 退出~
				`)
	fmt.Print("What are you want do? Please input Serial number:")

}
```

由以上所知，我们许定义的函数有5个，他们分别是`查看学生`,`增加学生`,`修改学生`,`删除学生`,`退出`,如下所示：

```go
func main() {
	smr = studentMgr{
		allStudent: make(map[int64]student),
	}
	for {
		showMenu()
		var choice int64
		fmt.Scan(&choice)
		fmt.Printf("You select %d\n", choice)
		switch choice {
		case 1:
			smr.showStudent()
		case 2:
			smr.addStudent()
		case 3:
			smr.editStudent()
		case 4:
			smr.delStudent()
		case 5:
			os.Exit(1)
		default:
			fmt.Println("Invalid input, please select again：")
		}
	}
}

```

在这里实例化了一个全局的管理类，所有的操作都经过它。

使用switch语句，进行多项的条件分支，更有利于我们编写更简洁的代码

### 定义功能函数

`查看学生`,`增加学生`,`修改学生`,`删除学生`

```go
// 查看学生函数
func (s studentMgr) showStudent() {}
// 增加学生函数
func (s studentMgr) addStudent()	{}
// 修改学生函数
func (s studentMgr) editStudent()	{}
// 删除学生函数
func (s studentMgr) delStudent()	{}
```

基本的就已经做完了，基础结构就已经完成了，鼓掌～

那么接下来，我们只需要一个个实现相对应的函数。即可实现功能。

首先我们实现的是查看学生函数。

### 实现查看学生功能

```go
func (s studentMgr) showStudent() {
	for _, stu := range s.allStudent {
		fmt.Printf("ID:%d, Name:%s\n", stu.id, stu.name)
	}
}
```

> 我们只需要遍历Map中所有的键与值，即可拿到所有的学生。这里没什么好说的

实现增加学生功能

```go
func (s studentMgr) addStudent() {
	var (
		stuId   int64
		stuName string
	)
	// 1. 根据输入内容创建学生
	fmt.Print("Please input you need ID:")
	fmt.Scanln(&stuId)
	fmt.Print("Please input you need name:")
	fmt.Scanln(&stuName)
	newStu := student{
		id:   stuId,
		name: stuName,
	}
	// 2. 将创建的学生加入stu中
	s.allStudent[newStu.id] = newStu
	fmt.Println("Added successfully")
}
```

在这里，我们需要进行的有两步

1. 获取用户键盘输入

   ```go
   var (
   		stuId   int64
   		stuName string
   	)
   	// 1. 根据输入内容创建学生
   	fmt.Print("Please input you need ID:")
   	fmt.Scanln(&stuId)
   	fmt.Print("Please input you need name:")
   	fmt.Scanln(&stuName)
   ```

   

2. 将输入的学生信息加入到管理函数中

   ```go
   newStu := student{
   		id:   stuId,
   		name: stuName,
   	}
   	// 2. 将创建的学生加入stu中
   	s.allStudent[newStu.id] = newStu
   	fmt.Println("Added successfully")
   }
   ```

   > 添加成功则提示成功

做到这里，咱们就可以进行一个小小的检测，有木有点小激动以及一点小方张。反正我有，示例如下

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkzi01hhipj30zm0u0jx0.jpg)

**留下一个小Bug，等你去解决，提示，如果key已存在，那么该添加操作会进行？如果暂时没思路，可以继续往下看。虽然并没有直接这里告诉你，但却在下方进行的相对应的解决**

### 实现修改学生功能

```go
func (s studentMgr) editStudent() {
	// 获取用户输入
	var StuId int64
	fmt.Print("Please input want change student IdCode:")
	fmt.Scanln(&StuId)
  // 检查该学号学生是否存在，没有则提示不存在
	value, ok := s.allStudent[StuId]
	if !ok {
		fmt.Println("Not found")
		return
	}
	fmt.Printf("You want change student message:"+
		" Id: %d, Name:%s\n", value.id, value.name)
	// 获取修改
	var newName string
	fmt.Print("Please change to new message:")
	fmt.Scanln(&newName)
	value.name = newName
	// 更新学生的姓名
	s.allStudent[StuId] = value
}
```

1. 首先我们获取用户输入

   ```go
   // 获取用户输入
   	var StuId int64
   	fmt.Print("Please input want change student IdCode:")
   	fmt.Scanln(&StuId)
   ```

2. 拿着用户输入的学生Id，去Map里面查找相对应的学生Id

   ```go
   value, ok := s.allStudent[StuId]
   	if !ok {
   		fmt.Println("Not found")
   		return
   	}
   	fmt.Printf("You want change student message:"+
   		" Id: %d, Name:%s\n", value.id, value.name)
   ```

   若想实现修改，是需要存在的。如果不存在此学生，提示没有找到该学生，直接return掉。证明无法修改。如果存在那么它一定是唯一的一个Id，因为我们用的是Map格式的嘛，key唯一。

3. 如果存在我们就需要获取到用户所修改的值，并且将原有的Name覆盖掉。即可实现修改

   ```go
   var newName string
   	fmt.Print("Please change to new message:")
   	fmt.Scanln(&newName)
   	value.name = newName
   	// 更新学生的姓名
   	s.allStudent[StuId] = value
   ```

测试时间，示例如下：

首先我是添加了一个学生在里面，`Id:1,Name:Payne`.

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkziis5yxvj31020u044i.jpg)

### 实现删除学生功能

```go
func (s studentMgr) delStudent() {
	var studentID int64
	// 获取用户需删除的id
	fmt.Print("Please input want delete studentId：")
	fmt.Scanln(&studentID)
	// 去map里面查找，若有则删除。没有则退出重新选择
	value, ok := s.allStudent[studentID]
	if !ok {
		fmt.Println("Not found")
		return
	}
	fmt.Printf("You want delete student message:"+
		" Id: %d, Name:%s\n", value.id, value.name)
	delete(s.allStudent, studentID)
	fmt.Print("Deleted Successfully\n")
}
```

1. 首先我们需要删除，那么它是一定存在我们才能去删除。这个没毛病吧？我觉很ok。

   ```go
   	var studentID int64
   	// 获取用户需删除的id
   	fmt.Print("Please input want delete studentId：")
   	fmt.Scanln(&studentID)
   ```

2. 不存在提示未找到

   ```go
   value, ok := s.allStudent[studentID]
   	if !ok {
   		fmt.Println("Not found")
   		return
   	}
   	fmt.Printf("You want delete student message:"+
   		" Id: %d, Name:%s\n", value.id, value.name)
   ```

3. 存在进行修改

   ```go
   	fmt.Printf("You want delete student message:"+
   		" Id: %d, Name:%s\n", value.id, value.name)
   	delete(s.allStudent, studentID)
   	fmt.Print("Deleted Successfully\n")
   ```
