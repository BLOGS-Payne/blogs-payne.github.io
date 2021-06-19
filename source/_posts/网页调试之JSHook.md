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
2. 反hook（类似于包装类、浏览器指纹、内部类等）

#### PCHook伪装

> 函数hook伪装

```js
// Disguise the prototype
attr.toString = function () {
return "function btoa() { [native code] }";
};
attr.length = 1;
```

![](https://tva1.sinaimg.cn/large/008i3skNgy1grgwa9ysgcj31d00bcjv6.jpg)

### 常用Hook逻辑



```
// _$$4
// _$jx
```



具体示例请参考：https://github.com/Payne-Wu/JsHookScript
