---
title: Golang介绍
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:10:19
auhtor: Payne
---

> Go 语言开发包
>
> 国外：<https://golang.org/dl/>
>
> 国内(推荐)： <https://golang.google.cn/dl/>
>
> 编辑器
>
> - Golang:<https://www.jetbrains.com/go/> 
> - Visual Studio Code: <https://code.visualstudio.com/> 

搭建 Go 语言开发环境，需要先下载 Go 语言开发包。
<!--more-->
### 查看操作系统及版本

Windows：![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfvrumlwpj31fk0m70x2.jpg)

Mac:

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfvxbp6hmj317i0d21b8.jpg)

Linux:

终端输入`uname -a`,示例如下

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfw129kelj31qe03c0uw.jpg)
<!--more-->
### Golang语言开发包

![Golang开发包](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfvdmu9zsj31au0u0ap5.jpg)

MSI 安装的方式比较简单推荐使用

Windows 系统上推荐使用这种方式。现在的操作系统基本上都是 64 位的，所以选择 64 位的 go1.15.windows-amd64.msi 下载即可，如果操作系统是 32 位的，选择 go1.15.windows-386.msi 进行下载。

下载后双击该 MSI 安装文件，按照提示一步步地安装即可。在默认情况下，Go 语言开发工具包会被安装到 c:\Go 目录，你也可以在安装过程中选择自己想要安装的目录。

假设安装到 c:\Go 目录，安装程序会自动把 c:\Go\bin 添加到你的 PATH 环境变量中，如果没有的话，你可以通过系统 -> 控制面板 -> 高级 -> 环境变量选项来手动添加。示例如下

- 进入

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfwha3s32j31fk0kw77n.jpg)

- 配置

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfwhx99dij30uu0huwfx.jpg)

### macOS 下安装

如果你的操作系统是 macOS，可以采用 PKG 安装包。下载 `go1.15.darwin-amd64.pkg` 后，双击按照提示安装即可。安装成功后，路径` /usr/local/go/bin` 应该已经被添加到了 PATH 环境变量中。

如果没有的话，你可以手动添加，把如下内容添加到 /etc/profile 或者 $HOME/.profile 文件保存即可。命令如下

```sh
export PATH=$PATH:/usr/local/go/bin
```

BrewHome安装

```sh
# brewHome安装
brew install golang
```

### Linux

- 保护管理工具安装

```sh
# yum(Centos)
sudo yum -y update # 更新yum
sudo yum install -y golang
# apt(ubantu)
sudo apt -y update
sudo apt install -y golang
```

- 压缩包安装(安装前请查看操作系统版本)

```sh
# amd 版本
wget https://golang.google.cn/dl/go1.15.4.linux-amd64.tar.gz
# arm版本
https://golang.google.cn/dl/go1.15.4.linux-arm64.tar.gz

# 解压(amd)
sudo tar -C /usr/local/ -xzvf go1.15.4.linux-amd64.tar.gz
# 解压
sudo tar -C /usr/local/ -xzvf go1.15.4.linux-arm64.tar.gz

# 环境变量配置
# sudo vim /etc/profile
 export GOROOT=/usr/local/go
 export GOPATH=/home/bruce/go
 export GOBIN=$GOPATH/bin
 export PATH=$PATH:$GOROOT/bin
 export PATH=$PATH:$GOPATH/bin
# 环境变量生效
source /etc/profile
```

> `GOROOT`设置golang开发包的安装位置，我们解压到了`/usr/local/`目录，该目录下的`go/`文件夹一定是go的环境的根目录，就是打开`go`目录后别再有一个`go/`目录。
>
> `GOBIN`目录是执行 `go install` 后生成可执行文件的目录
>
> `GOPATH`是我们的工作目录，一般我们设置到用户目录下，这个要根据你电脑的实际情况去配置。在介绍一下go的工作目录结构。在我们设置的工作目录下有3个子目录

## 测试安装

```sh
# 任意目录下输入go version
go version go1.15.2 darwin/amd64
# 查看环境配置
go env

```

```sh
# go env
GO111MODULE="on"
GOARCH="amd64"
GOBIN=""
GOCACHE="/Users/stringle-004/Library/Caches/go-build"
GOENV="/Users/stringle-004/Library/Application Support/go/env"
GOEXE=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="darwin"
GOINSECURE=""
GOMODCACHE="/Users/stringle-004/go/pkg/mod"
GONOPROXY=""
GONOSUMDB=""
GOOS="darwin"
GOPATH="/Users/stringle-004/go"
GOPRIVATE=""
GOPROXY="https://goproxy.cn,direct"
GOROOT="/usr/local/go"		# golang开发包的安装位置
GOSUMDB="sum.golang.org"
GOTMPDIR=""
GOTOOLDIR="/usr/local/go/pkg/tool/darwin_amd64"
GCCGO="gccgo"
AR="ar"
CC="clang"
CXX="clang++"
CGO_ENABLED="1"
GOMOD="/Users/stringle-004/go/src/github.com/payne/awesomeProject/go.mod"
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -fno-caret-diagnostics -Qunused-arguments -fmessage-length=0 -fdebug-prefix-map=/var/folders/sb/__n99hm13ms08lkk2lv5pxj40000gn/T/go-build659271527=/tmp/go-build -gno-record-gcc-switches -fno-common"
```

### GOPROXY

Go1.14版本之后，都推荐使用`go mod`模式来管理依赖环境了，也不再强制我们把代码必须写在`GOPATH`下面的src目录了，你可以在你电脑的任意位置编写go代码。（网上有些教程适用于1.11版本之前。）

默认GoPROXY配置是：`GOPROXY=https://proxy.golang.org,direct`，由于国内访问不到`https://proxy.golang.org`，所以我们需要换一个PROXY，这里推荐使用`https://goproxy.io`或`https://goproxy.cn`。

可以执行下面的命令修改GOPROXY：

```sh
go env -w GOPROXY=https://goproxy.cn,direct
```

## 跨平台编译

Go 语言开发工具包的另一强大功能就是可以跨平台编译。什么是跨平台编译呢？

就是在 macOS 开发，可以编译 Linux、Window 等平台上的可执行程序，这样你开发的程序，就可以在这些平台上运行。也就是说，你可以选择喜欢的操作系统做开发，并跨平台编译成需要发布平台的可执行程序即可。

Go 语言通过两个环境变量来控制跨平台编译，它们分别是 `GOOS` 和 `GOARCH` 。

- GOOS：代表要编译的目标操作系统，常见的有 Linux、Windows、Darwin 等。

- GOARCH：代表要编译的目标处理器架构，常见的有 386、AMD64、ARM64 等。

这样通过组合不同的 GOOS 和 GOARCH，就可以编译出不同的可执行程序。比如我现在的操作系统是 macOS AMD64 的，我想编译出 Linux AMD64 的可执行程序，只需要执行 go build 命令即可，如以下代码所示：

关于 GOOS 和 GOARCH 更多的组合，参考官方文档的 $GOOS and $GOARCH 这一节即可

```
GOOS=linux GOARCH=amd64 go build /Users/stringle-004/go/main.go
```

关于 GOOS 和 GOARCH 更多的组合，参考[官方文档](https://golang.org/doc/install/source#environment)的 $GOOS and $GOARCH 这一节即可

## Go 编辑器

第一款是 Visual Studio Code + Go 扩展插件，可以让你非常高效地开发，通过[官方网站]( https://code.visualstudio.com/ )下载所对应操作系统版本的Visual Studio Code。

- 安装：略（进入官网，下载安装即可）
- Visual Studio Code + Go设置

#### 安装中文简体插件

点击左侧菜单栏最后一项`管理扩展`，在`搜索框`中输入`chinese` ，选中结果列表第一项，点击`install`安装。

安装完毕后右下角会提示`重启VS Code`，重启之后你的VS Code就显示中文啦！

`VSCode`主界面介绍：

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfxc8ujjej30y80lcgok.jpg)

#### 安装go扩展

现在我们要为我们的VS Code编辑器安装`Go`扩展插件，让它支持Go语言开发。

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfxc5nin1j30y80pw0xy.jpg)

#### 安装中文简体插件

点击左侧菜单栏最后一项`管理扩展`，在`搜索框`中输入`chinese` ，选中结果列表第一项，点击`install`安装。

安装完毕后右下角会提示`重启VS Code`，重启之后你的VS Code就显示中文啦！

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkfxc0dxgxg30xq0ppngg.gif)



第二款是老牌 IDE 公司 JetBrains 推出的 Goland，所有插件已经全部集成，更容易上手，并且功能强大，新手老手都适合，你可以通过官方网站 https://www.jetbrains.com/go/ 下载使用。

## 第一个Golang程序

```sh
package main			# 可执行文件必须为package main开头

import "fmt"			# 导入“fmt”包，用于打印（fmt.Print（打印）、fmt.Println（换行打印）、fmt.Printf(格式化打印)等）

func main() {			# 主函数main
	fmt.Print("你好，我叫payne")		# 输入
}
# 你好，我叫payne
```
