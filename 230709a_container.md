# Linux容器的使用

## 目录

+ [**1**](#1-lxc) LXC
    + [**1.1**](#11-安装与配置) 安装与配置
    + [**1.2**](#12-下载镜像) 下载镜像
    + [**1.3**](#13-创建并启动容器) 创建并启动容器
    + [**1.4**](#14-基本操作) 基本操作
        + [**1.4.1**](#141-shell的使用) shell的使用
        + [**1.4.2**](#142-文件传输) 文件传输
        + [**1.4.3**](#143-挂载容器目录) 挂载容器目录
    + [**1.5**](#15-配置容器) 配置容器
        + [**1.5.1**](#151-常用配置) 常用配置
        + [**1.5.2**](#152-使用配置文件) 使用配置文件
    + [**1.6**](#16-镜像导入导出) 镜像导入导出
    + [**1.7**](#17-容器快照) 容器快照
        + [**1.7.1**](#171-创建和恢复) 创建和恢复
        + [**1.7.2**](#172-定时快照) 定时快照
    + [**1.8**](#18-特权容器) 特权容器
    + [**1.9**](#19-设备) 设备
        + [**1.9.1**](#191-添加与删除) 添加与删除
        + [**1.9.2**](#192-设备类型) 设备类型
    + [**1.10**](#110-存储管理) 存储管理
        + [**1.10.1**](#1101-一些基本概念) 一些基本概念
        + [**1.10.2**](#1102-创建存储池) 创建存储池
        + [**1.10.3**](#1103-使用存储池) 使用存储池
        + [**1.10.4**](#1104-创建存储卷) 创建存储卷
        + [**1.10.5**](#1105-使用存储卷) 使用存储卷
        + [**1.10.6**](#1106-存储卷用于备份) 存储卷用于备份
        + [**1.10.7**](#1107-备份存储卷) 备份存储卷
    + [**1.11**](#111-网络管理) 网络管理
        + [**1.11.1**](#1111-容器网络接口) 容器网络接口
        + [**1.11.2**](#1112-查看与配置) 查看与配置
        + [**1.11.3**](#1113-使用网桥) 使用网桥
        + [**1.11.4**](#1114-使用独占物理网卡) 使用独占物理网卡
        + [**1.11.5**](#1115-和宿主机共用网卡和mac) 和宿主机共用网卡和MAC
+ [**2**](#2-docker) Docker
    + [**2.1**](#21-安装与配置) 安装与配置
    + [**2.2**](#22-简单应用示例) 简单应用示例
        + [**2.2.1**](#221-创建应用镜像) 创建应用镜像
        + [**2.2.2**](#222-dockerhub上传) DockerHub上传
        + [**2.2.3**](#223-使用卷) 使用卷
        + [**2.2.4**](#224-bind-mount) Bind mount
        + [**2.2.5**](#225-多容器应用) 多容器应用
        + [**2.2.6**](#226-compose示例) Compose示例
        + [**2.2.7**](#227-镜像构建优化) 镜像构建优化
    + [**2.3**](#23-存储) 存储
    + [**2.4**](#24-网络) 网络
+ [**3**](#3-kubernetes) Kubernetes

## 1 LXC

ArchLinux下，基于LXD

https://wiki.archlinux.org/title/Linux_Containers

https://wiki.archlinux.org/title/LXD

https://documentation.ubuntu.com/lxd/en/latest/

## 1.1 安装与配置

```shell
sudo pacman -S lxd
```

编辑`/etc/subuid`和`/etc/subgid`

```
# /etc/subuid
root:1000000:655360
```

```
# /etc/subgid
root:1000000:655360
```

> 建议不要将映射限制设置为小于`65536`，尽量设置大一点，这里设置为`655360`，否则后续设置容器的`security.idmap.isolated=true`会失败

启动`lxd.socket`。用户第一次执行`lxc`命令操作`lxd`时`lxd.service`会被`lxd.socket`触发启动

```shell
sudo systemctl start lxd.socket
sudo systemctl enable lxd.socket
```

必须使用`root`身份执行以下初始化，初始化时根据提示选择自己的偏好。这里全部默认，给出存储池名称例如`pool0`即可

```shell
su
lxd init
```

把想要使用的非`root`用户添加到`lxd`组，就可以在非`root`下使用容器了

```shell
usermod -a -G lxd your_username
```

以非`root`用户身份运行一下`lxc`，正常情况下会输出`help`

```shell
lxc
```

> `lxd`是一个server-client类型的应用，其中`lxd`就是一个server daemon，以root运行，而`lxc`相当于client。`lxc`可以通过网络和一个远程的`lxd`服务进行交互。这里我们只在本机运用，无需额外进行相应配置

## 1.2 下载镜像

以下操作均在非`root`下进行

`lxd`从远程下载系统镜像并安装

```shell
lxc remote list
```

会输出当前可用的镜像，通常如下所示

```
+-----------------+------------------------------------------+---------------+-------------+--------+--------+--------+
|      NAME       |                   URL                    |   PROTOCOL    |  AUTH TYPE  | PUBLIC | STATIC | GLOBAL |
+-----------------+------------------------------------------+---------------+-------------+--------+--------+--------+
| images          | https://images.linuxcontainers.org       | simplestreams | none        | YES    | NO     | NO     |
+-----------------+------------------------------------------+---------------+-------------+--------+--------+--------+
| local (current) | unix://                                  | lxd           | file access | NO     | YES    | NO     |
+-----------------+------------------------------------------+---------------+-------------+--------+--------+--------+
| ubuntu          | https://cloud-images.ubuntu.com/releases | simplestreams | none        | YES    | YES    | NO     |
+-----------------+------------------------------------------+---------------+-------------+--------+--------+--------+
| ubuntu-daily    | https://cloud-images.ubuntu.com/daily    | simplestreams | none        | YES    | YES    | NO     |
+-----------------+------------------------------------------+---------------+-------------+--------+--------+--------+
```

> 每个镜像服务器都有一个`NAME`，我们指定服务器时就通过该名称指定。例如我们想用`https://images.linuxcontainers.org`，直接通过名称`images`指定该镜像服务器即可

可以自行添加镜像服务器，举例

```shell
lxc remote add tuna-lxc https://mirrors.tuna.tsinghua.edu.cn/lxc-images/ --protocol=simplestreams --public
```

查看一个镜像服务器上的镜像，例如列出`https://images.linuxcontainers.org`上所有镜像

```shell
lxc image list images:
```

搜索`archlinux`相关镜像

```shell
lxc image list images:archlinux
```

服务器`images`上有如下镜像，镜像分为`VIRTUAL-MACHINE`和`CONTAINER`两种。容器基于宿主系统的内核运行，它的镜像相比虚拟机要小很多

```
+----------------------------------+--------------+--------+------------------------------------------+--------------+-----------------+-----------+------------------------------+
|              ALIAS               | FINGERPRINT  | PUBLIC |               DESCRIPTION                | ARCHITECTURE |      TYPE       |   SIZE    |         UPLOAD DATE          |
+----------------------------------+--------------+--------+------------------------------------------+--------------+-----------------+-----------+------------------------------+
| archlinux (5 more)               | 3457466c4667 | yes    | Archlinux current amd64 (20230709_04:18) | x86_64       | VIRTUAL-MACHINE | 530.31MB  | Jul 9, 2023 at 12:00am (UTC) |
+----------------------------------+--------------+--------+------------------------------------------+--------------+-----------------+-----------+------------------------------+
| archlinux (5 more)               | fcdc6845ed7b | yes    | Archlinux current amd64 (20230709_04:18) | x86_64       | CONTAINER       | 187.85MB  | Jul 9, 2023 at 12:00am (UTC) |
+----------------------------------+--------------+--------+------------------------------------------+--------------+-----------------+-----------+------------------------------+
| archlinux/arm64 (2 more)         | 2ef34a0eb3be | yes    | Archlinux current arm64 (20230709_04:18) | aarch64      | CONTAINER       | 176.12MB  | Jul 9, 2023 at 12:00am 
(UTC) |
+----------------------------------+--------------+--------+------------------------------------------+--------------+-----------------+-----------+------------------------------+
| archlinux/cloud (3 more)         | 656ddc8565f7 | yes    | Archlinux current amd64 (20230709_04:18) | x86_64       | VIRTUAL-MACHINE | 546.75MB  | Jul 9, 2023 at 12:00am (UTC) |
+----------------------------------+--------------+--------+------------------------------------------+--------------+-----------------+-----------+------------------------------+
| archlinux/cloud (3 more)         | ba9682b01318 | yes    | Archlinux current amd64 (20230709_04:18) | x86_64       | CONTAINER       | 210.83MB  | Jul 9, 2023 at 12:00am (UTC) |
+----------------------------------+--------------+--------+------------------------------------------+--------------+-----------------+-----------+------------------------------+
| archlinux/desktop-gnome (3 more) | c202f5c2e949 | yes    | Archlinux current amd64 (20230709_04:18) | x86_64       | VIRTUAL-MACHINE | 1371.95MB | Jul 9, 2023 at 12:00am (UTC) |
+----------------------------------+--------------+--------+------------------------------------------+--------------+-----------------+-----------+------------------------------+
```

下载`archlinux`容器镜像到本地

```shell
lxc image copy images:archlinux/current/amd64 local:
```

列出本地已有镜像，会看到刚刚下载镜像的`FINGERPRINT`

```shell
lxc image list local:
```

查看镜像信息（可以指定镜像别名，见后）

```shell
lxc image info FINGERPRINT
```

## 1.3 创建并启动容器

使用上面的`FINGERPRINT`，通过`launch`命令创建Archlinux容器并启动，容器名称为`arch-01`（称为一个`instance`）。容器实例是non-volatile的，电脑重启后依然在并可以使用（默认路径在`/var/lib/lxd/containers`）

```shell
lxc launch FINGERPRINT arch-01
```

> 可以跳过容器镜像的下载，直接通过命令`lxc launch images:archlinux/current/amd64 arch-01`就会执行上述所有步骤，效果相同

我们下载镜像后，每次创建一个容器实例都要输入一次镜像的`FINGERPRINT`。我们可以为镜像设定一个别名，以后只要使用这个别名即可，也可以删除或重命名，如下例

```shell
lxc image alias create archimg-v01 FINGERPRINT
lxc image alias rename archimg-v01 img-01
lxc image alias delete img-01
```

容器启动后，需要首先配置`root`密码

```shell
lxc exec arch-01 passwd
```

> 使用`lxc exec`直接以`root`身份执行命令，实际使用时可以在执行的命令前加上`--`以支持命令参数的传递，例如在容器内执行`free -h`，使用`lxc exec arch-01 -- free -h`

查看一下当前已创建容器的运行状态

```shell
lxc list
```

查看一个容器的信息

```shell
lxc info arch-01
lxc info arch-01 --show-log
```

后续想要启动、重启、关闭容器，使用相应命令加上容器名即可

```shell
lxc start arch-01
lxc restart arch-01
lxc stop arch-01
```

可以删除容器实例，删除前要先停止该容器

```shell
lxc stop arch-01
lxc delete arch-01
```

或

```shell
lxc delete arch-01 -f
```

## 1.4 基本操作

### 1.4.1 shell的使用

容器启动后，可以使用两种方式进入容器的`shell`，一种是有完整的终端，需要登录

```shell
lxc console arch-01
```

> 注意，退出`lxc`终端为`ctrl+a`释放后按`q`，而不是`ctrl+a+q`

另一种方式就是直接执行`bash`（容器的`root`身份）

```shell
lxc exec arch-01 bash
```

### 1.4.2 文件传输

容器内的文件操作可以使用`lxc`的`file`命令

拉取容器内的`/var/log/pacman.log`到当前目录

```shell
lxc file pull arch-01/var/log/pacman.log . # pull -r 可以拉取一个目录
```

推送`./hosts`到容器的`/etc/hosts`

```shell
lxc file push ./hosts arch-01/etc/hosts # 同理可以使用-r推送一个目录
```

删除容器内的`/etc/modprobe.d/blacklist.conf`

```shell
lxc file delete arch-01/etc/modprobe.d/blacklist.conf
```

编辑容器内的`/etc/locale.gen`

```shell
lxc file edit arch-01/etc/locale.gen
```

### 1.4.3 挂载容器目录

文件传输也可以直接通过挂载容器的文件系统实现

首先确保安装`sshfs`

```shell
sudo pacman -S sshfs
```

挂载容器的`/home`目录到当前目录下的`lxc-mnt`

```shell
lxc file mount arch-01/home ./lxc-mnt
```

此时需要重新开一个终端，`ls lxc-mnt`就可以看到容器里的内容。卸载只要在执行挂载容器的终端`ctrl+c`即可。如果有异常，再手动`umount lxc-mnt`即可

> 还可以通过`lxc`设置基于SFTP远程访问，这里不再演示

## 1.5 配置容器

### 1.5.1 常用配置

容器所有的配置选项（不限于安全选项）可以通过`lxc config set arch-01 key=value`的形式进行设置，通过`lxc config show arch-01 --expanded`查看，也可以`lxc config edit arch-01`编辑所有选项

> 除了容器可以配置，`lxd`服务器本身也有配置选项，命令格式为`lxc config set key value`

设置`security.idmap.isolated`为`true`，可以防止一个容器受到DoS攻击时影响其他容器

```shell
lxc config set arch-01 security.idmap.isolated=true
```

此外为防止暴露cgroup名以及运行中的容器，启动容器前可以进行如下操作

```shell
sudo chmod 400 /proc/sched_debug
sudo chmod 700 /sys/kernel/slab
```

多个容器同时运行时，为防止宿主机爆内存，可以限制容器可用的内存大小

```shell
lxc config set arch-01 limits.memory=4GiB
```

也可以限制cpu数量（其他cpu对于容器来说依然可见，只是处于下线状态），以及cpu负载

```shell
lxc config set arch-01 limits.cpu=4
lxc config set arch-01 limits.cpu.allowance=50%
```

### 1.5.2 使用配置文件

创建多个容器实例时如果需要的配置相同，手动配置会过于繁琐，这时候就可以创建并使用`profile`，`profile`为yaml格式。一个容器实例可以加载多个`profile`，其中后面的`profile`中设置的值可以覆盖前面的`profile`

> 每个容器都有自己的配置。配置文件只是作为一个默认的配置背景，单个容器的不通用配置还是要使用`lxc config set`设置

列出当前可用的`profile`

```shell
lxc profile list 
```

可以看到`lxd`有一个默认的`default`配置文件，显示该`default`内容

```shell
lxc profile show default
```

输出

```
config: {}
description: Default LXD profile
devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: pool0
    type: disk
name: default
used_by:
- /1.0/instances/arch-01
```

> 有关容器实例的配置选项都放在`config:`中，而设备相关都位于`devices:`

创建一个新的`profile`，这里是`arch-common`

```shell
lxc profile create arch-common
```

可以设置容器实例的变量，或设备的变量

```shell
lxc profile set arch-common key1=value1 key2=value2
lxc profile device set arch-common device_name key1=value1 key2=value2
```

也可以直接编辑`arch-common`

```shell
lxc profile edit arch-common
```

除上述的方法，还可以先在本地创建配置文件，之后使用重定向

```shell
lxc profile edit arch-common < ./arch-common.yaml
```

编辑完配置文件以后，通过以下命令将该配置应用到容器实例`arch-01`

```shell
lxc profile add arch-01 arch-common
```

查看`arch-01`上配置是否生效

```shell
lxc config show arch-01
```

可以从容器移除一个`profile`

```shell
lxc profile remove arch-01 arch-common 
```

删除一个`profile`

```shell
lxc profile delete arch-common
```

## 1.6 镜像导入导出

`lxd`支持两种镜像格式，一种镜像是单一的压缩文件；而另一种镜像由两个压缩文件组成，其中之一是rootfs（`squashfs`格式），另外一个是metadata

导入单文件镜像

```shell
lxc image import arch-01.tar.gz
```

导入分体镜像

```shell
lxc image import arch-01 arch-01.root
```

导出一个本地镜像`archimg-v01`到当前目录

```shell
lxc image export archimg-v01 arch-exp 
```

也可以从一个容器实例或其快照打包并创建镜像，并导出

```shell
lxc publish arch-01 --alias=arch-modified
lxc image list
lxc image export arch-modified arch-exp
```

## 1.7 容器快照

### 1.7.1 创建和恢复

通过以下命令为容器`arch-01`创建一个快照

```shell
lxc snapshot arch-01 snap01
```

创建过后可以通过`info`查看`arch-01`对应的快照

```shell
lxc info arch-01
```

想要恢复到该快照，使用`restore`即可

```shell
lxc restore arch-01 snap01
```

删除快照

```shell
lxc delete arch-01/snap01
```

### 1.7.2 定时快照

设置快照前可以先设置一个快照过期时间，例如1周过期

```shell
lxc config set arch-01 snapshots.expiry=1w # 分钟M，小时H，天d，周w，月m，年y
```

以及快照的命名格式（模板格式，必须为这个`2006`年的时间）

```shell
lxc config set arch-01 snapshots.pattern="snap-{{ creation_date|date:'2006-01-02_15-04-05' }}"
```

或使用随机数格式，举例

```shell
lxc config set arch-01 snapshots.pattern="snap-%d"
```

设置为每天午夜进行快照

```shell
lxc config set arch-01 snapshots.schedule=@midnight # @hourly每小时，@daily每天，@weekly每周
```

## 1.8 特权容器

前面创建的容器都是非特权容器，通常具有更高的安全性。**无特殊需求应使用非特权容器**。特权容器的`root`就相当于宿主机的`root`

```shell
lxc config set arch-01 security.privileged=true
```

## 1.9 设备

可以向一个容器实例添加一些设备`device`，可用的设备类型如下

| ID | 名称 | 描述 |
| :- | :- | :- |
| 0 | `none` | dummy device |
| 1 | `nic` | 网络接口 |
| 2 | `disk` | 存储设备 |
| 3 | `unix-char` | UNIX字符设备 |
| 4 | `unix-block` | UNIX块设备 |
| 5 | `usb` | USB设备 |
| 6 | `gpu` | 显卡，计算卡 |
| 7 | `infiniband` | 光纤高速互联设备，常见于集群 |
| 8 | `unix-hotplug` | UNIX热插拔设备 |
| 9 | `tpm` | TPM安全模块 |

为支持最基本的POSIX，`lxd`为容器提供了以下标准设备。其余设备都需要配置

```shell
/dev/null
/dev/zero
/dev/full
/dev/console
/dev/tty
/dev/random
/dev/urandom
/dev/net/tun
/dev/fuse
lo
```

### 1.9.1 添加与删除

格式

```shell
lxc config device add instance_name device_name device_type key1=value1 key2=value2
```

示例，将宿主机的`/home/username/opt`映射到容器`arch-01`的`/opt`，在容器内`ls /opt`可以看到内容

```shell
lxc config device add arch-01 opt-dir disk source=/home/username/opt path=/opt
```

修改`device`配置

```shell
lxc config device set instance_name device_name key1=value1 key2=value2
```

查看当前`arch-01`的设备

```shell
lxc config device list arch-01
```

删除`opt-dir`

```shell
lxc config device remove arch-01 opt-dir
```

### 1.9.2 设备类型

**none**

Dummy device。如果使用了`profile`，它可能会带入我们不想要的设备。`add`添加一个类型为`none`同名设备即可覆盖

**nic**

见[1.11](#111-网络管理)

**disk**

添加一个[存储卷](#1105-使用存储卷)到容器的`/data`

```shell
lxc config device add arch-01 home-dir disk pool=pool0 source=myvol path=/data
```

最简单的映射一个宿主机路径到容器内

```shell
lxc config device add arch-01 home-dir disk source=/home/username path=/home/host-home
```

**unix-char**

添加`/dev/ttyUSB0`

```shell
lxc config device add arch-01 usbtty unix-char source=/dev/ttyUSB0 path=/dev/ttyUSB2 required=false
```

> `required`设置为`false`时容器启动无需该设备，使能热插拔，设备插入宿主机时会自动分配到容器

**unix-block**

添加u盘`/dev/sdb`

```shell
lxc config device add arch-01 usbflash unix-block source=/dev/sdb path=/dev/sdc required=false
```

**usb**

`usb`只适用于`libusb`的非高性能设备，不适用于需要内核驱动模块的设备，这些设备需要使用`unix-hotplug`或`unix-char`形式添加

```shell
lxc config device add arch-01 usbdev0 usb productid=120d vendorid=04b4 required=false
```

**gpu**

常用于分配计算卡

直接独占物理显卡，通常只需指定`pci`地址即可

```shell
lxc config device add arch-01 gpu0 gpu gputype=physical pci=0000:04:00.0
lxc config device add arch-01 gpu1 gpu gputype=physical pci=0000:3c:00.0
```

使用nvidia的MIG（Multi-Instance GPU）技术（需要Ampere及以上架构），需要提前创建一个MIG容器（在创建容器时指定`nvidia.runtime=true`）

```shell
lxc config device add arch-01 gpu0 gpu gputype=mig mig.uuid=74c6a31a-fde5-5c61-973b-70e12346c202 pci=0000:04:00.0
```

**infiniband**

服务器集群的光纤高速互联设备，简称IB（概念层级和以太网同等，但是IB设备可以处理更高层的网络协议，主要走DMA，占用CPU资源少）

独占模式

```shell
lxc config device add arch-01 ib0 infiniband nictype=physical parent=ibp4s0
```

> 可以通过`hwaddr`变量指定MAC地址

sriov模式

```shell
lxc config device add arch-01 ib0 infiniband nictype=sriov parent=ibp4s0
```

**unix-hotplug**

```shell
lxc config device add arch-01 usbdev0 unix-hotplug productid=120d vendorid=04b4 required=false
```

## 1.10 存储管理

列出当前的存储池，有我们创建的默认的`pool0`

```shell
lxc storage list
```

查看`pool0`的配置以及使用状况

```shell
lxc storage show pool0
lxc storage info pool0
```

初始化时我们创建的`pool0`默认位于`/var/lib/lxd/storage-pools/pool0`，为`dir`目录类型，使用的就是主机的文件系统，而不是像虚拟磁盘一样要经过两层文件系统。例如`arch-01`的完整根目录就位于`pool0`下的`arch-01/rootfs`

### 1.10.1 一些基本概念

存储池`storage pool`需要存储和容器、虚拟机实例相关的数据，例如实例的根目录，由实例创建的镜像，快照等。这些内容放在存储池下不同的目录中，例如容器实例以及根文件系统通常位于`containers`，虚拟机实例位于`virtual-machines`，它们的快照分别位于`*-snapshots`，在这些目录下创建的内容称为`storage volumes`存储卷，**存储池存放了存储卷**。用户可以自己创建存储卷，位于存储池下的`custom`目录中

`storage buckets`使用Amazon的S3（Simple Storage Service）协议

每一个存储池都有一个驱动，`lxd`下可用的驱动类型如下

| 驱动 | 说明 |
| :- | :- |
| `dir` | 直接指定一个宿主机目录，使用宿主机的文件系统 |
| `btrfs` | `btrfs`格式的磁盘，虚拟磁盘或挂载点 |
| `lvm` |  |
| `zfs` | `zfs`格式的磁盘，虚拟磁盘或已有的`zpool` |
| `ceph` | 网络存储 |
| `cephfs` | 网络存储 |
| `cdphobject` | 网络存储 |

### 1.10.2 创建存储池

配置存储池使用`lxc storage set pool1 key value`格式，或直接`lxc storage edit pool1`编辑配置文件

**dir**共用宿主机目录

创建一个新的`pool1`，查看`/home/username/pool1`下会出现`pool0`下一样的目录

```shell
lxc storage create pool1 dir source=/home/username/pool1
```

删除`pool1`

```shell
lxc storage delete pool1
```

**btrfs**

创建一个`btrfs`磁盘文件（loop-backed），磁盘文件位于`/var/lib/lxd/disks`

```shell
lxc storage create pool1 btrfs
```

或使用已挂载的`btrfs`磁盘

```shell
lxc storage create pool2 btrfs source=/home/username/mnt
```

或使用未挂载`btrfs`分区

```shell
lxc storage create pool3 btrfs source=/dev/sda4
```

**zfs**

创建一个`zfs`磁盘文件，`zpool`名称为`myzpool`

```shell
lxc storage create pool1 zfs zfs.pool_name=myzpool
```

或使用已有的`zpool`，或`zpool`的一个`dataset`

```shell
lxc storage create pool2 zfs source=myzpool
lxc storage create pool3 zfs source=myzpool/slice0
```

或使用`zfs`分区，同时新建一个`zpool`名称为`myzpool1`

```shell
lxc storage create pool4 zfs source=/dev/sda5 zfs.pool_name=myzpool1
```

**lvm**

loop-backed

```shell
lxc storage create pool1 lvm
```

或使用已有`lvm`组`myvg`

```shell
lxc storage create pool2 lvm source=myvg
```

或使用组`myvg`内的`mypool`

```shell
lxc storage create pool3 lvm source=myvg lvm.thinpool_name=mypool
```

或创建一个组

```shell
lxc storage create pool4 lvm source=/dev/sda6 lvm.vg_name=myvg
```

**ceph**

`lxd`支持`ceph` `cephfs` `cephobject`，这里不再示例

### 1.10.3 使用存储池

可以在创建实例时指定存储池，不指定默认使用我们创建的`pool0`

```shell
lxc launch local:arch-img arch-02 --storage pool1
```

也可以先在`myprofile`配置文件中设置，再使用该配置文件

```shell
lxc profile device add myprofile root disk path=/ pool=pool1
lxc launch local:arch-img arch-02 --profile myprofile
```

将实例`arch-01`从存储池`pool0`移动到`pool1`

```shell
lxc move arch-01 --storage pool1
```

### 1.10.4 创建存储卷

使用以下命令列出存储池`pool0`下的卷

```shell
lxc storage volume list pool0
```

查看用户卷`myvol`的信息

```shell
lxc storage volume show pool0 custom/myvol
lxc storage volume info pool0 custom/myvol
```

存储卷主要分为3类，一类是`container`或`virtual-machine`，一类是`image`，一类是`custom`。其中使用`lxc`命令创建实例时会自动创建`container`或`virtual-machine`类型的存储卷，该实例的文件系统就放置于该存储卷中；`image`无需关注；而`custom`是用户自己创建的卷，用途由用户决定，可以存放备份等

存储卷中可以存放`filesystem` `block`或`iso`类型的内容。其中`filesystem`是最常用的，它可以是一个目录，也可以是一个磁盘文件等；`block`为虚拟磁盘，只能用于虚拟机；`iso`为光盘文件

通过以下命令在`pool1`创建一个`custom`存储卷`myvol`，有需要可以在末尾添加上变量配置，例如在`dir`类型的存储池中，可以设置`size snapshots.expiry snapshots.pattern snapshots.schedule`等变量

```shell
lxc storage volume create pool1 myvol --type=filesystem key=value
```

可以通过以下命令配置`pool0`下的存储卷`myvol`，设置`myvol`大小`4GiB`。还可以进行其他配置

```shell
lxc storage volume set pool0 custom/myvol size=4GiB
```

可以设置一个存储池中创建新卷时的默认配置

```shell
lxc storage set pool0 volume.size 16GiB
```

### 1.10.5 使用存储卷

可以将我们自己创建的存储卷作为一个`disk`设备添加到一个实例，下例将`pool1`中的`myfsvol`（类型`filesystem`）挂到`arch-02`的`/data`

```shell
lxc storage volume attach pool1 myfsvol arch-02 /data
```

通过`lxc config show`可以看到分配的卷

```shell
lxc config show arch-02
```

卸载

```shell
lxc storage volume detach pool1 myfsvol arch-02
```

可以指定设备名例如`testfs0`

```shell
lxc storage volume attach pool1 myfsvol arch-02 testfs0 /data
lxc storage volume detach pool1 myfsvol arch-02 testfs0
```

上述命令本质还是将一个卷作为一个`disk`设备添加到容器实例

```shell
lxc config device add arch-02 testfs0 disk pool=pool0 source=myfsvol path=/data
```

> 还可以通过配置`limits.read limits.write limits.max`达到读写限速的目的

删除`pool0`下的卷`myvol`

```shell
lxc storage volume delete pool0 myvol
```

可以在不同的存储池之间拷贝用户创建的存储卷

```shell
lxc storage volume copy pool0/myvol pool1/myvol-cp
```

> 如果该卷有快照，可以加上`--volume-only`避免复制快照

移动或重命名

```shell
lxc storage volume move pool0/myvol pool1/myvol-mv
```

如果想要移动的不是`custom`而是容器实例`arch-01`，从`pool0`到`pool1`

```shell
lxc stop arch-01
lxc move arch-01 --storage pool1
```

也可以在不同的`lxd`服务器之间拷贝或移动

```shell
lxc storage volume copy local:pool0/myvol <target_remote>:pool0/newvol
```

### 1.10.6 存储卷用于备份

在`pool0`创建一个存储卷`backupvol`并用于备份与镜像

```shell
lxc config set storage.backups_volume pool0/backupvol
lxc config set storage.images_volume pool0/backupvol
```

### 1.10.7 备份存储卷

存储卷可以通过快照，导出等方法备份

**快照**

为`pool0`中的`myvol`卷创建一个快照`snapvol`

```shell
lxc storage volume snapshot pool0 myvol snapvol
```

恢复快照

```shell
lxc storage volume restore pool0 myvol snapvol
```

可以将快照恢复到其他地方

```shell
lxc storage volume copy pool0/myvol/snapvol pool1/testvol
```

删除快照

```shell
lxc storage volume delete pool0 myvol/snapvol
```

查看`myvol`的快照信息

```shell
lxc storage volume info pool0 myvol
```

显示`snapvol`信息

```shell
lxc storage volume show pool0 myvol/snapvol
```

可以编辑一个快照的配置

```shell
lxc storage volume edit pool0 myvol/snapvol
```

设置定时快照

```shell
lxc storage volume set pool0 myvol snapshots.schedule=@daily
```

**导出**

```shell
lxc storage volume export pool0 myvol ./myvol-bk.tar.gz
```

从文件恢复

```shell
lxc storage volume import pool0 ./myvol-bk.tar.gz myvol
```

## 1.11 网络管理

在初始化过程中我们创建了一个网桥`lxdbr0`，相当于我们的宿主机担当一个NAT网关（路由），容器实例通过虚拟以太网接口连接到该网关。这是最简单的配置。`lxdbr0`只有在`lxd`守护进程启动以后该才会创建，并且每启动一个容器实例时，`lxd`都会在宿主机以及容器内新建**一对**虚拟以太网接口（使用`ip link`查看）来互联，就像一个网络内多台主机连接到一个路由器。此时这些容器之间加上宿主机都可以互相ping通（因为宿主机就是路由），同时宿主机将容器访问外网的流量向有Internet连接的物理端口转发。而宿主机上层网络内的主机无法访问容器

### 1.11.1 容器网络接口

以下示例中，我们向容器`arch-01`添加一个新的接口`eth1`，连接到我们在宿主机创建的网桥`br0`

```shell
lxc config device add arch-01 eth1 nic nictype=bridged parent=br0
```

> 在`lxd`中，网络设备又称为NIC（Network Interface Controllers）。`lxd`可以向**容器**添加基于（宿主机的）`nic`或`network`网络设备建立的**网络接口**，其中`nic`为宿主机上不受`lxd`管辖的网络设备，而`network`是可以通过`lxc network`命令管辖的设备。基于宿主机`nic`设备创建的**容器内接口**需要使用`nictype`声明，而基于`network`设备概念和操作不同，见后文
>
> 上述示例中容器的`eth1`是基于宿主机网络设备`br0`创建的一个接口。`eth1`类型为`bridged`，它所关联的网桥`br0`是我们在主机自己创建的，所以使用`nictype`声明

常用的接口如下

> `lxd`建议使用`network`网络设备，方便操作。在没有分布式多主机的应用下，`bridged`接口已经足够。而`ovn`可以用于私有云

| 接口 | 适用宿主机设备 | 适用宿主机设备类型 | 解释 |
| :- | :- | :- | :- |
| `bridged` | `bridge`网桥 | `nictype` `network` | 基于宿主机已有的网桥创建一对虚拟以太网接口，将容器连接到该网桥 |
| `ovn` | `ovn`网络 | `network` | 基于已有的ovn网络创建一对虚拟网络接口，将容器连接到该ovn网络 |
| `physical` | `physical`物理网卡 | `nictype` `network` | 直接把宿主机的网卡分配给容器，宿主机不可再使用该网卡 |
| `macvlan` | `macvlan` | `nictype` `network` | 基于宿主机已有的网络设备新建一个设备，但是使用不同的MAC |
| `sriov` | `sriov` | `nictype` `network` | 需要物理设备支持SR-IOV |
| `ipvlan` | `ipvlan` | `nictype` | 基于宿主机已有的网络设备新建一个设备，使用相同的MAC，不同的IP |
| `p2p` | `p2p` | `nictype` | 仅仅创建一对虚拟接口 |
| `routed` | `routed` | `nictype` |  |

### 1.11.2 查看与配置

可以在宿主机上创建一个`network`给容器使用，宿主机上使用`lxd`可创建并管理的设备类型有`bridge ovn physical macvlan sriov`

查看宿主机上已经有的网络设备，通常会显示物理网卡以及我们在初始化时创建的`lxdbr0`

```shell
lxc network list
```

查看`lxdbr0`的配置以及运行状态

```shell
lxc network show lxdbr0
lxc network info lxdbr0
```

可以手动编辑`lxdbr0`的配置

```shell
lxc network edit lxdbr0
```

也可以通过以下命令进行单个变量的设置与重置

```shell
lxc network set lxdbr0 key=value
lxc network unset lxdbr0 key
```

### 1.11.3 使用网桥

示例，使用`lxc`创建一个新网桥`mybr0`，默认在`lxd`下这个网桥会通过`dnsmasq`为连接的容器实例提供DHCP，DNS服务以及IPv6相关的功能支持等

```shell
lxc network create mybr0 --type=bridge ipv4.address=.../24 ipv4.nat="true" ipv6.address=.../64 ipv6.nat="true" 
```

> 其余可以设置的变量有`bridge.hwaddr`宿主机端MAC地址，`ipv4.dhcp`是否开启DHCP，`ipv4.firewall`防火墙设置等

接下来将容器`arch-02`连接到该网桥

```shell
lxc network attach mybr0 arch-02 eth0
```

使用前述的方法也可以，需要使用`network`声明而不是`nictype`，无需声明类型为`bridged`

```shell
lxc config device add arch-02 eth0 nic network=mybr0
```

重命名`mybr0`为`lxdbr1`

```shell
lxc network rename mybr0 lxdbr1
```

删除`lxdbr1`

```shell
lxc network delete lxdbr1
```

### 1.11.4 使用独占物理网卡

物理网卡通常无法由`lxd`管理，需要通过以下命令添加

```shell
lxc config device add arch-01 eth1 nic nictype=physical parent=enp1s0
```

此时`enp1s0`从宿主机消失，想要恢复通过以下命令

```shell
lxc config device remove arch-01 eth1
```

### 1.11.5 和宿主机共用网卡和MAC

首先创建一个`macvlan`，名称为`lxd-macvlan0`

```shell
lxc network create lxd-macvlan0 --type=macvlan parent=enp1s0
```

将其添加到容器`arch-01`

```shell
lxc network attach lxd-macvlan0 arch-01 eth1
```

> 由于`lxd`对于容器虚拟网卡的自动ip配置仅限于`eth0`，所以需要额外配置。这里不再讲述

## 2 Docker

`docker`和`lxd`具有不同的定位，`lxd`主要用于整个操作系统的模拟，`lxd`的容器除内核和宿主机共用外都是独立的，拥有自己的init并可以管理服务，功能和虚拟机类似；而`docker`更多是为单个应用提供运行环境，主要是解决应用的缓存，配置，环境统一性等问题，其主要关注点在文件系统和进程的隔离上，多个应用通常需要使用多个`docker`容器

由于以上差别，`lxd`更多用于共享的（GPU）超算集群，而`docker`更多用于部署互联网服务

## 2.1 安装与配置

```shell
sudo pacman -S docker
```

如果已经安装了`lxd`，可能需要先向`DOCKER-USER`添加两条`iptables`防火墙规则，防止`lxd`无法联网。`docker`默认将全局的`FORWARD`设置为`DROP`

```shell
iptables -I DOCKER-USER -i lxdbr0 -o eth0 -j ACCEPT
iptables -I DOCKER-USER -o lxdbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

启动`docker`

```shell
sudo systemctl start docker
```

查看`docker`信息，此时普通用户需要`sudo`

```shell
sudo docker info
```

将想要使用`docker`的用户添加到`docker`组后登出，重新登录，并重启`docker`服务

```shell
su
usermod -a -G docker your-username
```

> 和`lxd`类似的，`docker`也是client-server软件，我们使用的`docker`命令行就是一个客户端，而我们通过`systemctl`启动的就是服务器。`docker`服务器重启或停止时所有容器实例都会重启或停止

和`lxd`一样，`docker`也只需使能`docker.socket`的自启动即可，用户运行`docker`客户端命令时`docker`服务器会自动触发启动

```shell
sudo systemctl enable docker.socket
sudo systemctl disable docker
sudo systemctl disable containerd
```

`docker`的配置文件放置于`/etc/docker/daemon.json`

```shell
sudo mkdir /etc/docker
sudo touch /etc/docker/daemon.json
sudo vim /etc/docker/daemon.json
```

配置如下，配置`log driver`，限制日志文件大小和数量，单个不超过`2m`字节，文件数不超过`5`个

```json
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "2m",
        "max-file": "5"
    }
}
```

之后重启`docker`服务

## 2.2 简单应用示例

### 2.2.1 创建应用镜像

应用打包就是将应用打包到一个`docker`镜像中，之后就可以基于该镜像启动容器实例运行服务

`docker`基于`Dockerfile`的描述构建这个镜像

基于`docker`官网的示例，我们尝试一个Node.js应用

```shell
git clone https://github.com/docker/getting-started.git
```

我们进入到仓库的`app`目录，创建一个`Dockerfile`

```shell
cd app
touch Dockerfile
```

```
# syntax=docker/dockerfile:1

FROM node:18-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
EXPOSE 3000
```

> 在`Dockerfile`中，我们指定想要使用`node:18-alpine`镜像，这是一个基于AlpineLinux的带有Node.js执行环境的容器镜像。下载解压镜像后将`/app`的内容放到容器中，并使用`yarn`依照`/app/package.json`安装依赖。`CMD`指定的是基于该镜像启动容器后需要执行的命令，这里是启动`node`。

构建镜像

```shell
docker build --platform linux/amd64 -t getting-started .
```

> `-t`指定的是此次构建镜像的名称（标签）。`.`指示`docker`在当前目录寻找`Dockerfile`

启动镜像，创建容器实例

```shell
docker run -dp 127.0.0.1:3000:3000 getting-started
```

> 我们启动了刚刚创建的镜像`getting-started`。由于之前在`Dockerfile`中指定服务运行在`3000`端口，所以需要使用`-p`参数将该端口映射到主机的`127.0.0.1:3000`，后面的`3000`就代表容器端口。`-d`表示`--detach`，让容器运行在后台

查看当前正在运行的容器实例，以及对应的镜像

```shell
docker ps
```

```
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                      NAMES
5628843613f3   getting-started   "docker-entrypoint.s…"   4 minutes ago   Up 4 minutes   127.0.0.1:3000->3000/tcp   boring_euclid
```

> 如果不通过`--names`参数指定名称，`docker`会随机进行命名，格式为形容词+`_`+名词，上例中为`boring_euclid`

停止运行中的容器实例

```shell
docker stop 5628843613f3
```

> 这里也可以使用`boring_euclid`指代该容器。`stop`结束以后的容器不能通过`docker ps`看到，需要通过`docker ps -a`查看，此时它还未被删除，并可以通过`start`再次启动

删除容器实例

```shell
docker rm 5628843613f3
```

### 2.2.2 DockerHub上传

注册账号，并创建一个`getting-started`仓库

使用注册时的用户名在本地登陆DockerHub

```shell
docker login -u your-username
```

为`getting-started`创建一个`tag`

```shell
docker tag getting-started your-username/getting-started:latest
```

> 结尾不显式指明`tag`默认就是`latest`。这里显式指明为`latest`

### 2.2.3 使用卷

在`docker`中，卷（`volume`）用于持久化存储，并在多个容器实例之间共享

创建卷`test-db`

```shell
docker volume create test-db
```

查看卷的信息

```shell
docker volume inspect test-db
```

```
[
    {
        "CreatedAt": "2023-07-19T17:51:48+01:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/test-db/_data",
        "Name": "test-db",
        "Options": null,
        "Scope": "local"
    }
]
```

> 上述信息指出了该卷在宿主机的路径，在容器中创建的文件都可以在该目录下查找到。可以多个容器同时使用该卷

删除并重新创建实例，挂载实例到容器的`/mnt/test-db`

```shell
docker rm -f 5628843613f3
docker run -dp 127.0.0.1:3000:3000 --mount type=volume,src=test-db,target=/mnt/test-db getting-started
```

### 2.2.4 Bind mount

`docker`的Bind mount主要用于和宿主机共享文件系统，可以将宿主机上的目录映射到容器里面使用。在应用开发时可以很方便的实现应用的自动重载和部署，而无需每次重新构建镜像

挂载`/home/username/repo`到容器下的`/src`

```shell
docker run -it --mount type=bind,src=/home/username/repo,target=/src getting-started
```

自动部署应用

```shell
docker run -dp 127.0.0.1:3000:3000 \
>   -w /app --mount type=bind,src=/home/username/repo,target=/app \
>   node:18-alpine \
>   sh -c "yarn install && yarn run dev"
```

> `-w`参数指定后面的shell指定执行的目录，为容器的`/app`，同时又将宿主机的`/home/username/repo`映射到这里。这里的自动部署基于`nodemon`实现，工程的`package.json`中指定了`dev`为`nodemon src/index.js`，`yarn run dev`后`nodemon`就会启动，并且在后续我们对源文件进行更改后会自动重启我们开发的应用

### 2.2.5 多容器应用

由于`docker`设计的初衷就是隔离运行环境，所以如果想要部署其他服务例如`mysql`，就只能运行在另外单独的容器中。应用程序和数据库服务器之间通过网络进行通信

查看当前`docker`已经有的网络

```shell
docker network ls
```

```
NETWORK ID     NAME      DRIVER    SCOPE
xxxxxxxxxxxx   bridge    bridge    local
xxxxxxxxxxxx   host      host      local
xxxxxxxxxxxx   none      null      local
```

为了让多个容器通信，首先我们创建一个网络`app-net`，默认类型为`bridge`网桥。创建后该网桥也可以通过`ip link`命令看到

```shell
docker network create app-net
```

创建一个`mysql`容器实例并加入到该网桥

```shell
docker run -d \
> --network app-net --network-alias mysql \
> --name sql-test \
> -v todo-mysql-data:/var/lib/mysql \
> -e MYSQL_ROOT_PASSWORD=secret \
> -e MYSQL_DATABASE=app-test \
> mysql
```

> 在我们没有事先创建卷的情况下，`docker`会自动帮我们创建，例如上例中的`todo-mysql-data`。这里的`--network-alias`指定访问主机名，作用类似于在网络内提供了指定主机的DNS或使用了NetBIOS，这样访问数据库就无需知道容器的IP地址了
>
> 和`lxd`类似的，`docker`在有容器实例连接到网桥以后也会创建虚拟以太网接口，此时`ip link`可以看到多出来的`vethxxxxx`接口
>
> `docker`建议在实际应用中不要使用上述方法指定MySQL的密码，使用`docker compose`

我们此时就可以尝试一下使用容器的`mysql`命令

```shell
docker exec -it sql-test mysql -u root -p
```

此后将其他容器连接到该网络就可以访问数据库

例如，我们使用一个工具容器`nicolaka/netshoot`来测试

```shell
docker run -it --network app-net nicolaka/netshoot
```

启动后运行以下命令请求一下`mysql`主机名，可以得到`mysql`容器的IP

```shell
dig mysql
```

重新创建并启动应用容器，使用以下命令，部署后的应用就会使用该数据库

```shell
docker run -dp 127.0.0.1:3000:3000 \
   -w /app -v "$(pwd):/app" \
   --network todo-app \
   -e MYSQL_HOST=mysql \
   -e MYSQL_USER=root \
   -e MYSQL_PASSWORD=secret \
   -e MYSQL_DB=todos \
   node:18-alpine \
   sh -c "yarn install && yarn run dev"
```

### 2.2.6 Compose示例

`docker`中Compose用于描述单、多容器应用，方便应用的快速部署，启动和停止，以及在不同机器间的迁移，是常用工具

`compose`需要通过以下命令安装

```shell
sudo pacman -S docker-compose
```

之后便可以使用`docker compose`命令

```shell
docker compose version
```

在我们之前克隆下来的`getting-started/app`中，创建一个`docker-compose.yml`，这就是描述文件，在实际应用中它随仓库一起参与`git`的版本控制

```yml
services:
  app:
    image: node:18-alpine
    command: sh -c "yarn install && yarn run dev"
    ports:
      - 127.0.0.1:3000:3000
    working_dir: /app
    volumes:
      - ./:/app
    environment:
      MYSQL_HOST: mysql
      MYSQL_USER: root
      MYSQL_PASSWORD: secret
      MYSQL_DB: todos
  mysql:
    image: mysql
    volumes:
      - todo-mysql-data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: todos
volumes:
  todo-mysql-data:
```

> 上述配置中，我们在`services`中分别描述了`app`以及`mysql`两个服务（服务可以取任何名字）以及对应的参数，这和我们使用命令行时传递的参数基本类似

直接在当前目录下执行以下命令启动该应用（事先删除之前的容器。该命令会依照`docker-compose.yml`，创建容器`app-app-1`和`app-mysql-1`，网桥`app_default`，以及卷`app_todo-mysql-data`）

```shell
docker compose up -d
```

此时可以查看日志，或显示指定服务的日志

```shell
docker compose logs -f
docker compose logs -f mysql
```

停止，依然在该目录下执行

```shell
docker compose down
```

此时容器实例以及网桥都会删除，但保留卷。如果想删除卷需要加`--volumes`参数

```shell
docker compose down --volumes
```

### 2.2.7 镜像构建优化

仅适用于使用`yarn`的Node.js应用

使用`docker image`的`history`功能可以看到每次执行镜像构建时的操作以及新增的文件大小，可以看到构建操作依照`Dockerfile`中的顺序执行

```shell
docker image history getting-started
```

这是之前的`Dockerfile`

```
# syntax=docker/dockerfile:1
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
```

> 以上`Dockerfile`存在一个问题，只要我们对工程文件进行了更改（例如更改了`src/static/index.html`），这点小小的更改会导致`yarn`重新执行一遍依赖的安装，速度很慢。为解决这个问题，我们需要在`COPY . .`之前就执行`yarn`

对`Dockerfile`作以下更改，在`yarn`执行之前先将`package.json yarn.lock`复制到容器中，保证`yarn`不会因为工程文件的更改而重新安装一遍依赖，同时依赖更改时可以检测出`package.json`的改动并自动安装

```
# syntax=docker/dockerfile:1
FROM node:18-alpine
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --production
COPY . .
CMD ["node", "src/index.js"]
```

同时在同目录下创建一个`.dockerignore`，防止`yarn`的包缓存目录`node_modules/`被重复复制

```
node_modules
```

构建镜像，工程更改时构建速度会快很多

```shell
docker build -t getting-started .
```

## 2.3 存储

## 2.4 网络

## 3 Kubernetes

K8s