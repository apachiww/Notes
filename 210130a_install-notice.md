# Linux以及FreeBSD的配置与使用技巧

参考：

[ArchWiki](https://wiki.archlinux.org/)

[Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page)

[Slackware](http://docs.slackware.com/)

[FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/)

## 目录

+ [**1**](#1-linux) Linux
    + [**1.1**](#11-防火墙iptables) 防火墙：iptables
        + [**1.1.1**](#111-基本概念) 基本概念
        + [**1.1.2**](#112-filter表简析) filter表简析
        + [**1.1.3**](#113-配置文件) 配置文件
        + [**1.1.4**](#114-常用命令和操作) 常用命令和操作
        + [**1.1.5**](#115-日志) 日志
        + [**1.1.6**](#116-常用配置) 常用配置
        + [**1.1.7**](#117-nat配置) NAT配置
    + [**1.2**](#12-存储与文件系统) 存储与文件系统
        + [**1.2.1**](#121-lvm逻辑卷管理) LVM逻辑卷管理
        + [**1.2.2**](#122-存储安全加密) 存储安全：加密
        + [**1.2.3**](#123-使用zfs) 使用ZFS
    + [**1.3**](#13-服务) 服务
        + [**1.3.1**](#131-基于systemd) 基于systemd
        + [**1.3.2**](#132-基于openrc) 基于openrc
    + [**1.4**](#14-其他杂项) 其他杂项
        + [**1.4.1**](#141-开机信息显示) 开机信息显示
        + [**1.4.2**](#142-sudo与特权用户) sudo与特权用户
        + [**1.4.3**](#143-将grub配置文件安装到esp分区) 将grub配置文件安装到ESP分区
        + [**1.4.4**](#144-cmos时间同步) CMOS时间同步
        + [**1.4.5**](#145-gpu与3d) GPU与3D
        + [**1.4.6**](#146-显示器亮度调节) 显示器亮度调节
+ [**2**](#2-freebsd) FreeBSD
    + [**2.1**](#21-防火墙) 防火墙
    + [**2.2**](#22-存储与文件系统) 存储与文件系统
        + [**2.2.1**](#221-zfs) ZFS
    + [**2.3**](#23-服务) 服务
    + [**2.4**](#24-其他杂项) 其他杂项

## 1 Linux

## 1.1 防火墙：iptables

Linux在内核中已经集成了网络数据包的观察（inspection），修改（modify），转发（forward），重定向（redirect），丢包（drop）功能。实现防火墙功能只需提供一些表（tables）即可。`iptables`就是配置这些表的工具

### 1.1.1 基本概念

每一张**表**`tables`都代表一个特定的功能，表由规则**链**`chains`组成，而规则链由**规则**`rules`构成。每一条规则`rules`由（多个）**匹配项**`matches`以及对应的**目标**`target`（动作）构成，在数据包和匹配项成功匹配时就会执行目标`target`对应的动作。匹配项可以判断数据包的各项参数，例如来源接口（`eth0 eth1 br0`等），传输层协议（`TCP UDP ICMP`等），目标端口，源IP等。如果一个数据包没有匹配上任何一个规则，每一条规则链还拥有一个`policy`，它指定了默认目标（行为）

> 之所以称为**链**，是因为数据包是依照规则链中规则的顺序一条一条依次匹配的。所以我们优先想要匹配的规则要往前面放
>
> `iptables`有4个内置目标类型，分别为`ACCEPT DROP QUEUE RETURN`，以及扩展目标类型`REJECT LOG`。一个规则的目标也可以是用户定义的**表**，这样可以从一个表跳到另一个表。最常用的目标有`ACCEPT DROP`以及用户定义的表。如果跳转到用户定义的表以后没有任何匹配的规则，那么就会跳回到原来的表，并继续在剩余规则中匹配

`iptables`工作原理如下

![](images/210130a002.jpg)

> Linux主机从任何端口（无论虚拟还是物理）接收到的数据包都要完整过一遍上图所示的流程。`raw mangle nat filter`就是表，而`PREROUTING INPUT FORWARD OUTPUT POSTROUTING`等就是属于这些表的规则链
>
> 路由会决定转发这些数据包还是将这些数据包给本机运行中的进程处理，相当于走左边的路径。否则走右边路径。最后路由会决定将处理后的数据包发往哪个接口
>
> 绝大部分情况下我们无需配置`raw mangle security`，只需关注`filter nat`两张表即可。`filter`就是我们主要需要配置的表，防火墙规则都放在这张表里

`iptables`对于IPv4以及IPv6分别有一个`systemd`服务，为`iptables`和`ip6tables`，默认自启，可以通过`systemctl`查看状态以及控制启动终止

```shell
sudo systemctl status iptables
sudo systemctl status ip6tables
```

### 1.1.2 filter表简析

`filter`表默认包含3个链`INPUT OUTPUT FORWARD`，如下

```shell
sudo iptables -nvL -t filter
```

```
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
```

> 没有配置任何有效的规则时，`policy`默认目标为`ACCEPT`。所有类型的数据包在经过规则链后最终都会被通过并移交给下一个处理阶段。而`DROP`表示将数据包直接丢弃消失，不再有任何后续处理或回应

### 1.1.3 配置文件

在`iptables`运行时我们的改动是易失的，重启以后就会恢复到原来的配置。`iptables`和`ip6tables`每次启动时都会从`/etc/iptables/iptables.rules`以及`/etc/iptables/ip6tables.rules`加载配置使用。为了将我们的配置存储到文件，可以使用以下命令

```shell
sudo iptables-save -f /etc/iptables/iptables.rules
sudo ip6tables-save -f /etc/iptables/ip6tables.rules
```

之后可以重启防火墙服务，或直接重载配置文件

```shell
sudo iptables-restore /etc/iptables/iptables.rules
sudo ip6tables-restore /etc/iptables/ip6tables.rules
```

### 1.1.4 常用命令和操作

常用命令示例（`iptables`命令通常都需要`sudo`执行）

创建新规则链

```shell
iptables -t filter -N LOGDROP # 创建一个名为LOGDROP的规则链
```

列出规则

```shell
iptables -t filter -L
iptables -t filter -nvL # 列出表filter对应的规则链与规则，-L相当于--list，-n表示将主机名和端口显示为数字格式的地址，-v为verbose
iptables -t filter -nvL --line-numbers # 同时显示规则行数，行数在编辑规则时会有用
iptables -t nat -S # 列出表nat对应的规则链名以及默认policy目标
```

置空规则链，包括默认内置的

```shell
iptables -t filter -F # flush，相当于将filter表中规则链INPUT，FORWARD，OUTPUT内所有的规则一个一个依次删除
iptables -t filter -F INPUT # 重置filter的INPUT规则链。也可以是用户创建的规则链
```

删除表中非内置的空规则链

```shell
iptables -t filter -X # 将用户自己添加的空规则链全部删除
iptables -t filter -X LOGDROP # 删除用户添加的规则链LOGDROP
```

设置规则链的默认`policy`目标

```shell
iptables -t filter -P FORWARD DROP # 将filter中FORWARD规则链的policy设置为DROP，默认行为直接丢包
```

追加规则

```shell
iptables -t filter -A INPUT -p tcp --dport 17500 -j REJECT --reject-with icmp-port-unreachable # -A表示在现有规则链下追加规则，目标为REJECT。接收到的数据包走的传输层协议为tcp，--dport指定数据包目标端口
```

> 一条规则需要指定目标（`-j`跳转到）以及各项用于匹配的参数，例如协议（`-p`），端口（`--dport --sport`），接口（`-i`），IP（`-d -s`）等

插入规则

```shell
iptables -t filter -I INPUT 2 -p tcp --dport 17500 -s 10.0.0.85 -j ACCEPT -m comment --comment "Dropbox" # -I表示在指定行数添加规则，该规则链内原有后续规则依次向后移动
```

替换规则

```shell
iptables -t filter -R INPUT 1 -p tcp --dport 17500 ! -s 10.0.0.85 -j REJECT --reject-with icmp-port-unreachable # -R表示替换INPUT中的规则，1表示第一行，!表示仅排除-s指定的特定的IP，除此IP外所有的其他IP都会和该规则匹配并被REJECT。使用iptables -L查看时就显示为!10.0.0.85
```

删除规则

```shell
iptables -t filter -D INPUT 1
```

### 1.1.5 日志

前面提到过`iptables`支持扩展目标`LOG`。`LOG`可以记录指定数据包，在从一条规则跳转到`LOG`后数据包不会消失，而是返回来继续匹配规则链中接下来的规则

可以创建一个`LOG`专用的规则链

```shell
iptables -t filter -N LOGDROP
```

示例，添加一些规则，记录并丢弃数据包

```shell
iptables -t filter -A LOGDROP -m limit --limit 5/m --limit-burst 10 -j LOG # 必须加限制防止攻击者写满磁盘，一开始的10个数据包会被记录，后续每分钟限制记录5个数据包
iptables -t filter -A LOGDROP -j DROP # 没添加任何匹配规则，无论什么数据包到这一步都会直接丢弃
```

> `-m`表示`match`，是一个扩展模块，用于检查并匹配数据包的特定属性，例如频度`limit`，连接状态`conntrack`等，后面需要加上该`match`对应的参数

从其他链中想要记录并丢弃数据包时，直接`-j`设置跳转到`LOGDROP`即可

日志捕捉记录的数据包可以通过`journalctl`查看

```shell
journalctl -k --grep="IN=.*OUT=.*"
```

### 1.1.6 常用配置

可以将`TCP UDP`数据包分别处理，可以分别创建`TCP UDP`两个链，并使得对应的匹配项跳转到这两个链

```shell
iptables -t filter -N TCP
iptables -t filter -N UDP
```

如果主机不作为路由使用，禁用数据包转发

```shell
iptables -t filter -P FORWARD DROP
```

基于白名单的防火墙，将`INPUT`默认目标设置为`DROP`

```shell
iptables -t filter -P INPUT DROP
```

允许已建立连接所属数据包，以及与这些连接有关的ICMP数据包

```shell
iptables -t filter -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

> `ESTABLISHED`表示已建立的连接。对于`iptables`来说，一个数据包可以对应有4种状态，分别为`NEW ESTABLISHED RELATED INVALID`。例如对于TCP数据包而言，`NEW`表示允许握手包建立新连接，`ESTABLISHED`表示允许已建立的连接继续，`RELATED`表示已建立的连接引发的数据包，`INVALID`表示除上述数据包以外的无效数据包
>
> 所谓`stateful firewall`就是防火墙会跟踪数据包的状态并使用一个状态机维护有效的连接，并判断每个数据包所属的状态。除以上状态，还有`UNTRACKED`状态，以及`SNAT DNAT`两个虚拟状态
>
> 注意，`iptables`还有一个不同的`--ctstatus`参数，使用格式和`--ctstate`类似，千万不要混淆

允许所有`lo`回环接口的流量

```shell
iptables -t filter -A INPUT -i lo -j ACCEPT
```

丢弃所有无效（`INVALID`）数据包

```shell
iptables -t filter -A INPUT -m conntrack --ctstate INVALID -j DROP
```

允许其他主机发来的ICMP的[ping请求](221112a_network.md#535-echo和回复)

```shell
iptables -t filter -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
```

在`INPUT`创建跳转，分别跳转到`TCP UDP`规则链

```shell
iptables -t filter -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
iptables -t filter -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP
```

> `--syn`匹配TCP连接发起时发送的第一个SYN数据包（也即SYN位有效，ACK位无效的数据包）

未匹配TCP UDP规则的（包括上述规则以及TCP UDP规则链内规则，原因[见前](#111-基本概念)），需要使用以下规则

```shell
iptables -t filter -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -t filter -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -t filter -A INPUT -j REJECT --reject-with icmp-proto-unreachable
```

> 上述配置中，所有的剩余数据包都会使用恰当的方式进行`REJECT`

接下来可以按照需求配置TCP UDP规则，由于是基于白名单的防火墙，配置允许的访问即可

```shell
iptables -t filter -A TCP -p tcp --dport 80 -j ACCEPT # 允许请求本机的http服务器
iptables -t filter -A TCP -p tcp --dport 22 -j ACCEPT # 允许SSH
```

防范TCP SYN扫描开放端口

```shell
iptables -t filter -I TCP -p tcp -m recent --update --rsource --seconds 60 --name TCP-PORTSCAN -j REJECT --reject-with tcp-reset

iptables -t filter -D INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -t filter -A INPUT -p tcp -m recent --set --rsource --name TCP-PORTSCAN -j REJECT --reject-with tcp-reset
```

> 在一台主机接收到其他地方发来的TCP SYN数据包时，如果此时对应TCP端口关闭，那么没有防火墙配置时主机会回复一个TCP RESET；而端口打开时会回复一个SYN+ACK。而防火墙经过配置可以直接丢弃这些数据包，不进行任何回复
>
> 工作原理：由于扫端口时第一个被扫的端口恰巧开放的概率较小（除非有意扫常用的端口），本机将会回复一个TCP RESET并将对方加入到`TCP-PORTSCAN`，此后对方在`60`秒内进行任何TCP连接尝试都会收到TCP RESET，此时防火墙是起作用的。**这种防范措施的弊端也显而易见，如果直接从常用的端口开始扫，此时对方不在**`TCP-PORTSCAN`**中，本机会回复TCP ACK泄露开放的端口**。所以在实际应用中需要使用非标准端口，例如不能在22端口监听SSH连接
>
> 上述示例中分别配置了`TCP INPUT`链中的`REJECT`行为

防范UDP扫描端口

```shell
iptables -t filter -I UDP -p udp -m recent --update --rsource --seconds 60 --name UDP-PORTSCAN -j REJECT --reject-with icmp-port-unreachable

iptables -t filter -D INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -t filter -A INPUT -p udp -m recent --set --rsource --name UDP-PORTSCAN -j REJECT --reject-with icmp-port-unreachable
```

> 对于无状态的UDP来说，如果是一个未开放的端口，主机回复`icmp-port-unreachable`，而开放的端口不会进行回复。配置基本相似，同样有类似的缺点

如果配置了TCP UDP防扫端口，需要重新将原先`INPUT`的最后一行放到最后

```shell
iptables -t filter  -D INPUT -j REJECT --reject-with icmp-proto-unreachable
iptables -t filter -A INPUT -j REJECT --reject-with icmp-proto-unreachable
```

防SSH爆破示例配置，这些规则需要放在跳转`TCP`表之前

```shell
iptables -N IN_SSH
iptables -N LOG_AND_DROP
iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -j IN_SSH
iptables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 3 --seconds 10 -j LOG_AND_DROP
iptables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 4 --seconds 1800 -j LOG_AND_DROP 
iptables -A IN_SSH -m recent --name sshbf --set -j ACCEPT
iptables -A LOG_AND_DROP -j LOG --log-prefix "iptables deny: " --log-level 7
iptables -A LOG_AND_DROP -j DROP
```

### 1.1.7 NAT配置

作为NAT网关使用，配置完成后数据包转发功能需要启用才会生效

例如，启用IPv4数据包转发

```shell
sysctl net.ipv4.ip_forward=1
```

NAT还需要配置`nat`表下的规则链`PREROUTING POSTROUTING`

首先在`filter`创建两个新链`FW_INTERFACES FW_OPEN`，分别用于私网机器以及公网接口

```shell
iptables -t filter -N FW_INTERFACES
iptables -t filter -N FW_OPEN
```

配置`filter`的`FORWARD`链

```shell
iptables -t filter -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A FORWARD -j FW_INTERFACES
iptables -t filter -A FORWARD -j FW_OPEN
iptables -t filter -A FORWARD -j REJECT --reject-with icmp-host-unreachable
iptables -t filter -P FORWARD DROP
```

> 上述配置将允许转发目的地址非本机地址的（跟踪状态有效的）数据包，并依次与`FW_INTERFACES FW_OPEN`进行匹配

`POSTROUTING`应用，可以配置允许私有网络内主机访问公网

```shell
iptables -t filter -A FW_INTERFACES -i eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth4 -j MASQUERADE
```

> 上述配置允许`eth0`所连接网络内的主机访问公网。注意，这里没有DHCP，`eth0`接口以及局域网内的主机都需要手动配置IP为`192.168.x.x`。私有网络内的数据包更改源IP后会从`eth4`发出，特殊目标`MASQUERADE`就代表了这个NAT操作
>
> 其他还有必要的DNS DHCP配置等操作，这里不再展示

`PREROUTING`应用，可以配置转发，从公网访问私网内的主机

```shell
iptables -t nat -A PREROUTING -i eth4 -p tcp --dport 22 -j DNAT --to 192.168.0.5
iptables -t filter -A FW_OPEN -d 192.168.0.5 -p tcp --dport 22 -j ACCEPT
```

> 上述配置中特殊目标`DNAT`就实现了端口映射功能。第一行配置指定`eth4`公网接口访问`22`端口的请求全部NAT转换IP后转发到`192.168.0.5`（相当于本机会监听22端口并在连接请求到来时转发）。第二行配置允许（NAT后的数据包）访问`192.168.0.5`的`22`端口

## 1.2 存储与文件系统

### 1.2.1 LVM逻辑卷管理

### 1.2.2 存储安全：加密

### 1.2.3 使用ZFS

## 1.3 服务

### 1.3.1 基于systemd

`systemd`是目前绝大部分主流Linux发行版的init

### 1.3.2 基于openrc

使用`openrc`的发行版有Alpine, Artix, Gentoo等

## 1.4 其他杂项

### 1.4.1 开机信息显示

编辑`/etc/default/grub`，去掉`quiet`

![](images/210130a001.jpg)

之后重新`grub-mkconfig`

### 1.4.2 sudo与特权用户

建议安装`sudo`后将想要使用特权指令的非特权用户添加到`wheel`组而不是手动添加用户入口。使用`visudo`编辑`/etc/sudoers`，去除`%wheel ALL=(ALL:ALL) NOPASSWD: ALL`（执行时无需密码）或`%wheel ALL=(ALL:ALL) ALL`（需要密码）的注释即可

```shell
su
usermod -a -G wheel your-username
visudo
```

### 1.4.3 将grub配置文件安装到ESP分区

通过以下命令，`grub`的配置文件就会安装到ESP分区下的`grub`目录，假设当前ESP挂载到`/mnt`

```shell
grub-install --target=x86_64-efi --efi-directory=/mnt --bootloader-id=GRUB --boot-directory=/mnt
grub-mkconfig -o /mnt/grub/grub.cfg
```

### 1.4.4 CMOS时间同步

`systemd`下使能`systemd-timesyncd`

```shell
sudo systemctl enable systemd-timesyncd
```

创建`/etc/systemd/timesyncd.conf.d/myserver.conf`配置文件

```shell
[Time]
NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
FallbackNTP=0.pool.ntp.org 1.pool.ntp.org
```

使能时钟同步

```shell
timedatectl set-ntp true
```

查看状态

```shell
timedatectl status
```

### 1.4.5 GPU与3D

测试程序，`mesa-utils`

```shell
sudo pacman -S mesa-utils
```

运行`vkgears`和`glxgears`经典齿轮测试程序，分别检查Vulkan和OpenGL是否可用

![](images/210130a003.png)

还可以安装`vulkan-tools`，运行`vkcube`

![](images/210130a004.png)

AMD显卡安装`radeontop`查看GPU资源使用

```shell
sudo pacman -S radeontop
```

### 1.4.6 显示器亮度调节

安装`light`并确保非特权用户加入`video`组

```shell
sudo pacman -S light
su
usermod -a -G video your-username
```

```shell
light -A 5 # 调亮5
light -U 5 # 降低5
```

## 2 FreeBSD

## 2.1 防火墙

## 2.2 存储与文件系统

### 2.2.1 ZFS

## 2.3 服务

## 2.4 其他杂项