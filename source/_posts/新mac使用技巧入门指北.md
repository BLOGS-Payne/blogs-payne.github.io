---
title: 新mac使用技巧入门指北
author: Payne
tags: ["Mac"]
categories:
- ["Mac"]
date: 2021-04-26 19:59:17
---
当第一手拿到mac，第一件事也许是去。。。

然而我想要说的是，把基本的环境搭建一下，设置调配一下
<!--more-->
### 键盘、鼠标的灵敏度

这也是个人习惯吧，我个人比较畅想那种打字、拖鼠标丝滑的感觉

偏好设置 -> 鼠标灵敏度看自己感觉拉。

偏好设置 -> 键盘

> 个人建议拉满

![image-20210426191253111](https://tva1.sinaimg.cn/large/008i3skNly1gpxcygvyc2j31100mctht.jpg)



## 定制zsh编辑器

原生的mac，zsh是没有命令提示的，以及显示也并没有那么好看。自定制一下

#### 下载oh-my-zsh

```sh
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
```

#### 复制 .zshrc

```shell
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
```

#### 修改默认 shell(可选)

```sh
chsh -s /bin/zsh
```

在终端中新建一个窗口(快捷键：command + n），你就发现不一样的shell，如下图所示

![image-20210426191816929](https://tva1.sinaimg.cn/large/008i3skNly1gpxd433qdsj317o0e0wes.jpg)

#### 配置命令补全的插件

```shell
git clone git://github.com/zsh-users/zsh-autosuggestions ～/.oh-my-zsh/plugins/zsh-autosuggestions
```

#### 编辑 .zshrc 文件

找到`plugins=(git)`,修改成`plugins=(git zsh-autosuggestions)`

![](https://tva1.sinaimg.cn/large/008i3skNly1gpxee9jh16j30zc06wtb6.jpg)

#### 生效配置

```shell
source ~/.zshrc
```

此时你就可以看到一个全新的Terminal,快来试试吧。爽不爽自己知道

## HomeBrew

[HomeBrew官方地址](https://brew.sh/)

简单来说他是类似于`yum、apt`,mac的包管理工具，使用它我们可以非常简单、丝滑的下载大部分的包、或者软件

或许第一次可以尝试使用如下命令进行安装

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

由于种种原因，如果安装不上，可以使用华科大的源进行安装

```shell
/bin/bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install.sh)"
```

安装完成后，检查一下

```shell
brew update && brew upgrade && brew doctor
```

设置

```
git -C "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core" remote set-url origin https://github.com/Homebrew/homebrew-core
```

### kubectl 自动补全
> 由于我习惯于zsh终端。这里给出zsh的，后面还有bash的

```shell
source <(kubectl completion zsh)
```

如果是`bash`
```shell
# Automatic completion of command
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
```