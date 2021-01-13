---
title: Redis概览与安装
author: Payne
tags: ["NoSQL", "Redis","数据库"]
categories:
  - ["Redis", "NoSQL","数据库"]
date: 2021-01-14 01:29:01
---
## Redis概览

Redis是一个开源（BSD许可）的内存数据结构存储，用作数据库、缓存和消息代理。Redis提供诸如字符串、哈希、列表、集合、带范围查询的排序集合、位图、超日志、地理空间索引和流等数据结构。Redis具有内置的复制、Lua脚本、LRU逐出、事务和不同级别的磁盘持久性，并通过Redis Sentinel和Redis Cluster的自动分区提供高可用性
<!--more-->
```undefined
数据类型丰富    								（笔试、面试）*****
支持持久化      								 （笔试、面试）*****
多种内存分配及回收策略
支持事务            						（面试） ****
消息队列、消息订阅 
支持高可用                             ****
支持分布式分片集群 							（面试）*****
缓存穿透\雪崩（笔试、面试）   					  *****
Redis API                  					 **
```

## Redis使用场景介绍

Memcached：多核的缓存服务，更加适合于多用户并发访问次数较少的应用场景
Redis：单核的缓存服务，单节点情况下，更加适合于少量用户，多次访问的应用场景。Redis一般是单机多实例架构，配合redis集群出现。

## Redis 安装

### 编译安装

```sh
# 官方示例
# 安装依赖
yum -y install gcc automake autoconf libtool make
# 安装源码包
wget https://download.redis.io/releases/redis-6.0.10.tar.gz
# 解压
tar xzf redis-6.0.10.tar.gz
# 进入文件
cd redis-6.0.10
# 编译安装
make


# 自定制
# 安装依赖
yum -y install gcc automake autoconf libtool make
# 创建目录
mkdir /database && cd /database
# 下载源码
wget https://download.redis.io/releases/redis-6.0.10.tar.gz
# 解压
tar xzf redis-6.0.10.tar.gz
# 进入目录
cd redis-6.0.10
# 编译安装
make
# 配置环境变量
echo "export PATH=/databases/redis-6.0.10/src:$PATH" >> /etc/profile  && source /etc/profile
```

安装成功，如下图

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmmgwgimywj30tu050jrs.jpg)

```sh
# src/redis-server & 
src/redis-cli
redis> set foo bar
OK
redis> get foo
"bar"
```

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmmhgt73evj30ji07gq3a.jpg)

> 温馨提示：
>
> 若编译失败，请检查`gcc`版本(可使用`gcc -v`)查看
>
> 我这里的是9.0.1

### 包管理工具安装

```sh
apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade 
apt install -y  software-properties-common
sudo add-apt-repository ppa:redislabs/redis
sudo apt-get update
sudo apt-get install redis
```



Referer

[Redis官网](https://redis.io/)

[Redis中文文档](http://www.redis.cn/)


