---
title: scrapy-splash对接代理
author: Payne
tags: ["scrapy", "splash", "scrapy-splash"]
categories:
- ["技术杂谈"]
date: 2020-12-19 14:11:52
---
## Scrapy-Splash使用及代理失败处理

在日常做爬虫的时候肯定遇到这么一些问题，网页js渲染，接口加密等，以至于无法有效的获取数据，那么此时若想获取数据大致有两种方向，`硬刚加密参数`或`使用渲染工具`

二者的各有所不同？

刚加密参数：

- 优势：爬取速度快，实效性。损耗资源更少

- 劣势：耗费时间长，不懂的完全不会，会的也不一定能完全处理。难以在有效的时间内获取到数据

渲染工具：webdervi，puppeteer，pyppeteer，splash

- 优势：见效快、新手友好
- 劣势：爬取速度较慢、数据实效性难以保证、损耗资源多

那么相信做爬虫的小伙伴一定会有相对应的权衡

> 个人建议：如果可以刚参数，尽量刚参数。一方面是为了自己的在爬虫这条路上逐步前进，另一方面是更加符合
>
> 当然如果实在搞不掉了，也可以使用渲染工具来进行模拟爬取
<!--more-->
### splash是什么？

**Splash-一种JavaScript渲染服务**

Splash是一种javascript渲染服务。这是一个带有HTTP API的轻量级Web浏览器，使用Twisted和QT5在Python 3中实现。（扭曲的）QT反应器用于使服务完全异步，从而允许通过QT主循环利用Webkit并发性。Splash的一些功能：

- 并行处理多个网页；
- 获取HTML结果和/或获取屏幕截图；
- 关闭图片或使用Adblock Plus规则来加快渲染速度；
- 在页面上下文中执行自定义JavaScript；
- 编写Lua浏览[脚本](https://splash.readthedocs.io/en/stable/scripting-tutorial.html#scripting-tutorial);
- 在[Splash-Jupyter](https://splash.readthedocs.io/en/stable/kernel.html#splash-jupyter) Notebook中开发Splash Lua脚本。
- 以HAR格式获取详细的渲染信息。

话不多说，直接上splash。谁让我菜呢？

### splash的安装

官方建议直接使用docker进行运行，[docker安装](https://docs.docker.com/get-docker/)

安装完成之后直接运行一下命令，使用docker运行splash

```sh
# 拉取splash
docker pull scrapinghub/splash
# 运行splash 
docker run -p 8050:8050 --name splash scrapinghub/splash
docker run -itd --name splash  -p 8050:8050 scrapinghub/splash --disable-lua-sandbox
# -p 向外暴露端口
# -d 守护进程方式运行(后台运行)
# --name 自定义昵称
# --disable-lua-sandbox 关闭沙盒模式。如果是在测试环境上可以直接去体验一下，功能更全。如果是在开发环境的话那就直接用正式的，虽然花里胡哨，但安全性并不好
```

此时你若无意外你可以访问'http://localhost:8050/'，就可以看到这样的画面

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glt2mblmo3j31kh0u0q51.jpg)

ok，到这里你就可以正常的使用它了，此时对于新手朋友的关照就已经结束了。接下来让我们对接scrapy。请确保scrapy可以正常运行。

```sh
# 创建项目
scrapy startproject <projectName>
# 创建spider
cd <projectName>
scrapy genspider httpbin httpbin.org/get
```

此时的项目结构应该如下

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glt3ab0oyij30kc0fc3yn.jpg)

### scrapy-splash试用前配置

#### 安装依赖

```sh
pip3 install scrapy-splash
```

settings.py

```python
# 修改
SPIDER_MIDDLEWARES = {
    'scrapy_splash.SplashDeduplicateArgsMiddleware': 100,
}

DOWNLOADER_MIDDLEWARES = {
    'scrapy_splash.SplashCookiesMiddleware': 723,
    'scrapy_splash.SplashMiddleware': 725,
    'scrapy.downloadermiddlewares.httpcompression.HttpCompressionMiddleware': 810,

}

# Configure scrapy-splash(加入)
SPLASH_URL = 'http://localhost:8050'
DUPEFILTER_CLASS = 'scrapy_splash.SplashAwareDupeFilter'
HTTPCACHE_STORAGE = 'scrapy_splash.SplashAwareFSCacheStorage'
```

Httbin.py

```python
import scrapy
from scrapy_splash import SplashRequest

class HttbinSpider(scrapy.Spider):
    name = 'httpbin'
    # allowed_domains = ['httbin.org/get']
    start_urls = ['https://httpbin.org/get']

    def start_requests(self):
        print(self.start_urls[0])
        yield SplashRequest(
            url=self.start_urls[0],
            callback=self.parse
        )

    def parse(self, response, **kwargs):
        print(response)
        print(response.text)
```

```sh
# 运行爬虫
scrapy crawl httpbin
```

返回打印结果如下

```sh
2020-12-19 13:21:51 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://httpbin.org/get via http://localhost:8050/render.html> (referer: None)
<200 https://httpbin.org/get>
<html><head></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">{
  "args": {}, 
  "headers": {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
    "Accept-Encoding": "gzip, deflate", 
    "Accept-Language": "en", 
    "Host": "httpbin.org", 
    "User-Agent": "Scrapy/2.4.0 (+https://scrapy.org)", 
    "X-Amzn-Trace-Id": "Root=1-5fdd8dea-4ba769963b76178b56cd9724"
  }, 
  "origin": "220.202.249.12", 
  "url": "https://httpbin.org/get"
}
</pre></body></html>

---略
```

我们用浏览器访问一下"https://httpbin.org/get"

```sh
{
  "args": {}, 
  "headers": {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9", 
    "Accept-Encoding": "gzip, deflate, br", 
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,ja;q=0.7", 
    "Dnt": "1", 
    "Host": "httpbin.org", 
    "Sec-Fetch-Dest": "document", 
    "Sec-Fetch-Mode": "navigate", 
    "Sec-Fetch-Site": "none", 
    "Sec-Fetch-User": "?1", 
    "Upgrade-Insecure-Requests": "1", 
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36", 
    "X-Amzn-Trace-Id": "Root=1-5fdd8e50-48c6e9ec6dc7274967b9a493"
  }, 
  "origin": "220.202.249.12", 
  "url": "https://httpbin.org/get"
}
```

Ok，基本的使用也就到这里ok了。那么该如何配置代理呢？访问量一大大多情况下都会封ip

#### 设置代理

如下

```sh
import scrapy
from scrapy_splash import SplashRequest

class HttbinSpider(scrapy.Spider):
    name = 'httbin'
    # allowed_domains = ['httbin.org/get']
    start_urls = ['https://httpbin.org/get']

    def start_requests(self):
        print(self.start_urls[0])
        header = {
            'User-Agent': 'Mozilla/5.0 (Linux; U; Android 0.5; en-us) AppleWebKit/522  (KHTML, like Gecko) Safari/419.3'
        }
        # yield scrapy.Request(url=self.start_urls[0], callback=self.parse, headers=header)
        yield SplashRequest(
            url=self.start_urls[0],
            callback=self.parse,
            args={
                "wait": 3,
                "proxy": 'http://119.114.100.159:22992'
            }

        )

    def parse(self, response, **kwargs):
        print(response)
        print(response.text)

# 输出结果如下
2020-12-19 13:31:06 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://httpbin.org/get via http://localhost:8050/render.html> (referer: None)
<200 https://httpbin.org/get>
<html><head></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">{
  "args": {}, 
  "headers": {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
    "Accept-Encoding": "gzip, deflate", 
    "Accept-Language": "en", 
    "Host": "httpbin.org", 
    "User-Agent": "Scrapy/2.4.0 (+https://scrapy.org)", 
    "X-Amzn-Trace-Id": "Root=1-5fdd9017-7ef5ac1d6c66d99b52b200c0"
  }, 
  "origin": "119.114.100.159", 	# 代理修改完成
  "url": "https://httpbin.org/get"
}
</pre></body></html>
```

使用中间件的方式设置代理

```python
class MyHttpProxyMiddleware(object):
      def process_request(self, request, spider):
	      request.meta['splash']['args']['proxy'] = proxyServer	# （eg：'http://119.114.100.159:22992'）
        # 认证消息，没有可以不写
	      # request.headers["Proxy-Authorization"] = proxyAuth
```

此时的中间件设置为

```sh
DOWNLOADER_MIDDLEWARES = {
    'learnSplash.middlewares.MyHttpProxyMiddleware': 724,
    'learnSplash.middlewares.MyUserAgentMiddleware': 400,
    'scrapy_splash.SplashCookiesMiddleware': 723,
    'scrapy_splash.SplashMiddleware': 725,
    'scrapy.downloadermiddlewares.httpcompression.HttpCompressionMiddleware': 810,

}
```

### 对接代理错误点总结：

1. ```python
   # settings中
   SPLASH_URL = 'http://localhost:8050'
   错写成SPLASH_URL = 'localhost:8050' (错误。验证方式command+鼠标左点击，若能正常显示splash页面即可)
   ```

2. ```python
   # 爬虫文件中
   args={
   "wait": 3,
   "proxy": 'http://119.114.100.159:22992'
   }
   # proxy，书写格式不对，缺少http等字段
   ```

3. ```python
   # 中间键设置代理
   # 错误点一：书写格式不对，缺少http等字段
   # 权重设置错误
   DOWNLOADER_MIDDLEWARES = {
       'learnSplash.middlewares.MyHttpProxyMiddleware': 724,
       'learnSplash.middlewares.MyUserAgentMiddleware': 400,
       'scrapy_splash.SplashCookiesMiddleware': 723,
       'scrapy_splash.SplashMiddleware': 725,
       'scrapy.downloadermiddlewares.httpcompression.HttpCompressionMiddleware': 810,
   
   }
   # MyHttpProxyMiddleware的权重必须小于等于725，否则设定不成功。将使用原始ip访问
   ```

### Referer

### [官方文档](https://splash.readthedocs.io/en/stable/)

[完整代码](https://github.com/PowerSpider/ScrapySplashTest)


