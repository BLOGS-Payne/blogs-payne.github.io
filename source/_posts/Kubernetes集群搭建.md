---
title: Kubernetes集群搭建
author: Payne
tags: ["Kubernetes", "docker","容器编排", "部署"]
categories:
  - ["Kubernetes", "docker"]
date: 2021-02-07 01:59:26
---
其实本节的文章我在很久之前就已经发过了一次，但不够详细，层次不轻。我今天部署的时候看的够呛(虽然也是部署成功了)，也算是对以前的坑，做个忏悔吧。本文可能会比较boring，但请相信这并不是我的本意。这一定是最精简的笔记之一，相信我这绝对不是混水。

本文主要分三大部分，他们分别是系统初始化、安装docker、安装Kubernetes，测试验证与删库跑路
<!--more-->
### 系统初始化

> 请注意后面的单词all，代表所有(master、node)
>
> Master：仅在master上
>
> node: 仅在node上

#### 关闭防火墙(`all`)

```sh
## 临时关闭
systemctl stop firewalld
## 永久关闭
systemctl disable firewalld
## 验证防火墙是否关闭
systemctl status firewalld 
```

效果如下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gne8fmrrrpj31cw0h6dl3.jpg)

#### 关闭selinux(`all`)

```sh
# 临时关闭
setenforce 0
# 永久
sed -i 's/enforcing/disabled/' /etc/selinux/config

```

#### 关闭swap(`all`)

```sh
# 临时
swapoff -a 
# 永久
sed  -ri 's/.*swap.*/#&/' /etc/fstab

# 一条命令完成所有
systemctl stop firewalld && setenforce 0 && swapoff -a && systemctl status firewalld 
```

#### 设置主机名称(`all`)

```
# 设置名称(k8s-m-1)忽略大写字母
hostnamectl set-hostname master
# 验证
hostname
```

#### 时间同步(`All`)

```sh
yum install -y ntpdate  && ntpdate time.windows.com
```

#### 在`Master`添加Hostname(`master`)

```sh
# 设置
cat >> /etc/hosts << EOF
masterIp master
node1Ip node1
node2Ip node2
EOF

# example
cat >> /etc/hosts << EOF
192.168.50.182	 master
192.168.50.252   node
EOF
```

> 验证，此时`ping node`， 看是否能ping通

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gne92s7tj7j31800ge41c.jpg)

#### 将桥接的IPV4 流量传递到iptables的链(`all`)

```sh
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 生效
sysctl --system
```

### 安装Docker

#### 删除docker(可选)

```sh
# You can use scripts for one click installation，You may need to type enter at the end
# remove docker 
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
# Set up repository
sudo yum install -y yum-utils
wget https:/mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
yum -y install docker-18.06.1.ce-3.e17
```

#### 安装docker

```sh
# Use Aliyun Docker
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# install docker from yum
yum install  -y docker-ce docker-ce-cli containerd.io
# cat version 
docker --version

# 配置镜像加速
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://etdea28s.mirror.aliyuncs.com"]
}
EOF

# reload
sudo systemctl daemon-reload
# 配置开启自启
sudo systemctl enable docker
# start docker
systemctl restart docker
```

**验证docker镜像加速**

在终端上输入`docker info`,效果图如下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gne9v1z6acj30ks03q3yn.jpg)

完成～

### 安装Kubernetes

#### 配置阿里镜像源(all)

```sh
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

#### 安装 kubectl kubelet kubeadm(`all`)

```sh
# install kubectl kubelet kubeadm
yum install -y kubectl kubelet kubeadm --disableexcludes=kubernetes
#--disableexcludes=kubernetes  禁掉除了这个之外的别的仓库
# set boot on opening computer
systemctl enable kubelet
```

#### kubeadm初始化(`Master`)

```sh
kubeadm init \
--apiserver-advertise-address=masterIp   \
--image-repository registry.aliyuncs.com/google_containers  \
--service-cidr=10.10.0.0/16 \
--pod-network-cidr=10.122.0.0/16

# eg  
kubeadm init \
--apiserver-advertise-address=192.168.50.182   \
--image-repository registry.aliyuncs.com/google_containers  \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16
```

如果没有Error，即kubeadm开始初始化成功

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnea5d1zctj31ek0b240h.jpg)

等上几分钟，初始化成功，如下图

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gneaijhntij31mw0l6jup.jpg)

**开启集群(master)**

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 验证
kubectl get node
# 正常打印出信息即，成功
```

**节点加入集群(node)**

```sh
# 例如
kubeadm join 192.168.50.182:6443 --token 7t70cl.hr22v89g7wkqojdf \
    --discovery-token-ca-cert-hash sha256:d0541c10506744981838a7d4ce504eb69d28fdcfc8e1261373505c42047be33f
```

这个是初始化完成后，系统给的。请以自己输出为准

```
# 默认token24hour后过期，获取新token命令如下：
kubeadm token create --print-join-command
```

**部署CNI网络组件**

```sh
# 由于是国外的源，国内无法访问。我们需要添加镜像，若存在，则忽略
echo "199.232.28.133 raw.githubusercontent.com" >> /etc/hosts

# 部署CNI网络组件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

```
# 开启IPVS，修改ConfigMap的kube-system/kube-proxy中的模式为ipvs
kubectl edit cm kube-proxy -n kube-system 
# 将空的data -> ipvs -> mode中替换如下
mode: "ipvs"
```

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk82xypglpj30rg0eo431.jpg)

此时已经全部就绪了，如下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnebsqe1pwj310g03sq3g.jpg)

### 验证测试

```sh
# kubectl create deployment NAME --image=image -- [COMMAND] [args...] [options]
# 简单部署nginx
kubectl create deployment nginx --image=nginx
# 对外暴露端口
kubectl expose deployment nginx --port=80 --type=NodePort
# 查看状态
kubectl get pod,svc
# 查看命名空间
kubectl get all -n kube-system
```

部署成功示意图

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnebxc1qlfj3114032weu.jpg)

向外暴露随机端口

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnebyb224zj315q03i0t8.jpg)

访问集群中任意一个ip

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnec5gpwbij30ni0gogn2.jpg)

完成～

补充，删除部署的服务

```
kubectl get deployment 
# 我们只需要删除对应的deploy 即可
kubectl delete deployment nginx
```

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnec92m03hj30wm03q0sv.jpg)

删除成功后，已经找不到nginx的影子，完成

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnece8de4uj31w40bkgr2.jpg)

## 总结

本节我们对使用`kubeadm`工具快速搭建搭建了Kubernetes的集群，系统初始化，记得关闭防火墙、分区等哦。

如果对你有帮助，感觉不错。可以推荐给朋友哦，让他拿着笔记部署，怎一个香字了得，加油，冲冲冲～