---
title: 网页调试之JSHook
author: Payne
tags: ["爬虫", "Crawler", "浏览器", "调试", "JS", "Hook"]
categories:
- ["爬虫", "调试", "Hook"]
date: 2021-06-12 22:25:29
---

## 网页调试之JSHook

### 什么是Hook？

Hook 又叫作钩子技术，它就是在程序运行的过程中，对其中的某个方法进行重写，在原有的方法前后自定义的代码。相当于在系统没有调用该函数之前，钩子程序就先捕获该消息，可以先得到控制权，这时钩子函数便可以加工处理（改变）该函数的执行行为。执行函数后释放控制权限，继续运行原有逻辑。
<!--more-->
### Hook执行流程图

![](https://tva1.sinaimg.cn/large/008i3skNgy1gqxgrt9q3sj30kv0j3wej.jpg)

### Hook思路

1. 寻找hook点
2. hook
3. 伪装hooker
4. 调试(堆栈)

### Hook公式

```javascript
// 函数hooker
var func_copy = func
func = function(argument){
	// hooker
  return func.apply(obj,argument)
}

// 属性hooker
var attr_copy = obj.attr
Object.defineProprety(obj, 'attr' {
  get:function() {
		// your code
  }
  set:function() {
		// your code
  }
}
```

### Hook实例

```js
// hook btoa
(function () {
    'use strict'
    alert('Start Hooking ...');
    function hook(obj, attr) {
        var func = obj[attr]
        obj[attr] = function () {
            console.log('hooked', obj, attr, arguments)
            var ret = func.apply(obj, arguments)
            debugger
            console.log('result', ret)
            return ret
        }
        // Disguise the prototype
        attr.toString = function () {
            return "function btoa() { [native code] }";
        };
        attr.length = 1;
    }
    hook(window, 'btoa')
})()

// hook eval
(function () {
    alert('Start Hooking ...');
    function Hooker(obj, attr) {
        var func = obj[attr]
        obj[attr] = function () {
            console.log('hooked', obj, attr, arguments);
            var result = func.apply(obj, arguments);
            debugger;
            console.log('result', result);
            return result;
        }
        // Disguise the prototype
        attr.toString = function () {
            return "function eval() { [native code] }";
        };
        attr.length = 1;
    }
    Hooker(window, 'eval')
})()


// hook document.cookie

```



### Hook 优与劣

#### 优点

1. 快速定位函数，方便调试
2. 注入，不影响原本逻辑

#### 弊端

1. 新手难以有效的hook
2. 反hook往往需要分析与绕过（类似于包装类、浏览器指纹、内部类等）

#### Hook伪装

> 函数hook伪装

```js
// Disguise the prototype
attr.toString = function () {
return "function btoa() { [native code] }";
};
attr.length = 1;
```



![](https://tva1.sinaimg.cn/large/008i3skNgy1grgwa9ysgcj31d00bcjv6.jpg)

### 更底层的Hook(原型链Hook)

在以上，我们对于函数进行了hook的总结，但若需要hook更加底层的函数该如何？

如果想要hook 例如 字符串的split方法,match方法。该如何？使用以上的方法将无法有效的实现hook。

示例：

```js
func = "需Hook处"

# 常规hook思路(错误示例)
1.保存改写函数
2.重写hook函数
3.下debugger或其他调试逻辑

split = function(val) {
  debugger;
}
```

![](https://tva1.sinaimg.cn/large/008i3skNgy1gs2rfrdgp1j307p04dq2t.jpg)

可正常操作

![](https://tva1.sinaimg.cn/large/008i3skNgy1gs2rhklerfj30830493yd.jpg)

无法实现对于split的hook，常规方案无法实现hook。

> 思考：为什么无法hook split -> 没有hook到split
>
> 为什么无法hook split？ -> 没有hook到split
>
> Split 的“原函数”在哪里？-> 原型链 -> String的方法

所以如果需要hook，就需要从原型链处进行入手,发现其实as.split 与 String.prototype 是同一个东西

![](https://tva1.sinaimg.cn/large/008i3skNgy1gs2rrew34wj307a029a9v.jpg)

那么我们直接对于进行如下操作,在控制台（console）中输入

```js
as = “hook mark”;

# rewrite
String.prototype.split = function() {
		console.log('val');
		debugger;
}
```

此时调用split函数，就会发现已经完成对split的hook

![image-20210702181800770](/Users/stringle-004/Library/Application Support/typora-user-images/image-20210702181800770.png)

随之而来的又是一个新问题，hook的为只要字符串调用split方法就都会被debugger到。显然并不适合在实践中进行调试。如下给出完整的hook split的代码

```js
// create split cache from proto
String.prototype.split_cache = String.prototype.split
String.prototype.split = function(val) {
    // Gets the variable of the current scope
    str = this.String();
    console.log('Arguments:', val)
    debugger;
    return str.split_cache(val);
}
```

> 如果感觉不明白为什么需要这样写的，或许需要复习一下js 原型链相关知识



### Hook失败原因归纳

Hook函数有时也会出现hook失败或者hook失效的情况，个人总结如下：

1. 函数hook一般情况下Hook不会失败，若失败一定是对于该函数的`__proto__`进行检测，此时只需要对`__proto__`,进行伪装即可
2. 当目标网站的所有逻辑都采用了`Object.defineProperty`时，属性Hook就会失效
3. 当Hook的函数为“内部”函数时，需要特殊的手段进行处理。例如将该函数加入到内存中。（当未加载页面，也会造成Hook失效）

### 常用Hook逻辑

具体示例请参考：https://github.com/Payne-Wu/JsHookScript

