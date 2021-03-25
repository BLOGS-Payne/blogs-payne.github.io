---
title: go代码测试
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2021-02-18 20:43:26
---
我们来了解golang的测试之前我们，先了解一下go语言自带的测试工具

## go test工具

Go语言中的测试依赖`go test`命令。编写测试代码和编写普通的Go代码过程是类似的，并不需要学习新的语法、规则或工具。

go test命令是一个按照一定约定和组织的测试代码的驱动程序。在包目录内，所有以`_test.go`为后缀名的源代码文件都是`go test`测试的一部分，不会被`go build`编译到最终的可执行文件中。

在`*_test.go`文件中有三种类型的函数，单元测试函数、基准测试函数和示例函数。

|   类型   |         格式          |              作用              |
| :------: | :-------------------: | :----------------------------: |
| 测试函数 |   函数名前缀为Test    | 测试程序的一些逻辑行为是否正确 |
| 基准函数 | 函数名前缀为Benchmark |         测试函数的性能         |
| 示例函数 |  函数名前缀为Example  |       为文档提供示例文档       |

#### 运行流程

`go test`命令会遍历所有的`*_test.go`文件中符合上述命名规则的函数，然后生成一个临时的main包用于调用相应的测试函数，然后构建并运行、报告测试结果，最后清理测试中生成的临时文件。

## 单元测试

> 以下是来自wiki对于单元测试的定义

在[计算机编程](https://zh.wikipedia.org/wiki/计算机编程)中，**单元测试**（英语：Unit Testing）又称为**模块测试**，是针对[程序模块](https://zh.wikipedia.org/wiki/模組_(程式設計))（[软件设计](https://zh.wikipedia.org/wiki/软件设计)的最小单位）来进行正确性检验的测试工作。程序单元是应用的最小可测试部件。在[过程化编程](https://zh.wikipedia.org/wiki/過程化編程)中，一个单元就是单个程序、函数、过程等；对于面向对象编程，最小单元就是方法，包括基类（超类）、抽象类、或者派生类（子类）中的方法。

通常来说，程序员每修改一次程序就会进行最少一次单元测试，在编写程序的过程中前后很可能要进行多次单元测试，以证实程序达到[软件规格书](https://zh.wikipedia.org/wiki/規格_(技術標準))要求的工作目标，没有[程序错误](https://zh.wikipedia.org/wiki/Bug)；虽然单元测试不是必须的，但也不坏，这牵涉到[项目管理](https://zh.wikipedia.org/wiki/專案管理)的政策决定。

每个理想的[测试案例](https://zh.wikipedia.org/wiki/测试案例)独立于其它案例；为测试时隔离模块，经常使用stubs、mock[[1\]](https://zh.wikipedia.org/wiki/单元测试#cite_note-mocksarentstubs-1)或fake等测试[马甲程序](https://zh.wikipedia.org/w/index.php?title=马甲程序&action=edit&redlink=1)。单元测试通常由[软件开发人员](https://zh.wikipedia.org/w/index.php?title=软件开发人员&action=edit&redlink=1)编写，用于确保他们所写的代码符合软件需求和遵循[开发目标](https://zh.wikipedia.org/w/index.php?title=开发目标&action=edit&redlink=1)。它的实施方式可以是非常手动的（透过纸笔），或者是做成[构建自动化](https://zh.wikipedia.org/wiki/構建自動化)的一部分。

简单来说，单元测试就是程序员自己对于自己的代码进行测试，而一个单元就是单个程序、函数、过程等；对于面向对象编程，最小单元就是方法，包括基类（超类）、抽象类、或者派生类（子类）中的方法。

更有一种开发手法，那就是TDD（Test Driven Development）,测试驱动开发。期望局部最优到全局最优，这个是一种非常不错的好习惯

> 请注意这里的局部最优的，局部，并不是函数内的详细。而是整个函数。甚至是一个类，等等。
>
> 因为有些函数内部的最优，并非这个函数的最优。这点我们需要格外的注意。若有兴趣，可了解一下有点关系的贪心算法

### 测试函数格式

其中参数`t`用于报告测试失败和附加的日志信息。 `testing.T`的拥有的方法如下：

```go
func (c *T) Error(args ...interface{})
func (c *T) Errorf(format string, args ...interface{})
func (c *T) Fail()
func (c *T) FailNow()
func (c *T) Failed() bool
func (c *T) Fatal(args ...interface{})
func (c *T) Fatalf(format string, args ...interface{})
func (c *T) Log(args ...interface{})
func (c *T) Logf(format string, args ...interface{})
func (c *T) Name() string
func (t *T) Parallel()
func (t *T) Run(name string, f func(t *T)) bool
func (c *T) Skip(args ...interface{})
func (c *T) SkipNow()
func (c *T) Skipf(format string, args ...interface{})
func (c *T) Skipped() bool
```

说了这么多，那么我们来实现一个`简单的`string中的Split函数，并对他进行单元测试，然后我们在剖析代码。了解单元测试的相关规范

```go
// splits.go
package splitStr

import (
	"strings"
)

// split package with a single split function.

// Split slices s into all substrings separated by sep and
// returns a slice of the substrings between those separators.
func Split(s, sep string) (result []string) {
	i := strings.Index(s, sep)
	for i > -1 {
		result = append(result, s[:i])
		s = s[i+1:]
		i = strings.Index(s, sep)
	}
	result = append(result, s)
	return
}

// split_test.go
package splitStr

import (
	"reflect"
	"testing"
)

// TestSplit 单元测试
func TestSplit(t *testing.T) { // 测试函数名必须以Test开头，必须接收一个*testing.T类型参数
	got := Split("a:b:c", ":")         // 程序输出的结果
	want := []string{"a", "b", "c"}    // 期望的结果
	if !reflect.DeepEqual(want, got) { // 因为slice不能直接比较，借助反射包中的方法比较
		t.Errorf("excepted:%v, got:%#v", want, got) // 测试失败输出错误提示
	}
}

// TestSplit2 单元测试组
func TestSplit2(t *testing.T) {
	// 定义一个测试用例类型
	type test struct {
		input string
		sep   string
		want  []string
	}
	// 定义一个存储测试用例的切片
	tests := []test{
		{input: "a:b:c", sep: ":", want: []string{"a", "b", "c"}},
		{input: "a:b:c", sep: ",", want: []string{"a:b:c"}},
		{input: "abcd", sep: "bc", want: []string{"a", "d"}},
	}
	// 遍历切片，逐一执行测试用例
	for _, tc := range tests {
		got := Split(tc.input, tc.sep)
		if !reflect.DeepEqual(got, tc.want) {
			t.Errorf("excepted:%v, got:%#v", tc.want, got)
		}
	}
}
```

运行结果如下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnrolzdwnuj318y0dq3z2.jpg)

说明测试成功，本次通过。当然你也可以在`Terminal`里面直接运行`go test`，命令，如下所示

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnropdatxhj30oa0bg0t4.jpg" style="zoom:70%;" />



> 温馨提示：关于可能造成运行test不成功原因
>
> 直接在`split_test.go`,运行。
>
> - 我们或许知道，go是以文件夹的方法来区分项目。所以当前文件，并不能跑到旁边文件中去找到`Split`,以至于测试失败。或未达到预期效果
>
> 那么正确的打开方式应该是？
>
> 在goland中，鼠标右键点击run测试文件所在的文件夹，选择后面第二个 `go test projectFileName`
>
> 在`Terminal`中，应在`测试文件所在的文件夹`的路径中，进行`go test [arge...]`

示例看完了，那么我们进行简单的剖析。我们先从函数文件说起，(也就是这里的`splits.go`)

1. 不在是`package main`,而是`packge projectFileName`
2. 函数名大写，大写意味着公有函数，可支持外部调用

测试文件

1. 文件名为'*_test.go'
2. 不在是`package main`,而是`packge projectFileName`
3. 函数名为TestFuncName



## 基准测试

### 基准测试函数格式

基准测试就是在一定的工作负载之下检测程序性能的一种方法。基准测试的基本格式如下：

```go
func BenchmarkName(b *testing.B){
    // ...
}
```

基准测试以`Benchmark`为前缀，需要一个`*testing.B`类型的参数b，基准测试必须要执行`b.N`次，这样的测试才有对照性，`b.N`的值是系统根据实际情况去调整的，从而保证测试的稳定性。 `testing.B`拥有的方法如下：

```go
func (c *B) Error(args ...interface{})
func (c *B) Errorf(format string, args ...interface{})
func (c *B) Fail()
func (c *B) FailNow()
func (c *B) Failed() bool
func (c *B) Fatal(args ...interface{})
func (c *B) Fatalf(format string, args ...interface{})
func (c *B) Log(args ...interface{})
func (c *B) Logf(format string, args ...interface{})
func (c *B) Name() string
func (b *B) ReportAllocs()
func (b *B) ResetTimer()
func (b *B) Run(name string, f func(b *B)) bool
func (b *B) RunParallel(body func(*PB))
func (b *B) SetBytes(n int64)
func (b *B) SetParallelism(p int)
func (c *B) Skip(args ...interface{})
func (c *B) SkipNow()
func (c *B) Skipf(format string, args ...interface{})
func (c *B) Skipped() bool
func (b *B) StartTimer()
func (b *B) StopTimer()
```

### 基准测试示例

我们为我们自己写的`Split`函数编写基准测试如下：

```go
// BenchmarkSplit 基准测试(性能测试)
func BenchmarkSplit(b *testing.B) {
	for i := 0; i <b.N ; i++ {
		Split("abcdebdae", "b")
	}
}

// 输出结果如下
goos: darwin
goarch: amd64
pkg: Gp/part5/splitStr
BenchmarkSplit
BenchmarkSplit-8   	 5740642	       209 ns/op
PASS
ok  	Gp/part5/splitStr	1.963s
```

> 其中
>
> BenchmarkSplit：表示对Split函数进行基准测试
>
> BenchmarkSplit-8：数字`8`表示`GOMAXPROCS`的值，这个对于并发基准测试很重要
>
> 5188407和206 ns/op：表示每次调用`Split`函数耗时`203ns`

我们还可以为基准测试添加`-benchmem`参数，来获得内存分配的统计数据。

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnrw3i5yuej312k07adg0.jpg)

>  112 B/op：表示每次操作内存分配了112字节
>
> `3 allocs/op`：则表示每次操作进行了3次内存分配！！！

优化后代码如下

```go
// split.go
func Split(s, sep string) (result []string) {
	i := strings.Index(s, sep)
  // 手动分配固定内存，避免多次创建
	result = make([]string, 0, strings.Count(s, sep)+1)
	for i > -1 {
		result = append(result, s[:i])
		s = s[i+len(sep):] // 这里使用len(sep)获取sep的长度
		i = strings.Index(s, sep)
	}
	result = append(result, s)
	return
}
```

优化后代码如下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnrx800j18j314g07gjrk.jpg)

> 这个使用make函数提前分配内存的改动，减少了2/3的内存分配次数，并且减少了一半的内存分配。
>
> 仅仅小小的一处改动，就引起如此大的性能改变。so good
>
> 量变产生质变

### 性能比较函数

上面的基准测试只能得到给定操作的绝对耗时，但是在很多性能问题是发生在两个不同操作之间的相对耗时，比如同一个函数处理1000个元素的耗时与处理1万甚至100万个元素的耗时的差别是多少？再或者对于同一个任务究竟使用哪种算法性能最佳？我们通常需要对两个不同算法的实现使用相同的输入来进行基准比较测试。

性能比较函数通常是一个带有参数的函数，被多个不同的Benchmark函数传入不同的值来调用。举个例子如下：

```go
func benchmark(b *testing.B, size int){/* ... */}
func Benchmark10(b *testing.B){ benchmark(b, 10) }
func Benchmark100(b *testing.B){ benchmark(b, 100) }
func Benchmark1000(b *testing.B){ benchmark(b, 1000) }
```

例如我们编写了一个计算斐波那契数列的函数如下：

```go
// fib.go

// Fib 是一个计算第n个斐波那契数的函数
func Fib(n int) int {
	if n < 2 {
		return n
	}
	return Fib(n-1) + Fib(n-2)
}
```

我们编写的性能比较函数如下：

```go
// fib_test.go

func benchmarkFib(b *testing.B, n int) {
	for i := 0; i < b.N; i++ {
		Fib(n)
	}
}

func BenchmarkFib1(b *testing.B)  { benchmarkFib(b, 1) }
func BenchmarkFib2(b *testing.B)  { benchmarkFib(b, 2) }
func BenchmarkFib3(b *testing.B)  { benchmarkFib(b, 3) }
func BenchmarkFib10(b *testing.B) { benchmarkFib(b, 10) }
func BenchmarkFib20(b *testing.B) { benchmarkFib(b, 20) }
func BenchmarkFib40(b *testing.B) { benchmarkFib(b, 40) }
```

运行基准测试：

```bash
split $ go test -bench=.
goos: darwin
goarch: amd64
pkg: github.com/Q1mi/studygo/code_demo/test_demo/fib
BenchmarkFib1-8         1000000000               2.03 ns/op
BenchmarkFib2-8         300000000                5.39 ns/op
BenchmarkFib3-8         200000000                9.71 ns/op
BenchmarkFib10-8         5000000               325 ns/op
BenchmarkFib20-8           30000             42460 ns/op
BenchmarkFib40-8               2         638524980 ns/op
PASS
ok      github.com/Q1mi/studygo/code_demo/test_demo/fib 12.944s
```

这里需要注意的是，默认情况下，每个基准测试至少运行1秒。如果在Benchmark函数返回时没有到1秒，则b.N的值会按1,2,5,10,20,50，…增加，并且函数再次运行。

最终的BenchmarkFib40只运行了两次，每次运行的平均值只有不到一秒。像这种情况下我们应该可以使用`-benchtime`标志增加最小基准时间，以产生更准确的结果。例如：

```bash
split $ go test -bench=Fib40 -benchtime=20s
goos: darwin
goarch: amd64
pkg: github.com/Q1mi/studygo/code_demo/test_demo/fib
BenchmarkFib40-8              50         663205114 ns/op
PASS
ok      github.com/Q1mi/studygo/code_demo/test_demo/fib 33.849s
```

这一次`BenchmarkFib40`函数运行了50次，结果就会更准确一些了。

使用性能比较函数做测试的时候一个容易犯的错误就是把`b.N`作为输入的大小，例如以下两个例子都是错误的示范：

```go
// 错误示范1
func BenchmarkFibWrong(b *testing.B) {
	for n := 0; n < b.N; n++ {
		Fib(n)
	}
}

// 错误示范2
func BenchmarkFibWrong2(b *testing.B) {
	Fib(b.N)
}
```