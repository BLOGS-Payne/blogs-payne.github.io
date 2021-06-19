---
title: 网页调试之debugger原理与绕过
author: Payne
tags: ["爬虫", "Crawler", "浏览器", "调试", "JS"]
categories:
- ["爬虫", "调试"]
date: 2021-06-09 09:02:14
---

## 网页调试之debugger原理与绕过

debugger 语句用于停止执行 JavaScript(以下简称JS)，并调用 (如果可用) 调试函数。

使用 debugger 语句类似于在代码中设置断点。
<!--more-->
**注意：** **如果调试工具不可用，则调试语句将无法工作。**

### 实现debugger功能

#### 直接使用书写debugger

```js
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Example DEBUGGER</title>
</head>

<body>
    <script>
        debugger;
    </script>
</body>

</html>
```

当我们使用浏览器打开Devtools即执行debugger；如下图所示

![](https://tva1.sinaimg.cn/large/008i3skNgy1grbr2fe8bsj30wp05hq32.jpg)

#### eval配合debugger

> eval() 函数计算 JavaScript 字符串，并把它作为脚本代码来执行。
>
> 如果参数是一个表达式，eval() 函数将执行表达式。如果参数是Javascript语句，eval()将执行 Javascript 语句。

```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Example DEBUGGER</title>
</head>

<body>
    <script>
        var a = 1;
        eval("var 1 = 1;debugger")
    </script>
</body>

</html>
```

> 当使用eval执行时，将会在虚拟机中执行，也就是说非同一作用域。
>
> 同时也由于`将字符串当作表达式来执行`，那么里面常常伴随着代码混淆

#### 函数内执行debugger

```javascript
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Example DEBUGGER</title>
</head>

<body>
    <script>
        (function a(){
            var data = Date();
            alert(data);
            debugger;
        }())
    </script>
</body>

</html>
```

因为以上三种体现形式，在debugger上所设计的方案十分多。例如常见的无限制debugger、配合settimeout延迟debugger、代码混淆+debugger等等。

设置debugger的原理去对抗反爬，其核心原理就是`如果调试工具可用，则调试语句将执行`.也就是经常一打开就跳出debugger。

> 无限debugger，其实是一种泛指的概念，无限泛指多，而非真的无限
>
> 其基于debugger之上，在此加入多次执行debugger的语句从而实现“无限debugger”。“反正只要chrome Devtools不开debugger便不会执行”.（经过调试是这样的，如果不准确请自行完善哦）

### debugger绕过原理

debugger的绕过也很简单，我个人总结共有两种大的方向。它们分别是替换、掠过。其原理都是不让debugger执行。个人并不推荐新手使用替换法中的方法

- 替换法
  - JS注入
  - 重写(Hook)
- 掠过法
  - Never pause here
  - 条件断点



#### JS注入

实现js注入的方式有很多，例如chrome Devtools的overrides、fiddler autoresponse、 mitmproxy、Charles的map local等等。若有兴趣自行搜索其使用方式

#### Never pause here

![](https://tva1.sinaimg.cn/large/008i3skNgy1grfmlz26gtj30gk04hmxb.jpg)

找到debugger前面的行号，鼠标右键点击该行号，点击Never pause here。便会跳过此断点

#### 条件断点

![](https://tva1.sinaimg.cn/large/008i3skNgy1grfmohbkekj30b7029wee.jpg)

![](https://tva1.sinaimg.cn/large/008i3skNgy1grfmqch8l2j30gz02j3yd.jpg)

找到debugger前面的行号，鼠标右键点击该行号，点击 Add conditional breakpoint，直接写false。回车即可

#### Deactivate breakpoints

![](https://tva1.sinaimg.cn/large/008i3skNgy1gro1s7b06wj30a401m0si.jpg)

打开这个图标如下图所示（高亮为打开）

![](https://tva1.sinaimg.cn/large/008i3skNgy1gro1somwu8j301w01aa9t.jpg)

当遇见breakpoints时会执行一次断点，鼠标单击如下图标

![](https://tva1.sinaimg.cn/large/008i3skNgy1gro1svh0onj301m01c3y9.jpg)

即可直接跳过breakpoints。

> 小技巧：Deactivate breakpoints可以配合xhr、dom、Script等断点使用，便于调试

#### Hook绕过

```js
function a() {
	eval("debugger");
}
```



```
(function() {
    var eval_cache = eval;
    eval = function(obj) {
        if (obj.indexof('debugger') === -1) {
            eval_cache(obj);
        }
    }
}())
```

> 此方法有局限性，若在此函数(在这里指函数a)若没有借用相关函数（eval），那么就无法使用此方法绕过

#### 函数滞空法

当遇见断点时，回退一次堆栈。将对应函数滞空即可,例如遇见如下的debugger

```js
function a() {
  debugger;
	eval("debugger");
}
```

直接在控制台输入如下内容即可。

![](https://tva1.sinaimg.cn/large/008i3skNgy1gro22wyydqj30zk06qt8s.jpg)

> 此方法有局限性，若在此函数中还参杂了关键代码，将可能无法访问或调试等

## 总结

Debugger绕过其实并不难，但在调试中仅仅是一道“开胃菜”，本节总结了debugger的实现方式，以及触发机制。当然也总结了几种我已知的所有绕过方案。

### 展望

如何hook“变量”debugger？如果可以实现那么就可以实现反调试的debugger“通杀”，当然目前我也有在探究此方案。在加到hook函数中，那么调试便可以近似于一步到位。
