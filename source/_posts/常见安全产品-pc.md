---
title: 常见安全产品(pc)
author: Payne
tags: ["爬虫", "Crawler", "Web Spider", "数据采集", "JS", "Chrome", "JavaScript", "技巧"]
categories:
- ["爬虫", "Crawler", "JavaScript", "技巧", "JS"]
date: 2021-07-11 21:36:28
---

## 常见安全产品介绍

在做爬虫的时候，很多时候都会遇到成熟的产品。该如何更好的识别他，对于解决有至关重要的帮助。一下一起来了解一下网站常见防护产品及特性

> 声明：本节不射猎任何产品破解，仅介绍其特征与辨别方式

### 一线

> 学习的对象，自研产品。安全系数高，分析较困难

ali、akamai、jd、pdd、google(含无感验证码)、各种银行支付接口
<!--more-->
#### ali滑块

![](https://tva1.sinaimg.cn/large/008i3skNgy1gs4rk7k7tgj31p60qkq5m.jpg)

控制台中有g.alicdn.com字样，其中/后为版本号

#### akamai

> 主要在tls指纹进行相关加密

#### jd

> 自写的虚拟机

#### pdd

> Web pack 打包 + 风控

#### google(含无感验证码)

5s 盾 + 谷歌验证码

### 二线

> 可敬的对象

加密与代码保护：瑞数信息（瑞数）、创宇超防（加速乐）、

验证码：极验、数美、五秒盾、易盾、顶象

#### 加密与代码保护

##### 瑞数信息（瑞数）

1. 未带cookie访问首先是一段神奇的页面，如下图所示

![image-20210711183607468](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210711183607468.png)

特征：

1.

一长段的：content。有点类似于ob的大数组

script标签中带有 r=“m”的字样

执行加密函数1，函数名为 `_$xx(xxx)`

执行加密函数2（时机加密处）

2. 无比恶心的乱码

![ddddd](https://tva1.sinaimg.cn/large/008i3skNgy1gsd76unofcj30sp02qt8m.jpg)

3. 动态js

4. 版本号

   ![](https://tva1.sinaimg.cn/large/008i3skNgy1gsd8b8qfa3j305y00i0si.jpg)

   ![image-20210711192226256](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210711192226256.png)

首数字开头的编号，编号常见的有4、5、6代

##### 创宇超防（加速乐）

1. 未带cookies访问，先是一段神奇的JS，设置cookie。如下图所示

![image-20210711183150521](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210711183150521.png)

实际内容如下图所示

![](https://tva1.sinaimg.cn/large/008i3skNgy1gsd6qt4brnj311b02qjrj.jpg)

2. 魔改ob

   用于cookies拼接

   ![](https://tva1.sinaimg.cn/large/008i3skNgy1gsd6wykikcj31lf0u0n36.jpg)

#### 验证码

##### 极验

geetest(极验)官网：https://www.geetest.com/

demo：https://www.geetest.com/demo/

![image-20210711195920957](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210711195920957.png)

<!---------->



##### 数美

官网：https://www.ishumei.com/

体验：https://www.ishumei.com/trial/captcha.html

![image-20210711195358760](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210711195358760.png)

##### 网易易盾

官网：https://dun.163.com/

Demo：https://dun.163.com/trial/space-inference

![image-20210711200120467](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210711200120467.png)

##### Vaptcha

https://www.vaptcha.com/

![](https://tva1.sinaimg.cn/large/008i3skNgy1gsd8xpb30oj30vc0g1afq.jpg)

##### 顶象



![image-20210711195702599](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210711195702599.png)

### 三线

> 主要来源于开源框架

Ob混淆系（obfuscator、sojson、Jsaham）、Jsfuck、JJEncode、AAEncode、eval等、

obfuscator: https://obfuscator.io/

sojson：https://www.sojson.com/jsjiemi.html

Jsaham：http://www.jshaman.com/#section2

jstuck:http://www.jsfuck.com/  GitHub:https://github.com/aemkei/jsfuck

JJEncode:http://www.atoolbox.net/Tool.php?Id=704

JJEncode:http://www.atoolbox.net/Tool.php?Id=703

Eval:https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/eval;

​	分析：eval换为console.log()(前提：console.log未改写)

#### 分析

##### ob系列

特点

1. 大数组
2. 数据移位（常见regex内存检测，建议不format绕过或remove regex）
3. 解密函数（常见regex内存检测，建议不format绕过或remove regex）
4. 定时器setInterval() 、setTimeout() + 无限debugger （可能含有）
5. **业务代码 + 控制流平坦化：（ob强度90%取决于此代码强度、这里是加密前的逻辑）**
6. 控制流平坦化  + 无限debugger + 僵尸代码注入（一般不含有业务逻辑）

Example:

1. 找到实际处（ob）
2. 找前三段（数组、数组移位、解密函数），剪切出去
3. 格式化控制流平坦化、实际逻辑。放回前剪切出去的内容
4. 定位加密函数

##### Jsfuck、JJEncode、AAEncode、表情包

配合eval类型防护：

> 1. 直接放控制台console执行(报非unsafe错误)；点击错位堆栈直接完成脱壳

![](https://tva1.sinaimg.cn/large/008i3skNgy1gsdbgkbq35j30ix0bjwet.jpg)

![](https://tva1.sinaimg.cn/large/008i3skNgy1gsdbfu2amkj31ae02maa0.jpg)

![image-20210711211026971](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210711211026971.png)

> 2.控制台不报错，构建强制报错。删除一些代码（为了不干扰原本代码，建议删除括号或加无意义代码）
>
> 3。控制台报unsafe错误，自写html文件运行。参考以上



混淆部分数字：

### 四线

> 工程化工具、各种加密函数魔改、辅助作用

webpack、vue、react、angular

webpack：https://webpack.docschina.org/

关键点：加载器

绕过方案：点位插桩
