---
title: Supervisor-程序管理更加得心应手
author: Payne
tags: ["技术杂谈"]
categories:
  - ["技术杂谈"]
date: 2021-01-12 19:33:32
---


## Supervisor初探篇

### 简介

Supervisor是一个客户机/服务器系统(也就是非常经典的C/S结构)，它允许用户在类UNIX操作系统上``控制``许多进程。
<!--more-->
### 优点

- **简单便捷**

  > 通过简单易懂的配置文件配置Supervisor，即可对任务的管理与监控，它提供了重新启动失败的进程和自动日志轮换等功能。

- **集中**

  > 提供了一个开始，停止和监视的地方。可以单独或成组控制过程。配置Supervisor以提供本地或远程命令行和Web界面。

- **高效**

  > 通过fork / exec启动其子进程，并且子进程不守护。进程终止时，操作系统会立即向Supervisor发送信号

- 可扩展

  > Supervisor具有一个简单的事件通知协议，该协议可以使用任何语言编写的程序对其进行监视，并且具有用于控制的XML-RPC接口

- 兼容强

  > 除Windows之外，Supervisor几乎适用于所有事物。它已在Linux，Mac OS X，Solaris和FreeBSD上经过测试和支持。它完全用Python编写

- 久经考验

  > 尽管Supervisor如今非常活跃，但它不是新软件。Supervisor已经存在了很多年，并且已经在许多服务器上使用

听我说了这么多，相信你也和我一样迫不及待想了解它。嘿呀，不要着急。在学习使用它之前，我们对它的基础组成有个了解，以便于稍后更加得心应手的使用

### 主要组件

- supervisord
- supervisorctl
- Web Server
- XML-RPC Interface

在简介中提到`Supervisor是一个客户机/服务器系统(也就是非常经典的C/S结构)`,那么也在此介绍一下各个组件

**Supervisord:** 服务端的主管被称为**supervisord**。它负责自行调用启动子程序，响应来自客户端的命令，重新启动崩溃或退出的子进程，记录其子进程`stdout`和`stderr` 输出以及生成和处理与子进程生存期中的点相对应的“事件”。

> 服务器进程使用的配置文件位于`/etc/supervisord.conf中`，通过适当的文件系统权限确保此文件的安全(它包含未加密的用户名和密码,它可能是我们服务器的root密码)

**Supervisorctl**:客户端的主管被称为 **supervisorctl**, 它提供了类似于shell的界面,以便于我们使用命令对服务端的主管进行管理与控制。从supervisorctl我们可以连接到不同的supervisord进程（一次一个），获取受其控制的子进程的状态，停止和启动子进程，以及获取正在运行的supervisord进程的列表

> 命令行客户机通过UNIX域套接字或internet（TCP）套接字与服务器通信。服务器可以断言客户端的用户应该在允许他执行命令之前提供身份验证凭据。客户机进程通常使用与服务器相同的配置文件，但是任何带有[supervisorctl]节的配置文件都可以工作。

如果在internet套接字上启动supervisord，则可以通过浏览器访问功能类似于supervisorctl web用户界面。访问服务器URL（例如。http://ip：prot）激活配置文件的[inet http server]部分后，通过web界面查看和控制进程状态。

**XML-RPC接口**：服务于Web UI的同一HTTP服务器提供XML-RPC接口，该接口可用于询问和控制管理程序及其运行的程序。[*XML-RPC API文档*](http://supervisord.org/api.html#xml-rpc)。

---

## Supervisor使用技巧篇

### Supervisor的安装

supervisor支持了大多包管理工具进行安装

```sh
# pip(推荐)
pip install supervisor
# mac 
brew install supervisor
# ubantu
apt install supervisor
# centos
yum install supervisor
```

### Supervisor的使用

这里我们建立一个测试用的py文件，如下

```python
import sys
import time
from random import uniform
from loguru import logger


def test():
	i = 0
	while True:
		logger.info(i)
		randomTime = uniform(0, 1)
		logger.info(f'Sleep {randomTime}s')
		time.sleep(randomTime)
		i += 1
		if i == 10:
			sys.exit()


if __name__ == '__main__':
	test()

```

此时可以正常运行

> 温馨提示：这样的死循环记得一定要给休眠或者退出条件，要不将会有快乐的事情发生哦

运行如下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gml27kbhxdj30z20u0tbj.jpg)

**对接Supervisor**

```sh
# supervisord.conf
[supervisord]
nodaemon=true								 ;守护进程，默认fales
logfile_maxbytes=50MB        ;日志文件大小，超出会rotate，默认 50MB，如果设成0，表示不限制大小
logfile_backups=10           ;日志文件保留备份数量默认10，设为0表示不备份
loglevel=debug               ;日志级别，默认info，其它: debug,warn,trace


[program:demo]
process_name=tester
command=python3 demo.py
autostart=true       ; 在supervisord启动的时候也自动启动
startsecs=10         ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
```

使用`supervisord -c supervisord.conf`，运行程序。

输出日志入下

```
2021-01-12 17:57:21,705 INFO supervisord started with pid 1257
2021-01-12 17:57:22,712 INFO spawned: 'tester' with pid 1260
2021-01-12 17:57:22,856 DEBG 'tester' stderr output:
2021-01-12 17:57:22.855 | INFO     | __main__:test:10 - 0
2021-01-12 17:57:22.856 | INFO     | __main__:test:12 - Sleep 0.681474110840254s

2021-01-12 17:57:23,542 DEBG 'tester' stderr output:
2021-01-12 17:57:23.541 | INFO     | __main__:test:10 - 1

2021-01-12 17:57:23,542 DEBG 'tester' stderr output:
2021-01-12 17:57:23.541 | INFO     | __main__:test:12 - Sleep 0.34284895238537105s

2021-01-12 17:57:23,887 DEBG 'tester' stderr output:
2021-01-12 17:57:23.886 | INFO     | __main__:test:10 - 2

2021-01-12 17:57:23,887 DEBG 'tester' stderr output:
2021-01-12 17:57:23.887 | INFO     | __main__:test:12 - Sleep 0.08220508414530214s

2021-01-12 17:57:23,970 DEBG 'tester' stderr output:
2021-01-12 17:57:23.969 | INFO     | __main__:test:10 - 3

2021-01-12 17:57:23,971 DEBG 'tester' stderr output:
2021-01-12 17:57:23.970 | INFO     | __main__:test:12 - Sleep 0.39740491822333646s

2021-01-12 17:57:24,372 DEBG 'tester' stderr output:
2021-01-12 17:57:24.371 | INFO     | __main__:test:10 - 4

2021-01-12 17:57:24,372 DEBG 'tester' stderr output:
2021-01-12 17:57:24.371 | INFO     | __main__:test:12 - Sleep 0.9054854146830564s

2021-01-12 17:57:25,280 DEBG 'tester' stderr output:
2021-01-12 17:57:25.279 | INFO     | __main__:test:10 - 5

2021-01-12 17:57:25,281 DEBG 'tester' stderr output:
2021-01-12 17:57:25.280 | INFO     | __main__:test:12 - Sleep 0.4563320839294708s

2021-01-12 17:57:25,742 DEBG 'tester' stderr output:
2021-01-12 17:57:25.741 | INFO     | __main__:test:10 - 6

2021-01-12 17:57:25,742 DEBG 'tester' stderr output:
2021-01-12 17:57:25.741 | INFO     | __main__:test:12 - Sleep 0.19482948337371853s

2021-01-12 17:57:25,939 DEBG 'tester' stderr output:
2021-01-12 17:57:25.938 | INFO     | __main__:test:10 - 7

2021-01-12 17:57:25,940 DEBG 'tester' stderr output:
2021-01-12 17:57:25.939 | INFO     | __main__:test:12 - Sleep 0.7755167696398192s

2021-01-12 17:57:26,719 DEBG 'tester' stderr output:
2021-01-12 17:57:26.718 | INFO     | __main__:test:10 - 8

2021-01-12 17:57:26,719 DEBG 'tester' stderr output:
2021-01-12 17:57:26.718 | INFO     | __main__:test:12 - Sleep 0.24748008436152524s

2021-01-12 17:57:26,972 DEBG 'tester' stderr output:
2021-01-12 17:57:26.971 | INFO     | __main__:test:10 - 9

2021-01-12 17:57:26,973 DEBG 'tester' stderr output:
2021-01-12 17:57:26.972 | INFO     | __main__:test:12 - Sleep 0.6178291278890581s

2021-01-12 17:57:27,607 DEBG fd 13 closed, stopped monitoring <POutputDispatcher at 140666266690064 for <Subprocess at 140666266191824 with name tester in state STARTING> (stderr)>
2021-01-12 17:57:27,607 DEBG fd 11 closed, stopped monitoring <POutputDispatcher at 140666266190928 for <Subprocess at 140666266191824 with name tester in state STARTING> (stdout)>
2021-01-12 17:57:27,608 INFO exited: tester (exit status 0; not expected)
2021-01-12 17:57:27,608 DEBG received SIGCHLD indicating a child quit
2021-01-12 17:57:28,613 INFO spawned: 'tester' with pid 1263
2021-01-12 17:57:28,720 DEBG 'tester' stderr output:
2021-01-12 17:57:28.719 | INFO     | __main__:test:10 - 0
2021-01-12 17:57:28.720 | INFO     | __main__:test:12 - Sleep 0.8226218737496696s

2021-01-12 17:57:29,543 DEBG 'tester' stderr output:
2021-01-12 17:57:29.542 | INFO     | __main__:test:10 - 1

2021-01-12 17:57:29,544 DEBG 'tester' stderr output:
2021-01-12 17:57:29.543 | INFO     | __main__:test:12 - Sleep 0.6507710747677439s

2021-01-12 17:57:30,195 DEBG 'tester' stderr output:
2021-01-12 17:57:30.195 | INFO     | __main__:test:10 - 2

2021-01-12 17:57:30,196 DEBG 'tester' stderr output:
2021-01-12 17:57:30.195 | INFO     | __main__:test:12 - Sleep 0.3645783421505362s

2021-01-12 17:57:30,565 DEBG 'tester' stderr output:
2021-01-12 17:57:30.564 | INFO     | __main__:test:10 - 3

2021-01-12 17:57:30,565 DEBG 'tester' stderr output:
2021-01-12 17:57:30.565 | INFO     | __main__:test:12 - Sleep 0.47083797385643844s

2021-01-12 17:57:31,037 DEBG 'tester' stderr output:
2021-01-12 17:57:31.036 | INFO     | __main__:test:10 - 4

2021-01-12 17:57:31,037 DEBG 'tester' stderr output:
2021-01-12 17:57:31.037 | INFO     | __main__:test:12 - Sleep 0.4875197581833751s

2021-01-12 17:57:31,531 DEBG 'tester' stderr output:
2021-01-12 17:57:31.530 | INFO     | __main__:test:10 - 5

2021-01-12 17:57:31,531 DEBG 'tester' stderr output:
2021-01-12 17:57:31.530 | INFO     | __main__:test:12 - Sleep 0.9094546698090918s

2021-01-12 17:57:32,444 DEBG 'tester' stderr output:
2021-01-12 17:57:32.443 | INFO     | __main__:test:10 - 6

2021-01-12 17:57:32,445 DEBG 'tester' stderr output:
2021-01-12 17:57:32.444 | INFO     | __main__:test:12 - Sleep 0.47064821128443857s

2021-01-12 17:57:32,921 DEBG 'tester' stderr output:
2021-01-12 17:57:32.920 | INFO     | __main__:test:10 - 7

2021-01-12 17:57:32,922 DEBG 'tester' stderr output:
2021-01-12 17:57:32.921 | INFO     | __main__:test:12 - Sleep 0.7673175029063347s

2021-01-12 17:57:33,691 DEBG 'tester' stderr output:
2021-01-12 17:57:33.690 | INFO     | __main__:test:10 - 8

2021-01-12 17:57:33,692 DEBG 'tester' stderr output:
2021-01-12 17:57:33.691 | INFO     | __main__:test:12 - Sleep 0.9317641783846109s

2021-01-12 17:57:34,625 DEBG 'tester' stderr output:
2021-01-12 17:57:34.624 | INFO     | __main__:test:10 - 9

2021-01-12 17:57:34,625 DEBG 'tester' stderr output:
2021-01-12 17:57:34.625 | INFO     | __main__:test:12 - Sleep 0.2558276039626808s

2021-01-12 17:57:34,899 DEBG fd 13 closed, stopped monitoring <POutputDispatcher at 140666266690000 for <Subprocess at 140666266191824 with name tester in state STARTING> (stderr)>
2021-01-12 17:57:34,899 DEBG fd 11 closed, stopped monitoring <POutputDispatcher at 140666266689872 for <Subprocess at 140666266191824 with name tester in state STARTING> (stdout)>
2021-01-12 17:57:34,899 INFO exited: tester (exit status 0; not expected)
2021-01-12 17:57:34,900 DEBG received SIGCHLD indicating a child quit
2021-01-12 17:57:36,912 INFO spawned: 'tester' with pid 1264
2021-01-12 17:57:37,022 DEBG 'tester' stderr output:
2021-01-12 17:57:37.021 | INFO     | __main__:test:10 - 0
2021-01-12 17:57:37.021 | INFO     | __main__:test:12 - Sleep 0.5475564566091946s

2021-01-12 17:57:37,572 DEBG 'tester' stderr output:
2021-01-12 17:57:37.571 | INFO     | __main__:test:10 - 1

2021-01-12 17:57:37,573 DEBG 'tester' stderr output:
2021-01-12 17:57:37.572 | INFO     | __main__:test:12 - Sleep 0.6326087978849619s

2021-01-12 17:57:38,207 DEBG 'tester' stderr output:
2021-01-12 17:57:38.206 | INFO     | __main__:test:10 - 2

2021-01-12 17:57:38,207 DEBG 'tester' stderr output:
2021-01-12 17:57:38.207 | INFO     | __main__:test:12 - Sleep 0.3225720045649825s

2021-01-12 17:57:38,531 DEBG 'tester' stderr output:
2021-01-12 17:57:38.530 | INFO     | __main__:test:10 - 3

2021-01-12 17:57:38,531 DEBG 'tester' stderr output:
2021-01-12 17:57:38.530 | INFO     | __main__:test:12 - Sleep 0.5121026075892807s

2021-01-12 17:57:39,044 DEBG 'tester' stderr output:
2021-01-12 17:57:39.043 | INFO     | __main__:test:10 - 4

2021-01-12 17:57:39,045 DEBG 'tester' stderr output:
2021-01-12 17:57:39.044 | INFO     | __main__:test:12 - Sleep 0.6613469797067474s

2021-01-12 17:57:39,710 DEBG 'tester' stderr output:
2021-01-12 17:57:39.709 | INFO     | __main__:test:10 - 5

2021-01-12 17:57:39,710 DEBG 'tester' stderr output:
2021-01-12 17:57:39.709 | INFO     | __main__:test:12 - Sleep 0.5058071583137449s

2021-01-12 17:57:40,220 DEBG 'tester' stderr output:
2021-01-12 17:57:40.219 | INFO     | __main__:test:10 - 6

2021-01-12 17:57:40,220 DEBG 'tester' stderr output:
2021-01-12 17:57:40.219 | INFO     | __main__:test:12 - Sleep 0.2779679640725812s

2021-01-12 17:57:40,502 DEBG 'tester' stderr output:
2021-01-12 17:57:40.502 | INFO     | __main__:test:10 - 7

2021-01-12 17:57:40,503 DEBG 'tester' stderr output:
2021-01-12 17:57:40.502 | INFO     | __main__:test:12 - Sleep 0.7282026322383534s

2021-01-12 17:57:41,231 DEBG 'tester' stderr output:
2021-01-12 17:57:41.231 | INFO     | __main__:test:10 - 8

2021-01-12 17:57:41,232 DEBG 'tester' stderr output:
2021-01-12 17:57:41.231 | INFO     | __main__:test:12 - Sleep 0.37634579152866654s

2021-01-12 17:57:41,610 DEBG 'tester' stderr output:
2021-01-12 17:57:41.610 | INFO     | __main__:test:10 - 9

2021-01-12 17:57:41,610 DEBG 'tester' stderr output:
2021-01-12 17:57:41.610 | INFO     | __main__:test:12 - Sleep 0.02539488384007338s

2021-01-12 17:57:41,660 DEBG fd 13 closed, stopped monitoring <POutputDispatcher at 140666266690256 for <Subprocess at 140666266191824 with name tester in state STARTING> (stderr)>
2021-01-12 17:57:41,660 DEBG fd 11 closed, stopped monitoring <POutputDispatcher at 140666266689872 for <Subprocess at 140666266191824 with name tester in state STARTING> (stdout)>
2021-01-12 17:57:41,660 INFO exited: tester (exit status 0; not expected)
2021-01-12 17:57:41,660 DEBG received SIGCHLD indicating a child quit
2021-01-12 17:57:44,666 INFO spawned: 'tester' with pid 1265
2021-01-12 17:57:44,775 DEBG 'tester' stderr output:
2021-01-12 17:57:44.774 | INFO     | __main__:test:10 - 0
2021-01-12 17:57:44.774 | INFO     | __main__:test:12 - Sleep 0.540035521075991s

2021-01-12 17:57:45,315 DEBG 'tester' stderr output:
2021-01-12 17:57:45.315 | INFO     | __main__:test:10 - 1

2021-01-12 17:57:45,316 DEBG 'tester' stderr output:
2021-01-12 17:57:45.315 | INFO     | __main__:test:12 - Sleep 0.6011099895313317s

2021-01-12 17:57:45,922 DEBG 'tester' stderr output:
2021-01-12 17:57:45.921 | INFO     | __main__:test:10 - 2

2021-01-12 17:57:45,923 DEBG 'tester' stderr output:
2021-01-12 17:57:45.922 | INFO     | __main__:test:12 - Sleep 0.5954410741418728s

2021-01-12 17:57:46,521 DEBG 'tester' stderr output:
2021-01-12 17:57:46.520 | INFO     | __main__:test:10 - 3

2021-01-12 17:57:46,521 DEBG 'tester' stderr output:
2021-01-12 17:57:46.521 | INFO     | __main__:test:12 - Sleep 0.10471143983800468s

2021-01-12 17:57:46,631 DEBG 'tester' stderr output:
2021-01-12 17:57:46.630 | INFO     | __main__:test:10 - 4

2021-01-12 17:57:46,632 DEBG 'tester' stderr output:
2021-01-12 17:57:46.631 | INFO     | __main__:test:12 - Sleep 0.12704017263351186s

2021-01-12 17:57:46,759 DEBG 'tester' stderr output:
2021-01-12 17:57:46.758 | INFO     | __main__:test:10 - 5

2021-01-12 17:57:46,760 DEBG 'tester' stderr output:
2021-01-12 17:57:46.759 | INFO     | __main__:test:12 - Sleep 0.26222866859817395s

2021-01-12 17:57:47,025 DEBG 'tester' stderr output:
2021-01-12 17:57:47.025 | INFO     | __main__:test:10 - 6

2021-01-12 17:57:47,026 DEBG 'tester' stderr output:
2021-01-12 17:57:47.025 | INFO     | __main__:test:12 - Sleep 0.31215837276333647s

2021-01-12 17:57:47,343 DEBG 'tester' stderr output:
2021-01-12 17:57:47.343 | INFO     | __main__:test:10 - 7

2021-01-12 17:57:47,344 DEBG 'tester' stderr output:
2021-01-12 17:57:47.343 | INFO     | __main__:test:12 - Sleep 0.8863919731268238s

2021-01-12 17:57:48,230 DEBG 'tester' stderr output:
2021-01-12 17:57:48.230 | INFO     | __main__:test:10 - 8

2021-01-12 17:57:48,230 DEBG 'tester' stderr output:
2021-01-12 17:57:48.230 | INFO     | __main__:test:12 - Sleep 0.6220607701794121s

2021-01-12 17:57:48,858 DEBG 'tester' stderr output:
2021-01-12 17:57:48.857 | INFO     | __main__:test:10 - 9

2021-01-12 17:57:48,858 DEBG 'tester' stderr output:
2021-01-12 17:57:48.858 | INFO     | __main__:test:12 - Sleep 0.9545468958914863s

2021-01-12 17:57:49,835 DEBG fd 13 closed, stopped monitoring <POutputDispatcher at 140666266690128 for <Subprocess at 140666266191824 with name tester in state STARTING> (stderr)>
2021-01-12 17:57:49,835 DEBG fd 11 closed, stopped monitoring <POutputDispatcher at 140666266689872 for <Subprocess at 140666266191824 with name tester in state STARTING> (stdout)>
2021-01-12 17:57:49,835 INFO exited: tester (exit status 0; not expected)
2021-01-12 17:57:49,835 DEBG received SIGCHLD indicating a child quit
2021-01-12 17:57:50,836 INFO gave up: tester entered FATAL state, too many start retries too quickly
```

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gml2i44gvnj327y0icwg0.jpg)

## Supervisor番外篇

### **Supervisorctl常用命令**

```sh
# supervisorctl status：查看进程的状态
supervisorctl status
status <name>           Get status for a single process
status <gname>:*        Get status for all processes in a group
status <name> <name>    Get status for multiple named processes
status                  Get all process status info

# supervisorctl start 启动进程
start <name>            Start a process
start <gname>:*         Start all processes in a group
start <name> <name>     Start multiple processes or groups
start all               Start all processes

# supervisorctl stop 停止进程
stop <name>             Stop a process
stop <gname>:*          Stop all processes in a group
stop <name> <name>      Stop multiple processes or groups
stop all                Stop all processes

# supervisorctl restart 重启进程
restart <name>          Restart a process
restart <gname>:*       Restart all processes in a group
restart <name> <name>   Restart multiple processes or groups
restart all             Restart all processes
Note: restart does not reread config files. For that, see reread and update.

# supervisorctl update 配置文件修改后可以使用该命令加载新的配置
update                  Reload config and add/remove as necessary, and will restart affected programs
update all              Reload config and add/remove as necessary, and will restart affected programs
update <gname> [...]    Update specific groups

supervisorctl reload: 重新启动配置中的所有程序

# 更多命令可 supervisorctl 进入终端。输入help(?)进行查看
```

### Supervisorctl 参数列表

```
supervisorctl -- control applications run by supervisord from the cmd line.

Usage: /Users/stringle-004/opt/miniconda3/envs/Proxypool/bin/supervisorctl [options] [action [arguments]]

Options:
-c/--configuration FILENAME -- configuration file path (searches if not given)
-h/--help -- print usage message and exit
-i/--interactive -- start an interactive shell after executing commands
-s/--serverurl URL -- URL on which supervisord server is listening
     (default "http://localhost:9001").
-u/--username USERNAME -- username to use for authentication with server
-p/--password PASSWORD -- password to use for authentication with server
-r/--history-file -- keep a readline history (if readline is available)

action [arguments] -- see below

Actions are commands like "tail" or "stop".  If -i is specified or no action is
specified on the command line, a "shell" interpreting actions typed
interactively is started.  Use the action "help" to find out about available
actions.
```



### supervisord.conf配置文件示例

使命令用`sudo echo_supervisord_conf > supervisord.conf` 进行创建

```sh
; Sample supervisor config file.
;
; For more information on the config file, please see:
; http://supervisord.org/configuration.html
;
; Notes:
;  - Shell expansion ("~" or "$HOME") is not supported.  Environment
;    variables can be expanded using this syntax: "%(ENV_HOME)s".
;  - Quotes around values are not supported, except in the case of
;    the environment= options as shown below.
;  - Comments must have a leading space: "a=b ;comment" not "a=b;comment".
;  - Command will be truncated if it looks like a config file comment, e.g.
;    "command=bash -c 'foo ; bar'" will truncate to "command=bash -c 'foo ".
;
; Warning:
;  Paths throughout this example file use /tmp because it is available on most
;  systems.  You will likely need to change these to locations more appropriate
;  for your system.  Some systems periodically delete older files in /tmp.
;  Notably, if the socket file defined in the [unix_http_server] section below
;  is deleted, supervisorctl will be unable to connect to supervisord.

[unix_http_server]
file=/tmp/supervisor.sock   ; the path to the socket file
;chmod=0700                 ; socket file mode (default 0700)
;chown=nobody:nogroup       ; socket file uid:gid owner
;username=user              ; default is no username (open server)
;password=123               ; default is no password (open server)

; Security Warning:
;  The inet HTTP server is not enabled by default.  The inet HTTP server is
;  enabled by uncommenting the [inet_http_server] section below.  The inet
;  HTTP server is intended for use within a trusted environment only.  It
;  should only be bound to localhost or only accessible from within an
;  isolated, trusted network.  The inet HTTP server does not support any
;  form of encryption.  The inet HTTP server does not use authentication
;  by default (see the username= and password= options to add authentication).
;  Never expose the inet HTTP server to the public internet.

;[inet_http_server]         ; inet (TCP) server disabled by default
;port=9001        ; ip_address:port specifier, *:port for all iface
;username=user              ; default is no username (open server)
;password=123               ; default is no password (open server)

[supervisord]
logfile=/tmp/supervisord.log ; main log file; default $CWD/supervisord.log
logfile_maxbytes=50MB        ; max main logfile bytes b4 rotation; default 50MB
logfile_backups=10           ; of main logfile backups; 0 means none, default 10
loglevel=info                ; log level; default info; others: debug,warn,trace
pidfile=/tmp/supervisord.pid ; supervisord pidfile; default supervisord.pid
nodaemon=false               ; start in foreground if true; default false
minfds=1024                  ; min. avail startup file descriptors; default 1024
minprocs=200                 ; min. avail process descriptors;default 200
;umask=022                   ; process file creation umask; default 022
;user=supervisord            ; setuid to this UNIX account at startup; recommended if root
;identifier=supervisor       ; supervisord identifier, default is 'supervisor'
;directory=/tmp              ; default is not to cd during start
;nocleanup=true              ; don't clean up tempfiles at start; default false
;childlogdir=/tmp            ; 'AUTO' child log dir, default $TEMP
;environment=KEY="value"     ; key value pairs to add to environment
;strip_ansi=false            ; strip ansi escape codes in logs; def. false

; The rpcinterface:supervisor section must remain in the config file for
; RPC (supervisorctl/web interface) to work.  Additional interfaces may be
; added by defining them in separate [rpcinterface:x] sections.

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

; The supervisorctl section configures how supervisorctl will connect to
; supervisord.  configure it match the settings in either the unix_http_server
; or inet_http_server section.

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket
;serverurl=http://127.0.0.1:9001 ; use an http:// url to specify an inet socket
;username=chris              ; should be same as in [*_http_server] if set
;password=123                ; should be same as in [*_http_server] if set
;prompt=mysupervisor         ; cmd line prompt (default "supervisor")
;history_file=~/.sc_history  ; use readline history if available

; The sample program section below shows all possible program subsection values.
; Create one or more 'real' program: sections to be able to control them under
; supervisor.

;[program:theprogramname]
;command=/bin/cat              ; the program (relative uses PATH, can take args)
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
;directory=/tmp                ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
;priority=999                  ; the relative start priority (default 999)
;autostart=true                ; start at supervisord start (default: true)
;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
;startretries=3                ; max # of serial start failures when starting (default 3)
;autorestart=unexpected        ; when to restart if exited after running (def: unexpected)
;exitcodes=0                   ; 'expected' exit codes used with autorestart (default 0)
;stopsignal=QUIT               ; signal used to kill process (default TERM)
;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
;killasgroup=false             ; SIGKILL the UNIX process group (def false)
;user=chrism                   ; setuid to this UNIX account to run the program
;redirect_stderr=true          ; redirect proc stderr to stdout (default false)
;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
;stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stdout_events_enabled=false   ; emit events on stdout writes (default false)
;stdout_syslog=false           ; send stdout to syslog with process name (default false)
;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
;stderr_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stderr_events_enabled=false   ; emit events on stderr writes (default false)
;stderr_syslog=false           ; send stderr to syslog with process name (default false)
;environment=A="1",B="2"       ; process environment additions (def no adds)
;serverurl=AUTO                ; override serverurl computation (childutils)

; The sample eventlistener section below shows all possible eventlistener
; subsection values.  Create one or more 'real' eventlistener: sections to be
; able to handle event notifications sent by supervisord.

;[eventlistener:theeventlistenername]
;command=/bin/eventlistener    ; the program (relative uses PATH, can take args)
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
;events=EVENT                  ; event notif. types to subscribe to (req'd)
;buffer_size=10                ; event buffer queue size (default 10)
;directory=/tmp                ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
;priority=-1                   ; the relative start priority (default -1)
;autostart=true                ; start at supervisord start (default: true)
;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
;startretries=3                ; max # of serial start failures when starting (default 3)
;autorestart=unexpected        ; autorestart if exited after running (def: unexpected)
;exitcodes=0                   ; 'expected' exit codes used with autorestart (default 0)
;stopsignal=QUIT               ; signal used to kill process (default TERM)
;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
;killasgroup=false             ; SIGKILL the UNIX process group (def false)
;user=chrism                   ; setuid to this UNIX account to run the program
;redirect_stderr=false         ; redirect_stderr=true is not allowed for eventlisteners
;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
;stdout_events_enabled=false   ; emit events on stdout writes (default false)
;stdout_syslog=false           ; send stdout to syslog with process name (default false)
;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
;stderr_events_enabled=false   ; emit events on stderr writes (default false)
;stderr_syslog=false           ; send stderr to syslog with process name (default false)
;environment=A="1",B="2"       ; process environment additions
;serverurl=AUTO                ; override serverurl computation (childutils)

; The sample group section below shows all possible group values.  Create one
; or more 'real' group: sections to create "heterogeneous" process groups.

;[group:thegroupname]
;programs=progname1,progname2  ; each refers to 'x' in [program:x] definitions
;priority=999                  ; the relative start priority (default 999)

; The [include] section can just contain the "files" setting.  This
; setting can list multiple files (separated by whitespace or
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

;[include]
;files = relative/directory/*.ini
```

常用配置

```
[unix_http_server]
file=/tmp/supervisor.sock   ;UNIX socket 文件，supervisorctl 会使用
;chmod=0700                 ;socket文件的mode，默认是0700
;chown=nobody:nogroup       ;socket文件的owner，格式：uid:gid
 
;[inet_http_server]         ;HTTP服务器，提供web管理界面
;port=9001        					;Web管理后台运行的IP和端口，如果开放到公网，需要注意安全性
;username=user              ;登录管理后台的用户名
;password=123               ;登录管理后台的密码
 
[supervisord]
logfile=/tmp/supervisord.log ;日志文件，默认是 $CWD/supervisord.log
logfile_maxbytes=50MB        ;日志文件大小，超出会rotate，默认 50MB，如果设成0，表示不限制大小
logfile_backups=10           ;日志文件保留备份数量默认10，设为0表示不备份
loglevel=info                ;日志级别，默认info，其它: debug,warn,trace
pidfile=/tmp/supervisord.pid ;pid 文件
nodaemon=false               ;是否在前台启动，默认是false，即以 daemon 的方式启动
minfds=1024                  ;可以打开的文件描述符的最小值，默认 1024
minprocs=200                 ;可以打开的进程数的最小值，默认 200
 
[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ;通过UNIX socket连接supervisord，路径与unix_http_server部分的file一致
;serverurl=http://127.0.0.1:9001 ; 通过HTTP的方式连接supervisord
 
; [program:xx]是被管理的进程配置参数，xx是进程的名称
[program:xx]
command=/opt/apache-tomcat-8.0.35/bin/catalina.sh run  ; 程序启动命令
autostart=true       ; 在supervisord启动的时候也自动启动
startsecs=10         ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
autorestart=true     ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
startretries=3       ; 启动失败自动重试次数，默认是3
user=tomcat          ; 用哪个用户启动进程，默认是root
priority=999         ; 进程启动优先级，默认999，值小的优先启动
redirect_stderr=true ; 把stderr重定向到stdout，默认false
stdout_logfile_maxbytes=20MB  ; stdout 日志文件大小，默认50MB
stdout_logfile_backups = 20   ; stdout 日志文件备份数，默认是10
; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
stdout_logfile=/opt/apache-tomcat-8.0.35/logs/catalina.out
stopasgroup=false     ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=false     ;默认为false，向进程组发送kill信号，包括子进程
 
;包含其它配置文件
[include]
files = relative/directory/*.ini    ;可以指定一个或多个以.ini结束的配置文件
```

## 总结

- 我们从`supervisor`基础模型，组成、再到到使用进行了介绍
- 验证了`supervisor`确实可以监控我们的任务，且给予了简单的控制面板，更加便于我们控制、监控
- `supervisor`的配置文件十分重要，是熟练使用的前提与基石

自从又了它，相信你对于任务的管理再也不会迷路了，冲冲冲～



![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmjvtjiqtdj31c20mggp8.jpg)


