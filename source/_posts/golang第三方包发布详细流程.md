---
title: golang第三方包发布详细流程
author: Payne
tags: ["Go", "git", "github"]
categories:
- ["Go", "git", "github"]
date: 2021-03-31 03:13:58
---
### 发布golang第三方包

事情是这样的，随着公司的业务的增长。各种重复的工作越来约多。CV久了就想在进一步的那啥，毕竟我懒，不是。我就想着能不能把那些重复cv的干脆写成一个第三方包，进行调用。咱不谈那些啥封装啥的，我也想过，我也做过。但无论咋封装，总不可能跨项目吧,还是需要。。。

所幸，还是有方法的，来吧，让我们发表第一个golang工具包
<!-- more -->
### 创建项目仓库

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2ghktr3vj31ml0u0abu.jpg)

1. 首先输入仓库的名字，我这里输入simpleExample，用来做演示
2. 这里选择public，公开。要不并不好拉
3. 选择需要添加的文件(可选)
4. 鼠标左键点击create repository创建此仓库

完成后就有一个名为simpleExample的项目仓库，如下图所示。

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2gnbyu4kj32620nm3zq.jpg)

如果`第三步`全都没选的话就是另外一个图了

> 这一步还是很简单的，毕竟github，全球最大的程序员交友网站不是。2110年了相信大家还是都会用的，是实在不会的，可自行百度，或者Google。

### 拉取仓库，编辑示例代码

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2gtep6b6j31hs0nigmr.jpg)

第一步，鼠标左键点击code

第二步，点击后面类似于粘贴板的东西，复制https的URL

然后在cd到GOPATH中使用git，把这个项目clone下来

例如，我在这里的使用的git命令如下

```sh
git clone https://github.com/Golzaes/simpleExample.git
```

执行成功后使用 `ls`命令查看一下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2gzfqf28j31f2032weo.jpg)

使用编辑器打开`simpleExample`这个项目文件夹，如下图所示

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2h1zo9gjj31fy0eugm9.jpg)

**go module初始化**

```diff
+ go mod init "github.com/Golzaes/simpleExample"
- go mod init "github.com/组织名/项目名" 
```

> 注意：这里的一定是`"github.com/组织名/项目名" `这样的格式

创建文件夹与示例代码

```go
// Example/example.go
package exampleCode

import "math/rand"

// ReadNumber create random number
func ReadNumber() int {
	// random number range
	rnr := 10
	//  returns, as an int, a non-negative pseudo-random number in [0,n)
	return rand.Intn(rnr)
}
```

> 注意这里的函数名`ReadNumber`，首字母必须大写！！！
>
> 否则无法再外部调用此函数

来个简单的单元测试

```go
// Example/example_test.go
package exampleCode

import "testing"

func TestReadNumber(t *testing.T) {
	tests := []struct {
		name string
		want int
	}{
		// TODO: Add test cases.
		{
			"exampleCode1",
			1,
		}, {
			"exampleCode2",
			2,
		}, {
			"exampleCode3",
			3,
		}, {
			"exampleCode4",
			4,
		},{
			"exampleCode5",
			5,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := ReadNumber(); got != tt.want {
				t.Errorf("ReadNumber() = %v, want %v", got, tt.want)
			}
		})
	}
}
```

运行测试

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2hje5s3pj31m20u0dhw.jpg)

有个测试过了，说明我们的代码没有问题，也可以外部调用

### 推送与发布代码

使用以下命令，提交与push

```
git add exampleCode/
git commit -am "add exampleCode"
git push origin master
```

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2hmyx0dlj31ws0u0409.jpg)

仔细对比就会发现，这里多了个`exampleCode`文件夹。到这里我们就已经将代码push到了github，接下来我们发布一个，这样我们可以在另外一个项目中以第三方包的形式使用

第一步，点击releases下面的create a new releases

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2hsentogj322q0smgn2.jpg)



先 填写标签号(常规格式是 x.y.z)例如我的`v0.0.1`,

填写发表的标题，一般是项目名

填写简介

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2hvvs1bsj31pk0u0tal.jpg)

然后鼠标左键点击 左下方的`publish release`，进行发布，发布完成后会自动跳转到如下图所示的发布栏

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2i0che88j323z0u0zl9.jpg)

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2i0zg0g6j327e0qm3zw.jpg)

至此，发布部分就已经完成了。那么自己来测试一下这个第三方包



### 使用发布的第三方包

新建一个项目、go mod init初始化、创建文件夹就不过多赘述了



下载我们发布的包

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2i6hgxrnj31ai044t8u.jpg)

```sh
go get github.com/Golzaes/simpleExample/exampleCode
```



![](https://tva1.sinaimg.cn/large/008eGmZEgy1gp2ibah1b2j31gt0u0my1.jpg)

在项目中import 这个包

### 小结

本文从创建仓库开始到发布第三方包后到使用第三方包，这样我们就可以跨项目使用啦。

如果测试未完成，请重新查阅。尤其是注意点！！！


