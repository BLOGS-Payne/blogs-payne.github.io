---
title: Tampermonkey安装与使用
author: Payne
tags: ["Tampermonkey"]
categories:
  - ["Tampermonkey"]
date: 2021-06-03 18:52:47
---
## Tampermonkey
[TOC]

**Tampermonkey** 是一款免费的浏览器扩展和最为流行的用户脚本管理器，虽然有些受支持的浏览器拥有原生的用户脚本支持，但 Tampermonkey 将在您的用户脚本管理方面提供更多的便利。 它提供了诸如便捷脚本安装、自动更新检查、标签中的脚本运行状况速览、内置的编辑器等众多功能， 同时Tampermonkey还有可能正常运行原本并不兼容的脚本。

<!--more-->

### Tampermonkey的安装

#### 方式一 Chrome商店直接下载

Chrome商店 -> 搜索 Tampermonkey -> Tampermonkey 安装即可

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr4arkuzzmj30yd08jdge.jpg)

一般情况下是无法下载的，除非你能。。。

#### 方式二：第三方网站进行插件文件下载

进入https://www.crx4chrome.com/crx/755/进行安装文件的下载，下载完成后。打开拓展程序(Chrome用户选项框 -> 更多工具 -> 拓展程序)

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr4ay74m2aj30kd0fkt95.jpg)

进入如下图所示的界面

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr4ayxb6y3j31fo0mgwgp.jpg)

打开右上角的 **开发者模式**，将已经下载的文件拖拽至上图所示的界面。即可完成安装。



### 使用第三方脚本

进入greasyfork https://greasyfork.org/zh-CN/scripts 获取需要的插件脚本即可

### 自定义开发脚本

鼠标点击**Tampermonkey**图标呼出其选项卡，点击添加脚本。即可进入新建脚本界面。

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr4baf3mybj31fj0i3gmi.jpg)

#### 语法规则

```javascript
// ==UserScript==
// @key value
// ==/UserScript==
```

#### 字段释意：

##### 基本信息

@name：脚本的名字(自定义)

@author 作者。该脚本的作者。可使用默认的you，或者你的名字

@description 脚本描述（类似于编程中的注释，阐述该脚本的作用等）


##### 命名空间

@namespace 脚本的命名空间(通常使用默认http://tampermonkey.net/，也可指定)

@homepage, @homepageURL, @website and @source 在选项页面使用的作者主页，用于从脚本名称链接到给定页面。如果@namespace 标记以“http://”开头，则其内容也将用于此目的。


##### 版本控制

@version 脚本版本号

@updateURL：用户脚本的更新 URL。 注意：需要一个@version 标签才能使更新检查工作

@downloadURL：URL定义检测到更新时下载脚本的 URL。如果使用值 none，则不会进行更新检查。

@supportURL 定义用户可以报告问题并获得个人支持的 URL。



##### 访问限制

@include

脚本允许运行的页面，可以是多个标签实例。 支持正则语句

> 注意：
>
> @include 不支持 URL 哈希参数，必须匹配没有哈希参数的路径并使用

示例：

```javascript
// ==UserScript==
// @name         New Userscript
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  try to take over the world!
// @author       You
// @include      https://www.tampermonkey.net/documentation.php?ext=dhdg
// @icon         https://www.google.com/s2/favicons?domain=tampermonkey.net
// @grant        none
// ==/UserScript==

(function() {
    'use strict';
    // Your code here...
    alert('HEllo')
})();
```

保存后，当我们访问https://www.tampermonkey.net/documentation.php?ext=dhdg的时候将会弹出Hello。如下图所示

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr4c8ojzwij30x204njre.jpg)

当@match 为 ***** 时，当访问任何一个页面都会alter出对应的内容来。如下图所示

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr4c9uenmkj30wy04nglk.jpg)

@match

@match 与 @include 非常相似，然而@match更安全。它对 * 字符的含义设置了更严格的规则。

@match 与 @include他们都是匹配基于一组由匹配模式定义的 URL。匹配模式本质上是以允许的方案开头的 URL。匹配模式本质上是以允许的方案（http、https、file 或 ftp，并且可以包含“*”字符）开头的 URL。特殊模式匹配以允许的方案开头的任何 URL。

'*' 的含义取决于它是在方案、主机还是路径部分。如果方案是 *，则它匹配 http 或 https，而不匹配 file、ftp 或 urn。如果主机只是 *，那么它匹配任何主机。如果主机是 *._hostname_，则它匹配指定的主机或其任何子域。在路径部分，每个 '*' 匹配 0 个或多个字符。

> @match 与 @include区别请参考
>
> https://wiki.greasespot.net/Metadata_Block#.40match
>
> 匹配规则
>
> https://developer.chrome.com/docs/extensions/mv3/match_patterns/

**简单来说推荐使用@match**

@exclude

不匹配，相当于访问黑名单。如果访问了@exclude中与之匹配的内容则不执行自定义的JavaScript代码

@exclude优先权大于match和@include。如果二者都匹配了，那么默认执行@exclude规则。也就是说即是’白名单‘也是’黑名单‘那么默认为’黑名单‘

##### 第三方链接

@require

指向在脚本本身开始运行之前加载和执行的 JavaScript 文件。

> 脚本中可以有任意数量的@require 键。每个 @require 在安装脚本时下载一次，并与脚本一起存储在用户的硬盘驱动器上。指定的 URL 可能与安装脚本的 URL 相关。

@resource

预加载可由脚本通过 GM_getResourceURL 和 GM_getResourceText 访问的资源。

> 虽然 resourceName 是非语义的，但它应该符合 JavaScript 标识符限制。每个@resource 必须有一个唯一的名称。
>
> 每个@resource 在安装脚本时下载一次，并与脚本一起存储在用户的硬盘驱动器上。指定的 URL 可能与安装脚本的 URL 相关。
>
> 这些命名资源可以分别通过[GM_getResourceText](https://wiki.greasespot.net/GM_getResourceText)和[GM_getResourceURL](https://wiki.greasespot.net/GM_getResourceURL)访问。

@connect

此标签定义域（无顶级域），包括允许通过 GM_xmlhttpRequest 检索的子域

> 可以简单的理解为发送请求。GET、POST、HEAD

@run-at

定义脚本被注入的时刻，与其他脚本处理程序相反， **@run-at** 定义了脚本想要运行的第一个可能时刻。这意味着可能会发生，使用 **@require** 标签的脚本可能会在文档加载后执行，导致获取所需脚本需要很长时间。无论如何，在给定注入时刻之后发生的所有 DOMNodeInserted 和 DOMContentLoaded 事件都被缓存并在注入时传递给脚本。

@run-at document-start 脚本将尽快注入。
@run-at document-body 如果 body 元素存在，脚本将被注入
@run-at document-end 该脚本将在调度 DOMContentLoaded 事件时或之后注入。
@run-at document-idle 脚本将在 DOMContentLoaded 事件被调度后注入。如果没有给出@run-at 标签，这是默认值。
@run-at context-menu 如果在浏览器上下文菜单中单击该脚本（仅限基于 Chrome 的桌面浏览器），则会注入该脚本。

> 建议使用@run-at document-start

@grant

@grant 用于将 GM_* 函数、unsafeWindow 对象和一些强大的窗口函数列入白名单。如果没有给出@grant 标签，TM 猜测脚本需要。

```
// @grant GM_setValue// @grant GM_getValue// @grant GM_setClipboard// @grant unsafeWindow// @grant window.close// @grant window.focus// @grant window.onurlchange
```

由于关闭和聚焦选项卡是一项强大的功能，因此也需要将其添加到 @grant 语句中。

如果脚本在单页应用程序上运行，那么它可以使用 window.onurlchange 来监听 URL 更改：

```
// ==UserScript==...// @grant window.onurlchange// ==/UserScript==if (window.onurlchange === null) {  // feature is supported  window.addEventListener('urlchange', (info) => ...);}
```

如果@grant 后跟“none”，则沙箱将被禁用，脚本将直接在页面上下文中运行。在此模式下，没有 GM_* 功能，但 GM_info 属性将可用。

```
// @grant none
```

> 推荐使用@grant none

@noframes

此标记使脚本在主页上运行，但不在 iframe 上运行。

<div>
  <center>
  	<font color=red size=5px style="font-family: cursive">Reference</br></font>
	</center>
</div>

- Tampermonkey官方地址：https://www.tampermonkey.net/
- Tampermonkey官方文档：https://www.tampermonkey.net/documentation.php?ext=dhdg

- https://wiki.greasespot.net/Metadata_Block#.40match

