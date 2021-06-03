---
title: 'Redis:在集合中复制键'
author: Payne
tags: ['Redis', 'redis', '小技巧']
categories:
  - ['Redis', 'redis', '小技巧']
date: 2021-06-03 19:06:09
---

**问题描述: 由于某种原因，我必须需要将某个集合的键（Key）复制一份副本。并移动到目标库**

拿到这个问题，脑海里一共有两种方式

- 将所有的此集合中的所有的值从redis里面读取出来，然后再存进去。
- 使用集合的思想进行取差集或并集。如果二者有一个且仅有一个为空那么他们返回的结果为有值的集合


<!--more-->
## Redis:在集合中复制键

### 方案一

将所有的此集合中的所有的值从redis里面读取出来，然后再存到目标库中。

> 思路清晰，不再过多赘述。

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr5bko8fz0j309m02k744.jpg)

> 如果数据较少可以使用SMEMBERS

类型为set,其中有26781027个

由于直接使用redis命令不是那么方便，故Python代码入下

```python
from loguru import logger
import redis
def conn_redis(db):
    """
    link redis
    :param db:
    :return: Redis Link object
    """
    REDIS_URL = f'redis://:{RedisPASSWD}@{RedisHOST}:{RedisPORT}/{db}'
    redis_client = redis.from_url(REDIS_URL)
    # 验证是否连接
    # print(redis_client.info())
    return redis_client


def get_val(key: str, step):
    """
    get values
    :param step:
    :param key:str
    :return:
    """
    try:
        redis_client = conn_redis(0)
        #  获取键的大小
        key_size = redis_client.scard(key)
        key_type = redis_client.type(key)
        logger.info(f'Key Name: {key}, key Type: {key_type} Key Size: {key_size}')
        page = int(key_size // step) + 1
        for i in range(0, page + 1):
            result = redis_client.sscan(key, i, '*', step)[1]
            yield result
    except Exception as e:
        logger.error(e)


def set_newVal(db):
    redis_client = conn_redis(db)
    redis_client.sadd("NewKey",result)
```

**方案一优化**

> sadd("NewKey",result)还是比较慢。使用pipeline

### 方案二

由于是集合，可以使用集合的操作。

> 任何集合的本身的补、并、差都是本身
>
> 1.集合的交集& ,set.intersection()
>
> 2.集合的并集 | ,set. union()
>
> 3.集合的差集  set.difference(s2) 将集合s1里去掉和s2交集的部分
>
> 4.集合的交叉补集  set.symmetric_difference() 并集里去掉交集的部分



![](https://tva1.sinaimg.cn/large/008i3skNgy1gr5exvf9xmj30q30aywej.jpg)



创建集合 1，2，3

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr5f96nq49j30fs055mx0.jpg)

取给定集合的并集存储在目标集合中

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr5fbdbwbsj30ct06gt8m.jpg)

取给差集合的并集存储在目标集合中

![](https://tva1.sinaimg.cn/large/008i3skNgy1gr5fe8xoj1j30dz043mx0.jpg)

这样就可以实现类似于copy的效果

所使用到的Redis命令

```shell
# help SMEMBERS
SMEMBERS key
summary: Get all the members in a set
since: 1.0.0
group: set

# help SSCAN
SSCAN key cursor [MATCH pattern] [COUNT count]
summary: Incrementally iterate Set elements 增量迭代集合元素
since: 2.8.0
group: set

# help SUNIONSTORE
SUNIONSTORE destination key [key ...]
summary: Add multiple sets and store the resulting set in a key 添加多个集合并将生成的集合存储在一个键中
since: 1.0.0
group: set

# help SDIFFSTORE
SDIFFSTORE destination key [key ...]
summary: Subtract multiple sets and store the resulting set in a key 减去多个集合并将得到的集合存储在一个键中
since: 1.0.0
group: set
```



## 总结

采用先取后存，以及集合的本身是本身的特性对于集合实现复制操作
