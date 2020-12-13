---
title: docker部署控制
author: Payne
tags: ["docker"]
categories:
- ["容器编排"]
date: 2020-12-13 23:44:48
---
## Docker swarm部署控制

还记得我之前写过一片文章叫做[《Docker快速部署项目，极速搭建分布式》](https://mp.weixin.qq.com/s?__biz=Mzg2MzM4NTg3MA==&tempkey=MTA5MF9RcFZ5c1B4QTFmSnZHd2Qxa3hMNWhpLXFoOEJYWVBBaUZyME1sRmVBQnR1QWN3V3FUZ1hfa1BnemdtOWpLY1o0RTlzVnE2OUtRblZPS1ZDV2pDSk9QU3BadDUzLTNJa3RHYmxFQXNqMjQyQ1dSNUlrcDdfTG1scDRTWVg2UDdiLTI5eWo4dE9HSHI4TlVKOVltZEdtVzZObW9NT19GN2I5eF9YbzdBfn4%3D&chksm=4e78226b790fab7d1fb0283f8b6294c40456df7aebf58d947412ed03d0c3fc3aa188de79f130#rd)，在那里讲述了如何去使用docker swarm，如何构建自己的私人镜像仓库。随着最近的业务量的增长，机子加多。对于docker swarm管理难度有上升的趋势。主要的问题有以下几个

- 物理机配置不同（比如 CPU、内存等）
- 部署着不同类型的服务（比如 Web服务、Job服务等）
- Swarm 集群中的节点跨机房，为了内部服务间通信更快，该如何分组部署
- 。。。

为了解决以上问题,以求更合理、更科学的管理部署所以有了今天这篇文章。
<!--more-->
docker 节点的部署调度一共有三种机制，随机部署、平衡部署、先满部署

> 随机部署：active中随机选择
>
> 平衡部署：尽可能先平均填满所有的节点
>
> 先满部署：与平衡部署相反，先部署至上限，然后在部署对应的


那么该如何管理呢？下面我介绍几种方式，如下

- NodeId
- HOSTNAME
- Node role
- node labels
- engine.labels

首先我们查看一下节点列表信息，直接使用`docker node ls`，即可

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glgia65xg6j31jo0b8dgn.jpg)

首先我们先解读一下，docker 的限制指令

```bash
# docker service create --help
--constraint list                    Placement constraints
--container-label list               Container labels
```

他们的 后面跟随的参数都是list，具体使用如以下示例

### NodeId

根据NodeId来指定部署节点，以下以搭建私人镜像仓库为示例。

#### docker service

```bash
docker service create \
--name registry \
--publish published=5000,target=5000 \
--constraint node.id==ytsyvuhfs60spr361y6irpynm \
registry:2
```

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glgiv5qw30j31le03i0sr.jpg)

命令解读

```bash
# 在docker swarm中创建服务
docker service create 	\
# --name 服务别名
# 指定node的id，ytsyvuhfs60spr361y6irpynm这个是我这里的node.id，你使用的时候需按照需求替换即可
--constraint node.id==ytsyvuhfs60spr361y6irpynm \
# 暴露公开的接口，可以让节点中的其他node可以访问
--publish published=5000,target=5000	\
# 镜像名：版本号
registry:2
```

这样我们就实现了指定节点的部署，是不是很简单呢。

#### docker stack

```yaml
# docker-compose.yaml 
version: '3'
services:
    registry:
         registry:2
         ports:
           - target: 8080
           - published: 8080
           - protocol: tcp
           - mode: ingress
         deploy:
           mode: global
           placement:
              constraints:                      # 添加条件约束
                - node.id==ytsyvuhfs60spr361y6irpynm
           restart_policy:
             condition: on-failure
             max_attempts: 3
```

### HOSTNAME

​	除此之外我们还可以指定hostname 去将应用部署到指定的hostname上，操作与以上差不多。那让我们来实现一下，首先我们需要查看对应节点的信息，在manager节点上使用`docker node ls `查看，如下

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glmhr7pa7oj31yo07ewfw.jpg)

#### docker service

**创建命令如下**,以nginx为例

```
docker service create \
--name nginx \
--constraint node.hostname==ecs-dc8a-0003 \
-p 80:80 nginx
```

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glmi66uraij31y405mt9f.jpg)

这样我们就将nginx服务部署至对应的节点了，并且扩容也仅会在此节点进行部署。示例如下

```
docker service scale nginx=3
```

![](https://tva1.sinaimg.cn/large/0081Kckwgy1glmidvm1g1j31y60pwtcy.jpg)

#### docker stack

```yaml
# docker-compose.yaml 
version: '3'
services:
    nginx:
         image: nginx
         ports:
           - target: 80
           - published: 80
           - protocol: tcp
           - mode: ingress
         deploy:
           mode: global
           placement:
              constraints:                      # 添加条件约束
                - node.hostname==ecs-dc8a-0003
           restart_policy:
             condition: on-failure
             max_attempts: 3
```



### Node role

前面我们了解到了根据`node.id`,`node.hostname`进行指定节点的部署，但指定的却是唯一的。那么该如何实现同一类进行随机的部署呢？到这里我们继续深入了解，更具节点关系的进行约束。可部署节点中的关系有leader，work。

例如，我想实现不在主节点上部署，虽然我们可以使用使用限制中的条件，避开。例如这样

```yaml
# 示例
docker service create \
--name registry \
--publish published=5000,target=5000 \
--constraint node.id!=ytsyvuhfs60spr361y6irpynm \ # 修改处
registry:2
```

只需要将`==`,改为`!=`,即可。

#### docker service

但终究还是感觉很不喜欢，其实我们也可以这样,根据节点关系进行约束部署，示例如下

```sh
docker service create \
--name nginx \
--publish published=80,target=80 \
--constraint node.role!=manager nginx
```

#### docker stack

```yaml
# docker-compose.yaml 
version: '3'
services:
    nginx:
         image: nginx
         ports:
           - target: 80
           - published: 80
           - protocol: tcp
           - mode: ingress
         deploy:
           mode: global
           placement:
              constraints:                      # 添加条件约束
                - node.role!=manager
           restart_policy:
             condition: on-failure
             max_attempts: 3
```

### Node lables

讲了这么多，照顾新手的就已经过去了，接下来我们晚点更常用的部署，更具lables，来部署。只要是同一个lable，就会可以被部署到，切后续还可以根据label进行更得心应手的管理，例如加入一个label，进行节点驱逐、然后在新加入lables，扩容

#### 添加标签与检查标签

```sh
# 添加标签
docker node update --label-add role=web hostname
# 检查标签
docker node inspect hostname 
# 删除标签
docker node update --label-rm role hostname
```

输出如下

```sh
"ID": "ttdku9ch37pknxu7b9sxknimb",                                                                                   
        "Version": {                                                                                                         
            "Index": 852                                                                                                     
        },                                                                                                                   
        "CreatedAt": "2020-12-08T11:10:53.322771866Z",                                                                       
        "UpdatedAt": "2020-12-13T13:24:57.009816659Z",                                                                       
        "Spec": {                                                                                                            
            "Labels": {                                                                                                      
                "role": "web"              # 这样我们就实现了添加标签                                                                                  
            },                                                                                                               
            "Role": "manager",                                                                                               
            "Availability": "active"                                                                                         
        },                 
        # 略
```

#### docker Service

```bash
docker service create \
  --name nginx_2 \
  --constraint 'node.labels.role == web' \
  nginx
```

#### docker Stack

```csharp
version: '3'
services:
    mycat:
         image: nginx
         ports:
           - target: 8080
             published: 8080
             protocol: tcp
             mode: ingress
         deploy:
           mode: global
           placement:
              constraints:                      # 添加条件约束
                - node.labels.role==web
           restart_policy:
             condition: on-failure
             max_attempts: 3
```

`constraints` 为数组，填写多个约束时，它们之间的关系是 `AND`。也就是说我们可以进行组合使用

### 更多请参考下表

| node attribute       | matches                        | example                                       |
| :------------------- | :----------------------------- | :-------------------------------------------- |
| `node.id`            | Node ID                        | `node.id==2ivku8v2gvtg4`                      |
| `node.hostname`      | Node hostname                  | `node.hostname!=node-2`                       |
| `node.role`          | Node role (`manager`/`worker`) | `node.role==manager`                          |
| `node.platform.os`   | Node operating system          | `node.platform.os==windows`                   |
| `node.platform.arch` | Node architecture              | `node.platform.arch==x86_64`                  |
| `node.labels`        | User-defined node labels       | `node.labels.security==high`                  |
| `engine.labels`      | Docker Engine’s labels         | `engine.labels.operatingsystem==ubuntu-14.04` |



### 推荐阅读

[此部分的官方文档](https://docs.docker.com/engine/reference/commandline/service_create/#set-service-mode---mode)




