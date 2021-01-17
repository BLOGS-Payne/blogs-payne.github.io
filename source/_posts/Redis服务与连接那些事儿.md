---
title: Redis服务与连接那些事儿
author: Payne
tags: ["NoSQL", "Redis","数据库"]
categories:
  - ["Redis", "NoSQL","数据库"]
date: 2021-01-18 01:28:06
---


## 启动示例

当我们需要使用Redis的时候需要把redis的服务开启。如下

```sh
# 启动
redis-server
# 守护进程方式启动
redis-server &
# 使用自定义redis.conf启动
redis-server path
```
<!--more-->
`redis-server`如图

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmoqnuejzfj31so0mitc6.jpg)

这样虽然是启动了，但是这个终端却用不了了，我个人并不是很喜欢。那么有没有可以让他既可以运行，而且保证不会占用我们的终端呢

这里有两种方法

- 使用`redis-server &`明显启动示例即可

- redis-server ----daemonize yes (以守护进程的方式运行redis)

  ![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmpopzvxl4j30s40cq0u4.jpg)

> 小技巧：
>
> redis-server --配置名 配置的值
>
> 例如：redis-server --port 8765 此时你就可以在你的8765端口上运行redis
>
> 这样就可以无需修改redis.conf,就可以定制化的运行redis

### Redis.conf

既然看过redis的配置文档，不自己亲手试一试怎么能行。话不多说直接开干。以下为给出最基本的的redis.conf，当然如果有需要也按需添加一些。

```
mkdir /database/6379
cat > /database/6379/redis.conf<<EOF
daemonize yes
port 6379
logfile /database/6379/redis.log
dir /database/6379
dbfilename dump.rdb
EOF
```

> 守护进程(后台)运行:daemonize yes
> 配置端口号 port 6379
> 配置日志 logfile /database/6379/redis.log
> 持久化文件存储位置 dir /database/6379
> RDB持久化数据文件 dbfilename dump.rdb

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmppbthbjgj31c80kktbr.jpg)

以上就已经完成了redis服务启动的部分，那么我们接下来看看redis的连接部分

## 连接

```sh
# 本地连接
redis-cli	# 相当于 redis-cli -h 127.0.0.1 -p 6379

# 远程连接
redis-cli -h host -p port -a passwd
```

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmq0bbke7zj30e0044745.jpg)

如图：出现此“unicode”编码显示问题，改如何解决？

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmq0dsx7o1j30zw06adft.jpg)

本地连接直接使用`redis-cli`，直接在本地连接即可。此过不多赘述

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmq0glrkj0j31pc07udgu.jpg)

> DENIED Redis is running in protected mode because protected mode is enabled, no bind address was specified, no authentication password is requested to clients. In this mode connections are only accepted from the loopback interface. If you want to connect from external computers to Redis you may adopt one of the following solutions: 
> 1) Just disable protected mode sending the command 'CONFIG SET protected-mode no' from the loopback interface by connecting to Redis from the same host the server is running, however MAKE SURE Redis is not publicly accessible from internet if you do so. Use CONFIG REWRITE to make this change permanent. 
> 2) Alternatively you can just disable the protected mode by editing the Redis configuration file, and setting the protected mode option to 'no', and then restarting the server. 
> 3) If you started the server manually just for testing, restart it with the '--protected-mode no' option. 
> 4) Setup a bind address or an authentication password. NOTE: You only need to do one of the above things in order for the server to start accepting connections from the outside.
>
> 译文：DENIED Redis正在保护模式下运行，因为已启用保护模式、未指定绑定地址、未向客户端请求身份验证密码。在这种模式下，只接受来自环回接口的连接。如果您想从外部计算机连接到Redis
>
> 只需通过从服务器运行的同一主机连接到Redis，从环回接口发送命令'CONFIG SET protected mode no'来禁用保护模式，但是如果这样做，请确保Redis不能从internet公开访问。使用CONFIG REWRITE将此更改永久化
>
> 您可以通过编辑Redis配置文件，将protectedmode选项设置为no，然后重新启动服务器来禁用protectedmode。
>
> 如果只是为了测试而手动启动服务器，请使用“-protected mode no”选项重新启动服务器
>
> 设置绑定地址或身份验证密码。
>
> 服务器就可以开始接受来自外部的连接。

那么从以上得知，redis是默认关闭远程连接以及开启保护模式。开启远程连接的方式有以下几种

1. 在本地(打开redis服务)的机器，采用回环地址连接(即是127.0.0.1)，连接redis，后使用`CONFIG SET protected mode no`就可以允许远程连接(推荐)，使用CONFIG REWRITE将此更改永久化
2. 在配置文件中关闭保护模式`protected mode no`,重启redis服务(不推荐)
3. 关闭redis服务，使用`redis-server -protected mode no`，启动服务
4. 配置ip访问或密码(最推荐)

综上，我们来配置一下我们的`redis.conf`，如下

```
daemonize yes
port 6379
logfile /database/6379/redis.log
dir /database/6379
dbfilename dump.rdb
requirepass 123321
```



## 性能测试

说到性能与测试这两个都是，大家一直关心的问题。那么redis的性能测试该怎么做呢。咋这里我们了解一下`redis-brnchmark`

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmq49jlh69j31ao0nmjw9.jpg)

具体参数如下

```sh
Usage: redis-benchmark [-h <host>] [-p <port>] [-c <clients>] [-n <requests>] [-k <boolean>]

 -h <hostname>      Server hostname (default 127.0.0.1)
 -p <port>          Server port (default 6379)
 -s <socket>        Server socket (overrides host and port)
 -a <password>      Password for Redis Auth
 --user <username>  Used to send ACL style 'AUTH username pass'. Needs -a.
 -c <clients>       Number of parallel connections (default 50)
 -n <requests>      Total number of requests (default 100000)
 -d <size>          Data size of SET/GET value in bytes (default 3)
 --dbnum <db>       SELECT the specified db number (default 0)
 --threads <num>    Enable multi-thread mode.
 --cluster          Enable cluster mode.
 --enable-tracking  Send CLIENT TRACKING on before starting benchmark.
 -k <boolean>       1=keep alive 0=reconnect (default 1)
 -r <keyspacelen>   Use random keys for SET/GET/INCR, random values for SADD,
                    random members and scores for ZADD.
  Using this option the benchmark will expand the string __rand_int__
  inside an argument with a 12 digits number in the specified range
  from 0 to keyspacelen-1. The substitution changes every time a command
  is executed. Default tests use this to hit random keys in the
  specified range.
 -P <numreq>        Pipeline <numreq> requests. Default 1 (no pipeline).
 -e                 If server replies with errors, show them on stdout.
                    (no more than 1 error per second is displayed)
 -q                 Quiet. Just show query/sec values
 --precision        Number of decimal places to display in latency output (default 0)
 --csv              Output in CSV format
 -l                 Loop. Run the tests forever
 -t <tests>         Only run the comma separated list of tests. The test
                    names are the same as the ones produced as output.
 -I                 Idle mode. Just open N idle connections and wait.

Examples:

 Run the benchmark with the default configuration against 127.0.0.1:6379:
   $ redis-benchmark

 Use 20 parallel clients, for a total of 100k requests, against 192.168.1.1:
   $ redis-benchmark -h 192.168.1.1 -p 6379 -n 100000 -c 20

 Fill 127.0.0.1:6379 with about 1 million keys only using the SET test:
   $ redis-benchmark -t set -n 1000000 -r 100000000

 Benchmark 127.0.0.1:6379 for a few commands producing CSV output:
   $ redis-benchmark -t ping,set,get -n 100000 --csv

 Benchmark a specific command line:
   $ redis-benchmark -r 10000 -n 10000 eval 'return redis.call("ping")' 0

 Fill a list with 10000 random elements:
   $ redis-benchmark -r 10000 -n 10000 lpush mylist __rand_int__

 On user specified command lines __rand_int__ is replaced with a random integer
 with a range of values selected by the -r option.

```

## 在线修改配置

```sh
CONFIG GET	*(配置名，例如daemonize，protected-mode等)				# 查看配置
CONFIG RESETSTAT	# 命令用于重置 INFO 命令中的某些统计数据
CONFIG REWRITE		# 将修改的设置回写配置文件
CONFIG SET			  # 设置参数
```

```sh
CONFIG GET	*
# 输出结果如下
  1) "rdbchecksum"                                                                                                           
  2) "yes"                                                                                                                   
  3) "daemonize"                                                                                                             
  4) "yes"                                                                                                                   
  5) "io-threads-do-reads"                                                                                                   
  6) "no"                                                                                                                    
  7) "lua-replicate-commands"                                                                                                
  8) "yes"                                                                                                                   
  9) "always-show-logo"                                                                                                      
 10) "no"                                                                                                                    
 11) "protected-mode"                                                                                                        
 12) "yes"                                                                                                                   
 13) "rdbcompression"                                                                                                        
 14) "yes"                                                                                                                   
 15) "rdb-del-sync-files"                                                                                                    
 16) "no"                                                                                                                    
 17) "activerehashing"                                                                                                       
 18) "yes"                                                                                                                   
 19) "stop-writes-on-bgsave-error"                                                                                           
 20) "yes"                                                                                                                   
 21) "dynamic-hz"                                                                                                            
 22) "yes"                                                                                                                   
 23) "lazyfree-lazy-eviction"                                                                                                
 24) "no"                                                                                                                    
 25) "lazyfree-lazy-expire"                                                                                                  
 26) "no"                                                                                                                    
 27) "lazyfree-lazy-server-del"                                                                                              
 28) "no"                                                                                                                    
 29) "lazyfree-lazy-user-del"                                                                                                
 30) "no"                                                                                                                    
 31) "repl-disable-tcp-nodelay"                                                                                              
 32) "no"                                                                                                                    
 33) "repl-diskless-sync"                                                                                                    
 34) "no"                                                                                                                    
 35) "gopher-enabled"                                                                                                        
 36) "no"                                                                                                                    
 37) "aof-rewrite-incremental-fsync"
 38) "yes"
 39) "no-appendfsync-on-rewrite"
 40) "no"
 41) "cluster-require-full-coverage"
 42) "yes"
 43) "rdb-save-incremental-fsync"
 44) "yes"
 45) "aof-load-truncated"
 46) "yes"
 47) "aof-use-rdb-preamble"
 48) "yes"
 49) "cluster-replica-no-failover"
 50) "no"
 51) "cluster-slave-no-failover"
 52) "no"
 53) "replica-lazy-flush"
 54) "no"
 55) "slave-lazy-flush"
 56) "no"
 57) "replica-serve-stale-data"
 58) "yes"
 59) "slave-serve-stale-data"
 60) "yes"
 61) "replica-read-only"
 62) "yes"
 63) "slave-read-only"
 64) "yes"
 65) "replica-ignore-maxmemory"
 66) "yes"
 67) "slave-ignore-maxmemory"
 68) "yes"
 69) "jemalloc-bg-thread"
 70) "yes"
 71) "activedefrag"
 72) "no"
 73) "syslog-enabled"
 74) "no"
 75) "cluster-enabled"
 76) "no"
 77) "appendonly"
 78) "no"
 79) "cluster-allow-reads-when-down"
 80) "no"
 81) "aclfile"
 82) ""
 83) "unixsocket"
 84) ""
 85) "pidfile"
 86) "/var/run/redis.pid"
 87) "replica-announce-ip"
 88) ""
 89) "slave-announce-ip"
 90) ""
 91) "masteruser"
 92) ""
 93) "masterauth"
 94) ""
 95) "cluster-announce-ip"
 96) ""
 97) "syslog-ident"
 98) "redis"
 99) "dbfilename"
100) "dump.rdb"
101) "appendfilename"
102) "appendonly.aof"
103) "server_cpulist"
104) ""
105) "bio_cpulist"
106) ""
107) "aof_rewrite_cpulist"
108) ""
109) "bgsave_cpulist"
110) ""
111) "ignore-warnings"
112) "ARM64-COW-BUG"
113) "supervised"
114) "no"
115) "syslog-facility"
116) "local0"
117) "repl-diskless-load"
118) "disabled"
119) "loglevel"
120) "notice"
121) "maxmemory-policy"
122) "noeviction"
123) "appendfsync"
124) "everysec"
125) "oom-score-adj"
126) "no"
127) "databases"
128) "16"
129) "port"
130) "6379"
131) "io-threads"
132) "1"
133) "auto-aof-rewrite-percentage"
134) "100"
135) "cluster-replica-validity-factor"
136) "10"
137) "cluster-slave-validity-factor"
138) "10"
139) "list-max-ziplist-size"
140) "-2"
141) "tcp-keepalive"
142) "300"
143) "cluster-migration-barrier"
144) "1"
145) "active-defrag-cycle-min"
146) "1"
147) "active-defrag-cycle-max"
148) "25"
149) "active-defrag-threshold-lower"
150) "10"
151) "active-defrag-threshold-upper"
152) "100"
153) "lfu-log-factor"
154) "10"
155) "lfu-decay-time"
156) "1"
157) "replica-priority"
158) "100"
159) "slave-priority"
160) "100"
161) "repl-diskless-sync-delay"
162) "5"
163) "maxmemory-samples"
164) "5"
165) "timeout"
166) "0"
167) "replica-announce-port"
168) "0"
169) "slave-announce-port"
170) "0"
171) "tcp-backlog"
172) "511"
173) "cluster-announce-bus-port"
174) "0"
175) "cluster-announce-port"
176) "0"
177) "repl-timeout"
178) "60"
179) "repl-ping-replica-period"
180) "10"
181) "repl-ping-slave-period"
182) "10"
183) "list-compress-depth"
184) "0"
185) "rdb-key-save-delay"
186) "0"
187) "key-load-delay"
188) "0"
189) "active-expire-effort"
190) "1"
191) "hz"
192) "10"
193) "min-replicas-to-write"
194) "0"
195) "min-slaves-to-write"
196) "0"
197) "min-replicas-max-lag"
198) "10"
199) "min-slaves-max-lag"
200) "10"
201) "maxclients"
202) "10000"
203) "active-defrag-max-scan-fields"
204) "1000"
205) "slowlog-max-len"
206) "128"
207) "acllog-max-len"
208) "128"
209) "lua-time-limit"
210) "5000"
211) "cluster-node-timeout"
212) "15000"
213) "slowlog-log-slower-than"
214) "10000"
215) "latency-monitor-threshold"
216) "0"
217) "proto-max-bulk-len"
218) "536870912"
219) "stream-node-max-entries"
220) "100"
221) "repl-backlog-size"
222) "1048576"
223) "maxmemory"
224) "0"
225) "hash-max-ziplist-entries"
226) "512"
227) "set-max-intset-entries"
228) "512"
```

> 小技巧：
>
> config get 支持模糊匹配，例如包含所有re开头的配置名，`config get re*`,
>
> 所有配置名包含`re`的配置，可以使用`config get *re*`

### 在线修改密码

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmqn2c3zruj31e00943zd.jpg)

原本的密码是`123321`,这里我们将它修改为`123123123`,再一次去连接它。发现此时的密码已经修改

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmqn3y1i0ej30wy0agdgx.jpg)



