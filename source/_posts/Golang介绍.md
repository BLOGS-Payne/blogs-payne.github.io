---
title: Golang介绍
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 21:52:58
author: payne
---


> - Golang官网地址:<https://golang.org/>
> - Golang官方文档:<https://golang.org/doc/>
> - Golang Packages:<https://golang.org/pkg/>
> - Golang中文网：<https://studygolang.com/>
> - Golang中文文档：<http://docscn.studygolang.com/>
> - Golang中文Packages：<https://studygolang.com/pkgdoc>

## 摘要

Golang(又称Go)是[Google](https://zh.wikipedia.org/wiki/Google)公司开发的一种[静态](https://zh.wikipedia.org/wiki/静态类型)[强类型](https://zh.wikipedia.org/wiki/強類型)、[编译型](https://zh.wikipedia.org/wiki/編譯語言)、[并发型](https://zh.wikipedia.org/wiki/並行計算)，并具有[垃圾回收功能](https://zh.wikipedia.org/wiki/垃圾回收_(計算機科學))的[编程语言](https://zh.wikipedia.org/wiki/编程语言)。

[罗伯特·格瑞史莫](https://zh.wikipedia.org/w/index.php?title=羅伯特·格瑞史莫&action=edit&redlink=1)，[罗勃·派克](https://zh.wikipedia.org/wiki/羅勃·派克)（Rob Pike）及[肯·汤普逊](https://zh.wikipedia.org/wiki/肯·汤普逊)于2007年9月开始设计GO，稍后Ian Lance Taylor、Russ Cox加入项目。Go是基于[Inferno](https://zh.wikipedia.org/wiki/Inferno)操作系统所开发的。Go于2009年11月正式宣布推出，成为[开放源代码](https://zh.wikipedia.org/wiki/開放原始碼)项目，支持[Linux](https://zh.wikipedia.org/wiki/Linux)、[macOS](https://zh.wikipedia.org/wiki/MacOS)、[Windows](https://zh.wikipedia.org/wiki/Windows)等操作系统。在2016年，Go被软件评价公司TIOBE 选为“TIOBE 2016 年最佳语言”。

目前，Go每半年发布一个二级版本（即从a.x升级到a.y）。
<!--more-->
## 描述

Go的语法接近[C语言](https://zh.wikipedia.org/wiki/C语言)，但对于[变量的声明](https://zh.wikipedia.org/w/index.php?title=变量的声明&action=edit&redlink=1)有所不同。Go支持[垃圾回收功能](https://zh.wikipedia.org/wiki/垃圾回收_(計算機科學))。Go的[并行计算](https://zh.wikipedia.org/wiki/并行计算)模型是以[东尼·霍尔](https://zh.wikipedia.org/wiki/東尼·霍爾)的[通信顺序进程](https://zh.wikipedia.org/wiki/交談循序程式)（CSP）为基础，采取类似模型的其他语言包括[Occam](https://zh.wikipedia.org/wiki/Occam)和[Limbo](https://zh.wikipedia.org/wiki/Limbo)[[3\]](https://zh.wikipedia.org/wiki/Go#cite_note-langfaq-3)，Go也具有这个模型的特征，比如[通道](https://zh.wikipedia.org/wiki/通道_(编程))传输。通过goroutine和通道等并行构造可以建造[线程池](https://zh.wikipedia.org/wiki/线程池)和[管道](https://zh.wikipedia.org/wiki/管道_(软件))等[[8\]](https://zh.wikipedia.org/wiki/Go#cite_note-8)。在1.8版本中开放插件（Plugin）的支持，这意味着现在能从Go中动态加载部分函数。

与C++相比，Go并不包括如[枚举](https://zh.wikipedia.org/wiki/枚举)、[异常处理](https://zh.wikipedia.org/wiki/异常处理)、[继承](https://zh.wikipedia.org/wiki/繼承_(計算機科學))、[泛型](https://zh.wikipedia.org/wiki/泛型)、[断言](https://zh.wikipedia.org/wiki/斷言_(程式))、[虚函数](https://zh.wikipedia.org/wiki/虚函数)等功能，但增加了 切片(Slice) 型、并发、管道、[垃圾回收功能](https://zh.wikipedia.org/wiki/垃圾回收_(計算機科學))、[接口](https://zh.wikipedia.org/wiki/介面_(資訊科技))等特性的语言级支持。Go 2.0版本将支持泛型[[9\]](https://zh.wikipedia.org/wiki/Go#cite_note-9)，对于[断言](https://zh.wikipedia.org/wiki/斷言_(程式))的存在，则持负面态度，同时也为自己不提供类型[继承](https://zh.wikipedia.org/wiki/繼承_(計算機科學))来辩护。

不同于[Java](https://zh.wikipedia.org/wiki/Java)，Go原生提供了[关联数组](https://zh.wikipedia.org/wiki/关联数组)（也称为[哈希表](https://zh.wikipedia.org/wiki/哈希表)（Hashes）或字典（Dictionaries）），就像字符串类型一样。

## 历史

2007年，[Google](https://zh.wikipedia.org/wiki/Google)设计Go，目的在于提高在[多核](https://zh.wikipedia.org/wiki/多核心處理器)、网络机器（networked machines）、大型[代码库](https://zh.wikipedia.org/wiki/代码库)（codebases）的情况下的开发效率。当时在Google，设计师们想要解决其他语言使用中的缺点，但是仍保留他们的优点。

- 静态类型和[运行时](https://zh.wikipedia.org/wiki/运行时)效率。（如：[C++](https://zh.wikipedia.org/wiki/C%2B%2B)）
- 可读性和易用性。（如：[Python](https://zh.wikipedia.org/wiki/Python) 和 [JavaScript](https://zh.wikipedia.org/wiki/JavaScript)）[[12\]](https://zh.wikipedia.org/wiki/Go#cite_note-12)
- 高性能的网络和[多进程](https://zh.wikipedia.org/wiki/多进程)。

设计师们主要受他们之间流传的“不要像C++”启发。

Go于2009年11月正式宣布推出，[[16\]](https://zh.wikipedia.org/wiki/Go#cite_note-16)版本1.0在2012年3月发布。之后，Go广泛应用于Google的产品以及许多其他组织和开源项目。

在2016年11月，Go（一种[无衬线体](https://zh.wikipedia.org/wiki/无衬线体)）和Go Mono 字体（一种[等宽字体](https://zh.wikipedia.org/wiki/等宽字体)）分别由设计师 Charles Bigelow 和 Kris Holmes 发布。 两种字体均采用了 [WGL4](https://zh.wikipedia.org/w/index.php?title=WGL4&action=edit&redlink=1) ，并且依照着 DIN 1450 标准，可清晰地使用了 large x-height 和 letterforms 。

在2018年8月，本地的图标更换了 。待描述完整 然而，Gopher mascot 仍旧命相同的名字。

在2018年8月，Go的主要贡献者发布了两个关于语言新功能的“草稿设计——[泛型](https://zh.wikipedia.org/wiki/泛型) 和 [异常处理](https://zh.wikipedia.org/wiki/异常处理)，同时寻求Go用户的反馈。Go 由于在1.x时，缺少对 [泛型](https://zh.wikipedia.org/wiki/泛型)编程 的支持和冗长的 [异常处理](https://zh.wikipedia.org/wiki/异常处理) 而备受批评。

**以上来自[wiki](https://zh.wikipedia.org/wiki/Go#%E6%8F%8F%E8%BF%B0),更多详情可查看**

## 为什么需要学习Golang？

> “[Go will be the server language of the future.](https://link.juejin.im/?target=https%3A%2F%2Ftwitter.com%2Ftobi%2Fstatus%2F326086379207536640)” — Tobias Lütke, Shopify
>

## 硬件的局限性

**[摩尔定律](https://link.juejin.im/?target=http%3A%2F%2Fwww.investopedia.com%2Fterms%2Fm%2Fmooreslaw.asp)正在失效。**

英特尔公司在 [2004 年推出](https://link.juejin.im/?target=http%3A%2F%2Fwww.informit.com%2Farticles%2Farticle.aspx%3Fp%3D339073)了第一款具有 3.0 GHz时钟速度的奔腾 4 处理器。如今，我的 [2016款 MacBook Pro](https://link.juejin.im/?target=http%3A%2F%2Fwww.apple.com%2Fmacbook-pro%2Fspecs%2F) 的时钟速度为 2.9 GHz。因此，差不多十年，原始处理能力都没有太多的增加。你可以在下图中看到处理能力的增长与时间的关系。

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkficnh9qrj30go0bkwkn.jpg)

从上面的图表可以看出，单线程的性能和处理器的频率在近十年几乎保持稳定。如果你认为添加更多的晶体管是一种解决问题的方法，那你就错了。这是因为在微观尺度上，量子特性开始显现（例如：量子隧道穿越），放更多的晶体管代价也会越多([为什么？](https://link.juejin.im/?target=https%3A%2F%2Fwww.quora.com%2FWhat-is-Quantum-Tunneling-Limit-How-does-it-limit-the-size-of-a-transistor))，而且，每美元可以添加晶体管的数量也开始下降。

所以，针对上述问题的解决方案如下：

- 厂商开始向处理器添加越来越多的内核。如今，我们已经有四核和八核的 CPU 可用。
- 我们还引入了超线程技术。
- 为处理器添加更多的缓存以提升性能。

但是，以上方案也有它们自身的限制。我们无法向处理器添加更多的缓存以提升性能，因为缓存具有物理限制：缓存越大，速度越慢。添加更多的内核到处理器也有它的成本。而且，这也无法无限扩展。这些多核处理器能同时运行多个线程，同时也能带来并发能力。我们稍后会讨论它。

因此，如果我们不能依赖于硬件的改进，唯一的出路就是找到一个高效的软件来提升性能，但遗憾的是，现代编程语言都不是那么高效。

> “现代处理器就像一辆有氮氧加速系统的直线竞速赛车，它们在直线竞速赛中表现优异。不幸的是，现代编程语言却像蒙特卡罗赛道，它们有大量的弯道。” - [David Ungar](https://link.juejin.im/?target=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FDavid_Ungar)

## Go 天生支持并发

如上所述，硬件提供商正在向处理器添加更多的内核以提升性能。所有的数据中心都在这些处理器上运行，我们应该期待在未来几年内核数量的增长。更重要的是，如今的应用程序都是使用多个微服务来维持数据库的连接、消息队列和缓存的维护。因此，我们开发的软件和编程语言可以更容易的支持并发，并且它们应该随着内核数量的增长而可扩展。

但是大多数现代编程语言（如 Java、Python 等）都来自于 90 年代的单线程环境。这些语言大多数都支持多线程。但真正的问题是并发执行，线程锁、竞争条件和死锁。这些问题都使得很难在这些语言上创建一个多线程的应用程序。

例如，在 Java 中创建新的线程会消耗大量内存。因为每一个线程都会消耗大约 1 MB 大小的堆内存，如果你运行上千个线程，他们会对堆造成巨大的压力，最终会由于内存不足而宕机。此外，你想要在两个或者多个线程之间通信也是非常困难的。

另一方面，Go 于 2009 年发布，那时多核处理器已经上市了。这也是为什么 Go 是在考虑并发的基础上构建的。Go 用 goroutine 来替代线程，它们从堆中消耗了大约 2 KB 的内存。因此你可以随时启动上百万个 goroutine。

## Go 直接在底层硬件上运行

与其他现代高级语言（如 Java/Python）相比，使用 C、C++ 的最大好处就是它的性能，因为 C/C++ 是编译型语言而不是解释型语言。

处理器能理解二进制文件。通常来说，当你编译一个用 Java 或者其他基于 JVM 的语言构建的应用程序，它将人类可读的代码编译为字节代码，这可以被 JVM 或者在底层操作系统之上运行的其他虚拟机所理解。当执行的时候，虚拟机解释这些字节码并且将他们转化为处理器能理解的二进制文件。

## 用 Go 编写的代码易于维护

我告诉你一件事，Go 没有像其他语言一样疯狂于编程语法，它的语法非常整洁。

Go 的的设计者在谷歌创建这门语言的时候就考虑到了这一点，由于谷歌拥有非常强大的代码库，成千上万的开发者都工作在相同的代码库上，代码应该易于其他开发者理解，一段代码应该对另一段代码有最小的影响。这些都会使得代码易于维护，易于修改。

Go 有意的忽视了许多现代面向对象语言的一些特性。

- **没有类。** 所有代码都仅用 package 分开，Go 只有结构体而不是类。
- **不支持继承。** 这将使得代码易于修改。在其他语言中，如： Java/Python，如果类 ABC 继承类 XYZ 并且你在类 XYZ 中做了一些改动，那么这可能会在继承类 XYZ 的其他类中产生一些副作用。通过移除继承，Go 也使得理解代码变得很容易 **（因为当你在看一段代码时不需要同时查看父类）**。
- 没有构造方法。
- 没有注解。
- 没有泛型。
- 没有异常。

以上这些改变使得 Go 与其他语言截然不同，这使得用 Go 编程与其他语言很不一样。你可能不喜欢以上的一些观点。但是，并不是说没有上述这些特性，你就无法对你的应用程序编码。你要做的就是多写几行代码，但从积极的一面，它将使你的代码更加清晰，为代码添加更多的清晰度。

## Go 来势汹汹

- 我知道这不是一个直接的技术优势，但 Go 是由谷歌设计并支持的，谷歌拥有世界上最大的云基础设施之一，并且规模庞大。谷歌设计 Go 以解决可扩展性和有效性问题。这些是创建我们自己的服务器时都会遇到的问题。
- Go 更多的也是被一些大公司所使用，如 Adobe、BBC、IBM，因特尔甚至是 [Medium](https://link.juejin.im/?target=https%3A%2F%2Fmedium.engineering%2Fhow-medium-goes-social-b7dbefa6d413%23.r8nqjxjpk)。
