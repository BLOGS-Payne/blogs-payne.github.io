---
title: 'sql,何必在忆-基础篇'
author: Payne
tags: ["MySQL", "数据库"]
categories:
  - ["数据库", "MySQL"]
date: 2021-01-11 16:21:48
---
还记得那是在2018年的十月的某个日子，虽早已入秋，但夏日的炎热却丝毫不减退散。那时的我正捧着一本`SQL Server程序设计`的白蓝皮书与九栋315的狗子们，匆匆的走向`j1-402`进行了我们人生中第一次`SQL数据库的学习`，时光总是戏人，现实总是玩笑。当初的几个伙伴都走向了各行各业，而唯有我编程课，问啥啥不会，写啥啥就废的我进入了IT行业。说来实在嘲讽，缅怀那些我错过的编程课，致那些年说过无数次“让我学`SQL`,根本不可能”，我承认我打脸了。正如此章的title一般，“SQL语句， 何必在忆？”

很久之前就学了SQL，然而又忘记，今天正式系统的性的回顾一下，温故而知新。可以为师矣
<!--more-->
## 表属性

### 表的属性

```sh
存储引擎:
InnoDB（默认的）
字符集和排序规则:
utf8
utf8mb4
```

### 列的属性

```sh
约束(一般建表时添加):
primary key ：主键约束
设置为主键的列，此列的值必须非空且唯一，主键在一个表中只能有一个，但是可以有多个列一起构成。 作为聚簇索引
not null      ：非空约束
列值不能为空，也是表设计的规范，尽可能将所有的列设置为非空。可以设置默认值为0
unique key ：唯一键
列值不能重复
unsigned ：无符号
针对数字列，非负数。

其他属性:
key :索引
可以在某列上建立索引，来优化查询,一般是根据需要后添加
default           :默认值
列中，没有录入值时，会自动使用default的值填充
auto_increment:自增长
针对数字列，顺序的自动填充数据（默认是从1开始，将来可以设定起始点和偏移量）
comment : 注释
```

### sql_mode

作用：影响sql执行行为，规范SQL语句的书写方式(例如除数不能为0)

可以使用select @sql_mode查看(各版本有所出入)

### 字符集(charset)及校对规则(Collation)

#### 字符集：

- utf8：最大存储长度，单个字符最多3字节
- utf8mb4：最大存储长度，单个字符最多4字节

常用于建库建表时

```
create database dbname charset utf8mb4;
# 查看数据库的字符集合
show create database dbname;
```

#### 校对规则

每种字符集，有多种校对规则(排序)，例如常见的ASCII编码表

```
show collation;
```

作用：影响排序的操作

### 数据类型

#### text类型

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gmd63x1tzoj311o0u0go0.jpg)

#### Number类型

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gmd64lw40rj313c0kegn5.jpg)

`*`:这些整数类型拥有额外的选项 UNSIGNED。通常，整数可以是负数或正数。如果添加 UNSIGNED 属性，那么范围将从 0 开始，而不是某个负数。

#### Date类型

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gmd66b11g5j313o0piabh.jpg)

`*`即便 DATETIME 和 TIMESTAMP 返回相同的格式，它们的工作方式很不同。在 INSERT 或 UPDATE 查询中，TIMESTAMP 自动把自身设置为当前的日期和时间。TIMESTAMP 也接受不同的格式，比如 YYYYMMDDHHMMSS、YYMMDDHHMMSS、YYYYMMDD 或 YYMMDD。



## 什么是SQL语句

SQL语句是结构化查询语言(Structured Query Language)的简称,是一种特殊目的的编程语言，是一种数据库查询和程序设计语言，用于存取数据以及查询、更新和管理关系数据库系统。

## SQL语句的类型

数据查询语言（[DQL](https://baike.baidu.com/item/DQL):Data Query Language）：其语句，也称为“数据检索[语句](https://baike.baidu.com/item/语句)”，用以从表中获得数据，确定数据怎样在应用程序给出。保留字[SELECT](https://baike.baidu.com/item/SELECT/10735068)是DQL（也是所有SQL）用得最多的动词，其他DQL常用的保留字有WHERE，ORDER BY，GROUP BY和HAVING。这些DQL保留字常与其它类型的SQL语句一起使用。

[数据操作语言](https://baike.baidu.com/item/数据操作语言)（DML：Data Manipulation Language）：其语句包括动词[INSERT](https://baike.baidu.com/item/INSERT)、[UPDATE](https://baike.baidu.com/item/UPDATE)和[DELETE](https://baike.baidu.com/item/DELETE)。它们分别用于添加、修改和删除。

事务控制语言（TCL）：它的语句能确保被DML语句影响的表的所有行及时得以更新。包括COMMIT（提交）命令、SAVEPOINT（保存点）命令、ROLLBACK（回滚）命令。

[数据控制语言](https://baike.baidu.com/item/数据控制语言)（DCL）：它的语句通过GRANT或REVOKE实现权限控制，确定单个用户和用户组对[数据库对象](https://baike.baidu.com/item/数据库对象)的访问。某些RDBMS可用GRANT或REVOKE控制对[表单](https://baike.baidu.com/item/表单)个列的访问。

数据定义语言（[DDL](https://baike.baidu.com/item/DDL/21997)）：其语句包括动词CREATE,ALTER和DROP。在数据库中创建新表或修改、删除表（CREATE TABLE 或 DROP TABLE）；为表加入索引等。

指针控制语言（CCL）：它的语句，像DECLARE CURSOR，FETCH INTO和UPDATE WHERE CURRENT用于对一个或多个表单独行的操作。

比较常用的有`DDL(数据定义语言)`\`DCL(数据控制语言)`\`DML(数据操作语言)`\`DQL(数据查询语言)`

## SQL

### Client

```
?         (\?) Synonym for `help'.           # 帮助信息                                                                                
clear     (\c) Clear the current input statement.  清空此行sql                                                                         
connect   (\r) Reconnect to the server. Optional arguments are db and host.                                                  
delimiter (\d) Set statement delimiter.                                                                                      
edit      (\e) Edit command with $EDITOR.                                                                                    
ego       (\G) Send command to mysql server, display result vertically. 格式化输出
exit      (\q) Exit mysql. Same as quit.	退出登陆 ctrl(control) + d 
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile. # 记录日志（语句+结果） eg:tee /tmp/mysql.log
notee     (\t) Don't write into outfile. 不记录日志
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument. 导入脚步，相当于 <
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
```

### server

#### DDL 数据定义语言

在日常中DDL多用于库、表的管理.

**库名与库属性**

```sql
## 增
create database dbname
eg: create database dbname charset utf8mb4
## 删
drop database dbname
## 改 (从小到大改， utf8 -> utf8mb4, 严格超集)
alter  database dbname 将修改的属性名 将要修改的属性值
## 查
show databases;
```

> 建库规范：
> 1.库名不能有大写字母,不能太长(<30字符) 多平台兼容性问题  
> 2.建库要加字符集      
> 3.库名不能有数字开头
> 4.库名要和业务相关

**表**

```sql
# 增加
create table tableName(
列1  属性（数据类型、约束、其他属性） ，
列2  属性，
列3  属性
)
eg:
CREATE TABLE student(
id      INT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT '学号',
sname   VARCHAR(255) NOT NULL COMMENT '姓名',
sage    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '年龄',
sgender ENUM('m','f','n') NOT NULL DEFAULT 'n' COMMENT '性别' ,
sfz     CHAR(18) NOT NULL UNIQUE  COMMENT '身份证',
intime  TIMESTAMP NOT NULL DEFAULT NOW() COMMENT '入学时间'
) ENGINE=INNODB CHARSET=utf8 COMMENT '学生表';

id INT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT '全局id', 

CREATE TABLE TableName2 LIKE TableName1;

# 删除表
drop table tableName

# 修改
ALTER TABLE tableName ADD(DROP) 属性（数据类型、约束、其他属性）
eg:
# 在stuent表中添加qq列
ALTER TABLE student ADD qq VARCHAR(20) NOT NULL UNIQUE COMMENT 'qq';
# 在sname后加微信列
ALTER TABLE student ADD wechat VARCHAR(64) NOT NULL UNIQUE  COMMENT '微信号' AFTER sname ;
# 在id列前加一个新列num
ALTER TABLE student ADD num INT NOT NULL COMMENT '数字' FIRST;

# 删除列 
ALTER TABLE stu DROP num;
ALTER TABLE stu DROP qq;
ALTER TABLE stu DROP wechat;

# 将sgender 改为 sg 数据类型改为 CHAR 类型
ALTER TABLE student change sgender sg CHAR(1) NOT NULL DEFAULT 'n' ;


用的时候，一定要注意：
修改数据类型，修改字段位置  ---用modify
修改名字 --就用change
# 范围大用change，小用modify。
# 均需要加入类型，限制
```

> 1. 表名小写
> 2. 不能是数字开头
> 3. 注意字符集和存储引擎
> 4. 表名和业务有关
> 5. 选择合适的数据类型，简短的、长度合适的数据类型
> 6. 每个列都要有注释
> 7. 每个列设置为非空，无法保证非空，用0来填充。
> 8. 必须有主键


####  DCL 数据控制语言

控制就是操作权限，而在DCL之中，主要有两个语法：GRANT,REVOKE

```
# 用户管理
create user xxx@"白名单" indentified by "password"
drop user
alter user
select user,host from mysql.user;
# 权限
## 查看所有权限列表
show privileges;
all 
with grant option

# 查看用户权限
show grant UserName@"白名单"
select * from mysql.user\G; 
```

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmfo1pre7wj31hy0u0afz.jpg)

**DCL**

授权

```
grant 权限 on 对象 to 用户 identified by “密码”
# mysql 8.0+:(中文表示，可自定制)
create user 用户 identified by “密码”
grant 权限1，权限2，权限3... on 对象 to 用户 identified by “密码”
```

权限:
	ALL: 管理员(不包含“	Grant option”，给他人授权)
	权限1，权限2，权限3...： 普通人员(开发人员)
	Grant option

对象范围:  库，表

|     "."     |      ---> chmod  -R 755 /      |  管理员  |
| :---------: | :----------------------------: | :------: |
| userName.*  |  ---> chmod  -R 755 userName/  | 普通用户 |
| userName.t1 | ---> chmod  -R 755 userName/t1 |          |



```
# 授权
grant create update, select ... on 库名.表的范围[*(所有), 表名1] to userName@“白名单”
```

Mysql授权表

|    user     |       *.*        |      |
| :---------: | :--------------: | ---- |
|     db      |       db.*       |      |
| Tables_priv |     db.table     |      |
|   Colums    |        列        |      |
| Procs_priv  | 存储过程中的权限 |      |

回收权限

```
revoke 权限 on 库 from 用户@“白名单”
# 具体eg如上
```

拓展，忘记root密码了该怎么办？

```
# 需知
# --skip-grant-tables 跳过授权表
# --skip-network  关闭TCP/IP连接

# 1.关闭数据库(任选其一)
service mysqld stop
/etc/init.d/mysqld stop
pkill mysqld

# 2.跳过验证(任选其一)
service mysqld start --skip-grant-tables
service mysqld restart --skip-grant-tables
mysql_safe --skip-grant-tables &

# 3.禁止远程连接
service mysqld start --skip-grant-tables --skip-network 
service mysqld restart --skip-grant-tables --skip-network

# 4.修改密码
## 4.1手动加载授权表
flush privileges
## 4.2修改密码
alter user root@"localhost" indentified by "new Passwd"

# 5.重启数据库
service mysqld restart
```

**原理探究**

说到这个，那就不得不从mysql的`server`层说起了，mysql的架构图如下(仅关键部分)

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmgl5sg1n2j30rq0ic3yp.jpg)

当我们忘记密码的时候,改怎么办呢？

这就对于我们平时对于mysql的模型有所考察了，如果你知道mysql的他内部到底是如何运行的,那么只需要在合适的地方，按照我们所想的给他“绕道而行”，是否就可以绕过这个密码验证了呢？答案是当然可以的。

首先我们介绍一下上面这副图中执行流程，当我们启动mysql服务的时候，系统会自动帮我们做一下这些事儿

1. 首先提供可连接的协议，也就是提供服务
2. 打开用户与密码校验，以处理将要连接的客户
3. 验证成功，分配独立的连接线程

如果我们需要跳过密码校验,那么只需要做以下几件事。

1. 让系统重启
2. 在重启的过程中停掉用户与密码校验

这样我们就可以连接了，但是还不够。尽然已经停掉了。此时的我们无法修改密码.(跳过验证，而不是把验证功能移除了)

那么我们此时还需要把验证功能加载进来，然后对验证的表进行修改。

#### DML 数据操作语言

这个也是我们日常中用的最多的地方，应为建库表，改权限，改密码。修改等等什么的并不是每次都要嘛.这个也很好理解

> DML 数据操作语言 对表中的数据行进行增、删、改

**insert**

```sh
# 语法
单行数据
INSERT INTO tableName(key1, key2, key3..) VALUES(value1, value2,value3...) [SELECT * FROM tableName]

# 多行数据
INSERT INTO tableName(key1, key2, key3..) VALUES \
(value1, value2,value3...)
(value1, value2,value3...)
(value1, value2,value3...);
...
[SELECT * FROM tableName]
```

> 插入时, key1,key2,key3 必须与value1，value2， value3 数量一致
>
> 插入对应字段
>
> ```
> INSERT INTO tableName(key1, key3..) VALUES(value1, value3...) [SELECT * FROM tableName]
> ```

**update**

```
# 更新前我们一般都会先查表内数据
# 查询出对应表已存在所有行
DESC tableName;
# 查询对应表已存在数据
SELECT * FROM tableName;	# * 可替换成字段名，查对应字段

# 更新数据
UPDATE student SET 字段名='新值' [WHERE 限定条件];
```

Eg:

创建一张新的student表

```
# 建表
CREATE TABLE `student` (
 `id` int NOT NULL AUTO_INCREMENT COMMENT '学号',
 `sname` varchar(255) CHARACTER SET utf8 NOT NULL COMMENT '姓名',
 `sage` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '年龄',
 `intime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入学时间',
 PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生表'

# 插入演示数据
INSERT INTO student(sname,sage) VALUES("赵一", 1),
("王二", 2),
("张三", 3),
("李四", 4);

```

数据库

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmgmsbglbmj30ey09it8s.jpg)

需求一:

李四改名为“里斯”;

```
UPDATE student SET sname="里斯" WHERE sname = "李四";

# 或者
UPDATE student SET sname="里斯" WHERE id=4;
UPDATE student SET sname="里斯" WHERE sage=4;
```

修改后，如下所示

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmgmx1cum6j30ey09eq30.jpg)

需求二:

将所有表内成员的年龄+10;

```
UPDATE student SET sage=sage + 10
# UPDATE student SET sage+=10(错误写法,开发时候用的什么sage ++， sage +=，在这里都不允许)
```

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmgn1b1f0bj30f009ct8s.jpg)

需求三:将所有表内成员的年龄+10,除了里斯

```
UPDATE student SET sage=sage + 10 WHERE sname != "里斯";
# 当然也可以这样写;
UPDATE student SET sage=sage + 10 WHERE sname = "赵一" OR sname = "王二" OR sname="张三" ;
```

> AND: 执行均满足
>
> OR: 满足其一执行
>
> where 见下文

**delete**

```objectivec
# 删除指定数据
DELETE FROM tableName  [WHERE id=1];

# 清空标中所有数据
DELETE FROM student;
truncate table student;
```

> 区别:
> delete: DML操作, 是逻辑性质删除,逐行进行删除,速度慢.
> truncate: DDL操作,对与表段中的数据页进行清空,速度快.

伪删除：用update来替代delete，最终保证业务中查不到（select）

```
1.添加状态列
ALTER TABLE stuent ADD state TINYINT NOT NULL DEFAULT 1 ;
SELECT * FROM stuent;
2. UPDATE 替代 DELETE
UPDATE stuent SET state=0 WHERE id=6;
3. 业务语句查询
SELECT * FROM stu WHERE state=1;
```

> **拓展**
>
> ```
> DELETE FROM student;
> DROP TABLE student;
> truncate table student;
> ```
>
> 以上三条删除语句有何区别？
>
> 同：三者都是删除语句，均可删除
>
> 异:
>
> DELETE FROM student:
>
> 逻辑上`逐行`删除，数据过多，操作很慢
>
> 并没有真正的从磁盘上删除，知识在磁盘上打上标记，磁盘空间不立即释放。HWM高位线不会降低
>
> DROP TABLE student;
>
> 将表结构(元数据)和数据行，物理层次删除
>
> truncate truncate table student;
>
> 清空表段中的所有数据页，物理层次删除全表数据，磁盘空间立即释放。HWM高位线降低
>
> ![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmhjljoy2gj30j20643zc.jpg)



#### DQL 数据查询语言

show类

```
show databases;
show CREATE DATABASE databaseName;

show table;
show CREATE TABLE table;

desc tableName;
```

**select类** 

> 获取表中的数据行

```css
# select @@xxx 查看系统参数
SELECT @@port;
SELECT @@basedir;
SELECT @@datadir;
SELECT @@socket;
SELECT @@server_id;

# select 函数
SELECT NOW();
SELECT DATABASE();
SELECT USER();
SELECT CONCAT("hello world");
SELECT CONCAT(USER,"@",HOST) FROM mysql.user;
SELECT GROUP_CONCAT(USER,"@",HOST) FROM mysql.user;
```

手册 https://dev.mysql.com/doc/refman/8.0/en/sql-function-reference.html

select配合子句

```
select 
FROM 表1，表2...,
WHERE 过滤条件1，过滤条件2，过滤条件3 ...
GROUP BY 条件列1，条件列2，条件列3 ...
	# selct_list 列名
HAVING 过滤条件1，过滤条件2，过滤条件3 ...
ORDER BY 条件列1，条件列2，条件列3 ...
LIMIT 限制条件;
```



**单表子句-from**

```undefined
SELECT 列1,列2 FROM 表
SELECT  *  FROM 表

# EG
# 查询student中所有的数据(不要对大表进行操作)
SELECT * FROM stu ;
# 查询stu表中,学生姓名和入学时间
SELECT sname , intime FROM stuent;
```

**单表子句-where**

```undefined
SELECT col1,col2 FROM TABLE WHERE colN 条件;
# where 操作符(>、<、>=、 <=、 <>、in、like、and、or)
SELECT col1,col2 FROM TABLE WHERE = 条件;

# where 模糊查询
SELECT * FROM city WHERE district LIKE 'guang%';    
%  : 表示任意0个或多个字符。可匹配任意类型和长度的字符，有些情况下若是中文，请使用两个百分号（%%）表示。
_  : 表示任意单个字符。匹配单个任意字符，它常用来限制表达式的字符长度语句
[] : 表示括号内所列字符中的一个（类似正则表达式）。指定一个字符、字符串或范围，要求所匹配对象为它们中的任一个。

# where配合between...and...
SELECT * FROM city  WHERE population >1000000 AND population <2000000;
SELECT * FROM city  WHERE population BETWEEN 1000000 AND 2000000;
```

 **group by**

根据 by后面的条件进行分组，方便统计，by后面跟一个列或多个列

未分组分组列，使用聚合函数

聚合函数

```swift
**max()**      ：最大值
**min()**      ：最小值
**avg()**      ：平均值
**sum()**      ：总和
**count()**    ：个数
group_concat() : 列转行
```

**HAVING**

需要在group by 之后，在做判断过滤使用(类似于where)

**order by**

> 实现先排序，by后添加条件列(默认从小到大)
>
> 逆序：后加DESC

**distinct：去重复**

```cpp
SELECT countrycode FROM city ;
SELECT DISTINCT(countrycode) FROM city  ;
```

联合查询- union all

```csharp
-- 中国或美国城市信息

SELECT * FROM city 
WHERE countrycode IN ('CHN' ,'USA');

SELECT * FROM city WHERE countrycode='CHN'
UNION ALL
SELECT * FROM city WHERE countrycode='USA'

说明:一般情况下,我们会将 IN 或者 OR 语句 改写成 UNION ALL,来提高性能
UNION     去重复
UNION ALL 不去重复
```

**LIMIT 限制条件**

限制查询

```sql
select * FROM 表名 LIMIT 限制条件
eg:
--- 只输出前1000条
select * FROM 表名 LIMIT 1000
--- 只输出前1000-2000条
select * FROM 表名 LIMIT 1000, 2000

select * FROM 表名 LIMIT 1000, 2000
相当于
select * FROM 表名 LIMIT 2000 OFFSET 1000
```

**join 多表连接查询**

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gmhk5wso0sj31080ak76b.jpg)

**内连接**

查询li4家的地址

```sql
SELECT A.name,B.address FROM
A JOIN  B
ON A.id=B.id	--- 关联列
WHERE A.name='li4'


--- 相当于

SELECT A.name,B.address FROM
A JOIN  B
ON A.id=B.id
WHERE A.name='li4'
```

**外连接**

驱动表建议使用 数据少的表 为驱动表

```sql
SELECT A.name,B.address FROM
A JOIN  B
ON A.id=B.id	--- 关联列
WHERE A.name='li4'


--- 相当于

SELECT A.name,B.address FROM
A left JOIN  B
ON A.id=B.id
WHERE A.name='li4'

---  A left JOIN  B 其中a位驱动表
```
