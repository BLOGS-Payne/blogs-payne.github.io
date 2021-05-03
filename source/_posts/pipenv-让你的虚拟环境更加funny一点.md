---
title: pipenv 让你的虚拟环境更加funny一点
author: Payne
tags: ["Python"]
categories:
- ["Python", "技术杂谈"]
date: 2020-12-22 00:34:28
---

## 什么是虚拟环境？

- 由[百度百科](https://cuiqingcai.com/[https://baike.baidu.com/item/虚拟环境/6529153?fr=aladdin](https://baike.baidu.com/item/虚拟环境/6529153?fr=aladdin) ) 得知： 以专利的实时动态程序行为修饰与模拟算法，直接利用本机的 OS，模拟出自带与本机相容 OS 的虚拟机（Vista 下可模拟 Vista、XP，Windows 7 下则可模拟 Windows 7、Vista、XP），也称为 “虚拟环境”
- 功能： 每一个环境都相当于一个新的 Python 环境。你可以在这个新的环境里安装库，运行代码等
<!--more-->
## 为什么需要使用虚拟环境？

- 众所周知 Python 的强大在于其兼容性，其强大的社区等。正因为第三方库多，层次不齐造成了许多的第三方库并不兼容
- 真实环境与虚拟环境二者相对关联，并非绝对关联，可以在虚拟环境里面随便造。
- 虚拟环境中进行了隔离，更方便我们部署上线

## 什么时候需要使用虚拟环境？

**例如：**

- 项目依赖版本不同时 
- 所需包与其他包(非此项目所需，但却存在)产生冲突时
- 等等

## 为什么虚拟环境使用`pipenv`好一点？

**Pipenv**是一种工具，旨在将所有包装领域（捆扎机，作曲家，npm，货物，纱线等）中的最佳产品引入Python世界。*Windows是我们世界上的头等公民。*

它会自动为您的项目创建和管理virtualenv，并`Pipfile`在您安装/卸载软件包时从您的软件包中添加/删除软件包。它还会生成非常重要的`Pipfile.lock`，用于生成确定性构建。

Pipenv的主要目的是为应用程序的用户和开发人员提供一种简单的方法来设置工作环境。有关库和应用程序之间的区别以及使用`setup.py`vs`Pipfile`定义依赖[项的区别](https://docs.pipenv.org/advanced/#pipfile-vs-setuppy)，请参见[☤Pipfile vs setup.py](https://docs.pipenv.org/advanced/#pipfile-vs-setuppy)。

Pipenv试图解决的问题是多方面的：

- 您不再需要使用`pip`和`virtualenv`分开。他们一起工作。
- 管理`requirements.txt`文件可能会出现问题，因此Pipenv使用`Pipfile`和`Pipfile.lock`将抽象依赖声明与上次测试的组合分开。
- 哈希值随处可见。安全。自动公开安全漏洞。
- 强烈建议使用最新版本的依赖项，以最大程度地减少由于过时的组件引起的安全风险。
- 让您深入了解依赖关系图（例如）。`$ pipenv graph`
- 通过加载`.env`文件来简化开发工作流程。

## pipenv安装

建议使用`pip3`, mac还是服务器上的Linux一般都会有`python2.x`版本。在这种场景大多情况下，`pip`指向`python2.x`,并非`python3.x`

```sh
pip3 install --upgrade pip
# 推荐使用pip来安装
pip3 install pipenv
```

其他几种安装方式

```sh
# If you’re on MacOS, you can install Pipenv easily with Homebrew:
brew install pipenv

# Or, if you’re using Fedora 28:
sudo dnf install pipenv

# if you're using centos
sudo yum install -y pipenv
```

反正安装都一样,无论是使用其他的包管理工具还是pip，都可以

## 创建虚拟环境

```sh
# python3 环境创建
pipenv --python 3.x
pipenv --three
pipenv install

# 创建完成后，虚拟环境的pip。并不是你真实环境的pip版本，如果有需要，需要升级一下pip 的版本
python3 -m pip install --upgrade pip
```

> 值得一提的是，首先必须得安装了相对应的Python 版本才能创建虚拟环境。可能点萌萌哒。举个栗子，例如我的电脑环境中只有python3.7，而我想创建一个python2.7 这样是不能创建的
>
> Pip3安装的pipenv 只能python3 只能使用

## 安装删除第三方库

```sh
pipenv install packageName

# 安装多个包，中间以空格分隔即可
pipenv install packageName-1 packageName-2 packageNama-3

pipenv uninstall packageName
```

## Terminal激活虚拟环境

```sh
pipenv shell
```

> - 此时终端会在最前面显示``(xxx)``, xxx一般为项目文件名。证明退出成功
> - 并不需要关心虚拟环境的具体位置，只需要在当前目录下。有`Pipfile`即可

## Terminal中退出虚拟环境

在其他包的虚拟环境中退出可能是使用`deactivate`,在conda 中使用`conda deactivate`,而在pipenv 中直接使用

```sh
exit
# 即可退出
```

> 如果使用deactivate，然后在使用`pipenv shell`,造成本终端页面进入虚拟环境失败。请参考勘误2

## 删除虚拟环境

在此项目目录下只需一下命令

```sh
pipenv --rm 
```

## 镜像源安装第三方包

我相信你也和我一样遇见过或尽力过下载第三方包失效包很慢，或者干脆出现`timeout`导致第三方包下载失败的情况，那么接下来让我们来使用国内的镜像源进行安装第三方包。速度嗖嗖嗖～

### 单一的安装

```sh
# 以requests 为栗子
 pipenv install requests  --pypi-mirror https://pypi.tuna.tsinghua.edu.cn/simple/
```

### 修改配置文件

使用pipenv创建虚拟环境之后会在项目目录下生成`Pipfile`,的文件。

```sh
# Pipfile
[[source]]
url = "https://pypi.tuna.tsinghua.edu.cn/simple/"
verify_ssl = true
name = "pypi"

[packages]
requests = "*"

[dev-packages]

[requires]
python_version = "3.8"

```

### 获取包依赖

我们可以使用命令来清晰地呈现出当前安装的 Python 包版本及之间的依赖关系，命令如下：

```
pipenv graph
```

> ~ ProjectNote % pipenv graph
> lxml==4.6.2
> requests==2.25.1
>
>   - certifi [required: >=2017.4.17, installed: 2020.12.5]
>   - chardet [required: >=3.0.2,<5, installed: 4.0.0]
>   - idna [required: >=2.5,<3, installed: 2.10]
>   - urllib3 [required: >=1.21.1,<1.27, installed: 1.26.2]

### 产生 Pipfile.lock

有时候可能 Pipfile.lock 文件不存在或被删除了，这时候我们可以使用如下命令生成：

```
pipenv lock
```

以上就是pipenv基础使用了，但这还不够哦。接下来让我们深入探究一下

## 不知道但常用

```sh
Usage: pipenv [OPTIONS] COMMAND [ARGS]...

Options:
  --where                         Output project home information.
  --venv                          Output virtualenv information.
  --py                            Output Python interpreter information.
  --envs                          Output Environment Variable options.
  --rm                            Remove the virtualenv.
  --bare                          Minimal output.
  --completion                    Output completion (to be executed by the
                                  shell).

  --man                           Display manpage.
  --support                       Output diagnostic information for use in
                                  GitHub issues.

  --site-packages / --no-site-packages
                                  Enable site-packages for the virtualenv.
                                  [env var: PIPENV_SITE_PACKAGES]

  --python TEXT                   Specify which version of Python virtualenv
                                  should use.

  --three / --two                 Use Python 3/2 when creating virtualenv.
  --clear                         Clears caches (pipenv, pip, and pip-tools).
                                  [env var: PIPENV_CLEAR]

  -v, --verbose                   Verbose mode.
  --pypi-mirror TEXT              Specify a PyPI mirror.
  --version                       Show the version and exit.
  -h, --help                      Show this message and exit.


Usage Examples:
   Create a new project using Python 3.7, specifically:
   $ pipenv --python 3.7

   Remove project virtualenv (inferred from current directory):
   $ pipenv --rm

   Install all dependencies for a project (including dev):
   $ pipenv install --dev

   Create a lockfile containing pre-releases:
   $ pipenv lock --pre

   Show a graph of your installed dependencies:
   $ pipenv graph

   Check your installed dependencies for security vulnerabilities:
   $ pipenv check

   Install a local setup.py into your virtual environment/Pipfile:
   $ pipenv install -e .

   Use a lower-level pip command:
   $ pipenv run pip freeze

Commands:
  check      Checks for PyUp Safety security vulnerabilities and against PEP
             508 markers provided in Pipfile.

  clean      Uninstalls all packages not specified in Pipfile.lock.
  graph      Displays currently-installed dependency graph information.
  install    Installs provided packages and adds them to Pipfile, or (if no
             packages are given), installs all packages from Pipfile.

  lock       Generates Pipfile.lock.
  open       View a given module in your editor.
  run        Spawns a command installed into the virtualenv.
  scripts    Lists scripts in current environment config.
  shell      Spawns a shell within the virtualenv.
  sync       Installs all packages specified in Pipfile.lock.
  uninstall  Uninstalls a provided package and removes it from Pipfile.
  update     Runs lock, then sync.
```

### 在真实环境中使用虚拟环境中包并运行

> 场景如下：
>
> 假设正式环境中为一个干净的仓库,有且仅有初始的包
>
> 虚拟环境中有所需要的第三方包。
>
> 如何实现在真实环境中使用虚拟环境中的第三方包并运行

```
pipenv run python xxx.py
```

### 产生 Pipfile.lock

有时候可能 Pipfile.lock 文件不存在或被删除了，这时候我们可以使用以下命令生成：

```
pipenv lock
```

## 批量安装第三方依赖包

部署的时候只需要将此执行一下命令即可安装所有的依赖包，它是依靠Pipfile.lock的

```sh
pipenv sync
```

### 示例:使用pipenv 对接docker或其他的部署

只说不做假把式，只做不说傻把式。搞了这么多，来个case实现与项目接轨吧。这里为以docker部署为栗子

首先在项目中我们也使用虚拟环境去开发,当然也建议这样去做。没错，我是在教你做事。嘻嘻～

此时的项目应该差不多如下,此时两个为必须存在一个是`Pipfile`, 一个是项目文件(文件夹)。`deploy`，`Dockerfile`为后实现

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glvroonkofj30ly07i0so.jpg)

书写Dockerfile，拿docker部署没有Dockerfile是不阔能滴

Dockerfile实现如下,可以按需修改

```dockerfile
FROM python:3.8
COPY . /code
WORKDIR /code
RUN sh deploy.sh
CMD ["pipenv", "run", "python3", "testfile.py"]
```

Deploy.sh如下

其实deploy 其中的内容可以直接放到dockerfile中，我自己喜欢这样。更加清晰一点。啊，如此清晰的逻辑与结构，无敌～。我又在教你做事，大哥别杀我

```sh
# 保持pip版本为最新版，及安装pipenv
python3 -m pip install --upgrade pip  && pip3 install pipenv
# 创建虚拟环境
pipenv --python 3.8
# 安装环境依赖(第三方包)
pipenv update
```

> 这里需要注意的是，我建议你使用`pipenv update`,更加保险。
>
> 什么， 你问我为什么不用sync？
>
> 既然你诚心诚意的发问了，那我就大发慈悲的告诉你吧。哈哈～
>
> `pipenv update`相当于执行了`pipenv lock`和`pipenv sync`两个命令
>
> 如果用`pipenv sync`，而此时的你如果没有`Pipfile.lock`,那岂不是很尬

Docker build 执行结果如下

```sh
Sending build context to Docker daemon  99.33kB
Step 1/5 : FROM python:3.8
 ---> d1bfb3dd9268
Step 2/5 : WORKDIR /code
 ---> Running in 74cda17b1483
Removing intermediate container 74cda17b1483
 ---> ecfd46d28538
Step 3/5 : COPY . /code
 ---> 8a89f329a4f9
Step 4/5 : RUN pip install pipenv && sh deploy.sh
 ---> Running in cea95051d481
Collecting pipenv
  Downloading pipenv-2020.11.15-py2.py3-none-any.whl (3.9 MB)
Requirement already satisfied: setuptools>=36.2.1 in /usr/local/lib/python3.8/site-packages (from pipenv) (51.0.0)
Requirement already satisfied: pip>=18.0 in /usr/local/lib/python3.8/site-packages (from pipenv) (20.3.3)
Collecting virtualenv-clone>=0.2.5
  Downloading virtualenv_clone-0.5.4-py2.py3-none-any.whl (6.6 kB)
Collecting certifi
  Downloading certifi-2020.12.5-py2.py3-none-any.whl (147 kB)
Collecting virtualenv
  Downloading virtualenv-20.2.2-py2.py3-none-any.whl (5.7 MB)
Collecting appdirs<2,>=1.4.3
  Downloading appdirs-1.4.4-py2.py3-none-any.whl (9.6 kB)
Collecting distlib<1,>=0.3.1
  Downloading distlib-0.3.1-py2.py3-none-any.whl (335 kB)
Collecting filelock<4,>=3.0.0
  Downloading filelock-3.0.12-py3-none-any.whl (7.6 kB)
Collecting six<2,>=1.9.0
  Downloading six-1.15.0-py2.py3-none-any.whl (10 kB)
Installing collected packages: six, filelock, distlib, appdirs, virtualenv-clone, virtualenv, certifi, pipenv
Successfully installed appdirs-1.4.4 certifi-2020.12.5 distlib-0.3.1 filelock-3.0.12 pipenv-2020.11.15 six-1.15.0 virtualenv-20.2.2 virtualenv-clone-0.5.4
Creating a virtualenv for this project...
Pipfile: /code/Pipfile
Using /usr/local/bin/python3.8 (3.8.6) to create virtualenv...
⠦ Creating virtual environment...created virtual environment CPython3.8.6.final.0-64 in 1079ms
  creator CPython3Posix(dest=/root/.local/share/virtualenvs/code-_Py8Si6I, clear=False, no_vcs_ignore=False, global=False)
  seeder FromAppData(download=False, pip=bundle, setuptools=bundle, wheel=bundle, via=copy, app_data_dir=/root/.local/share/virtualenv)
    added seed packages: pip==20.3.1, setuptools==51.0.0, wheel==0.36.1
  activators BashActivator,CShellActivator,FishActivator,PowerShellActivator,PythonActivator,XonshActivator
                                                                                                                                                                           ✔ Successfully created virtual environment! 
Virtualenv location: /root/.local/share/virtualenvs/code-_Py8Si6I
Installing dependencies from Pipfile.lock (d2a522)...
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
All dependencies are now up-to-date!
Removing intermediate container cea95051d481
 ---> 5bc79a1c17b6
Step 5/5 : CMD ["pipenv", "run", "python3", "testfile.py"]
 ---> Running in d86af926715c
Removing intermediate container d86af926715c
 ---> a64b6bc63353
Successfully built a64b6bc63353
Successfully tagged test:1
(ProjectNote) stringle-004@zhixiankeji-004s-MacBook-Pro ProjectNote % docker run  test:1
<Response [200]>
<!DOCTYPE html>
<!--STATUS OK--><html> <head><meta http-equiv=content-type content=text/html;charset=utf-8><meta http-equiv=X-UA-Compatible content=IE=Edge><meta content=always name=referrer><link rel=stylesheet type=text/css href=https://ss1.bdstatic.com/5eN1bjq8AAUYm2zgoY3K/r/www/cache/bdorz/baidu.min.css><title>百度一下，你就知道</title></head> <body link <div id=wrapper> <div id=head> <div class=head_wrapper> <div class=s_form> <div class=s_form_wrapper> <div id=lg> <img hidefocus=true src=//www.baidu.com/img/bd_logo1.png width=270 height=129> </div> <form id=form name=f action=//www.baidu.com/s class=fm> <input type=hidden name=bdorz_come value=1> <input type=hidden name=ie value=utf-8> <input type=hidden name=f value=8> <input type=hidden name=rsv_bp value=1> <input type=hidden name=rsv_idx value=1> <input type=hidden name=tn value=baidu><span class="bg s_ipt_wr"><input id=kw name=wd class=s_ipt value maxlength=255 autocomplete=off autofocus=autofocus></span><span class="bg s_btn_wr"><input type=submit id=su value=百度一下 clabg s_btn" autofocus></span> </form> </div> </div> <div id=u1> <a href=http://news.baidu.com name=tj_trnews class=mnav>新闻</a> <a href=https://www.hao123.com name=tj_trhao1 class=mnav>hao123</a> <a href=http://map.baidu.com name=tj_trmap class=mnav>地图</a> <a href=http://v.baidu.com name=tj_trvideo class=mnav>视频</a> <a href=http://tieba.bacom name=tj_trtieba class=mnav>贴吧</a> <noscript> <a href=http://www.baidu.com/bdorz/login.gif?login&amp;tpl=mn&amp;u=http%3A%2F%2Fwww.baidu.com%2f%3fbdorz_come%3d1 name=tlogin class=lb>登录</a> </noscript> <script>document.write('<a href="http://www.baidu.com/bdorz/login.gif?login&tpl=mn&u='+ encodeURIComponent(window.location.href+ (windowocation.search === "" ? "?" : "&")+ "bdorz_come=1")+ '" name="tj_login" class="lb">登录</a>');
                </script> <a href=//www.baidu.com/more/ name=tj_briicon class=bri style="display: block;">更多产品</a> </div> </div> </div> <div id=ftCon> <div id=ftConw> <p id=lh> <a href=http://home.baidu.com>关于百度</a> <a href=http://ir.baidu.com>About Baidu</a> </p> <p id=cp>&copy;2017&nbsp;Baidu&nbsp;<a href=http://www.baidu.com/duty/>前必读</a>&nbsp; <a href=http://jianyi.baidu.com/ class=cp-feedback>意见反馈</a>&nbsp;京ICP证030173号&nbsp; <img src=//www.baidu.com/img/gs.gif> </p> </div> </div> </div> <tml>

<Element html at 0x7fbfe776d100>
```

Docker 构建注意事项：

1. ```sh
   # Pipfile文件
   [requires]
   python_version = "3.8"
   
   # dockerfile
   FROM python:3.8
   
   这两个后面跟的版本号必须一致，否则将会构建失败
   ```

2. 使用`pipenv update `而不是`pipenv sync`,为什么，我就不告诉你了。看上面就好





## 勘误

### 1.pip版本过低造成安装失败

还记得我之前在服务器上，无论怎么安装就是安装不上，无论是其他包还是`pipenv`.后来硬是找不到什么原因。直到。。。

```sh
# 查看pip 版本
pip3 -V
# or
pip3 --version
```

> 输出结果类似如下
>
> ```sh
> ~ % pip3 -V
> pip 20.3.3 from /usr/local/lib/python3.9/site-packages/pip (python 3.9)
> ```

如果pip 的版本还不是20版本的，需要进行升级

```sh
# 推荐
python3 -m pip install --upgrade pip [--user]
# 或者
python3 -m pip install -U pip [--user]
# 不推荐
pip3 install --upgrade pip
pip3 install -U pip
```

> - 其中[--user] 为可选参数，最好加上。一般情况下不加也没事
>
> - `-m`:run library module as a script (terminates option list) 将库模块作为脚本运行（终止选项列表）

### 2.虚拟环境重载错误

之前使用其他的python虚拟环境工具的时候，使用`deactivate`,退出虚拟环境。而`pipenv`, 并不是这样

使用`deactivate`,退出虚拟环境后又使用`pipenv shell, 进入虚拟环境，结果显示...

> Shell for UNKNOWN_VIRTUAL_ENVIRONMENT already activated.
> No action taken to avoid nested environments.

```sh
# 先exit 一下即可，然后使用
pipenv shell
# 即可重新进入虚拟环境
```

3. 创建虚拟环境需注意 
   pipenv 并不支持嵌套的虚拟环境，默认使用此文件的父级目录中的pipfile
   
   > 比如：在projectfile中有文件src-1，pipfile, src-2,如果进入src-1 中执行`pipenv install`or`pipenv --python 3.8`or `pipenv  tree`,中任何一个命令都会优先使用projectfile/pipfile
   >

## Referer

[pipenv官方文档](https://docs.pipenv.org/)

[pipenv pypi](https://pypi.org/project/pipenv/)
