---
title: 使用Golang操作文件的那些事儿
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-28 00:11:57
---
## Golang 文件操作

Os模块的使用与源码研究

文件：计算机中的文件是存储在外部介质（通常是磁盘）上的数据集合，文件分为文本文件和二进制文件。例如咱们常见的文件后缀名`.exe`,`.txt`,'.word'...等等

文件的基本操作可简单分为`增`、`删`两类，也就是咱们所说的CURD(增删改查)，也是基于此两类操作。可简单理解为`打开文件夹`、`CURD`、关闭文件夹。结束～

golang对于文件基本上都是基于Golang的`os`模块，那让我们一起了解一下，那么Golang是如何对文件进行操作呢。Let's Go~
<!--more-->
### 打开文件

Golang中打开文件使用`os.Open`模块,官方os.open部分源码如下：

```go
// os.Open
// Open opens the named file for reading. If successful, methods on
// the returned file can be used for reading; the associated file
// descriptor has mode O_RDONLY.
// If there is an error, it will be of type *PathError.
func Open(name string) (*File, error) {
	return OpenFile(name, O_RDONLY, 0)
}
```

> Open打开命名文件以供读取。如果成功，则可以使用返回文件上的方法进行读取；关联的文件。描述符的模式为O_RDONLY。 如果有错误，它将是* PathError类型。
>
> 它接收一个string 类型的变量`name`,返回两个值，File的指针和错误error。那么我们使用它打开文件的的时候就需要这样做
>
> ```go
> fileObj, err := os.Open(name string)
> // 其中os.Open中的name为路径Path
> ```

基础使用的介绍暂且为止，其实我们更应该关心的应该是`OpenFile(name, O_RDONLY, 0)`，这个函数到底干了啥，我们追踪一下这个函数(在GoLang编辑器中， mac可以直接使用command + 鼠标左键直接进入，Win可以使用ctrl + 鼠标左键)，如下:

```go
func OpenFile(name string, flag int, perm FileMode) (*File, error) {
	testlog.Open(name)
	f, err := openFileNolog(name, flag, perm)
	if err != nil {
		return nil, err
	}
	f.appendMode = flag&O_APPEND != 0

	return f, nil
}
// OpenFile是广义的open调用；大多数用户将使用Open 或Create代替。它打开带有指定标志的命名文件（O_RDONLY等）。如果该文件不存在，并且传递了O_CREATE标志，则会使用模式perm（在umask之前）创建该文件。如果成功，返回文件上的方法可以用于I / O。 如果有错误，它将是* PathError类型。
```

这个文件全部内容还是有点分量的，有信息的伙伴，可以详细的阅读一下全部内容。暂且为止

那让我们实践一下，使用Golang打开文件，如下

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	// 打开此文件，./main.go为相对路径。在这里是此文件
	fileObj, err := os.Open("./main.go")
	// 异常处理
	if err != nil {
		fmt.Printf("Open File Error Message:%#v\n", err)
		return
	}
	// 尝试打印(此处输出的为地址值)
	fmt.Println(&fileObj)
	// defer 关闭文件
	defer fileObj.Close()
}

```

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gl44ct0b29j31fu0u07d6.jpg)

以防忘记关闭文件，造成bug，我们在这里使用defer + 关闭。

> 注意：在编辑器中并不建议直接使用鼠标右键运行，这样可能会导致路径错误。大部分的编辑器都并不是只运行此文件!!!
>
> ```sh
> Open File Error Message:&os.PathError{Op:"open", Path:"./main.go", Err:0x2}
> ```
>
> 如果你遇见了类似的错误，你可以直接在终端中，切换到当前路径。使用`go run main.go`，直接运行。这样就可以直接得到正确的结果啦

### 读取文件

打开文件之后，那么我们可以就可以对他们进行操作了，我们在这里主要演示一下读取文件的操作。还是老样子，先看一下主要的相关源码，如下:

```go
// FileObj.Read()
func (f *File) Read(b []byte) (n int, err error) {
	if err := f.checkValid("read"); err != nil {
		return 0, err
	}
	n, e := f.read(b)
	return n, f.wrapErr("read", e)
}

// f.read(b)
func (f *File) read(b []byte) (n int, err error) {
	n, err = f.pfd.Read(b)
	runtime.KeepAlive(f)
	return n, err
}
```

> FileObj.Read()
>
> 示例化接受文件的地址值(也就是咱们前面打开获取到的结果)，接受切片的字节，返回读取的内容，以及错误
>
> 在此函数中首先检查是否为有效的读取，然后在进行f.read(b)的操作,接受其返回结果。
>
> f.read(b)
>
> 在这里，主要检测是否在读取，如果是那么返回本次的读取内容

从以上我们不难看出，其实读取文件是读取文件内部的字节

那么更具FileObj.Read()，我们可以了解它基本的使用方法，如下

```go
func (f *File) Read(b []byte) (n int, err error)
```

读取部分的示例代码如下：

在这里我们需要考虑：是否能够正常读取？是否读完了？具体请看异常处理部分

```go
// 读取文件
	// 定义每次读取的大小
	//var tmp = make([]byte, 128)
	var tmp  [128]byte

	// n:从开始到结尾的内容
	n, err := fileObj.Read(tmp[:])
	// 异常处理
	if err != nil {
		fmt.Printf("Read of File Error, ErrorMessage:%#v\n", err)
		return
	}
	if err == io.EOF {
		fmt.Println("文件读完了")
		return
	}
	fmt.Printf("读取了%d个字节\n", n)
	fmt.Printf("读取到的内容：\n%s",tmp[:])
```

输出结果如下：

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gl453fvstjj30su0fg75h.jpg)

以上很明显是并没有读完的仅读取了部分，原始的全部代码如下

```go
package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	// 打开此文件，./main.go为相对路径。在这里是此文件
	fileObj, err := os.Open("./main.go")
	// 异常处理
	if err != nil {
		fmt.Printf("Open of File Error, ErrorMessage:%#v\n", err)
		return
	}
	// 尝试打印(此处输出的为地址值)
	fmt.Println(&fileObj)
	// defer 关闭文件
	defer fileObj.Close()

	// 读取文件
	// 定义每次读取的大小
	//var tmp = make([]byte, 128)
	var tmp  [128]byte

	// n:从开始到结尾的内容
	n, err := fileObj.Read(tmp[:])
	// 异常处理
	if err != nil {
		fmt.Printf("Read of File Error, ErrorMessage:%#v\n", err)
		return
	}
	if err == io.EOF {
		fmt.Println("文件读完了")
		return
	}
	fmt.Printf("读取了%d个字节\n", n)
	fmt.Printf("读取到的内容：\n%s",tmp[:])
}

```

### 完整读取

#### for无线循环读取

由于以上我们并没有读取完整个文件，那么我需要读取全部的该怎么办呢？一个方法是不断的读取下去，然后和在一起就是完整的内容了，示例代码如下

```go
package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	// 打开此文件，./main.go为相对路径。在这里是此文件
	fileObj, err := os.Open("./main.go")
	// 异常处理
	if err != nil {
		fmt.Printf("Open of File Error, ErrorMessage:%#v\n", err)
		return
	}
	// 尝试打印(此处输出的为地址值)
	fmt.Println(&fileObj)
	// defer 关闭文件
	defer fileObj.Close()
	// 循环读取文件
	var content []byte
	var tmp = make([]byte, 128)
	for {
		n, err := fileObj.Read(tmp)
		if err == io.EOF {
			fmt.Println("文件读完了")
			break
		}
		if err != nil {
			fmt.Printf("Read of File Error, ErrorMessage:%#v\n", err)
			return
		}
		content = append(content, tmp[:n]...)
	}
	fmt.Println(string(content))
}

```

主要的思路为：无限循环去读取，读完了之后break掉。然后把读取的内容合并起来

这种读取虽然可行，不过是否有点太麻烦了，那么有什么更简便的方式呢？答案当然是有的，bufio读取

#### bufio读取

bufio是在file的基础上封装了一层API，支持更多的功能。

主要的部分源码如下所示

```go
// bufio.NewReader
// NewReader returns a new Reader whose buffer has the default size.
func NewReader(rd io.Reader) *Reader {
	return NewReaderSize(rd, defaultBufSize)
}

// NewReaderSize
// NewReaderSize returns a new Reader whose buffer has at least the specified
// size. If the argument io.Reader is already a Reader with large enough
// size, it returns the underlying Reader.
func NewReaderSize(rd io.Reader, size int) *Reader {
	// Is it already a Reader?
	b, ok := rd.(*Reader)
	if ok && len(b.buf) >= size {
		return b
	}
	if size < minReadBufferSize {
		size = minReadBufferSize
	}
	r := new(Reader)
	r.reset(make([]byte, size), rd)
	return r
}
```

它简便的原因是因为已经帮我们定义了文件的指针，以及它还定义了缓冲区，这样我们使用它来读取更加的快与便捷。

 bufio.NewReader语法格式

```go
func NewReader(rd io.Reader) *Reader 
// 其中rd为我们打开文件的对象
```

使用如下

```go
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

func main() {
	// 打开此文件，./main.go为相对路径。在这里是此文件
	fileObj, err := os.Open("./main.go")
	// 异常处理
	if err != nil {
		fmt.Printf("Open of File Error, ErrorMessage:%#v\n", err)
		return
	}
	// 尝试打印(此处输出的为地址值)
	fmt.Println(&fileObj)
	// defer 关闭文件
	defer fileObj.Close()
	// bufio读取
	reader := bufio.NewReader(fileObj)
	for {
		line, err := reader.ReadString('\n') //注意是字符
		if err == io.EOF {
			if len(line) != 0 {
				fmt.Println(line)
			}
			fmt.Println("文件读完了")
			break
		}
		if err != nil {
			fmt.Println("read file failed, err:", err)
			return
		}
		fmt.Print(line)
	}
}
```

输入结果如上，略。。。

搞了这么多，就没有一键读取的么？当然也是有的，让我们来了体验一下`ioutil`读取整个文件的愉悦。

```
package main

import (
	"fmt"
	"io/ioutil"
)

// ioutil.ReadFile读取整个文件
func main() {
	content, err := ioutil.ReadFile("./main.go")
	if err != nil {
		fmt.Println("read file failed, err:", err)
		return
	}
	fmt.Println(string(content))
}
```

其内部的实现原理，先预测整个文件的大小。然后一次性全部读取。当然需要做好异常的准备哦

```go
// ReadFile reads the file named by filename and returns the contents.
// A successful call returns err == nil, not err == EOF. Because ReadFile
// reads the whole file, it does not treat an EOF from Read as an error
// to be reported.
func ReadFile(filename string) ([]byte, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	// It's a good but not certain bet that FileInfo will tell us exactly how much to
	// read, so let's try it but be prepared for the answer to be wrong.
	var n int64 = bytes.MinRead

	if fi, err := f.Stat(); err == nil {
		// As initial capacity for readAll, use Size + a little extra in case Size
		// is zero, and to avoid another allocation after Read has filled the
		// buffer. The readAll call will read into its allocated internal buffer
		// cheaply. If the size was wrong, we'll either waste some space off the end
		// or reallocate as needed, but in the overwhelmingly common case we'll get
		// it just right.
		if size := fi.Size() + bytes.MinRead; size > n {
			n = size
		}
	}
	return readAll(f, n)
}
```

### 文件写入操作

`os.OpenFile()`函数能够以指定模式打开文件，从而实现文件写入相关功能。

```go
func OpenFile(name string, flag int, perm FileMode) (*File, error) {
	...
}
```

其中：

`name`：要打开的文件名 `flag`：打开文件的模式。 模式有以下几种：

|     模式      |   含义   |
| :-----------: | :------: |
| `os.O_WRONLY` |   只写   |
| `os.O_CREATE` | 创建文件 |
| `os.O_RDONLY` |   只读   |
|  `os.O_RDWR`  |   读写   |
| `os.O_TRUNC`  |   清空   |
| `os.O_APPEND` |   追加   |

`perm`：文件权限，一个八进制数。r（读）04，w（写）02，x（执行）01。

#### Write和WriteString

```go
func main() {
	file, err := os.OpenFile(test.txt", os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0666)
	if err != nil {
		fmt.Println("open file failed, err:", err)
		return
	}
	defer file.Close()
	str := "hello"
	file.Write([]byte(str))       //写入字节切片数据
	file.WriteString("hello") //直接写入字符串数据
}
```

#### bufio.NewWriter

```go
func main() {
	file, err := os.OpenFile("xx.txt", os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0666)
	if err != nil {
		fmt.Println("open file failed, err:", err)
		return
	}
	defer file.Close()
	writer := bufio.NewWriter(file)
	for i := 0; i < 10; i++ {
		writer.WriteString("hello") //将数据先写入缓存
	}
	writer.Flush() //将缓存中的内容写入文件
}
```

#### ioutil.WriteFile

```go
func main() {
	str := "hello"
	err := ioutil.WriteFile("./asd.txt", []byte(str), 0666)
	if err != nil {
		fmt.Println("write file failed, err:", err)
		return
	}
}
```

so cool～