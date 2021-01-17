---
title: 详探Redis.conf
author: Payne
tags: ["NoSQL", "Redis","数据库"]
categories:
  - ["Redis", "NoSQL","数据库"]
date: 2021-01-18 01:26:08
---




> Redis版本：6.0.10
>
> redis.conf 默认路径：/opt/redis-6.0.10 路径下（如果为自定制安装，则在您设置的redis路径下）

还记得我刚入行的时候，我的师傅就经常告诉我们`配置比开发更重要`，因为很多时候就是由于配置不当，而造成后期的难以预想的各种问题，以至于项目难以维护等等由于配置。进入一个公司首先的也是看相关项目的文档。so，如果需要对于redis有更深入的了解，与使用配置文件不可不读。为CURD，但不止于CURD。那么接下来我们对于`redis.conf`有个了解，话不多说，开干。
<!--more-->





## 前言

```ini
Redis configuration file example.

Note that in order to read the configuration file, Redis must be
started with the file path as first argument:

./redis-server /path/to/redis.conf

Note on units: when memory size is needed, it is possible to specify
it in the usual form of 1k 5GB 4M and so forth:

1k => 1000 bytes
1kb => 1024 bytes
1m => 1000000 bytes
1mb => 1024*1024 bytes
1g => 1000000000 bytes
1gb => 1024*1024*1024 bytes

units are case insensitive so 1GB 1Gb 1gB are all the same.
```

Redis启动必须指定配置文件路径(如果没有则使用默认的配置文件)，

> 说明如果我们把`默认的`配置文件给删除了，是无法启动redis的。
>
> 同理既然可以指定路径，那么我们也可以参考默认配置文件，定制化配置Redis

需要使用内存大小时，可以指定单位，通常是以 k,gb,m的形式出现，并且**单位不区分大小写**。

仔细看你会发现它只支持`bytes`类型，不支持``bit`等类型

## INCLUDES

```ini
Include one or more other config files here.  This is useful if you
have a standard template that goes to all Redis servers but also need
to customize a few per-server settings.  Include files can include
other files, so use this wisely.
# 在此处包括一个或多个其他配置文件。如果您具有可用于所有Redis服务器的标准模板，但还需要自定义一些每台服务器设置，则此功能很有用。包含文件可以包含其他文件，因此请明智地使用它
Note that option "include" won't be rewritten by command "CONFIG REWRITE"
from admin or Redis Sentinel. Since Redis always uses the last processed
line as value of a configuration directive, you'd better put includes
at the beginning of this file to avoid overwriting config change at runtime.
# 请注意，选项“ include”将不会被admin或Redis Sentinel中的命令“ CONFIG REWRITE”重写。由于Redis始终使用最后处理的行作为配置指令的值，因此最好将include放在此文件的开头，以避免在运行时覆盖配置更改
If instead you are interested in using includes to override configuration
options, it is better to use include as the last line.
# 相反，如果您有兴趣使用include覆盖配置选项，则最好使用include作为最后一行
include /path/to/local.conf
include /path/to/other.conf
```

我们知道Redis只有一个配置文件，如果多个人进行开发维护，那么就需要多个这样的配置文件，这时候多个配置文件就可以在此通过 include /path/to/local.conf 配置进来，而原本的 redis.conf 配置文件就作为一个总闸。

另外需要注意的时，如果将此配置写在redis.conf 文件的开头，那么后面的配置会覆盖引入文件的配置，如果想以引入文件的配置为主，那么需要将 include 配置写在 redis.conf 文件的末尾。

## MODULES

```ini
Load modules at startup. If the server is not able to load modules
it will abort. It is possible to use multiple loadmodule directives.

loadmodule /path/to/my_module.so
loadmodule /path/to/other_module.so
```

通过这里的 loadmodule 配置将引入自定义模块来新增一些功能。

## NETWORK(重要)

```ini
By default, if no "bind" configuration directive is specified, Redis listens
for connections from all available network interfaces on the host machine.
It is possible to listen to just one or multiple selected interfaces using
the "bind" configuration directive, followed by one or more IP addresses.
# 默认情况下，如果未指定“ bind”配置指令，则Redis侦听主机上所有可用网络接口的连接。可以使用“ bind”配置指令仅侦听一个或多个所选接口，然后侦听一个或多个IP地址
Examples:

bind 192.168.1.100 10.0.0.1
bind 127.0.0.1 ::1

~~~ WARNING ~~~ If the computer running Redis is directly exposed to the
internet, binding to all the interfaces is dangerous and will expose the
instance to everybody on the internet. So by default we uncomment the
following bind directive, that will force Redis to listen only on the
IPv4 loopback interface address (this means Redis will only be able to
accept client connections from the same host that it is running on).
# ~~~警告~~~如果运行Redis的计算机直接暴露于Internet，则绑定到所有接口都是很危险的，并且会将实例暴露给Internet上的所有人。因此，默认情况下，我们取消注释以下bind指令，这将强制Redis仅在IPv4环回接口地址上侦听（这意味着Redis将只能接受来自其运行所在主机的客户端连接）
IF YOU ARE SURE YOU WANT YOUR INSTANCE TO LISTEN TO ALL THE INTERFACES
JUST COMMENT OUT THE FOLLOWING LINE.
# 如果您确定要立即侦听所有接口，只需在后续行中注明即可。
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bind 127.0.0.1 ::1



Protected mode is a layer of security protection, in order to avoid that
Redis instances left open on the internet are accessed and exploited.
# 保护模式是安全保护的一层，目的是避免访问和利用Internet上打开的Redis实例。
When protected mode is on and if:
# 当保护模式开启时，如果
1) The server is not binding explicitly to a set of addresses using the
"bind" directive.
# 服务器未使用“ bind”指令显式绑定到一组地址
2) No password is configured.
# 没有配置密码
The server only accepts connections from clients connecting from the
IPv4 and IPv6 loopback addresses 127.0.0.1 and ::1, and from Unix domain
sockets.
# 服务器仅接受来自客户端的连接，这些客户端从IPv4和IPv6回送地址127.0.0.1和:: 1以及Unix域套接字连接
```

bind:绑定redis服务器网卡IP，默认为127.0.0.1,即本地回环地址。这样的话，访问redis服务只能通过本机的客户端连接，而无法通过远程连接。如果bind选项为空的话，那会接受所有来自于可用网络接口的连接。

同时需要注意的是 如果注释掉`bind`后面的内容，运行Redis的计算机将直接暴露于在internet上，绑定到所有接口是危险的，并且会暴露向互联网上的每个人提供实例。需谨慎选择

> 至少也得加个密码(见下文)

```
By default protected mode is enabled. You should disable it only if
you are sure you want clients from other hosts to connect to Redis
even if no authentication is configured, nor a specific set of interfaces
are explicitly listed using the "bind" directive.
# 默认情况下启用保护模式。仅当您确定您希望其他主机的客户端连接到Redis时，即使未配置身份验证，也不要使用“ bind”指令显式列出一组特定的接口，才应禁用它
protected-mode yes
```

默认情况下，启用保护模式。只有当您确定希望来自其他主机的客户端连接到Redis时才应该禁用它，即使没有配置身份验证，也没有使用“bind”指令显式列出一组特定的接口。

```
Accept connections on the specified port, default is 6379 (IANA 815344).
If port 0 is specified Redis will not listen on a TCP socket.
# 接受指定端口上的连接，默认为6379（IANA 815344）。如果指定了端口0，则Redis将不会在TCP套接字上侦听
port 6379
```

接受指定端口上的连接，默认值为6379。如果指定了端口0，Redis将不会侦听TCP套接字。由于Redis是单线程模型，因此单机开多个Redis进程的时候需要修改端口。

```
TCP listen() backlog.

In high requests-per-second environments you need a high backlog in order
to avoid slow clients connection issues. Note that the Linux kernel
will silently truncate it to the value of /proc/sys/net/core/somaxconn so
make sure to raise both the value of somaxconn and tcp_max_syn_backlog
in order to get the desired effect.
tcp-backlog 511

在每秒高请求的环境中，您需要一个高积压工作，以避免客户端连接速度慢的问题。请注意，Linux内核将静默地将其截断为/proc/sys/net/core/somaxconn so的值
确保同时提高somaxconn和tcp\u max\u syn\u backlog的值以获得所需的效果
```

> 默认值 511
> tcp-backlog：511
>
> 此参数确定了TCP连接中已完成队列(完成三次握手之后)的长度， 当然此值必须不大于Linux系统定义的/proc/sys/net/core/somaxconn值，默认是511，而Linux的默认参数值是128。当系统并发量大并且客户端速度缓慢的时候，可以将这二个参数一起参考设定。
>
> 建议修改为 2048
> 修改somaxconn
>
> 该内核参数默认值一般是128，对于负载很大的服务程序来说大大的不够。一般会将它修改为2048或者更大。
>
> echo 2048 > /proc/sys/net/core/somaxconn 但是这样系统重启后保存不了
>
> 在/etc/sysctl.conf中添加如下
>
> net.core.somaxconn = 2048
>
> 然后在终端中执行
>
> sysctl -p

```
Unix socket.

Specify the path for the Unix socket that will be used to listen for
incoming connections. There is no default, so Redis will not listen
on a unix socket when not specified.

unixsocket /tmp/redis.sock
unixsocketperm 700
```

指定用于侦听传入连接的Unix套接字的路径。没有默认值，因此Redis在未指定时不会侦听unix套接字。

```
Close the connection after a client is idle for N seconds (0 to disable)
timeout 0
```

客户端空闲N秒后关闭连接（0表示禁用）

```ini
TCP keepalive.

If non-zero, use SO_KEEPALIVE to send TCP ACKs to clients in absence
of communication. This is useful for two reasons:
# 如果不为零，请在没有通信的情况下使用SO_KEEPALIVE向客户端发送TCP ACK。这很有用，有两个原因：
1) Detect dead peers.   # 检测死者
2) Force network equipment in the middle to consider the connection to be
alive.                  # 强制中间的网络设备考虑连接处于活动状态。

On Linux, the specified value (in seconds) is the period used to send ACKs.
Note that to close the connection the double of the time is needed.
On other kernels the period depends on the kernel configuration.
# 在Linux上，指定的值（以秒为单位）是用于发送ACK的时间段。请注意，关闭连接需要两倍的时间。在其他内核上，周期取决于内核配置
A reasonable value for this option is 300 seconds, which is the new
Redis default starting with Redis 3.2.1.
# 此选项的合理值是300秒，这是从Redis 3.2.1开始的新Redis默认值。
tcp-keepalive 300
```

TCP保持连接。

如果非零，则在没有通信的情况下，使用SO_KEEPALIVE向客户端发送TCP确认。这有两个原因：

1） 检测死掉的同伴。

2） 强制中间的网络设备认为连接是活动的。

在Linux上，指定的值（以秒为单位）是用于发送ACK的时间段。请注意，要关闭连接，需要两倍的时间。

在其他内核上，周期取决于内核配置。

这个选项的合理值是300秒，这是从redis3.2.1开始的新Redis默认值。

tcp保持300

## TLS/SSL



```
By default, TLS/SSL is disabled. To enable it, the "tls-port" configuration
directive can be used to define TLS-listening ports. To enable TLS on the
default port, use:
# 默认情况下，TLSSSL被禁用。要启用它，可以使用“ tls-port”配置指令来定义TLS侦听端口。要在默认端口上启用TLS，请使用
port 0
tls-port 6379
```

默认情况下，TLS/SSL处于禁用状态。要启用它，“tls端口”配置

指令可用于定义TLS侦听端口。



```ini
Configure a X.509 certificate and private key to use for authenticating the
server to connected clients, masters or cluster peers.  These files should be
PEM formatted.
# 配置X.509证书和私钥，用于对连接的客户端，主服务器或集群对等服务器进行身份验证。这些文件应为PEM格式
tls-cert-file redis.crt 
tls-key-file redis.key

Configure a DH parameters file to enable Diffie-Hellman (DH) key exchange:

tls-dh-params-file redis.dh

Configure a CA certificate(s) bundle or directory to authenticate TLS/SSL
clients and peers.  Redis requires an explicit configuration of at least one
of these, and will not implicitly use the system wide configuration.

tls-ca-cert-file ca.crt
tls-ca-cert-dir /etc/ssl/certs

By default, clients (including replica servers) on a TLS port are required
to authenticate using valid client side certificates.
# 默认情况下，要求TLS端口上的客户端（包括副本服务器）使用有效的客户端证书进行身份验证
If "no" is specified, client certificates are not required and not accepted.
If "optional" is specified, client certificates are accepted and must be
valid if provided, but are not required.
# 如果指定“否”，则不需要也不接受客户端证书。如果指定了“可选”，则接受客户端证书，并且如果提供的话，客户端证书必须有效，但不是必需的
tls-auth-clients no
tls-auth-clients optional

By default, a Redis replica does not attempt to establish a TLS connection
with its master.
# 默认情况下，Redis副本不会尝试与其主服务器建立TLS连接
Use the following directive to enable TLS on replication links.
# 使用以下指令在复制链接上启用TLS
tls-replication yes

By default, the Redis Cluster bus uses a plain TCP connection. To enable
TLS for the bus protocol, use the following directive:

tls-cluster yes

Explicitly specify TLS versions to support. Allowed values are case insensitive
and include "TLSv1", "TLSv1.1", "TLSv1.2", "TLSv1.3" (OpenSSL >= 1.1.1) or
any combination. To enable only TLSv1.2 and TLSv1.3, use:

tls-protocols "TLSv1.2 TLSv1.3"

Configure allowed ciphers.  See the ciphers(1ssl) manpage for more information
about the syntax of this string.

Note: this configuration applies only to <= TLSv1.2.

tls-ciphers DEFAULT:!MEDIUM

Configure allowed TLSv1.3 ciphersuites.  See the ciphers(1ssl) manpage for more
information about the syntax of this string, and specifically for TLSv1.3
ciphersuites.

tls-ciphersuites TLS_CHACHA20_POLY1305_SHA256

When choosing a cipher, use the server's preference instead of the client
preference. By default, the server follows the client's preference.

tls-prefer-server-ciphers yes

By default, TLS session caching is enabled to allow faster and less expensive
reconnections by clients that support it. Use the following directive to disable
caching.

tls-session-caching no

Change the default number of TLS sessions cached. A zero value sets the cache
to unlimited size. The default size is 20480.

tls-session-cache-size 5000

Change the default timeout of cached TLS sessions. The default timeout is 300
seconds.

tls-session-cache-timeout 60
```

## GENERAL

```
By default Redis does not run as a daemon. Use 'yes' if you need it.
Note that Redis will write a pid file in /usr/local/var/run/redis.pid when daemonized.
daemonize no
```

　daemonize:设置为yes表示指定Redis以守护进程的方式启动（即后台启动）。默认值为 no

```
If you run Redis from upstart or systemd, Redis can interact with your
supervision tree. Options:
supervised no      - no supervision interaction
supervised upstart - signal upstart by putting Redis into SIGSTOP mode
                    requires "expect stop" in your upstart job config
supervised systemd - signal systemd by writing READY=1 to $NOTIFY_SOCKET
supervised auto    - detect upstart or systemd method based on
                    UPSTART_JOB or NOTIFY_SOCKET environment variables
Note: these supervision methods only signal "process is ready."
   They do not enable continuous pings back to your supervisor.
supervised no
```

如果你使用系统的`upstart`或者`systemd`运行redis。他们可以管理监控redis。默认不启用

参数

supervised no： - no supervision interaction（无监督-无监督互动）

supervised upstart - 监督upstart-通过将Redis置于SIGSTOP模式来发出upstart信号在upstart作业配置中需要“expect stop”

supervised systemd - 受监控的systemd-通过写入READY=1到$NOTIFY\u SOCKET发送信号systemd

supervised auto - 基于upstart\u JOB或NOTIFY\u SOCKET环境变量检测upstart或systemd方法

> 注意：这些监督方法仅表示“过程准备就绪”，它们不支持连续ping返回到您的主管。
>

```

If a pid file is specified, Redis writes it where specified at startup
and removes it at exit.

When the server runs non daemonized, no pid file is created if none is
specified in the configuration. When the server is daemonized, the pid file
is used even if not specified, defaulting to "/usr/local/var/run/redis.pid".

Creating a pid file is best effort: if Redis is not able to create it
nothing bad happens, the server will start and run normally.
pidfile /var/run/redis_6379.pid
```

　pidfile: 配置PID文件路径，当redis作为守护进程运行的时候，它会把 pid 默认写到 /var/redis/run/redis_6379.pid 文件里面

```
Specify the server verbosity level.
This can be one of:
debug (a lot of information, useful for development/testing)
verbose (many rarely useful info, but not a mess like the debug level)
notice (moderately verbose, what you want in production probably)
warning (only very important / critical messages are logged)
loglevel notice

Specify the log file name. Also the empty string can be used to force
Redis to log on the standard output. Note that if you use standard
output for logging but daemonize, logs will be sent to /dev/null
logfile ""
```

　loglevel ：定义日志级别。默认值为notice，有如下4种取值：

> debug（大量信息，对开发/测试有用）
>
> verbose（许多很少有用的信息，但不像调试级别那样混乱）
>
> notice（适度冗长，可能是生产中需要的内容）
>
> warning（只记录非常重要/关键的消息）

logfile ：配置log文件地址,默认打印在命令行终端的窗口上

```
To enable logging to the system logger, just set 'syslog-enabled' to yes,
and optionally update the other syslog parameters to suit your needs.
syslog-enabled no

Specify the syslog identity.
syslog-ident redis

Specify the syslog facility. Must be USER or between LOCAL0-LOCAL7.
syslog-facility local0

Set the number of databases. The default database is DB 0, you can select
a different one on a per-connection basis using SELECT <dbid> where
dbid is a number between 0 and 'databases'-1
databases 16
```

databases：设置数据库的数目。默认的数据库是DB 0 ，可以在每个连接上使用select <dbid> 命令选择一个不同的数据库，dbid是一个介于0到databases - 1 之间的数值。默认值是 16，也就是说默认Redis有16个数据库。

```
By default Redis shows an ASCII art logo only when started to log to the
standard output and if the standard output is a TTY. Basically this means
that normally a logo is displayed only in interactive sessions.

However it is possible to force the pre-4.0 behavior and always show a
ASCII art logo in startup logs by setting the following option to yes.
always-show-logo yes
```

## SNAPSHOTTING（快照，重要！！！）

```
Save the DB on disk:

save <seconds> <changes>

Will save the DB if both the given number of seconds and the given
number of write operations against the DB occurred.

In the example below the behavior will be to save:
after 900 sec (15 min) if at least 1 key changed
after 300 sec (5 min) if at least 10 keys changed
after 60 sec if at least 10000 keys changed

Note: you can disable saving completely by commenting out all "save" lines.

It is also possible to remove all the previously configured save
points by adding a save directive with a single empty string argument
like in the following example:

save ""

```

save 900 1
save 300 10
save 60 10000

save：这里是用来配置触发 Redis的持久化条件，也就是什么时候将内存中的数据保存到硬盘。默认如下配置：

```
save 900 1：表示900 秒内如果至少有 1 个 key 的值变化，则保存
save 300 10：表示300 秒内如果至少有 10 个 key 的值变化，则保存
save 60 10000：表示60 秒内如果至少有 10000 个 key 的值变化，则保存
```

> ```
> By default Redis will stop accepting writes if RDB snapshots are enabled
>  (at least one save point) and the latest background save failed.
>  This will make the user aware (in a hard way) that data is not persisting
>  on disk properly, otherwise chances are that no one will notice and some
>  disaster will happen.
>  
>   If the background saving process will start working again Redis will
>  automatically allow writes again.
>  
>   However if you have setup your proper monitoring of the Redis server
>  and persistence, you may want to disable this feature so that Redis will
>  continue to work as usual even if there are problems with disk,
>  permissions, and so forth.
> stop-writes-on-bgsave-error yes
> ```
>
> 默认情况下，如果启用RDB快照，Redis将停止接受写操作
>
> （至少一个保存点）和最新的后台保存失败。
>
> 这将使用户意识到（以一种困难的方式）数据没有持久化
>
> 在磁盘上正确，否则很可能没有人会注意到和一些
>
> 灾难就会发生。
>
> 如果后台保存过程将重新开始工作，Redis将自动允许再次写入。但是，如果您已经设置了对Redis服务器的适当监视
>
> 和持久性，您可能希望禁用此功能，以便Redis
>
> 即使磁盘、权限等出现问题，也要继续正常工作。

```
Compress string objects using LZF when dump .rdb databases?
By default compression is enabled as it's almost always a win.
If you want to save some CPU in the saving child set it to 'no' but
the dataset will likely be bigger if you have compressible values or keys.
rdbcompression yes
```

转储.rdb数据库时使用LZF压缩字符串对象？

默认情况下，压缩是启用的，因为它几乎总是一个胜利。

如果您想在保存子进程中保存一些CPU，请将其设置为“否”，但是

如果有可压缩的值或键，数据集可能会更大。



```ini
Since version 5 of RDB a CRC64 checksum is placed at the end of the file.
This makes the format more resistant to corruption but there is a performance
hit to pay (around 10%) when saving and loading RDB files, so you can disable it
for maximum performances.

RDB files created with checksum disabled have a checksum of zero that will
tell the loading code to skip the check.
rdbchecksum yes

由于RDB版本5，CRC64校验和放在文件的末尾。这使格式更能抵抗损坏，但在保存和加载RDB文件时，性能会受到影响（约10%），因此可以禁用它以获得最大性能。在禁用校验和的情况下创建的RDB文件的校验和为零，这将告诉加载代码跳过检查。
```

```ini
The filename where to dump the DB
dbfilename dump.rdb

将数据库转储到的文件名
```



```ini

Remove RDB files used by replication in instances without persistence
enabled. By default this option is disabled, however there are environments
where for regulations or other security concerns, RDB files persisted on
disk by masters in order to feed replicas, or stored on disk by replicas
in order to load them for the initial synchronization, should be deleted
ASAP. Note that this option ONLY WORKS in instances that have both AOF
and RDB persistence disabled, otherwise is completely ignored.

An alternative (and sometimes better) way to obtain the same effect is
to use diskless replication on both master and replicas instances. However
in the case of replicas, diskless is not always an option.
rdb-del-sync-files no

The working directory.

The DB will be written inside this directory, with the filename specified
above using the 'dbfilename' configuration directive.

The Append Only File will also be created inside this directory.

Note that you must specify a directory here, not a file name.

dir /usr/local/var/db/redis/

在没有持久性的实例中删除复制使用的RDB文件启用。默认情况下，此选项处于禁用状态，但是在某些环境中，出于管理法规或其他安全考虑，应尽快删除由主服务器保留在磁盘上以馈送副本的RDB文件，或由副本存储在磁盘上以加载它们以进行初始同步。请注意，此选项仅适用于同时禁用AOF和RDB持久性的实例，否则将完全忽略。
另一种（有时更好）获得相同效果的方法是在主实例和副本实例上使用无盘复制。但是，对于副本，无磁盘并不是一种好的选择。
rdb del同步文件编号
工作目录。
数据库将被写入这个目录，并指定文件名
使用“dbfilename”配置指令。
只附加的文件也将在这个目录中创建。
请注意，必须在此处指定目录，而不是文件名。
```

　dbfilename ：设置快照的文件名，默认是 dump.rdb

　　⑥、dir：设置快照文件的存放路径，这个配置项一定是个目录，而不能是文件名。使用上面的 dbfilename 作为保存的文件名。

## REPLICATION（主从复制）

```ini
REPLICATION 

Master-Replica replication. Use replicaof to make a Redis instance a copy of
another Redis server. A few things to understand ASAP about Redis replication.

+------------------+      +---------------+
|      Master      | ---> |    Replica    |
| (receive writes) |      |  (exact copy) |
+------------------+      +---------------+

1) Redis replication is asynchronous, but you can configure a master to
stop accepting writes if it appears to be not connected with at least
a given number of replicas.
# Redis复制是异步的，但是您可以配置一个主机，如果它看起来没有连接到至少给定数量的副本，那么它就停止接受写操作。
2) Redis replicas are able to perform a partial resynchronization with the
master if the replication link is lost for a relatively small amount of
time. You may want to configure the replication backlog size (see the next
sections of this file) with a sensible value depending on your needs.
# 如果复制链路丢失的时间相对较短，Redis复制副本可以执行与主机的部分重新同步。您可能需要根据需要使用合理的值来配置复制积压工作大小（请参阅本文件的下一节）。
3) Replication is automatic and does not need user intervention. After a
network partition replicas automatically try to reconnect to masters
and resynchronize with them.
# 复制是自动的，不需要用户干预。在网络分区之后，复制副本会自动尝试重新连接到主机并与它们重新同步。

replicaof <masterip> <masterport>

If the master is password protected (using the "requirepass" configuration
directive below) it is possible to tell the replica to authenticate before
starting the replication synchronization process, otherwise the master will
refuse the replica request.
# 如果主机受密码保护（使用下面的“requirepass”配置指令），则可以在启动复制同步过程之前通知复制副本进行身份验证，否则主机将拒绝副本请求。

masterauth <master-password>

However this is not enough if you are using Redis ACLs (for Redis version
6 or greater), and the default user is not capable of running the PSYNC
command and/or other commands needed for replication. In this case it's
better to configure a special user to use with replication, and specify the
masteruser configuration as such:
# 但是，如果您正在使用Redis ACL（用于Redis版本6或更高版本），并且默认用户无法运行PSYNC命令和/或其他复制所需的命令，这还不够。在这种情况下，最好配置一个特殊用户以用于复制
masteruser <username>

When masteruser is specified, the replica will authenticate against its
master using the new AUTH form: AUTH <username> <password>.
# 指定masteruser时，副本将使用新的AUTH表单针对其主服务器进行身份验证
When a replica loses its connection with the master, or when the replication
is still in progress, the replica can act in two different ways:
# 当副本失去与主数据库的连接时，或者仍在进行复制时，副本可以采取两种不同的方式进行操作
1) if replica-serve-stale-data is set to 'yes' (the default) the replica will
still reply to client requests, possibly with out of date data, or the
data set may just be empty if this is the first synchronization.
# 如果复制副本服务过时数据设置为“是”（默认值），则复制副本仍将回复客户端请求，可能包含过期数据，或者如果这是第一次同步，则数据集可能只是空的。
2) If replica-serve-stale-data is set to 'no' the replica will reply with
an error "SYNC with master in progress" to all commands except:
INFO, REPLICAOF, AUTH, PING, SHUTDOWN, REPLCONF, ROLE, CONFIG, SUBSCRIBE,
UNSUBSCRIBE, PSUBSCRIBE, PUNSUBSCRIBE, PUBLISH, PUBSUB, COMMAND, POST,
HOST and LATENCY.
# 如果将replica-serve-stale-data设置为“ no”，则该副本将对所有命令（“ INFO，REPLICAOF，AUTH，PING，SHUTDOWN，REPLCONF，ROLE，CONFIG，SUBSCRIBE）进行错误答复” ，退订，PSUBSCRIBE，PUNSUBSCRIBE，PUBLISH，PUBSUB，COMMAND，POST，HOST和LATENCY。
replica-serve-stale-data yes

You can configure a replica instance to accept writes or not. Writing against
a replica instance may be useful to store some ephemeral data (because data
written on a replica will be easily deleted after resync with the master) but
may also cause problems if clients are writing to it because of a
misconfiguration.
# 您可以配置副本实例以接受或不接受写入。针对副本实例进行写操作可能对存储一些临时数据很有用（因为与主实例重新同步后，写入副本上的数据将很容易删除），但是如果客户端由于配置错误而向其进行写操作，也会导致问题。
Since Redis 2.6 by default replicas are read-only.

Note: read only replicas are not designed to be exposed to untrusted clients
on the internet. It's just a protection layer against misuse of the instance.
Still a read only replica exports by default all the administrative commands
such as CONFIG, DEBUG, and so forth. To a limited extent you can improve
security of read only replicas using 'rename-command' to shadow all the
administrative / dangerous commands.
# 只读副本并非旨在向Internet上不受信任的客户端公开。它只是防止实例滥用的保护层。默认情况下，只读副本仍会导出所有管理命令，例如CONFIG，DEBUG等。在一定程度上，您可以使用'rename-command'隐藏所有管理危险命令来提高只读副本的安全性
replica-read-only yes
Replication SYNC strategy: disk or socket.

New replicas and reconnecting replicas that are not able to continue the
replication process just receiving differences, need to do what is called a
"full synchronization". An RDB file is transmitted from the master to the
replicas.
# 仅仅接受差异就无法继续复制过程的新副本和重新连接的副本需要进行所谓的“完全同步”。 RDB文件从主数据库传输到副本数据库
The transmission can happen in two different ways:

1) Disk-backed: The Redis master creates a new process that writes the RDB
             file on disk. Later the file is transferred by the parent
             process to the replicas incrementally.
2) Diskless: The Redis master creates a new process that directly writes the
          RDB file to replica sockets, without touching the disk at all.

With disk-backed replication, while the RDB file is generated, more replicas
can be queued and served with the RDB file as soon as the current child
producing the RDB file finishes its work. With diskless replication instead
once the transfer starts, new replicas arriving will be queued and a new
transfer will start when the current one terminates.
# 使用磁盘支持的复制，当生成RDB文件时，只要生成RDB文件的当前子级完成工作，就可以将更多副本排入队列并与RDB文件一起使用。如果使用无盘复制，则一旦传输开始，新的副本将排队，并且当当前副本终止时将开始新的传输
When diskless replication is used, the master waits a configurable amount of
time (in seconds) before starting the transfer in the hope that multiple
replicas will arrive and the transfer can be parallelized.
# 使用无盘复制时，主服务器在开始传输之前等待一段可配置的时间（以秒为单位），以希望多个副本可以到达并且传输可以并行化
With slow disks and fast (large bandwidth) networks, diskless replication
works better.
# 对于慢速磁盘和快速（大带宽）网络，无盘复制效果更好
repl-diskless-sync no

When diskless replication is enabled, it is possible to configure the delay
the server waits in order to spawn the child that transfers the RDB via socket
to the replicas.
# 启用无盘复制后，可以配置服务器等待的延迟，以便生成通过套接字将RDB传输到副本的子代。
This is important since once the transfer starts, it is not possible to serve
new replicas arriving, that will be queued for the next RDB transfer, so the
server waits a delay in order to let more replicas arrive.
# 这一点很重要，因为一旦传输开始，就无法为到达下一个RDB传输的新副本提供服务，因此服务器会等待一段时间才能让更多副本到达。
The delay is specified in seconds, and by default is 5 seconds. To disable
it entirely just set it to 0 seconds and the transfer will start ASAP.
# 延迟以秒为单位指定，默认情况下为5秒。要完全禁用它，只需将其设置为0秒，传输就会尽快开始。
repl-diskless-sync-delay 5

-----------------------------------------------------------------------------
WARNING: RDB diskless load is experimental. Since in this setup the replica
does not immediately store an RDB on disk, it may cause data loss during
failovers. RDB diskless load + Redis modules not handling I/O reads may also
cause Redis to abort in case of I/O errors during the initial synchronization
stage with the master. Use only if your do what you are doing.
-----------------------------------------------------------------------------
# 警告：RDB无盘加载是实验性的。因为在此设置中，副本不会立即在磁盘上存储RDB，所以它可能会导致故障转移期间的数据丢失。在与主机的初始同步阶段，如果IO错误，则RDB无盘负载+ Redis模块不处理IO读取也可能导致Redis中止。仅在执行自己的操作时使用
Replica can load the RDB it reads from the replication link directly from the
socket, or store the RDB to a file and read that file after it was completely
received from the master.
# 副本可以直接从套接字加载从复制链接读取的RDB，也可以将RDB存储到文件中，并在从主服务器完全接收到该文件后读取该文件。
In many cases the disk is slower than the network, and storing and loading
the RDB file may increase replication time (and even increase the master's
Copy on Write memory and salve buffers).
However, parsing the RDB file directly from the socket may mean that we have
to flush the contents of the current database before the full rdb was
received. For this reason we have the following options:
# 在许多情况下，磁盘的速度比网络慢，并且存储和加载RDB文件可能会增加复制时间（甚至会增加主服务器的“写时复制”内存和从属缓冲区）。但是，直接从套接字解析RDB文件可能意味着我们必须在收到完整的rdb之前刷新当前数据库的内容。因此，我们有以下选择
"disabled"    - Don't use diskless load (store the rdb file to the disk first)
# 不要使用无盘负载（首先将rdb文件存储到磁盘）
"on-empty-db" - Use diskless load only when it is completely safe.
# 仅在完全安全的情况下使用无盘加载
"swapdb"      - Keep a copy of the current db contents in RAM while parsin 
the data directly from the socket. note that this requires sufficient memory, if you don't have it, you risk an OOM kill.
# 直接从套接字解析数据时，将当前数据库内容的副本保留在RAM中。请注意，这需要足够的内存，如果没有足够的内存，则可能会杀死OOM
repl-diskless-load disabled

Replicas send PINGs to server in a predefined interval. It's possible to
change this interval with the repl_ping_replica_period option. The default
value is 10 seconds.
# 副本以预定义的时间间隔将PING发送到服务器。可以使用repl_ping_replica_period选项更改此间隔。默认值为10秒
repl-ping-replica-period 10

The following option sets the replication timeout for:
# 以下选项设置了复制超时
1) Bulk transfer I/O during SYNC, from the point of view of replica.
# 从副本的角度来看，在SYNC期间进行批量传输IO。
2) Master timeout from the point of view of replicas (data, pings).
# 从副本（数据，ping）的角度来看主超时
3) Replica timeout from the point of view of masters (REPLCONF ACK pings).
# 从主服务器角度来看副本超时（REPLCONF ACK ping）
It is important to make sure that this value is greater than the value
specified for repl-ping-replica-period otherwise a timeout will be detected
every time there is low traffic between the master and the replica. The default
value is 60 seconds.
# 重要的是要确保该值大于为repl-ping-replica-period指定的值，否则，每当主机和副本之间的通信量较低时，就会检测到超时。默认值为60秒。
repl-timeout 60

Disable TCP_NODELAY on the replica socket after SYNC?
# 同步后在副本套接字上禁用TCP_NODELAY

If you select "yes" Redis will use a smaller number of TCP packets and
less bandwidth to send data to replicas. But this can add a delay for
the data to appear on the replica side, up to 40 milliseconds with
Linux kernels using a default configuration.
# 如果选择“是”，则Redis将使用更少的TCP数据包和更少的带宽将数据发送到副本。但这会增加数据在副本端显示的延迟，对于使用默认配置的Linux内核，此延迟最多40毫秒
If you select "no" the delay for data to appear on the replica side will
be reduced but more bandwidth will be used for replication.
# 如果选择“否”，则将减少数据在副本侧出现的延迟，但将使用更多带宽进行复制
By default we optimize for low latency, but in very high traffic conditions
or when the master and replicas are many hops away, turning this to "yes" may
be a good idea.
# 默认情况下，我们会针对低延迟进行优化，但是在流量非常高的情况下，或者当主服务器和副本距离很多跳时，将其设置为“是”可能是个好主意
repl-disable-tcp-nodelay no

Set the replication backlog size. The backlog is a buffer that accumulates
replica data when replicas are disconnected for some time, so that when a
replica wants to reconnect again, often a full resync is not needed, but a
partial resync is enough, just passing the portion of data the replica
missed while disconnected.
# 设置复制积压大小。待办事项是一个缓冲区，当副本断开连接一段时间后，该缓冲区将累积副本数据，因此，当副本要重新连接时，通常不需要完全重新同步，但是部分重新同步就足够了，只需传递副本中的部分数据断开连接时错过
The bigger the replication backlog, the longer the replica can endure the
disconnect and later be able to perform a partial resynchronization.
# 复制积压量越大，副本可以承受断开连接并随后能够执行部分重新同步的时间越长
The backlog is only allocated if there is at least one replica connected.
# 仅在连接至少一个副本时分配积压
repl-backlog-size 1mb

After a master has no connected replicas for some time, the backlog will be
freed. The following option configures the amount of seconds that need to
elapse, starting from the time the last replica disconnected, for the backlog
buffer to be freed.
# 主服务器在一段时间内没有连接的副本后，积压的订单将被释放。以下选项配置了从断开最后一个副本的时间开始，释放待办事项缓冲区所需的秒数
Note that replicas never free the backlog for timeout, since they may be
promoted to masters later, and should be able to correctly "partially
resynchronize" with other replicas: hence they should always accumulate backlog.
# 请注意，副本永远不会释放积压的超时，因为它们可能稍后会升级为主副本，并且应该能够与其他副本正确“部分重新同步”：因此，它们应始终累积积压。
A value of 0 means to never release the backlog.
# 值为0表示永不释放积压
repl-backlog-ttl 3600

The replica priority is an integer number published by Redis in the INFO
output. It is used by Redis Sentinel in order to select a replica to promote
into a master if the master is no longer working correctly.
# 副本优先级是Redis在INFO输出中发布的整数。如果主服务器不再正常工作，Redis Sentinel会使用它来选择要升级为主服务器的副本
A replica with a low priority number is considered better for promotion, so
for instance if there are three replicas with priority 10, 100, 25 Sentinel
will pick the one with priority 10, that is the lowest.
# 优先级数字低的副本被认为更适合升级，例如，如果有三个副本的优先级分别为10、100和25，Sentinel将选择优先级为10的副本，这是最低的
However a special priority of 0 marks the replica as not able to perform the
role of master, so a replica with priority of 0 will never be selected by
Redis Sentinel for promotion.
# 但是，特殊优先级0会将副本标记为不能执行主角色，因此Redis Sentinel永远不会选择优先级为0的副本进行升级，默认情况下，优先级为100
By default the priority is 100.
replica-priority 100

It is possible for a master to stop accepting writes if there are less than
N replicas connected, having a lag less or equal than M seconds.
# 如果连接的副本少于N个，且延迟小于或等于M秒，则主服务器可能会停止接受写入
The N replicas need to be in "online" state.
# N个副本需要处于“联机”状态
The lag in seconds, that must be <= the specified value, is calculated from
the last ping received from the replica, that is usually sent every second.
# 延迟（以秒为单位）必须小于等于指定值，该延迟是从副本接收到的最后一次ping计算得出的，通常每秒钟发送一次
This option does not GUARANTEE that N replicas will accept the write, but
will limit the window of exposure for lost writes in case not enough replicas
are available, to the specified number of seconds.
# 此选项不能保证N个副本将接受写操作，但是如果没有足够的副本可用，则会将丢失写操作的暴露窗口限制为指定的秒数
For example to require at least 3 replicas with a lag <= 10 seconds use:
# 例如，要求至少3个副本的延迟<= 10秒，请使用
min-replicas-to-write 3
min-replicas-max-lag 10

Setting one or the other to 0 disables the feature.
# 将一个或另一个设置为0将禁用该功能
By default min-replicas-to-write is set to 0 (feature disabled) and
min-replicas-max-lag is set to 10.
# 默认情况下，将要写入的最小副本设置为0（禁用功能），并且将最小副本最大延迟设置为10
A Redis master is able to list the address and port of the attached
replicas in different ways. For example the "INFO replication" section
offers this information, which is used, among other tools, by
Redis Sentinel in order to discover replica instances.
Another place where this info is available is in the output of the
"ROLE" command of a master.
# Redis主服务器能够以不同方式列出附加副本的地址和端口。例如，“ INFO复制”部分提供了此信息，Redis Sentinel使用此信息以及其他工具来发现副本实例。该信息可用的另一个位置是主服务器的“ ROLE”命令的输出
The listed IP address and port normally reported by a replica is
obtained in the following way:
# 副本通常报告的列出的IP地址和端口可以通过以下方式获得
IP: The address is auto detected by checking the peer address
of the socket used by the replica to connect with the master.
# IP：通过检查副本用来与主服务器连接的套接字的对等地址来自动检测该地址
Port: The port is communicated by the replica during the replication
handshake, and is normally the port that the replica is using to
listen for connections.
# 端口：端口在复制握手期间由副本进行通信，通常是副本用来侦听连接的端口。
However when port forwarding or Network Address Translation (NAT) is
used, the replica may actually be reachable via different IP and port
pairs. The following two options can be used by a replica in order to
report to its master a specific set of IP and port, so that both INFO
and ROLE will report those values.
# 但是，当使用端口转发或网络地址转换（NAT）时，实际上可以通过不同的IP和端口对访问该副本。副本可以使用以下两个选项，以便向其主服务器报告特定的IP和端口集，以便INFO和ROLE都将报告这些值
There is no need to use both the options if you need to override just
the port or the IP address.
# 如果只需要覆盖端口或IP地址，则无需使用这两个选项。
replica-announce-ip 5.5.5.5
replica-announce-port 1234
```

①、slave-serve-stale-data：默认值为yes。当一个 slave 与 master 失去联系，或者复制正在进行的时候，slave 可能会有两种表现：

　　　　1) 如果为 yes ，slave 仍然会应答客户端请求，但返回的数据可能是过时，或者数据可能是空的在第一次同步的时候 

　　　　2) 如果为 no ，在你执行除了 info he salveof 之外的其他命令时，slave 都将返回一个 "SYNC with master in progress" 的错误

②、slave-read-only：配置Redis的Slave实例是否接受写操作，即Slave是否为只读Redis。默认值为yes。

③、repl-diskless-sync：主从数据复制是否使用无硬盘复制功能。默认值为no。

④、repl-diskless-sync-delay：当启用无硬盘备份，服务器等待一段时间后才会通过套接字向从站传送RDB文件，这个等待时间是可配置的。 这一点很重要，因为一旦传送开始，就不可能再为一个新到达的从站服务。从站则要排队等待下一次RDB传送。因此服务器等待一段 时间以期更多的从站到达。延迟时间以秒为单位，默认为5秒。要关掉这一功能，只需将它设置为0秒，传送会立即启动。默认值为5。

⑤、repl-disable-tcp-nodelay：同步之后是否禁用从站上的TCP_NODELAY 如果你选择yes，redis会使用较少量的TCP包和带宽向从站发送数据。但这会导致在从站增加一点数据的延时。 Linux内核默认配置情况下最多40毫秒的延时。如果选择no，从站的数据延时不会那么多，但备份需要的带宽相对较多。默认情况下我们将潜在因素优化，但在高负载情况下或者在主从站都跳的情况下，把它切换为yes是个好主意。默认值为no。

## KEYS TRACKING

```ini
KEYS TRACKING 
# Redis为客户端的值缓存实现服务器辅助的支持。这是使用无效表实现的，该无效表使用1600万个插槽记住哪些客户端可能具有某些键子集。依次将其用于向客户端发送无效消息
Redis implements server assisted support for client side caching of values.
This is implemented using an invalidation table that remembers, using
16 millions of slots, what clients may have certain subsets of keys. In turn
this is used in order to send invalidation messages to clients. Please
check this page to understand more about the feature:

https://redis.io/topics/client-side-caching

When tracking is enabled for a client, all the read only queries are assumed
to be cached: this will force Redis to store information in the invalidation
table. When keys are modified, such information is flushed away, and
invalidation messages are sent to the clients. However if the workload is
heavily dominated by reads, Redis could use more and more memory in order
to track the keys fetched by many clients.
# 为客户端启用跟踪时，假定所有只读查询都已缓存：这将强制Redis将信息存储在失效表中。修改密钥后，将清除此类信息，并将无效消息发送给客户端。但是，如果工作负载主要由读取控制，则Redis可能会使用越来越多的内存来跟踪许多客户端获取的密钥
For this reason it is possible to configure a maximum fill value for the
invalidation table. By default it is set to 1M of keys, and once this limit
is reached, Redis will start to evict keys in the invalidation table
even if they were not modified, just to reclaim memory: this will in turn
force the clients to invalidate the cached values. Basically the table
maximum size is a trade off between the memory you want to spend server
side to track information about who cached what, and the ability of clients
to retain cached objects in memory.

# 如果将值设置为0，则表示没有限制，Redis将在失效表中保留所需数量的键。在“统计信息”信息部分中，您可以找到有关每个给定时刻失效表中的键数的信息。
If you set the value to 0, it means there are no limits, and Redis will
retain as many keys as needed in the invalidation table.
In the "stats" INFO section, you can find information about the number of
keys in the invalidation table at every given moment.

Note: when key tracking is used in broadcasting mode, no memory is used
in the server side so this setting is useless.

tracking-table-max-keys 1000000
```



## SECURITY(重要)

```ini
SECURITY 

Warning: since Redis is pretty fast, an outside user can try up to
1 million passwords per second against a modern box. This means that you
should use very strong passwords, otherwise they will be very easy to break.
Note that because the password is really a shared secret between the client
and the server, and should not be memorized by any human, the password
can be easily a long string from /dev/urandom or whatever, so by using a
long and unguessable password no brute force attack will be possible.
# 警告：由于Redis的速度非常快，因此外部用户每秒可以在一个现代机器上尝试最多100万个密码。这意味着您应该使用非常安全的密码，否则密码很容易破解。
# 请注意，由于该密码实际上是客户端和服务器之间的共享机密，并且不应被任何人记住，因此该密码可以很容易地是来自devurandom或其他任何形式的长字符串，因此使用长而毫无疑问的密码不会造成暴力攻击是可能的
Redis ACL users are defined in the following format:

user <username> ... acl rules ...

For example:

user worker +@list +@connection ~jobs:* on >ffa9203c493aa99

The special username "default" is used for new connections. If this user
has the "nopass" rule, then new connections will be immediately authenticated
as the "default" user without the need of any password provided via the
AUTH command. Otherwise if the "default" user is not flagged with "nopass"
the connections will start in not authenticated state, and will require
AUTH (or the HELLO command AUTH option) in order to be authenticated and
start to work.
# 特殊的用户名“默认”用于新连接。如果该用户具有“ nopass”规则，则新连接将立即被认证为“默认”用户，而不需要通过AUTH命令提供的任何密码。否则，如果未将“默认”用户标记为“ nopass”，则连接将以未认证状态启动，并且需要AUTH（或HELLO命令AUTH选项）才能进行认证并开始工作
The ACL rules that describe what a user can do are the following:

on           Enable the user: it is possible to authenticate as this user.
off          Disable the user: it's no longer possible to authenticate
           with this user, however the already authenticated connections
           will still work.
+<command>   Allow the execution of that command
-<command>   Disallow the execution of that command
+@<category> Allow the execution of all the commands in such category
           with valid categories are like @admin, @set, @sortedset, ...
           and so forth, see the full list in the server.c file where
           the Redis command table is described and defined.
           The special category @all means all the commands, but currently
           present in the server, and that will be loaded in the future
           via modules.
+<command>|subcommand    Allow a specific subcommand of an otherwise
                       disabled command. Note that this form is not
                       allowed as negative like -DEBUG|SEGFAULT, but
                       only additive starting with "+".
allcommands  Alias for +@all. Note that it implies the ability to execute
           all the future commands loaded via the modules system.
nocommands   Alias for -@all.
~<pattern>   Add a pattern of keys that can be mentioned as part of
           commands. For instance ~* allows all the keys. The pattern
           is a glob-style pattern like the one of KEYS.
           It is possible to specify multiple patterns.
allkeys      Alias for ~*
resetkeys    Flush the list of allowed keys patterns.
><password>  Add this password to the list of valid password for the user.
           For example >mypass will add "mypass" to the list.
           This directive clears the "nopass" flag (see later).
<<password>  Remove this password from the list of valid passwords.
nopass       All the set passwords of the user are removed, and the user
           is flagged as requiring no password: it means that every
           password will work against this user. If this directive is
           used for the default user, every new connection will be
           immediately authenticated with the default user without
           any explicit AUTH command required. Note that the "resetpass"
           directive will clear this condition.
resetpass    Flush the list of allowed passwords. Moreover removes the
           "nopass" status. After "resetpass" the user has no associated
           passwords and there is no way to authenticate without adding
           some password (or setting it as "nopass" later).
reset        Performs the following actions: resetpass, resetkeys, off,
           -@all. The user returns to the same state it has immediately
           after its creation.

ACL rules can be specified in any order: for instance you can start with
passwords, then flags, or key patterns. However note that the additive
and subtractive rules will CHANGE MEANING depending on the ordering.
For instance see the following example:

user alice on +@all -DEBUG ~* >somepassword

This will allow "alice" to use all the commands with the exception of the
DEBUG command, since +@all added all the commands to the set of the commands
alice can use, and later DEBUG was removed. However if we invert the order
of two ACL rules the result will be different:
# 这将允许“ alice”使用除DEBUG命令之外的所有命令，因为+ @ all将所有命令添加到了alice可以使用的命令集中，并且后来删除了DEBUG。但是，如果我们颠倒两个ACL规则的顺序，结果将有所不同
user alice on -DEBUG +@all ~* >somepassword

Now DEBUG was removed when alice had yet no commands in the set of allowed
commands, later all the commands are added, so the user will be able to
execute everything.

Basically ACL rules are processed left-to-right.

For more information about ACL configuration please refer to
the Redis web site at https://redis.io/topics/acl

ACL LOG

The ACL Log tracks failed commands and authentication events associated
with ACLs. The ACL Log is useful to troubleshoot failed commands blocked 
by ACLs. The ACL Log is stored in memory. You can reclaim memory with 
ACL LOG RESET. Define the maximum entry length of the ACL Log below.
acllog-max-len 128
# ACL日志跟踪与ACL关联的失败命令和身份验证事件。 ACL日志可用于对ACL阻止的失败命令进行故障排除。 ACL日志存储在内存中。您可以使用ACL LOG RESET回收内存。在下面定义ACL日志的最大输入长度。 acllog-max-len 128
Using an external ACL file

Instead of configuring users here in this file, it is possible to use
a stand-alone file just listing users. The two methods cannot be mixed:
if you configure users here and at the same time you activate the external
ACL file, the server will refuse to start.
# 除了在此文件中配置用户之外，还可以使用仅列出用户的独立文件。两种方法不能混用：如果您在此处配置用户并同时激活外部ACL文件，则服务器将拒绝启动
The format of the external ACL user file is exactly the same as the
format that is used inside redis.conf to describe users.

aclfile /etc/redis/users.acl

IMPORTANT NOTE: starting with Redis 6 "requirepass" is just a compatibility
layer on top of the new ACL system. The option effect will be just setting
the password for the default user. Clients will still authenticate using
AUTH <password> as usually, or more explicitly with AUTH default <password>
if they follow the new protocol: both will work.
# 重要说明：从Redis 6开始，“ requirepass”只是新ACL系统之上的兼容性层。选项效果将只是为默认用户设置密码。客户端仍将照常使用AUTH <password>进行身份验证，如果遵循新协议，则仍将使用AUTH default <password>进行更明确的身份验证
requirepass foobared

Command renaming (DEPRECATED).

------------------------------------------------------------------------
WARNING: avoid using this option if possible. Instead use ACLs to remove
commands from the default user, and put them only in some admin user you
create for administrative purposes.
------------------------------------------------------------------------
# 警告：尽可能避免使用此选项。而是使用ACL从默认用户中删除命令，并将其仅放置在您出于管理目的而创建的某些admin用户中
It is possible to change the name of dangerous commands in a shared
environment. For instance the CONFIG command may be renamed into something
hard to guess so that it will still be available for internal-use tools
but not available for general clients.
# 可以在共享环境中更改危险命令的名称。例如，CONFIG命令可能会重命名为一些难以猜测的名称，因此它仍可用于内部使用的工具，但不适用于一般客户
Example:

rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52

It is also possible to completely kill a command by renaming it into
an empty string:

rename-command CONFIG ""

Please note that changing the name of commands that are logged into the
AOF file or transmitted to replicas may cause problems.
# 注意，更改登录到AOF文件或传输到副本的命令的名称可能会导致问题
```

rename-command：命令重命名，对于一些危险命令例如：

- flushdb（清空数据库）

- flushall（清空所有记录）

- config（客户端连接后可配置服务器）

- keys（客户端连接后可查看所有存在的键）          

> 作为服务端redis-server，常常需要禁用以上命令来使得服务器更加安全，禁用的具体做法是是：
>
> rename-command FLUSHALL ""

也可以保留命令但是不能轻易使用，重命名这个命令即可：

- rename-command FLUSHALL abcdefg 这样，重启服务器后则需要使用新命令来执行操作，否则服务器会报错unknown command。

**requirepass:设置redis连接密码**

　　比如: requirepass 123456 表示redis的连接密码为123456.

## CLIENTS

```
CLIENTS 

Set the max number of connected clients at the same time. By default
this limit is set to 10000 clients, however if the Redis server is not
able to configure the process file limit to allow for the specified limit
the max number of allowed clients is set to the current file limit
minus 32 (as Redis reserves a few file descriptors for internal uses).
# 同时设置最大连接客户端数。默认情况下，此限制设置为10000个客户端，但是，如果Redis服务器无法将进程文件限制配置为允许指定的限制，则允许的最大客户端数设置为当前文件限制减去32（因为Redis保留了内部使用的几个文件描述符）
Once the limit is reached Redis will close all the new connections sending
an error 'max number of clients reached'.
# 达到限制后，Redis将关闭所有新连接，并发送错误消息“已达到最大客户端数”。
IMPORTANT: When Redis Cluster is used, the max number of connections is also
shared with the cluster bus: every node in the cluster will use two
connections, one incoming and another outgoing. It is important to size the
limit accordingly in case of very large clusters.
# 重要信息：使用Redis群集时，最大连接数也与群集总线共享：群集中的每个节点将使用两个连接，一个进入，另一个向外。在群集非常大的情况下，相应地调整限制大小非常重要
maxclients 10000
```

maxclients ：设置客户端最大并发连接数，默认无限制，Redis可以同时打开的客户端连接数为Redis进程可以打开的最大文件。 描述符数-32（redis server自身会使用一些），如果设置 maxclients为0 。表示不作限制。当客户端连接数到达限制时，Redis会关闭新的连接并向客户端返回max number of clients reached错误信息

## MEMORY MANAGEMENT

```ini
MEMORY MANAGEMENT 

Set a memory usage limit to the specified amount of bytes.
When the memory limit is reached Redis will try to remove keys
according to the eviction policy selected (see maxmemory-policy).
# 将内存使用限制设置为指定的字节数。当达到内存限制时，Redis将尝试根据所选的逐出策略来删除密钥
If Redis can't remove keys according to the policy, or if the policy is
set to 'noeviction', Redis will start to reply with errors to commands
that would use more memory, like SET, LPUSH, and so on, and will continue
to reply to read-only commands like GET.
# 如果Redis无法根据该策略删除密钥，或者如果该策略设置为'noeviction'，则Redis将开始对将使用更多内存的命令（例如SET，LPUSH等）进行错误答复，并将继续回复诸如GET之类的只读命令
This option is usually useful when using Redis as an LRU or LFU cache, or to
set a hard memory limit for an instance (using the 'noeviction' policy).
# 当将Redis用作LRU或LFU缓存，或为实例设置硬盘限制时，此选项通常很有用
WARNING: If you have replicas attached to an instance with maxmemory on,
the size of the output buffers needed to feed the replicas are subtracted
from the used memory count, so that network problems / resyncs will
not trigger a loop where keys are evicted, and in turn the output
buffer of replicas is full with DELs of keys evicted triggering the deletion
of more keys, and so forth until the database is completely emptied.
# 警告：如果您将副本附加到实例上且maxmemory处于打开状态，则从使用的内存计数中减去提供副本所需的输出缓冲区的大小，以便网络问题重新同步将不会触发逐出密钥的循环。使副本的输出缓冲区已满，其中有被驱逐的键DEL触发了更多键的删除，依此类推，直到数据库完全清空
In short... if you have replicas attached it is suggested that you set a lower
limit for maxmemory so that there is some free RAM on the system for replica
output buffers (but this is not needed if the policy is 'noeviction').
# 简而言之...如果您附加了副本，建议您为maxmemory设置一个下限，以便系统上有一些可用的RAM用于副本输出缓冲区（但是如果策略为“ noeviction”，则不需要这样做）
maxmemory <bytes>

MAXMEMORY POLICY: how Redis will select what to remove when maxmemory
is reached. You can select one from the following behaviors:
# MAXMEMORY POLICY：达到maxmemory后，Redis将如何选择要删除的内容。您可以从以下行为中选择一种
volatile-lru -> Evict using approximated LRU, only keys with an expire set.
allkeys-lru -> Evict any key using approximated LRU.
volatile-lfu -> Evict using approximated LFU, only keys with an expire set.    # 使用近似的LRU驱逐，仅使用已过期的密钥
allkeys-lfu -> Evict any key using approximated LFU.                           # 使用近似的LFU退出任何密钥
volatile-random -> Remove a random key having an expire set.                   # 删除具有过期设置的随机密钥
allkeys-random -> Remove a random key, any key.                                # 删除随机密钥，任何密钥
volatile-ttl -> Remove the key with the nearest expire time (minor TTL)        # 取出最接近到期时间（较小的TTL）的密钥
noeviction -> Don't evict anything, just return an error on write operations.  # 不驱逐任何东西，仅在写操作时返回错误

LRU means Least Recently Used       # LRU表示最近最少使用   LFU表示最少使用
LFU means Least Frequently Used

Both LRU, LFU and volatile-ttl are implemented using approximated
randomized algorithms. 
# LRU，LFU和volatile-ttl均使用近似随机算法实现

Note: with any of the above policies, Redis will return an error on write
   operations, when there are no suitable keys for eviction.

   At the date of writing these commands are: set setnx setex append
   incr decr rpush lpush rpushx lpushx linsert lset rpoplpush sadd
   sinter sinterstore sunion sunionstore sdiff sdiffstore zadd zincrby
   zunionstore zinterstore hset hsetnx hmset hincrby incrby decrby
   getset mset msetnx exec sort
# 注意：使用上述任何策略时，如果没有合适的退出键，Redis将在写入操作中返回错误。在撰写本文时，这些命令是：
# set setnx setex append incr decr rpush lpush rpushx lpushx linsert lset rpoplpush sadd interinterstore sunion 
# sunionstore sdiff sdiffstore zadd zincrby zunionstore zinterstore hset hsetnx hmset hincrby mcrby deby byby
The default is:

maxmemory-policy noeviction

LRU, LFU and minimal TTL algorithms are not precise algorithms but approximated
algorithms (in order to save memory), so you can tune it for speed or
accuracy. By default Redis will check five keys and pick the one that was
used least recently, you can change the sample size using the following
configuration directive.
# LRU，LFU和最小TTL算法不是精确算法，而是近似算法（以节省内存），因此您可以针对速度或准确性进行调整。默认情况下，Redis将检查五个键并选择最近使用最少的键，您可以使用以下配置指令更改样本大小
The default of 5 produces good enough results. 10 Approximates very closely
true LRU but costs more CPU. 3 is faster but not very accurate.
# 默认值为5会产生足够好的结果。 10非常接近真实的LRU，但是会花费更多的CPU。 3更快但不是很准确
maxmemory-samples 5

Starting from Redis 5, by default a replica will ignore its maxmemory setting
(unless it is promoted to master after a failover or manually). It means
that the eviction of keys will be just handled by the master, sending the
DEL commands to the replica as keys evict in the master side.
# 从Redis 5开始，默认情况下，副本将忽略其maxmemory设置（除非在故障转移后或手动提升为主副本）。这意味着密钥的移出将仅由主服务器处理，将DEL命令作为副本在主计算机侧逐出，将DEL命令发送到副本
This behavior ensures that masters and replicas stay consistent, and is usually
what you want, however if your replica is writable, or you want the replica
to have a different memory setting, and you are sure all the writes performed
to the replica are idempotent, then you may change this default (but be sure
to understand what you are doing).
# 此行为可确保主副本和副本始终保持一致，这通常是您想要的，但是，如果副本是可写的，或者您希望副本具有不同的内存设置，并且您确定对副本执行的所有写操作都是幂等的，那么您可以更改此默认设置（但请务必了解您在做什么）
Note that since the replica by default does not evict, it may end using more
memory than the one set via maxmemory (there are certain buffers that may
be larger on the replica, or data structures may sometimes take more memory
and so forth). So make sure you monitor your replicas and make sure they
have enough memory to never hit a real out-of-memory condition before the
master hits the configured maxmemory setting.
# 请注意，由于默认情况下该副本不会退出，因此它可能会结束使用比通过maxmemory设置的内存更多的内存（某些缓冲区在副本上可能会更大，或者数据结构有时会占用更多的内存，依此类推）。因此，请确保您监视副本，并确保副本具有足够的内存，以便在主副本达到配置的最大内存设置之前永远不会遇到真正的内存不足情况
replica-ignore-maxmemory yes

Redis reclaims expired keys in two ways: upon access when those keys are
found to be expired, and also in background, in what is called the
"active expire key". The key space is slowly and interactively scanned
looking for expired keys to reclaim, so that it is possible to free memory
of keys that are expired and will never be accessed again in a short time.
# Redis通过两种方式回收过期的密钥：访问时发现这些密钥已过期，以及在后台，称为“活动的过期密钥”。缓慢地，交互地扫描密钥空间，以查找要回收的过期密钥，以便可以释放已过期且不久之后将不再访问的密钥的内存
The default effort of the expire cycle will try to avoid having more than
ten percent of expired keys still in memory, and will try to avoid consuming
more than 25% of total memory and to add latency to the system. However
it is possible to increase the expire "effort" that is normally set to
"1", to a greater value, up to the value "10". At its maximum value the
system will use more CPU, longer cycles (and technically may introduce
more latency), and will tolerate less already expired keys still present
in the system. It's a tradeoff between memory, CPU and latency.
# 到期周期的默认工作将尝试避免在内存中保留超过百分之十的过期密钥，并且将尝试避免消耗超过总内存的25％并增加系统延迟。但是，可以将通常设置为“ 1”的过期“努力”增加到更大的值，直到值“ 10”。系统将以其最大值使用更多的CPU，更长的周期（并且从技术上讲可能会引入更多的延迟），并且将容忍更少的系统中仍然存在的已过期密钥。在内存，CPU和延迟之间进行权衡
active-expire-effort 1
```

> LRU是Least Recently Used的缩写，即最近最少使用
> LFU（Least Frequently Used ，最近最少使用算法）也是一种常见的缓存算法
> 

maxmemory：设置Redis的最大内存，如果设置为0 。表示不作限制。通常是配合下面介绍的maxmemory-policy参数一起使用。

maxmemory-policy ：当内存使用达到maxmemory设置的最大值时，redis使用的内存清除策略。有以下几种可以选择：

　　　　1）volatile-lru  利用LRU算法移除设置过过期时间的key 

　　　　2）allkeys-lru  利用LRU算法移除任何key 

　　　　3）volatile-random 移除设置过过期时间的随机key 

　　　　4）allkeys-random 移除随机ke

　　　　5）volatile-ttl  移除即将过期的key(minor TTL) 

　　　　6）noeviction noeviction  不移除任何key，只是返回一个写错误 ，默认选项

maxmemory-samples ：LRU 和 minimal TTL 算法都不是精准的算法，但是相对精确的算法(为了节省内存)。随意你可以选择样本大小进行检，redis默认选择5个样本进行检测，你可以通过maxmemory-samples进行设置样本数。

## LAZY FREEING

```ini
LAZY FREEING 

Redis has two primitives to delete keys. One is called DEL and is a blocking
deletion of the object. It means that the server stops processing new commands
in order to reclaim all the memory associated with an object in a synchronous
way. If the key deleted is associated with a small object, the time needed
in order to execute the DEL command is very small and comparable to most other
O(1) or O(log_N) commands in Redis. However if the key is associated with an
aggregated value containing millions of elements, the server can block for
a long time (even seconds) in order to complete the operation.
# Redis有两个删除键的原语。一种称为DEL，它是对象的阻塞删除。这意味着服务器停止处理新命令，以便以同步方式回收与对象关联的所有内存。如果删除的键与一个小对象相关联，则执行DEL命令所需的时间非常短，可与Redis中的大多数其他O（1）或O（log_N）命令相提并论。但是，如果键与包含数百万个元素的聚合值相关联，则服务器可能会阻塞很长时间（甚至几秒钟）以完成操作
For the above reasons Redis also offers non blocking deletion primitives
such as UNLINK (non blocking DEL) and the ASYNC option of FLUSHALL and
FLUSHDB commands, in order to reclaim memory in background. Those commands
are executed in constant time. Another thread will incrementally free the
object in the background as fast as possible.
# 由于上述原因，Redis还提供了非阻塞删除原语，例如UNLINK（非阻塞DEL）以及FLUSHALL和FLUSHDB命令的ASYNC选项，以便在后台回收内存。这些命令在固定时间内执行。另一个线程将尽可能快地在后台逐渐释放对象
DEL, UNLINK and ASYNC option of FLUSHALL and FLUSHDB are user-controlled.
It's up to the design of the application to understand when it is a good
idea to use one or the other. However the Redis server sometimes has to
delete keys or flush the whole database as a side effect of other operations.
Specifically Redis deletes objects independently of a user call in the
following scenarios:
# 用户可以控制FLUSHALL和FLUSHDB的DEL，UNLINK和ASYNC选项。由应用程序的设计来决定何时使用一个或另一个是一个好主意。但是，Redis服务器有时必须删除键或刷新整个数据库，这是其他操作的副作用。特别是在以下情况下，Redis会独立于用户调用而删除对象
1) On eviction, because of the maxmemory and maxmemory policy configurations,
in order to make room for new data, without going over the specified
memory limit.
2) Because of expire: when a key with an associated time to live (see the
EXPIRE command) must be deleted from memory.
3) Because of a side effect of a command that stores data on a key that may
already exist. For example the RENAME command may delete the old key
content when it is replaced with another one. Similarly SUNIONSTORE
or SORT with STORE option may delete existing keys. The SET command
itself removes any old content of the specified key in order to replace
it with the specified string.
4) During replication, when a replica performs a full resynchronization with
its master, the content of the whole database is removed in order to
load the RDB file just transferred.

In all the above cases the default is to delete objects in a blocking way,
like if DEL was called. However you can configure each case specifically
in order to instead release memory in a non-blocking way like if UNLINK
was called, using the following configuration directives.
# 在上述所有情况下，默认设置都是以阻塞方式删除对象，就像调用DEL一样。但是，可以使用以下配置指令专门配置每种情况，以便以非阻塞方式释放内存，例如是否调用了UNLINK。
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no

It is also possible, for the case when to replace the user code DEL calls
with UNLINK calls is not easy, to modify the default behavior of the DEL
command to act exactly like UNLINK, using the following configuration
directive:
# 对于用UNLINK调用替换用户代码DEL调用不容易的情况，也可以使用以下配置指令将DEL命令的默认行为修改为与UNLINK完全一样
lazyfree-lazy-user-del no
```

## THREADED I/O

```ini
THREADED I/O 

Redis is mostly single threaded, however there are certain threaded
operations such as UNLINK, slow I/O accesses and other things that are
performed on side threads.
# Redis大多是单线程的，但是有一些线程操作，例如UNLINK，缓慢的IO访问和其他在侧线程上执行的操作
Now it is also possible to handle Redis clients socket reads and writes
in different I/O threads. Since especially writing is so slow, normally
Redis users use pipelining in order to speed up the Redis performances per
core, and spawn multiple instances in order to scale more. Using I/O
threads it is possible to easily speedup two times Redis without resorting
to pipelining nor sharding of the instance.
# 现在，还可以在不同的IO线程中处理Redis客户端套接字的读写。由于特别慢的写入速度，通常Redis用户使用流水线来加快每个内核的Redis性能，并生成多个实例以扩展规模。使用IO线程，可以轻松地将Redis加速两次，而无需求助于实例的流水线处理或分片
By default threading is disabled, we suggest enabling it only in machines
that have at least 4 or more cores, leaving at least one spare core.
Using more than 8 threads is unlikely to help much. We also recommend using
threaded I/O only if you actually have performance problems, with Redis
instances being able to use a quite big percentage of CPU time, otherwise
there is no point in using this feature.
# 默认情况下，线程是禁用的，我们建议仅在具有至少4个或更多内核的计算机上启用它，而至少保留一个备用内核。使用8个以上的线程不太可能有很大帮助。我们还建议仅在实际存在性能问题时才使用线程IO，Redis实例可以使用很大一部分CPU时间，否则使用此功能毫无意义。
So for instance if you have a four cores boxes, try to use 2 or 3 I/O
threads, if you have a 8 cores, try to use 6 threads. In order to
enable I/O threads use the following configuration directive:
# 因此，例如，如果您有四个核的盒子，请尝试使用2个或3个IO线程，如果您有8个核，请尝试使用6个线程。为了启用IO线程，请使用以下配置指令
io-threads 4

Setting io-threads to 1 will just use the main thread as usual.
When I/O threads are enabled, we only use threads for writes, that is
to thread the write(2) syscall and transfer the client buffers to the
socket. However it is also possible to enable threading of reads and
protocol parsing using the following configuration directive, by setting
it to yes:
# 将io-threads设置为1只会照常使用主线程。启用IO线程后，我们仅使用线程进行写操作，即对write（2）系统调用进行线程化，并将客户端缓冲区传输到套接字。但是，也可以使用以下配置指令，通过将其设置为yes，来启用读取线程和协议解析
io-threads-do-reads no

Usually threading reads doesn't help much.
# 通常线程读取并没有多大帮助
NOTE 1: This configuration directive cannot be changed at runtime via
CONFIG SET. Aso this feature currently does not work when SSL is
enabled.
# 注意1：无法在运行时通过CONFIG SET更改此配置指令。启用SSL后，该功能目前也无法使用。
NOTE 2: If you want to test the Redis speedup using redis-benchmark, make
sure you also run the benchmark itself in threaded mode, using the
--threads option to match the number of Redis threads, otherwise you'll not
be able to notice the improvements.
# 注意2：如果要使用redis-benchmark测试Redis加速，请确保还使用--threads选项匹配Redis线程数，在线程模式下运行基准测试本身，否则将无法注意改进
```

## KERNEL OOM CONTROL

```ini
KERNEL OOM CONTROL # 内核OOM控制

On Linux, it is possible to hint the kernel OOM killer on what processes
should be killed first when out of memory.
# 在Linux上，可以向内核OOM杀手提示内存不足时应首先终止哪些进程
Enabling this feature makes Redis actively control the oom_score_adj value
for all its processes, depending on their role. The default scores will
attempt to have background child processes killed before all others, and
replicas killed before masters.
# 启用此功能可使Redis根据其进程主动控制其所有进程的oom_score_adj值。默认分数将尝试使后台子进程在所有其他进程之前被杀死，副本在主数据库之前被杀死
oom-score-adj no

When oom-score-adj is used, this directive controls the specific values used
for master, replica and background child processes. Values range -1000 to
1000 (higher means more likely to be killed).
# 使用oom-score-adj时，此伪指令控制用于主，副本和后台子进程的特定值。值范围-1000至1000（值越高，表示被杀死的可能性越高）
Unprivileged processes (not root, and without CAP_SYS_RESOURCE capabilities)
can freely increase their value, but not decrease it below its initial
settings.
# 无特权的进程（不是root进程，并且没有CAP_SYS_RESOURCE功能）可以自由地增加其值，但不能将其降低到其初始设置以下
Values are used relative to the initial value of oom_score_adj when the server
starts. Because typically the initial value is 0, they will often match the
absolute values.

oom-score-adj-values 0 200 800
```

## APPEND ONLY MODE(重要)

```ini
APPEND ONLY MODE 

By default Redis asynchronously dumps the dataset on disk. This mode is
good enough in many applications, but an issue with the Redis process or
a power outage may result into a few minutes of writes lost (depending on
the configured save points).
# 服务器启动时，使用相对于oom_score_adj初始值的值。因为通常初始值为0，所以它们通常会与绝对值匹配。
The Append Only File is an alternative persistence mode that provides
much better durability. For instance using the default data fsync policy
(see later in the config file) Redis can lose just one second of writes in a
dramatic event like a server power outage, or a single write if something
wrong with the Redis process itself happens, but the operating system is
still running correctly.
# 仅附加文件是一种替代的持久性模式，可提供更好的持久性。例如，使用默认数据fsync策略（请参阅配置文件中的稍后内容），Redis在严重的事件（例如服务器断电）中仅会丢失一秒钟的写入，如果Redis进程本身发生问题，则可能会丢失一次写入，但是操作系统仍在正常运行
AOF and RDB persistence can be enabled at the same time without problems.
If the AOF is enabled on startup Redis will load the AOF, that is the file
with the better durability guarantees.
# 可以同时启用AOF和RDB持久性，而不会出现问题。如果在启动时启用了AOF，则Redis将加载AOF，即具有更好持久性的文件
Please check http://redis.io/topics/persistence for more information.

appendonly no

The name of the append only file (default: "appendonly.aof")

appendfilename "appendonly.aof"

The fsync() call tells the Operating System to actually write data on disk
instead of waiting for more data in the output buffer. Some OS will really flush
data on disk, some other OS will just try to do it ASAP.
# fsync（）调用告诉操作系统将数据实际写入磁盘，而不是等待输出缓冲区中的更多数据。某些操作系统确实会刷新磁盘上的数据，而另一些操作系统会尽快尝试
Redis supports three different modes:

no: don't fsync, just let the OS flush the data when it wants. Faster.
always: fsync after every write to the append only log. Slow, Safest.
everysec: fsync only one time every second. Compromise.

The default is "everysec", as that's usually the right compromise between
speed and data safety. It's up to you to understand if you can relax this to
"no" that will let the operating system flush the output buffer when
it wants, for better performances (but if you can live with the idea of
some data loss consider the default persistence mode that's snapshotting),
or on the contrary, use "always" that's very slow but a bit safer than
everysec.

More details please check the following article:
http://antirez.com/post/redis-persistence-demystified.html

If unsure, use "everysec".

appendfsync always
appendfsync everysec
appendfsync no

When the AOF fsync policy is set to always or everysec, and a background
saving process (a background save or AOF log background rewriting) is
performing a lot of I/O against the disk, in some Linux configurations
Redis may block too long on the fsync() call. Note that there is no fix for
this currently, as even performing fsync in a different thread will block
our synchronous write(2) call.
# 当AOF fsync策略设置为always或everysec，并且后台保存进程（后台保存或AOF日志后台重写）对磁盘执行大量IO时，在某些Linux配置中，Redis可能会在fsync上阻塞太长时间（ ）致电。请注意，目前尚无此修复程序，因为即使在其他线程中执行fsync也将阻塞我们的同步write（2）调用
In order to mitigate this problem it's possible to use the following option
that will prevent fsync() from being called in the main process while a
BGSAVE or BGREWRITEAOF is in progress.
# 为了减轻此问题，可以使用以下选项来防止在BGSAVE或BGREWRITEAOF进行时在主进程中调用fsync（）
This means that while another child is saving, the durability of Redis is
the same as "appendfsync none". In practical terms, this means that it is
possible to lose up to 30 seconds of log in the worst scenario (with the
default Linux settings).
# 这意味着当另一个子线程正在保存时，Redis的持久性与“ appendfsync none”相同。实际上，这意味着在最坏的情况下（使用默认的Linux设置）可能会丢失多达30秒的日志
If you have latency problems turn this to "yes". Otherwise leave it as
"no" that is the safest pick from the point of view of durability.
# 如果您有延迟问题，请将其设置为“是”。否则，从耐用性的角度出发，将其保留为“ no”是最安全的选择
no-appendfsync-on-rewrite no

Automatic rewrite of the append only file.
Redis is able to automatically rewrite the log file implicitly calling
BGREWRITEAOF when the AOF log size grows by the specified percentage.
# 自动重写仅附加文件。当AOF日志大小增加指定百分比时，Redis能够自动重写日志文件，隐式调用BGREWRITEAOF
This is how it works: Redis remembers the size of the AOF file after the
latest rewrite (if no rewrite has happened since the restart, the size of
the AOF at startup is used).
# 它是这样工作的：Redis在最近一次重写之后会记住AOF文件的大小（如果自重新启动以来未发生任何重写，则使用启动时AOF的大小）。
This base size is compared to the current size. If the current size is
bigger than the specified percentage, the rewrite is triggered. Also
you need to specify a minimal size for the AOF file to be rewritten, this
is useful to avoid rewriting the AOF file even if the percentage increase
is reached but it is still pretty small.
# 将此基本大小与当前大小进行比较。如果当前大小大于指定的百分比，则触发重写。另外，您需要指定要重写的AOF文件的最小大小，这对于避免重写AOF文件很有用，即使达到百分比增加，但它仍然很小
Specify a percentage of zero in order to disable the automatic AOF
rewrite feature.
# 指定零百分比以禁用自动AOF重写功能
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

An AOF file may be found to be truncated at the end during the Redis
startup process, when the AOF data gets loaded back into memory.
This may happen when the system where Redis is running
crashes, especially when an ext4 filesystem is mounted without the
data=ordered option (however this can't happen when Redis itself
crashes or aborts but the operating system still works correctly).
# 当AOF数据重新加载回内存时，在Redis启动过程中可能会发现AOF文件在末尾被截断。当运行Redis的系统崩溃时，尤其是在没有data = ordered选项的情况下挂载ext4文件系统时，可能会发生这种情况（但是，当Redis本身崩溃或中止，但操作系统仍然可以正常运行时，就不会发生这种情况）
Redis can either exit with an error when this happens, or load as much
data as possible (the default now) and start if the AOF file is found
to be truncated at the end. The following option controls this behavior.
# 发生这种情况时，Redis可能会退出并显示错误，也可以加载尽可能多的数据（当前为默认值），如果发现AOF文件最后被截断，则Redis会开始。以下选项控制此行为
If aof-load-truncated is set to yes, a truncated AOF file is loaded and
the Redis server starts emitting a log to inform the user of the event.
Otherwise if the option is set to no, the server aborts with an error
and refuses to start. When the option is set to no, the user requires
to fix the AOF file using the "redis-check-aof" utility before to restart
the server.
# 如果aof-load-truncated设置为yes，则将加载截短的AOF文件，并且Redis服务器将开始发出日志以将事件通知用户。否则，如果该选项设置为no，则服务器将中止并显示错误并拒绝启动。如果该选项设置为no，则用户需要在重新启动服务器之前使用“ redis-check-aof”实用程序修复AOF文件
Note that if the AOF file will be found to be corrupted in the middle
the server will still exit with an error. This option only applies when
Redis will try to read more data from the AOF file but not enough bytes
will be found.
# 请注意，如果在中间发现AOF文件已损坏，则服务器仍将退出并出现错误。仅当Redis尝试从AOF文件读取更多数据但找不到足够的字节时，此选项才适用。
aof-load-truncated yes

When rewriting the AOF file, Redis is able to use an RDB preamble in the
AOF file for faster rewrites and recoveries. When this option is turned
on the rewritten AOF file is composed of two different stanzas:
# 重写AOF文件时，Redis可以使用AOF文件中的RDB前同步码来更快地进行重写和恢复。启用此选项后，重写的AOF文件由两个不同的节组成
[RDB file] [AOF tail]

When loading, Redis recognizes that the AOF file starts with the "REDIS"
string and loads the prefixed RDB file, then continues loading the AOF
tail.
# 加载时，Redis会识别AOF文件以“ REDIS”字符串开头并加载带前缀的RDB文件，然后继续加载AOF尾部。
aof-use-rdb-preamble yes
```

appendonly（AOF）是一种替代的持久性模式，可提供更好的持久性。例如，使用默认数据fsync策略（请参阅配置文件中的稍后内容），Redis在严重的事件（例如服务器断电）中仅会丢失一秒钟的写入，如果Redis进程本身发生问题，则可能会丢失一次写入，但是操作系统仍在正常运行

可以同时启用AOF和RDB持久性，而不会出现问题。如果在启动时启用了AOF，则Redis将加载AOF，即具有更好持久性的文件

appendonly（AOF）默认是关闭的，我们可以`appendonly yes`打开，默认文件名为`appendonly.aof`

> 默认redis使用的是rdb方式持久化，这种方式在许多应用中已经足够用了。但是redis如果中途宕机，会导致可能有几分钟的数据丢失，根据save来策略进行持久化，Append Only File是另一种持久化方式，  可以提供更好的持久化特性。Redis会把每次写入的数据在接收后都写入appendonly.aof文件，每次启动时Redis都会先把这个文件的数据读入内存里，先忽略RDB文件。默认值为no

appendonly（AOF）的启动参数有三个：默认使用appendfsync everysec

> appendfsync always
> appendfsync everysec
> appendfsync no
>
> aof持久化策略的配置；no表示不执行fsync，由操作系统保证数据同步到磁盘，速度最快；always表示每次写入都执行fsync，以保证数据同步到磁盘；everysec表示每秒执行一次fsync，可能会导致丢失这1s数据

在aof重写或者写入rdb文件的时候，会执行大量IO，此时对于everysec和always的aof模式来说，执行fsync会造成阻塞过长时间，no-appendfsync-on-rewrite字段设置为默认设置为no。如果对延迟要求很高的应用，这个字段可以设置为yes，否则还是设置为no，这样对持久化特性来说这是更安全的选择。  设置为yes表示rewrite期间对新写操作不fsync,暂时存在内存中,等rewrite完成后再写入，默认为no，建议yes。Linux的默认fsync策略是30秒。可能丢失30秒数据。默认值为no。

> 如果您有延迟问题，请将其设置为“是”。否则，从耐用性的角度出发，将其保留为“ no”是最安全的选择

auto-aof-rewrite-percentage：默认值为100。aof自动重写配置，当目前aof文件大小超过上一次重写的aof文件大小的百分之多少进行重写，即当aof文件增长到一定大小的时候，Redis能够调用bgrewriteaof对日志文件进行重写。当前AOF文件大小是上次日志重写得到AOF文件大小的二倍（设置为100）时，自动启动新的日志重写过程。

auto-aof-rewrite-min-size：64mb。设置允许重写的最小aof文件大小，避免了达到约定百分比但尺寸仍然很小的情况还要重写。

aof-load-truncated：aof文件可能在尾部是不完整的，当redis启动的时候，aof文件的数据被载入内存。重启可能发生在redis所在的主机操作系统宕机后，尤其在ext4文件系统没有加上data=ordered选项，出现这种现象 redis宕机或者异常终止不会造成尾部不完整现象，可以选择让redis退出，或者导入尽可能多的数据。如果选择的是yes，当截断的aof文件被导入的时候，会自动发布一个log给客户端然后load。如果是no，用户必须手动redis-check-aof修复AOF文件才可以。默认值为 yes

## LUA SCRIPTING

```ini

LUA SCRIPTING  

Max execution time of a Lua script in milliseconds.
# Lua脚本的最大执行时间（以毫秒为单位）。
If the maximum execution time is reached Redis will log that a script is
still in execution after the maximum allowed time and will start to
reply to queries with an error.
# 如果达到了最大执行时间，Redis将记录脚本在允许的最大时间后仍在执行中，并将开始以错误答复查询
When a long running script exceeds the maximum execution time only the
SCRIPT KILL and SHUTDOWN NOSAVE commands are available. The first can be
used to stop a script that did not yet call any write commands. The second
is the only way to shut down the server in the case a write command was
already issued by the script but the user doesn't want to wait for the natural
termination of the script.
# 如果长时间运行的脚本超过了最大执行时间，则只有“ SCRIPT KILL”和“ SHUTDOWN NOSAVE”命令可用。第一个可用于停止尚未调用任何写命令的脚本。第二种是在脚本已经发出写命令但用户不想等待脚本自然终止的情况下关闭服务器的唯一方法
Set it to 0 or a negative value for unlimited execution without warnings.
# 将其设置为0或负值可无警告地无限执行
lua-time-limit 5000
```

lua-time-limit：一个lua脚本执行的最大时间，单位为ms。默认值为5000

## REDIS CLUSTER(重要)

```ini
REDIS CLUSTER  

Normal Redis instances can't be part of a Redis Cluster; only nodes that are
started as cluster nodes can. In order to start a Redis instance as a
cluster node enable the cluster support uncommenting the following:
# 普通Redis实例不能属于Redis集群；只有作为群集节点启动的节点可以。为了将Redis实例启动为集群节点，请启用集群支持
cluster-enabled yes

Every cluster node has a cluster configuration file. This file is not
intended to be edited by hand. It is created and updated by Redis nodes.
Every Redis Cluster node requires a different cluster configuration file.
Make sure that instances running in the same system do not have
overlapping cluster configuration file names.
# 每个群集节点都有一个群集配置文件。该文件不适合手工编辑。它由Redis节点创建和更新。每个Redis群集节点都需要一个不同的群集配置文件。确保在同一系统上运行的实例没有重叠的集群配置文件名
cluster-config-file nodes-6379.conf

Cluster node timeout is the amount of milliseconds a node must be unreachable
for it to be considered in failure state.
Most other internal time limits are a multiple of the node timeout.
# 群集节点超时是一个节点必须不可达的毫秒数，才能将其视为故障状态。其他大多数内部时间限制是节点超时的倍数
cluster-node-timeout 15000

A replica of a failing master will avoid to start a failover if its data
looks too old.
# 如果发生故障的主副本的数据看起来太旧，它将避免启动故障转移。
There is no simple way for a replica to actually have an exact measure of
its "data age", so the following two checks are performed:
# 没有一种简单的方法可以使副本实际上具有其“数据年龄”的准确度量，因此执行以下两项检查
1) If there are multiple replicas able to failover, they exchange messages
in order to try to give an advantage to the replica with the best
replication offset (more data from the master processed).
Replicas will try to get their rank by offset, and apply to the start
of the failover a delay proportional to their rank.
# # 如果存在多个能够进行故障转移的副本，则它们会交换消息，以便尝试利用具有最佳复制偏移量的副本（已处理来自主数据库的更多数据）来获得优势。副本将尝试按偏移量获得其排名，并将故障切换延迟按其排名成比例地应用于故障转移的开始
2) Every single replica computes the time of the last interaction with
its master. This can be the last ping or command received (if the master
is still in the "connected" state), or the time that elapsed since the
disconnection with the master (if the replication link is currently down).
If the last interaction is too old, the replica will not try to failover
at all.
# 每个单个副本都会计算与其主副本之间最后一次交互的时间。这可以是最后收到的ping或命令（如果主服务器仍处于“已连接”状态），也可以是自从与主服务器断开连接以来经过的时间（如果复制链接当前已关闭）。如果最后一次交互太旧，则副本将完全不会尝试故障转移
The point "2" can be tuned by user. Specifically a replica will not perform
the failover if, since the last interaction with the master, the time
elapsed is greater than:
# 用户可以调整点“ 2”。特别是，如果自从上次与主服务器进行交互以来，如果经过的时间大于或等于一个副本，则副本将不执行故障转移。
(node-timeout * cluster-replica-validity-factor) + repl-ping-replica-period
# （节点超时 * 集群副本有效性因子）+ 复制周期
So for example if node-timeout is 30 seconds, and the cluster-replica-validity-factor
is 10, and assuming a default repl-ping-replica-period of 10 seconds, the
replica will not try to failover if it was not able to talk with the master
for longer than 310 seconds.
# 因此，例如，如果节点超时为30秒，并且集群副本有效期因子为10，并且假设默认的repl-ping-replica-period为10秒，则副本将无法尝试进行故障转移，如果它不能与主人交谈超过310秒
A large cluster-replica-validity-factor may allow replicas with too old data to failover
a master, while a too small value may prevent the cluster from being able to
elect a replica at all.
# 较大的群集副本有效性因素可能会使数据过旧的副本无法对主副本进行故障转移，而值太小可能会使群集根本无法选择副本
For maximum availability, it is possible to set the cluster-replica-validity-factor
to a value of 0, which means, that replicas will always try to failover the
master regardless of the last time they interacted with the master.
(However they'll always try to apply a delay proportional to their
offset rank).
# 为了获得最大可用性，可以将cluster-replica-validity-factor设置为0，这意味着，无论副本上次与主服务器交互是什么，副本将始终尝试对主服务器进行故障转移。 （但是，他们将始终尝试按与其偏移等级成比例的方式应用延迟）
Zero is the only value able to guarantee that when all the partitions heal
the cluster will always be able to continue.
# 零是唯一能够确保当所有分区恢复正常时群集将始终能够继续运行的值
cluster-replica-validity-factor 10

Cluster replicas are able to migrate to orphaned masters, that are masters
that are left without working replicas. This improves the cluster ability
to resist to failures as otherwise an orphaned master can't be failed over
in case of failure if it has no working replicas.
# 群集副本能够迁移到孤立的主数据库，即那些没有工作副本的主数据库。这提高了群集抵抗故障的能力，否则如果孤立的主节点没有可用的副本，则该主节点在发生故障的情况下无法进行故障转移
Replicas migrate to orphaned masters only if there are still at least a
given number of other working replicas for their old master. This number
is the "migration barrier". A migration barrier of 1 means that a replica
will migrate only if there is at least 1 other working replica for its master
and so forth. It usually reflects the number of replicas you want for every
master in your cluster.
# 仅当旧的主副本仍存在至少给定数量的其他工作副本时，副本副本才会迁移到孤立的主副本。这个数字是“移民壁垒”。迁移屏障为1意味着，仅当副本数据库的主副本中至少有1个其他工作副本时，副本副本才会迁移。它通常反映出集群中每个主数据库所需的副本数
Default is 1 (replicas migrate only if their masters remain with at least
one replica). To disable migration just set it to a very large value.
A value of 0 can be set but is useful only for debugging and dangerous
in production.
# 缺省值为1（仅当其主副本保留至少一个副本副本时，副本副本才会迁移）。要禁用迁移，只需将其设置为非常大的值即可。可以设置为0，但仅用于调试和生产危险
cluster-migration-barrier 1

By default Redis Cluster nodes stop accepting queries if they detect there
is at least a hash slot uncovered (no available node is serving it).
This way if the cluster is partially down (for example a range of hash slots
are no longer covered) all the cluster becomes, eventually, unavailable.
It automatically returns available as soon as all the slots are covered again.
# 默认情况下，如果Redis Cluster节点检测到至少发现一个哈希槽（没有可用的节点正在为其提供服务），它们将停止接受查询。这样，如果集群部分关闭（例如，不再覆盖哈希槽范围），则所有集群最终将变得不可用。再次覆盖所有插槽后，它将自动返回可用状态
However sometimes you want the subset of the cluster which is working,
to continue to accept queries for the part of the key space that is still
covered. In order to do so, just set the cluster-require-full-coverage
option to no.
# 但是，有时您希望正在运行的集群子集继续接受对仍覆盖的部分键空间的查询。为此，只需将cluster-require-full-coverage选项设置为no

cluster-require-full-coverage yes

This option, when set to yes, prevents replicas from trying to failover its
master during master failures. However the master can still perform a
manual failover, if forced to do so.
# 设置为yes时，此选项可防止副本在主服务器发生故障时尝试对其主服务器进行故障转移。但是，主服务器仍然可以执行手动故障转移（如果被迫执行）
This is useful in different scenarios, especially in the case of multiple
data center operations, where we want one side to never be promoted if not
in the case of a total DC failure.
# 这在不同的情况下很有用，尤其是在多个数据中心操作的情况下，在这种情况下，如果完全DC失败，我们希望不升级一侧。
cluster-replica-no-failover no

This option, when set to yes, allows nodes to serve read traffic while the
the cluster is in a down state, as long as it believes it owns the slots. 
# 设置为yes时，此选项允许节点在群集处于关闭状态时为其提供读取流量，只要它认为自己拥有插槽即可
This is useful for two cases.  The first case is for when an application 
doesn't require consistency of data during node failures or network partitions.
One example of this is a cache, where as long as the node has the data it
should be able to serve it. 
# 这对于两种情况很有用。第一种情况是在节点故障或网络分区期间应用程序不需要数据一致性时。一个示例是高速缓存，只要节点具有数据，它就应该能够为其服务
The second use case is for configurations that don't meet the recommended  
three shards but want to enable cluster mode and scale later. A 
master outage in a 1 or 2 shard configuration causes a read/write outage to the
entire cluster without this option set, with it set there is only a write outage.
Without a quorum of masters, slot ownership will not change automatically. 
# 第二个用例是针对不符合建议的三个分片但希望启用集群模式并在以后扩展的配置。如果没有设置此选项，则在1或2分片配置中的主服务器中断会导致整个集群的读写中断。如果没有法定人数的主持人，则插槽所有权不会自动更改
cluster-allow-reads-when-down no

In order to setup your cluster make sure to read the documentation
available at http://redis.io web site.
```

cluster-enabled：集群开关，默认是不开启集群模式。

cluster-config-file：集群配置文件的名称，每个节点都有一个集群相关的配置文件，持久化保存集群的信息。 这个文件并不需要手动配置，这个配置文件有Redis生成并更新，每个Redis集群节点需要一个单独的配置文件。请确保与实例运行的系统中配置文件名称不冲突。默认配置为nodes-6379.conf

cluster-node-timeout ：可以配置值为15000。节点互连超时的阀值，集群节点超时毫秒数

cluster-slave-validity-factor ：可以配置值为10。在进行故障转移的时候，全部slave都会请求申请为master，但是有些slave可能与master断开连接一段时间了， 导致数据过于陈旧，这样的slave不应该被提升为master。该参数就是用来判断slave节点与master断线的时间是否过长。

> 判断方法是：比较slave断开连接的时间和(node-timeout * slave-validity-factor) + repl-ping-slave-period   如果节点超时时间为三十秒, 并且slave-validity-factor为10,假设默认的repl-ping-slave-period是10秒，即如果超过310秒slave将不会尝试进行故障转移

cluster-migration-barrier ：可以配置值为1。master的slave数量大于该值，slave才能迁移到其他孤立master上，如这个参数若被设为2，那么只有当一个主节点拥有2 个可工作的从节点时，它的一个从节点会尝试迁移。

cluster-require-full-coverage：默认情况下，集群全部的slot有节点负责，集群状态才为ok，才能提供服务。 设置为no，可以在slot没有全部分配的时候提供服务。不建议打开该配置，这样会造成分区的时候，小分区的master一直在接受写请求，而造成很长时间数据不一致。

## CLUSTER DOCKER/NAT support 

```ini
CLUSTER DOCKER/NAT support  

In certain deployments, Redis Cluster nodes address discovery fails, because
addresses are NAT-ted or because ports are forwarded (the typical case is
Docker and other containers).
# 在某些部署中，Redis群集节点地址发现失败，这是因为地址经过NAT限制或端口已转发（典型情况是Docker和其他容器）
In order to make Redis Cluster working in such environments, a static
configuration where each node knows its public address is needed. The
following two options are used for this scope, and are:
# 为了使Redis Cluster在这样的环境中工作，需要一个静态配置，其中每个节点都知道其公共地址。以下两个选项用于此范围，分别是
* cluster-announce-ip
* cluster-announce-port
* cluster-announce-bus-port

Each instructs the node about its address, client port, and cluster message
bus port. The information is then published in the header of the bus packets
so that other nodes will be able to correctly map the address of the node
publishing the information.
# 每个节点都向节点指示其地址，客户端端口和群集消息总线端口。然后将信息发布在总线数据包的标题中，以便其他节点将能够正确映射发布信息的节点的地址
If the above options are not used, the normal Redis Cluster auto-detection
will be used instead.
# 如果未使用上述选项，则将使用常规的Redis群集自动检测
Note that when remapped, the bus port may not be at the fixed offset of
clients port + 10000, so you can specify any port and bus-port depending
on how they get remapped. If the bus-port is not set, a fixed offset of
10000 will be used as usual.
# 请注意，重新映射时，总线端口可能不在客户端端口+ 10000的固定偏移处，因此您可以根据重新映射的方式指定任何端口和总线端口。如果未设置总线端口，则将照常使用10000的固定偏移量
Example:

cluster-announce-ip 10.1.1.5
cluster-announce-port 6379
cluster-announce-bus-port 6380
```

在某些部署中，Redis群集节点寻址失败，这是因为地址经过NAT限制或端口已转发（典型情况是Docker和其他容器），为了使Redis Cluster在这样的环境中工作，需要一个静态配置，其中每个节点都知道其公共地址。以下两个选项用于此范围，分别是

* cluster-announce-ip
* cluster-announce-port
* cluster-announce-bus-port



## SLOW LOG

```ini
SLOW LOG 

The Redis Slow Log is a system to log queries that exceeded a specified
execution time. The execution time does not include the I/O operations
like talking with the client, sending the reply and so forth,
but just the time needed to actually execute the command (this is the only
stage of command execution where the thread is blocked and can not serve
other requests in the meantime).
# Redis Slow Log是一个用于记录超过指定执行时间的查询的系统。执行时间不包括与客户端交谈，发送回复等IO操作，而仅包括实际执行命令所需的时间（这是命令执行的唯一阶段，在该阶段线程被阻塞并且无法服务同时提出其他要求）
You can configure the slow log with two parameters: one tells Redis
what is the execution time, in microseconds, to exceed in order for the
command to get logged, and the other parameter is the length of the
slow log. When a new command is logged the oldest one is removed from the
queue of logged commands.
# 您可以使用以下两个参数配置慢速日志：一个告诉Redis，为了使命令被记录下来，执行时间要超过多少微秒，而另一个参数是慢速日志的长度。记录新命令时，最早的命令将从记录的命令队列中删除
The following time is expressed in microseconds, so 1000000 is equivalent
to one second. Note that a negative number disables the slow log, while
a value of zero forces the logging of every command.
# 时间以微秒为单位，因此1000000等于一秒。请注意，负数将禁用慢速日志记录，而零值将强制记录每个命令
slowlog-log-slower-than 10000

There is no limit to this length. Just be aware that it will consume memory.
You can reclaim memory used by the slow log with SLOWLOG RESET.
slowlog-max-len 128
# 该长度没有限制。请注意，它将消耗内存。您可以使用SLOWLOG RESET回收慢日志使用的内存
```

Slowlog-log-slower-than: 默认值为10000，其中1000000等于1秒（负数将禁用慢速日志记录，而零值将强制记录每个命令）

slowlog-max-len: 日志的长度默认值为128，新日志将追加。就日志将从前删除。

## LATENCY MONITOR

```ini
LATENCY MONITOR 

The Redis latency monitoring subsystem samples different operations
at runtime in order to collect data related to possible sources of
latency of a Redis instance.
# Redis延迟监视子系统在运行时对不同的操作进行采样，以便收集与Redis实例的潜在延迟源相关的数据
Via the LATENCY command this information is available to the user that can
print graphs and obtain reports.
# 通过LATENCY命令，该信息可供打印，获取报告的用户使用
The system only logs operations that were performed in a time equal or
greater than the amount of milliseconds specified via the
latency-monitor-threshold configuration directive. When its value is set
to zero, the latency monitor is turned off.
# 系统仅记录在等于或大于通过delay-monitor-threshold配置指令指定的毫秒量的时间内执行的操作。当其值设置为零时，等待时间监视器将关闭
By default latency monitoring is disabled since it is mostly not needed
if you don't have latency issues, and collecting data has a performance
impact, that while very small, can be measured under big load. Latency
monitoring can easily be enabled at runtime using the command
"CONFIG SET latency-monitor-threshold <milliseconds>" if needed.
# 默认情况下，延迟监视是禁用的，因为如果您没有延迟问题，通常不需要它，并且收集数据会对性能产生影响，尽管影响很小，但是可以在大负载下进行测量。如果需要，可以在运行时使用命令“ CONFIG SET delay-monitor-threshold <milliseconds>”轻松启用延迟监视
latency-monitor-threshold 0
```

## EVENT NOTIFICATION 

```ini
EVENT NOTIFICATION 

Redis can notify Pub/Sub clients about events happening in the key space.
This feature is documented at http://redis.io/topics/notifications
# Redis可以通知PubSub客户端关键空间中发生的事件
For instance if keyspace events notification is enabled, and a client
performs a DEL operation on key "foo" stored in the Database 0, two
messages will be published via Pub/Sub:
# 例如，如果启用了键空间事件通知，并且客户端对存储在数据库0中的键“ foo”执行了DEL操作，则将通过PubSub发布两条消息
PUBLISH __keyspace@0__:foo del
PUBLISH __keyevent@0__:del foo

It is possible to select the events that Redis will notify among a set
of classes. Every class is identified by a single character:
# 可以在一组类中选择Redis将通知的事件。每个类别都由单个字符标识
K     Keyspace events, published with __keyspace@<db>__ prefix.             # 空键事件，以__keyspace @ <db> __前缀发布
E     Keyevent events, published with __keyevent@<db>__ prefix.             # 按键事件，以__keyevent @ <db> __前缀发布
g     Generic commands (non-type specific) like DEL, EXPIRE, RENAME, ...    # 通用命令（非类型专用），例如DEL，EXPIRE，RENAME
$     String commands                                                       # 字符串命令
l     List commands                                                         # 列表命令
s     Set commands                                                          # 集合命令
h     Hash commands                                                         # 哈希命令
z     Sorted set commands                                                   # 有序集合命令
x     Expired events (events generated every time a key expires)            # 过期事件（每次密钥过期时生成的事件）
e     Evicted events (events generated when a key is evicted for maxmemory) # 驱逐事件（将密钥驱逐到最大内存时生成的事件）
t     Stream commands                                                       # 流命令
m     Key-miss events (Note: It is not included in the 'A' class)           # 键丢失事件（注意：它不包含在“ A”类中）
A     Alias for g$lshzxet, so that the "AKE" string means all the events    # glshzxet的别名，因此“ AKE”字符串表示所有事件
    (Except key-miss events which are excluded from 'A' due to their
     unique nature).

The "notify-keyspace-events" takes as argument a string that is composed
of zero or multiple characters. The empty string means that notifications
are disabled.
# “ notify-keyspace-events”将由零个或多个字符组成的字符串作为参数。空字符串表示已禁用通知
Example: to enable list and generic events, from the point of view of the
       event name, use:

notify-keyspace-events Elg

Example 2: to get the stream of the expired keys subscribing to channel
         name __keyevent@0__:expired use:

notify-keyspace-events Ex

By default all notifications are disabled because most users don't need
this feature and the feature has some overhead. Note that if you don't
specify at least one of K or E, no events will be delivered.
notify-keyspace-events ""
# 默认情况下，所有通知都被禁用，因为大多数用户不需要此功能，并且该功能有一些开销。请注意，如果您未指定K或E中的至少一个，则不会传递任何事件。 notify-keyspace-events
```

## GOPHER SERVER

```
GOPHER SERVER 

Redis contains an implementation of the Gopher protocol, as specified in
the RFC 1436 (https://www.ietf.org/rfc/rfc1436.txt).
# Redis包含RFC 1436（https：www.ietf.orgrfcrfc1436.txt）中指定的Gopher协议的实现。
The Gopher protocol was very popular in the late '90s. It is an alternative
to the web, and the implementation both server and client side is so simple
that the Redis server has just 100 lines of code in order to implement this
support.
# Gopher协议在90年代后期非常流行。它是Web的替代方法，服务器和客户端的实现是如此简单，以至于Redis服务器只有100行代码才能实现这种支持
What do you do with Gopher nowadays? Well Gopher never *really* died, and
lately there is a movement in order for the Gopher more hierarchical content
composed of just plain text documents to be resurrected. Some want a simpler
internet, others believe that the mainstream internet became too much
controlled, and it's cool to create an alternative space for people that
want a bit of fresh air.
# 您现在如何使用Gopher？好吧，Gopher从未真正死过，最近出现了一种运动，目的是使Gopher具有更多层次的内容（由纯文本文档组成）得以复活。有些人想要一个更简单的互联网，另一些人则认为主流互联网变得过于受控，为想要一点新鲜空气的人们创造一个替代空间很酷。
Anyway for the 10nth birthday of the Redis, we gave it the Gopher protocol
as a gift.
# 无论如何，在Redis十岁生日的时候，我们给了它Gopher协议作为礼物
--- HOW IT WORKS? ---

The Redis Gopher support uses the inline protocol of Redis, and specifically
two kind of inline requests that were anyway illegal: an empty request
or any request that starts with "/" (there are no Redis commands starting
with such a slash). Normal RESP2/RESP3 requests are completely out of the
path of the Gopher protocol implementation and are served as usual as well.
# Redis Gopher支持使用Redis的内联协议，特别是两种仍然非法的内联请求：空请求或任何以“”开头的请求（没有以这样的斜杠开头的Redis命令）。正常的RESP2RESP3请求完全超出了Gopher协议实现的路径，并且也照常使用
If you open a connection to Redis when Gopher is enabled and send it
a string like "/foo", if there is a key named "/foo" it is served via the
Gopher protocol.
# 如果在启用Gopher时打开与Redis的连接，并向其发送“ foo”之类的字符串，则如果存在名为“ foo”的密钥，则会通过Gopher协议为其提供服务
In order to create a real Gopher "hole" (the name of a Gopher site in Gopher
talking), you likely need a script like the following:

https://github.com/antirez/gopher2redis

--- SECURITY WARNING ---

If you plan to put Redis on the internet in a publicly accessible address
to server Gopher pages MAKE SURE TO SET A PASSWORD to the instance.
Once a password is set:

1. The Gopher server (when enabled, not by default) will still serve
  content via Gopher.
2. However other commands cannot be called before the client will
  authenticate.

So use the 'requirepass' option to protect your instance.

Note that Gopher is not currently supported when 'io-threads-do-reads'
is enabled.

To enable Gopher support, uncomment the following line and set the option
from no (the default) to yes.

gopher-enabled no
```

## ADVANCED CONFIG

```ini
ADVANCED CONFIG 

Hashes are encoded using a memory efficient data structure when they have a
small number of entries, and the biggest entry does not exceed a given
threshold. These thresholds can be configured using the following directives.
# 当哈希条目只有少量条目且最大条目未超过给定阈值时，将使用内存高效的数据结构对其进行编码。可以使用以下指令配置这些阈值
hash-max-ziplist-entries 512
hash-max-ziplist-value 64

Lists are also encoded in a special way to save a lot of space.
The number of entries allowed per internal list node can be specified
as a fixed maximum size or a maximum number of elements.
# 列表也以特殊方式编码，以节省大量空间。每个内部列表节点允许的条目数可以指定为固定的最大大小或最大元素数
For a fixed maximum size, use -5 through -1, meaning:
# 对于固定的最大大小，请使用-5到-1，表示
-5: max size: 64 Kb  <-- not recommended for normal workloads
-4: max size: 32 Kb  <-- not recommended
-3: max size: 16 Kb  <-- probably not recommended
-2: max size: 8 Kb   <-- good
-1: max size: 4 Kb   <-- good
Positive numbers mean store up to _exactly_ that number of elements
per list node.
# 正数表示每个列表节点最多可存储_exactly_个元素
The highest performing option is usually -2 (8 Kb size) or -1 (4 Kb size),
but if your use case is unique, adjust the settings as necessary.
# 最高性能的选项通常是-2（8 Kb大小）或-1（4 Kb大小），但是如果您的用例是唯一的，请根据需要调整设置
list-max-ziplist-size -2

Lists may also be compressed.   # 列表也可以被压缩。
Compress depth is the number of quicklist ziplist nodes from *each* side of
the list to *exclude* from compression.  The head and tail of the list
are always uncompressed for fast push/pop operations.  Settings are:
# 压缩深度是列表的每侧要从压缩中排除的快速列表ziplist节点的数量。列表的开头和结尾始终是未压缩的，以便快速进行pushpop操作。设置是
0: disable all list compression # 禁用所有列表压缩
1: depth 1 means "don't start compressing until after 1 node into the list,
going from either the head or tail" # 深度1表示“直到列表中有1个节点之后，才开始压缩，从头到尾
So: [head]->node->node->...->node->[tail]
[head], [tail] will always be uncompressed; inner nodes will compress.
2: [head]->[next]->node->node->...->node->[prev]->[tail]
2 here means: don't compress head or head->next or tail->prev or tail,
but compress all nodes between them.
3: [head]->[next]->[next]->node->node->...->node->[prev]->[prev]->[tail]
etc.
list-compress-depth 0

Sets have a special encoding in just one case: when a set is composed
of just strings that happen to be integers in radix 10 in the range
of 64 bit signed integers.
The following configuration setting sets the limit in the size of the
set in order to use this special memory saving encoding.
# 在仅一种情况下，集合具有特殊的编码：当集合仅由恰好是基数10中整数（在64位有符号整数范围内）的字符串组成时。以下配置设置设置了大小限制，以便使用此特殊的内存节省编码
set-max-intset-entries 512

Similarly to hashes and lists, sorted sets are also specially encoded in
order to save a lot of space. This encoding is only used when the length and
elements of a sorted set are below the following limits:
# 与哈希表和列表类似，对排序集也进行了特殊编码，以节省大量空间。仅当排序集的长度和元素低于以下限制时，才使用此编码
zset-max-ziplist-entries 128
zset-max-ziplist-value 64

HyperLogLog sparse representation bytes limit. The limit includes the
16 bytes header. When an HyperLogLog using the sparse representation crosses
this limit, it is converted into the dense representation.
# HyperLogLog稀疏表示形式的字节数限制。限制包括16个字节的标头。当使用稀疏表示的HyperLogLog超过此限制时，它将转换为密集表示
A value greater than 16000 is totally useless, since at that point the
dense representation is more memory efficient.
# 大于16000的值是完全没有用的，因为在那一点上，密集表示的存储效率更高
The suggested value is ~ 3000 in order to have the benefits of
the space efficient encoding without slowing down too much PFADD,
which is O(N) with the sparse encoding. The value can be raised to
~ 10000 when CPU is not a concern, but space is, and the data set is
composed of many HyperLogLogs with cardinality in the 0 - 15000 range.
# 建议值约为3000，以便在不减慢过多PFADD的情况下获得节省空间编码的好处，而PFADD的稀疏编码为O（N）。当不关心CPU但有空间时，该值可以提高到10000，并且数据集由基数在0-15000范围内的许多HyperLogLog组成
hll-sparse-max-bytes 3000

Streams macro node max size / items. The stream data structure is a radix
tree of big nodes that encode multiple items inside. Using this configuration
it is possible to configure how big a single node can be in bytes, and the
maximum number of items it may contain before switching to a new node when
appending new stream entries. If any of the following settings are set to
zero, the limit is ignored, so for instance it is possible to set just a
max entires limit by setting max-bytes to 0 and max-entries to the desired
value.
# 流宏节点最大大小的项目。流数据结构是一个大节点的基数树，它对内部的多个项目进行编码。使用此配置，可以配置单个节点的大小（以字节为单位），以及在添加新的流条目时切换到新节点之前它可能包含的最大项目数。如果以下任何设置被设置为零，则该限制将被忽略，例如，可以通过将max-bytes设置为0并将max-entries设置为所需的值来仅设置最大整数限制
stream-node-max-bytes 4096
stream-node-max-entries 100

Active rehashing uses 1 millisecond every 100 milliseconds of CPU time in
order to help rehashing the main Redis hash table (the one mapping top-level
keys to values). The hash table implementation Redis uses (see dict.c)
performs a lazy rehashing: the more operation you run into a hash table
that is rehashing, the more rehashing "steps" are performed, so if the
server is idle the rehashing is never complete and some more memory is used
by the hash table.
# 活动重新哈希处理每100毫秒CPU时间使用1毫秒，以帮助重新哈希主Redis哈希表（将顶级键映射到值的一个哈希表）。 Redis使用的哈希表实现（请参阅dict.c）执行一次懒惰的重新哈希处理：您在要进行哈希处理的哈希表中运行的操作越多，执行的哈希处理“步骤”就越多，因此，如果服务器空闲，则哈希处理将永远不会完成哈希表使用了更多的内存
The default is to use this millisecond 10 times every second in order to
actively rehash the main dictionaries, freeing memory when possible.
# 默认值是每秒使用10毫秒的毫秒数来主动重新哈希主字典，并在可能的情况下释放内存
If unsure:
use "activerehashing no" if you have hard latency requirements and it is
not a good thing in your environment that Redis can reply from time to time
to queries with 2 milliseconds delay.
# 如果不确定：如果您有严格的延迟要求，则使用“ activehashing no”，并且在您的环境中，Redis可以不时地以2毫秒的延迟答复查询不是一件好事

use "activerehashing yes" if you don't have such hard requirements but
want to free memory asap when possible.
# 如果您没有如此严格的要求，但想在可能的情况下尽快释放内存，请使用“ activerehashing yes”
activerehashing yes

The client output buffer limits can be used to force disconnection of clients
that are not reading data from the server fast enough for some reason (a
common reason is that a Pub/Sub client can't consume messages as fast as the
publisher can produce them).
# 客户端输出缓冲区限制可用于出于某些原因强制断开那些没有足够快地从服务器读取数据的客户端（常见原因是PubSub客户端不能像发布者产生消息那样快地消耗消息）
The limit can be set differently for the three different classes of clients:
# 可以为三种不同类别的客户设置不同的限制
normal -> normal clients including MONITOR clients  # 普通客户，包括MONITOR客户
replica  -> replica clients                         # 复制客户端
pubsub -> clients subscribed to at least one pubsub channel or pattern  # 客户订阅了至少一个pubsub频道或模式

The syntax of every client-output-buffer-limit directive is the following:
# 每个client-output-buffer-limit指令的语法如下
client-output-buffer-limit <class> <hard limit> <soft limit> <soft seconds>

A client is immediately disconnected once the hard limit is reached, or if
the soft limit is reached and remains reached for the specified number of
seconds (continuously).
So for instance if the hard limit is 32 megabytes and the soft limit is
16 megabytes / 10 seconds, the client will get disconnected immediately
if the size of the output buffers reach 32 megabytes, but will also get
disconnected if the client reaches 16 megabytes and continuously overcomes
the limit for 10 seconds.
# 一旦达到硬限制，或者达到软限制并在指定的秒数内（连续）保持达到此限制，客户端将立即断开连接。因此，例如，如果硬限制为32兆字节，软限制为16兆字节10秒，则如果输出缓冲区的大小达到32兆字节，客户端将立即断开连接，但是如果客户端达到16兆字节并连续不断，连接也会断开连接超过极限10秒
By default normal clients are not limited because they don't receive data
without asking (in a push way), but just after a request, so only
asynchronous clients may create a scenario where data is requested faster
than it can read.
# 默认情况下，普通客户端不受限制，因为它们不会在不询问的情况下（以推送方式）接收数据，而是在请求之后才接收数据，因此，只有异步客户端才可能创建这样的场景：请求数据的速度比读取数据的速度快
Instead there is a default limit for pubsub and replica clients, since
subscribers and replicas receive data in a push fashion.
# 而是对pubsub和副本客户端有默认限制，因为订阅者和副本以推送方式接收数据
Both the hard or the soft limit can be disabled by setting them to zero.
# 硬限制或软限制都可以通过将其设置为零来禁用
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60

Client query buffers accumulate new commands. They are limited to a fixed
amount by default in order to avoid that a protocol desynchronization (for
instance due to a bug in the client) will lead to unbound memory usage in
the query buffer. However you can configure it here if you have very special
needs, such us huge multi/exec requests or alike.
# 客户端查询缓冲区会累积新命令。默认情况下，它们被限制为固定数量，以避免协议不同步（例如，由于客户端中的错误）将导致查询缓冲区中的未绑定内存使用。但是，如果您有非常特殊的需求（例如我们巨大的multiexec请求等），则可以在此处进行配置。
client-query-buffer-limit 1gb

In the Redis protocol, bulk requests, that are, elements representing single
strings, are normally limited to 512 mb. However you can change this limit
here, but must be 1mb or greater
# 在Redis协议中，批量请求（即表示单个字符串的元素）通常限制为512 mb。但是，您可以在此处更改此限制，但必须为1mb或更大
proto-max-bulk-len 512mb

Redis calls an internal function to perform many background tasks, like
closing connections of clients in timeout, purging expired keys that are
never requested, and so forth.
# Redis调用内部函数来执行许多后台任务，例如在超时时关闭客户端连接，清除从未请求的过期密钥等
Not all tasks are performed with the same frequency, but Redis checks for
tasks to perform according to the specified "hz" value.
# 并非所有任务都以相同的频率执行，但是Redis会根据指定的“ hz”值检查要执行的任务
By default "hz" is set to 10. Raising the value will use more CPU when
Redis is idle, but at the same time will make Redis more responsive when
there are many keys expiring at the same time, and timeouts may be
handled with more precision.
# 默认情况下，“ hz”设置为10。提高该值将在Redis空闲时使用更多的CPU，但是同时当有多个键同时到期时，它将使Redis的响应速度更快，并且可以使用更多的超时来处理精确
The range is between 1 and 500, however a value over 100 is usually not
a good idea. Most users should use the default of 10 and raise this up to
100 only in environments where very low latency is required.
# 范围在1到500之间，但是值通常不超过100。大多数用户应该使用默认值10，并且仅在要求非常低延迟的环境中才将其提高到100
hz 10

Normally it is useful to have an HZ value which is proportional to the
number of clients connected. This is useful in order, for instance, to
avoid too many clients are processed for each background task invocation
in order to avoid latency spikes.
# 通常，具有与连接的客户端数量成比例的HZ值很有用。例如，这有助于避免每次后台任务调用处理过多的客户端，从而避免延迟高峰
Since the default HZ value by default is conservatively set to 10, Redis
offers, and enables by default, the ability to use an adaptive HZ value
which will temporarily raise when there are many connected clients.
# 由于默认的默认HZ值保守地设置为10，因此Redis提供并默认启用了使用自适应HZ值的能力，当有许多连接的客户端时，该值会暂时升高
When dynamic HZ is enabled, the actual configured HZ will be used
as a baseline, but multiples of the configured HZ value will be actually
used as needed once more clients are connected. In this way an idle
instance will use very little CPU time while a busy instance will be
more responsive.
# 启用动态HZ后，实际配置的HZ将用作基准，但是一旦连接了更多客户端，实际将使用配置的HZ值的倍数。这样，空闲实例将占用很少的CPU时间，而忙碌的实例将具有更快的响应能力
dynamic-hz yes

When a child rewrites the AOF file, if the following option is enabled
the file will be fsync-ed every 32 MB of data generated. This is useful
in order to commit the file to the disk more incrementally and avoid
big latency spikes.
# 当孩子重写AOF文件时，如果启用了以下选项，则每生成32 MB的数据，文件就会进行同步处理。这对于将文件更多地提交到磁盘并避免大的延迟峰值很有用。
aof-rewrite-incremental-fsync yes

When redis saves RDB file, if the following option is enabled
the file will be fsync-ed every 32 MB of data generated. This is useful
in order to commit the file to the disk more incrementally and avoid
big latency spikes.
# 当redis保存RDB文件时，如果启用以下选项，则每生成32 MB数据将对文件进行fsync处理。这对于将文件更多地提交到磁盘并避免大的延迟峰值很有用。
rdb-save-incremental-fsync yes

Redis LFU eviction (see maxmemory setting) can be tuned. However it is a good
idea to start with the default settings and only change them after investigating
how to improve the performances and how the keys LFU change over time, which
is possible to inspect via the OBJECT FREQ command.
# 可以调整Redis LFU逐出（请参阅maxmemory设置）。但是，最好从默认设置开始，仅在研究了如何提高性能以及LFU密钥随时间变化后才进行更改，可以通过OBJECT FREQ命令进行检查。
There are two tunable parameters in the Redis LFU implementation: the
counter logarithm factor and the counter decay time. It is important to
understand what the two parameters mean before changing them.
# Redis LFU实现中有两个可调参数：计数器对数因子和计数器衰减时间。重要的是在更改它们之前了解两个参数的含义
The LFU counter is just 8 bits per key, it's maximum value is 255, so Redis
uses a probabilistic increment with logarithmic behavior. Given the value
of the old counter, when a key is accessed, the counter is incremented in
this way:
# LFU计数器每个密钥只有8位，最大值是255，因此Redis使用具有对数行为的概率增量。给定旧计数器的值，当访问键时，计数器以这种方式递增
1. A random number R between 0 and 1 is extracted.
2. A probability P is calculated as 1/(old_value*lfu_log_factor+1).
3. The counter is incremented only if R < P.

The default lfu-log-factor is 10. This is a table of how the frequency
counter changes with a different number of accesses with different
logarithmic factors:

+--------+------------+------------+------------+------------+------------+
| factor | 100 hits   | 1000 hits  | 100K hits  | 1M hits    | 10M hits   |
+--------+------------+------------+------------+------------+------------+
| 0      | 104        | 255        | 255        | 255        | 255        |
+--------+------------+------------+------------+------------+------------+
| 1      | 18         | 49         | 255        | 255        | 255        |
+--------+------------+------------+------------+------------+------------+
| 10     | 10         | 18         | 142        | 255        | 255        |
+--------+------------+------------+------------+------------+------------+
| 100    | 8          | 11         | 49         | 143        | 255        |
+--------+------------+------------+------------+------------+------------+

NOTE: The above table was obtained by running the following commands:

redis-benchmark -n 1000000 incr foo
redis-cli object freq foo

NOTE 2: The counter initial value is 5 in order to give new objects a chance
to accumulate hits.

The counter decay time is the time, in minutes, that must elapse in order
for the key counter to be divided by two (or decremented if it has a value
less <= 10).

The default value for the lfu-decay-time is 1. A special value of 0 means to
decay the counter every time it happens to be scanned.

lfu-log-factor 10
lfu-decay-time 1
```

## ACTIVE DEFRAGMENTATION

```ini
ACTIVE DEFRAGMENTATION 

What is active defragmentation?
-------------------------------

Active (online) defragmentation allows a Redis server to compact the
spaces left between small allocations and deallocations of data in memory,
thus allowing to reclaim back memory.
# 通过主动（在线）碎片整理，Redis服务器可以压缩内存中小量分配和释放数据之间剩余的空间，从而允许回收内存
Fragmentation is a natural process that happens with every allocator (but
less so with Jemalloc, fortunately) and certain workloads. Normally a server
restart is needed in order to lower the fragmentation, or at least to flush
away all the data and create it again. However thanks to this feature
implemented by Oran Agra for Redis 4.0 this process can happen at runtime
in a "hot" way, while the server is running.
# 碎片是每个分配器（幸运的是，Jemalloc发生的情况）和某些工作负载都会发生的自然过程。通常，需要重新启动服务器以减少碎片，或者至少清除所有数据并重新创建。但是，由于Oran Agra为Redis 4.0实现了此功能，因此在服务器运行时，此过程可以在运行时以“热”方式进行
Basically when the fragmentation is over a certain level (see the
configuration options below) Redis will start to create new copies of the
values in contiguous memory regions by exploiting certain specific Jemalloc
features (in order to understand if an allocation is causing fragmentation
and to allocate it in a better place), and at the same time, will release the
old copies of the data. This process, repeated incrementally for all the keys
will cause the fragmentation to drop back to normal values.
# 基本上，当碎片超过一定级别时（请参阅下面的配置选项），Redis将开始通过利用某些特定的Jemalloc功能在连续的内存区域中创建值的新副本（以便了解分配是否导致碎片并进行分配更好的位置），同时将释放数据的旧副本。对于所有键，以增量方式重复此过程将导致碎片恢复到正常值
Important things to understand:

1. This feature is disabled by default, and only works if you compiled Redis
to use the copy of Jemalloc we ship with the source code of Redis.
This is the default with Linux builds.
# 默认情况下，此功能是禁用的，并且仅当您编译Redis以使用我们随Redis的源代码提供的Jemalloc副本时才可用。这是Linux构建的默认设置
2. You never need to enable this feature if you don't have fragmentation
issues.
# 如果没有碎片问题，则无需启用此功能
3. Once you experience fragmentation, you can enable this feature when
needed with the command "CONFIG SET activedefrag yes".
# 遇到碎片之后，可以在需要时使用命令“ CONFIG SET activedefrag yes”启用此功能。
The configuration parameters are able to fine tune the behavior of the
defragmentation process. If you are not sure about what they mean it is
a good idea to leave the defaults untouched.
# 配置参数能够微调碎片整理过程的行为。如果您不确定它们的含义，最好不要更改默认值
Enabled active defragmentation
activedefrag no

Minimum amount of fragmentation waste to start active defrag
# 启动主动碎片整理的最小碎片废物量
active-defrag-ignore-bytes 100mb

Minimum percentage of fragmentation to start active defrag
# 启动主动碎片整理的最小碎片百分比
active-defrag-threshold-lower 10

Maximum percentage of fragmentation at which we use maximum effort
# 我们在最大程度地使用碎片的最大百分比
active-defrag-threshold-upper 100

Minimal effort for defrag in CPU percentage, to be used when the lower
threshold is reached
# 达到下限阈值时使用的最小的CPU碎片整理工作
active-defrag-cycle-min 1

Maximal effort for defrag in CPU percentage, to be used when the upper
threshold is reached
# 达到上限时使用的最大的CPU碎片整理工作
active-defrag-cycle-max 25

Maximum number of set/hash/zset/list fields that will be processed from
the main dictionary scan
# 主字典扫描将处理的sethashzsetlist字段的最大数目
active-defrag-max-scan-fields 1000

Jemalloc background thread for purging will be enabled by default
# 默认情况下，将启用用于清除的Jemalloc后台线程
jemalloc-bg-thread yes

It is possible to pin different threads and processes of Redis to specific
CPUs in your system, in order to maximize the performances of the server.
This is useful both in order to pin different Redis threads in different
CPUs, but also in order to make sure that multiple Redis instances running
in the same host will be pinned to different CPUs.
# 可以将Redis的不同线程和进程固定到系统中的特定CPU，以最大化服务器的性能。这不仅有助于将不同的Redis线程固定在不同的CPU中，而且还可以确保将在同一主机中运行的多个Redis实例固定到不同的CPU。

Normally you can do this using the "taskset" command, however it is also
possible to this via Redis configuration directly, both in Linux and FreeBSD.
# 通常，您可以使用“ taskset”命令来执行此操作，但是在Linux和FreeBSD中，也可以直接通过Redis配置来执行此操作
You can pin the server/IO threads, bio threads, aof rewrite child process, and
the bgsave child process. The syntax to specify the cpu list is the same as
the taskset command:
# 您可以固定serverIO线程，bio线程，aof重写子进程和bgsave子进程。指定cpu列表的语法与taskset命令相同
Set redis server/io threads to cpu affinity 0,2,4,6:
server_cpulist 0-7:2

Set bio threads to cpu affinity 1,3:
# 将生物线程设置为cpu亲和力1,3
bio_cpulist 1,3

Set aof rewrite child process to cpu affinity 8,9,10,11:
# 将aof重写子进程设置为cpu亲和力8,9,10,11
aof_rewrite_cpulist 8-11

Set bgsave child process to cpu affinity 1,10,11
# 将bgsave子进程设置为cpu亲和力1,10,11
bgsave_cpulist 1,10-11

```

基本上，当碎片超过一定级别时（请参阅下面的配置选项），Redis将开始通过利用某些特定的Jemalloc功能在连续的内存区域中创建值的新副本（以便了解分配是否导致碎片并进行分配更好的位置），同时将释放数据的旧副本。对于所有键，以增量方式重复此过程将导致碎片恢复到正常值，默认情况下，此功能是禁用的，并且仅当您编译Redis以使用我们随Redis的源代码提供的Jemalloc副本时才可用。这是Linux构建的默认设置。如果没有碎片问题，则无需启用此功能

遇到碎片之后，可以在需要时使用命令“ CONFIG SET activedefrag yes”启用此功能。

Activedefrag 配置参数能够微调碎片整理过程的行为，默认为No
active-defrag-ignore-bytes 启动主动碎片整理的最小碎片废物量默认100mb
active-defrag-threshold-lower: 启动主动碎片整理的最小碎片百分比，默认10
active-defrag-cycle-min：达到下限阈值时使用的最小的CPU碎片整理工作，默认1
active-defrag-cycle-max：达到上限时使用的最大的CPU碎片整理工作，默认25
active-defrag-max-scan-fields 主字典扫描将处理的sethashzsetlist字段的最大数目，默认1000
active-defrag-cycle-min：达到下限阈值时使用的最小的CPU碎片整理工作，默认1x