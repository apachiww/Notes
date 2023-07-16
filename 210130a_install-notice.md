# Linux以及FreeBSD的配置与使用技巧

参考：

[ArchWiki](https://wiki.archlinux.org/)

[Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page)

[Slackware](http://docs.slackware.com/)

[FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/)

## 1 Linux

## 1.1 防火墙：iptables

Linux在内核中已经集成了网络数据包的观察（inspection），修改（modify），转发（forward），重定向（redirect），丢包（drop）功能。实现防火墙功能只需提供一些表（tables）即可。`iptables`就是配置这些表的工具

### 1.1.1 基本概念

每一张**表**`tables`都代表一个特定的功能，表由规则**链**`chains`组成，而规则链由**规则**`rules`构成。每一条规则`rules`由（多个）**匹配项**`matches`以及对应的**目标**`target`（动作）构成，在数据包和匹配项成功匹配时就会执行目标`target`对应的动作。匹配项可以判断数据包的各项参数，例如来源接口（`eth0 eth1 br0`等），传输层协议（`TCP UDP ICMP`等），目标端口，源IP等。如果一个数据包没有匹配上任何一个规则，每一条规则链还拥有一个`policy`，它指定了默认目标（行为）

> 之所以称为**链**，是因为数据包是依照规则链中规则的顺序一条一条依次匹配的
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

### 1.4.3 将grub配置文件安装到ESP分区而不是Linux系统分区

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

## 2 FreeBSD

## 2.1 防火墙

## 2.2 存储与文件系统

### 2.2.1 ZFS

## 2.3 服务

## 2.4 其他杂项