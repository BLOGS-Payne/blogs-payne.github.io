---
title: docker 底层原理探究
author: Payne
tags: ["docker"]
categories:
- ["容器编排"]
date: 2021-01-24 13:12:10
---


Docker is written in the [Go programming language](https://golang.org/) and takes advantage of several features of the Linux kernel to deliver its functionality.
<!--more-->
Docker用`Go编程语言`编写，并利用Linux内核的多个功能来实现其功能。

## Namespaces(命名空间)

Docker uses a technology called `namespaces` to provide the isolated workspace called the *container*. When you run a container, Docker creates a set of *namespaces* for that container.

> Docker使用`命名空间`的技术实现容器(虚拟)独立的工作区

**理解`Namespaces`**

**Namespaces**,可以理解为虚拟化隔离

当我们在系统上运行程序时，系统会为我们分配`pid`,`net`,`ipc`,`mnt`,`uts`等资源，当我们在Linux中运行时这些都是全局的。

当我们使用命名空间即可实现隔离的机制，每个分配`pid`,`net`,`ipc`,`mnt`,`uts`都是独立的，这样我们就可以实现权限管理等

These namespaces provide a layer of isolation. Each aspect of a container runs in a separate namespace and its access is limited to that namespace.

Docker Engine uses namespaces such as the following on Linux:

- **The `pid` namespace:** Process isolation (PID: Process ID).
- **The `net` namespace:** Managing network interfaces (NET: Networking).
- **The `ipc` namespace:** Managing access to IPC resources (IPC: InterProcess Communication).
- **The `mnt` namespace:** Managing filesystem mount points (MNT: Mount).
- **The `uts` namespace:** Isolating kernel and version identifiers. (UTS: Unix Timesharing System).

**进程ID（pid）**

进程的`PID`命名空间提供与一组独立的从其他命名空间进程ID（PID）的处理。PID名称空间是嵌套的，这意味着在创建新进程时，它将为每个名称空间从当前名称空间到初始PID名称空间都有一个PID。因此，初始PID名称空间能够查看所有进程，尽管与其他名称空间看到的PID不同。

在PID名称空间中创建的第一个进程被分配了编号为1的进程，并获得与常规进程相同的大多数特殊处理，最值得注意的是，名称空间内的`孤立进程`。这也意味着此PID 1进程的终止将立即终止其PID名称空间中的所有进程以及所有后代。

**网络（网络）**

网络名称空间可虚拟化`网络堆栈`。创建时，网络名称空间仅包含`回送`接口。

每个`网络接口`（物理或虚拟）都存在于1个名称空间中，并且可以在名称空间之间移动。

每个名称空间都有一组专用的`P地址`，自己的`路由表`，`套接字`列表，连接跟踪表，防火墙和其他与网络相关的资源。

销毁网络名称空间会破坏其中的任何虚拟接口，并将其中的任何物理接口移回到初始网络名称空间。

**进程间通信（ipc）**

IPC名称空间将进程与`SysV`样式的进程间通信隔离开。这样可以防止不同IPC名称空间中的进程使用例如SHM系列功能在两个进程之间建立一定范围的共享内存。相反，每个进程将能够对共享内存区域使用相同的标识符，并产生两个这样的不同区域。

**挂载（mnt）**

安装名称空间控制安装点。创建后，会将当前安装名称空间中的安装复制到新的名称空间，但是之后创建的安装点不会在名称空间之间传播（使用共享子树，可以在名称空间之间传播安装点。

用于创建这种类型的新名称空间的克隆标志是CLONE_NEWNS-“ NEW NameSpace”的缩写。该术语不是描述性的（因为它没有告诉您要创建哪种类型的名称空间），因为挂载名称空间是第一类名称空间，设计人员并不预期会有其他名称空间。

**UTS (UNIX [Time-Sharing](https://en.wikipedia.org/wiki/Time-sharing))** 

命名空间允许单个系统对不同的进程使用不同的主机名和域名。

## Control groups

Docker Engine on Linux also relies on another technology called *control groups* (`cgroups`). A cgroup limits an application to a specific set of resources. Control groups allow Docker Engine to share available hardware resources to containers and optionally enforce limits and constraints. For example, you can limit the memory available to a specific container.

> Linux上的Docker引擎还依赖另一种称为*控制组*（`cgroups`）的技术。cgroup将应用程序限制为一组特定的资源。控制组允许Docker引擎将可用的硬件资源共享给容器，并可以选择性地实施限制和约束。例如，可以限制特定容器的可用内存。

## Union file systems

Union file systems, or UnionFS, are file systems that operate by creating layers, making them very lightweight and fast. Docker Engine uses UnionFS to provide the building blocks for containers. Docker Engine can use multiple UnionFS variants, including AUFS, btrfs, vfs, and DeviceMapper.

> Union文件系统（UnionFS）是通过``创建层``来操作的文件系统，使它们非常轻量级和快速。Docker引擎使用UnionFS为容器提供构建块。Docker引擎可以使用多种UnionFS变体，包括AUFS、btrfs、vfs和DeviceMapper。

## Container format

Docker Engine combines the namespaces, control groups, and UnionFS into a wrapper called a container format. The default container format is `libcontainer`. In the future, Docker may support other container formats by integrating with technologies such as BSD Jails or Solaris Zones.

> Docker引擎将名称空间、控制组和UnionFS组合成一个称为容器格式的包装器。默认容器格式为“libcontainer”。将来，Docker可以通过集成BSD监狱或Solaris区域等技术来支持其他容器格式。



## 总结

docker使用go语言编写，基于**Namespaces**进行虚拟化隔离，Control groups进行对资源的限制，联合文件Union file systems来快速构建（可复用的镜像层），