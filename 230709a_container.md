# Linux容器和虚拟机

## 目录

+ [**1**](#1-lxd) LXD
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
        + [**1.11.5**](#1115-macvlan) macvlan
+ [**2**](#2-docker) Docker
    + [**2.1**](#21-安装与配置) 安装与配置
    + [**2.2**](#22-简单应用示例) 简单应用示例
        + [**2.2.1**](#221-创建应用镜像) 创建应用镜像
        + [**2.2.2**](#222-dockerhub上传) DockerHub上传
        + [**2.2.3**](#223-使用卷) 使用卷
        + [**2.2.4**](#224-bind-mount示例) Bind mount示例
        + [**2.2.5**](#225-多容器应用) 多容器应用
        + [**2.2.6**](#226-compose示例) Compose示例
        + [**2.2.7**](#227-镜像构建优化) 镜像构建优化
    + [**2.3**](#23-基本使用) 基本使用
        + [**2.3.1**](#231-创建与使用容器) 创建与使用容器
        + [**2.3.2**](#232-docker信息) docker信息
        + [**2.3.3**](#233-镜像) 镜像
        + [**2.3.4**](#234-日志) 日志
        + [**2.3.5**](#235-安全) 安全
    + [**2.4**](#24-存储管理) 存储管理
        + [**2.4.1**](#241-本地卷) 本地卷
        + [**2.4.2**](#242-第三方卷驱动) 第三方卷驱动
        + [**2.4.3**](#243-bind-mount) bind mount
        + [**2.4.4**](#244-tmpfs) tmpfs
        + [**2.4.5**](#245-存储驱动) 存储驱动
    + [**2.5**](#25-网络管理) 网络管理
        + [**2.5.1**](#251-网桥) 网桥
        + [**2.5.2**](#252-共享主机网络) 共享主机网络
        + [**2.5.3**](#253-macvlan) macvlan
    + [**2.6**](#26-docker-build) Docker Build
        + [**2.6.1**](#261-dockerfile) Dockerfile
        + [**2.6.2**](#262-上下文) 上下文
        + [**2.6.3**](#263-多阶段构建) 多阶段构建
        + [**2.6.4**](#264-builders) Builders
        + [**2.6.5**](#265-输出) 输出
    + [**2.7**](#27-docker-compose) Docker Compose
        + [**2.7.1**](#271-基本用法) 基本用法
        + [**2.7.2**](#272-环境变量) 环境变量
        + [**2.7.3**](#273-profile) Profile
        + [**2.7.4**](#274-使用gpu) 使用GPU
        + [**2.7.5**](#275-网络配置) 网络配置
        + [**2.7.6**](#276-卷) 卷
+ [**3**](#3-kubernetes) Kubernetes
+ [**4**](#4-containerd) containerd
+ [**5**](#5-kata-containers) Kata Containers
+ [**6**](#6-qemu) QEMU
    + [**6.1**](#61-先行检查) 先行检查
    + [**6.2**](#62-qemu使用简介) QEMU使用简介
        + [**6.2.1**](#621-创建磁盘镜像) 创建磁盘镜像
        + [**6.2.2**](#622-通过光盘镜像安装) 通过光盘镜像安装
        + [**6.2.3**](#623-运行) 运行
        + [**6.2.4**](#624-iommu的基本配置) IOMMU的基本配置
        + [**6.2.5**](#625-一些性能调优方法) 一些性能调优方法
    + [**6.3**](#63-qemu命令行完整参考) QEMU命令行完整参考
+ [**7**](#7-virtualbox) VirtualBox
+ [**8**](#8-vagrant) Vagrant
+ [**9**](#9-libvirt) libvirt
+ [**10**](#10-podman) Podman
    + [**10.1**](#101-普通用户使用) 普通用户使用
    + [**10.2**](#102-登录容器仓库) 登录容器仓库
    + [**10.3**](#103-容器镜像) 容器镜像
        + [**10.3.1**](#1031-远程镜像) 远程镜像
        + [**10.3.2**](#1032-containerfile) Containerfile
    + [**10.4**](#104-卷) 卷
        + [**10.4.1**](#1041-podman-unshare) podman unshare
    + [**10.5**](#105-网络) 网络
    + [**10.6**](#106-使用systemd管理容器) 使用systemd管理容器
    + [**10.7**](#107-补充) 补充
        + [**10.7.1**](#1071-暂停容器) 暂停容器
+ [**11**](#11-专题sr-iov) 专题：SR-IOV
+ [**12**](#12-专题linux-cgroup) 专题：Linux cgroup
    + [**12.1**](#121-cgroup基本概念) cgroup基本概念
    + [**12.2**](#122-cgroup-v1) cgroup v1
    + [**12.3**](#123-cgroup-v2) cgroup v2
    + [**12.4**](#124-namespaces) namespaces
    + [**12.5**](#125-使用cgroup) 使用cgroup
+ [**13**](#13-ioi容器工具isolate) IOI容器工具：isolate

## 1 LXD

ArchLinux下，基于LXD

https://wiki.archlinux.org/title/Linux_Containers

https://wiki.archlinux.org/title/LXD

https://documentation.ubuntu.com/lxd/en/latest/

> LXD已经被商业公司Canonical接管。正如MySQL被Sun收购一样（现Oracle），历史再次重演，LXD的Fork版本Incus已经诞生（[2023.8.7](https://linuxcontainers.org/incus/)）。截至2023.10.11，Incus 0.1已经进入ArchLinux AUR，在以后将会替换LXD。而仓库的LXD已经不再更新
>
> 更新：Incus已经进入extra，可以直接通过Arch仓库安装
>
> 在AlpineLinux下需要安装`incus incus-client incus-openrc incus-utils`。命令行中使用`incusd`取代`lxd`，`incus`取代`lxc`。初始化使用命令`incus admin init`。将需要使用`incus`的用户加入`incus`组。加入`incus-admin`组可以得到额外的管理权限
>
> [ArchWiki](https://wiki.archlinux.org/title/Incus)给出了迁移到Incus的方法以及一些初始配置。Incus的用法和LXD基本相同，不再讲述

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
| archlinux/arm64 (2 more)         | 2ef34a0eb3be | yes    | Archlinux current arm64 (20230709_04:18) | aarch64      | CONTAINER       | 176.12MB  | Jul 9, 2023 at 12:00am (UTC) |
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

使用上面的`FINGERPRINT`（可以只输入几位），通过`launch`命令创建Archlinux容器并启动，容器名称为`arch-01`（称为一个`instance`）。容器实例是non-volatile的，电脑重启后依然在并可以使用（默认路径在`/var/lib/lxd/containers`）

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

在初始化过程中我们创建了一个网桥`lxdbr0`，它可以连通我们的宿主机以及容器，此时相当于我们的宿主机担当一个NAT网关（路由），容器实例通过虚拟以太网接口连接到该网关。这是最简单的配置。`lxdbr0`只有在`lxd`守护进程启动以后该才会创建，并且每启动一个容器实例时，`lxd`都会在宿主机以及容器内新建**一对**虚拟以太网接口（使用`ip link`查看）来互联，就像一个网络内多台主机连接到一个路由器。此时这些容器之间加上宿主机都可以互相ping通（因为宿主机就是路由），同时宿主机将容器访问外网的流量向有Internet连接的物理端口转发。而宿主机上层网络内的主机无法访问容器

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

### 1.11.5 macvlan

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

`docker`和`lxd`本质都是容器管理工具，但是`docker`和`lxd`具有不同的定位。`lxd`主要用于整个操作系统的模拟，`lxd`的容器通常有较为健全的功能，可以管理服务，有更强大的硬件配置功能，整体功能和虚拟机类似，但相比之下内存浪费更少；而`docker`更多是为单个应用提供轻量化的运行环境，主要是解决应用的缓存，配置，依赖，环境统一性等问题，多个应用通常需要使用多个`docker`容器

通常`lxd`使用完整的操作系统镜像，主要是完整的发行版镜像；而`docker`不一定使用完整的发行版镜像（虽然也可以支持），而是使用面向一种特定服务的定制最小化镜像（去除了大部分常用Linux系统工具，只保留非常基本的命令）

由于以上差别，`lxd`更多用于共享的（GPU）计算集群，可以作为虚拟机的类似替代品使用；而`docker`更多用于部署互联网服务，尤其是一些需要灵活调整容量的场合

## 2.1 安装与配置

```shell
sudo pacman -S docker
```

如果已经安装了`lxd`，可能需要先向`DOCKER-USER`添加两条`iptables`防火墙规则，防止`lxd`无法联网。`docker`默认将全局的`FORWARD`设置为`DROP`

```shell
iptables -I DOCKER-USER -i lxdbr0 -o eth0 -j ACCEPT
iptables -I DOCKER-USER -o lxdbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

> 如果还没有安装配置过`lxd`，需要配置`/etc/subuid /etc/subgid`，[见前](#11-安装与配置)

启动`docker`

```shell
sudo systemctl start docker
```

查看`docker`信息，此时普通用户需要`sudo`

```shell
sudo docker info
```

将想要使用`docker`的用户添加到`docker`组后登出，重新登录，并重启`docker`服务，后续就无需`sudo`

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

配置如下，配置`log driver`，限制日志文件大小和数量，单个不超过`2M`字节，文件数不超过`5`个

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

可以先看后面的[基本使用](#23-基本使用)

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

> 构建镜像就是将我们的应用部署到下载的镜像中，并重新构建镜像。`-t`指定的是此次构建镜像的名称（标签）。`.`指示`docker`在当前目录寻找`Dockerfile`

启动镜像，创建容器实例

```shell
docker run -dp 127.0.0.1:3000:3000 getting-started
```

> 我们启动了刚刚创建的镜像`getting-started`。由于之前在`Dockerfile`中指定服务运行在`3000`端口，所以需要使用`-p`参数将该端口映射到主机的`127.0.0.1:3000`，后面的`3000`就代表容器端口。`-d`表示`--detach`，让容器运行在后台

查看当前的容器实例，以及对应的镜像

```shell
docker ps -a
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

删除容器实例。如果此时容器未停止，需要添加`-f`参数删除

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

根据DockerHub的指示上传镜像

### 2.2.3 使用卷

在`docker`中，卷（`volume`）用于持久化存储，并可以在多个容器实例之间共享

创建卷`test-db`

```shell
docker volume create test-db
```

查看卷的信息

```shell
docker volume inspect test-db
```

```json
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

> 上述信息`Mountpoint`指出了该卷在宿主机的路径，在容器中创建的文件都可以在该目录下查找到。可以多个容器同时使用该卷

删除并重新创建实例，挂载实例到容器的`/mnt/test-db`

```shell
docker rm -f 5628843613f3
docker run -dp 127.0.0.1:3000:3000 --mount type=volume,src=test-db,target=/mnt/test-db getting-started
```

### 2.2.4 Bind mount示例

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

> `-w`参数指定后面的shell指定执行的目录，为容器的`/app`，同时又将宿主机的`/home/username/repo`映射到这里。这里的自动部署基于Node.js的`nodemon`实现，工程的`package.json`中指定了`dev`为`nodemon src/index.js`，`yarn run dev`后`nodemon`就会启动，并且在后续我们对源文件进行更改后会自动重启我们开发的应用

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
>  -w /app -v "$(pwd):/app" \
>  --network todo-app \
>  -e MYSQL_HOST=mysql \
>  -e MYSQL_USER=root \
>  -e MYSQL_PASSWORD=secret \
>  -e MYSQL_DB=todos \
>  node:18-alpine \
>  sh -c "yarn install && yarn run dev"
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

同时在`Dockerfile`同目录下创建一个`.dockerignore`，防止`yarn`的包缓存目录`node_modules/`被重复复制

```
node_modules
```

构建镜像，工程更改时构建速度会快很多

```shell
docker build -t getting-started .
```

## 2.3 基本使用

### 2.3.1 创建与使用容器

先看[下载镜像](#233-镜像)

查看当前所有容器

```shell
docker ps -a
# = docker container ls -a
```

显示一个容器的详细信息

```shell
docker container inspect alpine-test
```

基于镜像`alpine:latest`创建容器`alpine-test`，但不启动

```shell
docker create --name alpine-test alpine:latest
# = docker container create --name alpine-test alpine:latest
```

可以在后面指定容器启动后在（容器内）前台执行的程序

```shell
docker create --name alpine-test alpine:latest some-front-daemon
```

> 默认情况下创建的容器在后台运行，不能使用shell。上述的`alpine`官方镜像由于没有指定容器中前台运行的服务程序，**如果不指定该前台程序容器启动后会立即退出**

如果想要在启动后使用终端，创建容器时需要加`-i -t`参数。这样创建出来的容器会一直等待我们`attach`终端（`detach`后依旧运行），我们在容器内`exit`退出后由于`sh`终止，容器才立即终止运行

```shell
docker create --name alpine-test -it alpine:latest
```

删除容器

```shell
docker rm alpine-test
# = docker container rm alpine-test
```

删除所有未在运行的容器

```shell
docker container prune
```

重命名容器

```shell
docker rename alpine-test alpine-one
# = docker container rename alpine-test alpine-one
```

常用参数

| 参数 | 作用 |
| :- | :- |
| `--name` | 容器名，`docker ps -a`显示的名字 |
| `--hostname` | 容器主机名，`/etc/hostname` |
| `--network-alias` | 只能用于用户自己创建的网桥网络，指定容器的网络名，相较IP访问更方便 |
| `--network` | 连接到[网络](#25-网络管理)，只能一个。不指定默认连接到`bridge` |
| `--publish -p` | 将容器端口映射到主机端口，例如容器`80`映射到主机`8080`使用`8080:80`，见[网络](#25-网络管理) |
| `--mount` | 挂载一个卷或`bind mount`或`tmpfs`到容器，见[存储](#24-存储管理)。挂载已有卷添加`src=,dst=`参数即可 |
| `--volume -v` | 见[存储](#24-存储管理) |
| `--volume-driver` | 见[存储](#24-存储管理)，使用卷驱动（若卷没有事先创建，可以指定） |
| `--volumes-from` | 后加运行中的容器名，将指定容器的卷也挂载到新建容器的相同目录下 |
| `--interactive -i` | 保持STDIN开启 |
| `--tty -t` | 分配虚拟终端，经常和`-i`连用 |
| `--rm` | 容器退出后自动删除 |
| `--read-only` | 只读挂载容器根文件系统 |
| `--cpus` | 指定CPU内核数量 |
| `--cpu-shares -c` | 多个容器运行时本容器被分配的CPU时间比例，默认为`1024`，可以设置为`512 2048 4096`等，例如三个容器分别为`1024 512 512`，那么第一个容器分配50%资源 |
| `--cpuset-cpus` | 指定运行的CPU序号，格式示例`0,3-5` `2,3` `5-8` |
| `--cpuset-mems` | 在NUMA上指定内存节点序号，格式同上 |
| `--memory -m` | 内存限制 |
| `--kernel-memory` | 内核内存限制 |
| `--dns` | 指定DNS服务器地址 |
| `--ip --ip6` | 指定容器IP |
| `--mac-address` | 指定容器MAC |
| `--env -e` | 设置容器环境变量 |
| `--log-driver --log-opt` | 日志驱动和选项 |
| `--user -u` | 指定容器中运行程序的用户（默认`root`），覆盖`Dockerfile`的`US正在运行ER`配置 |
| `--workdir -w` | 指定容器中运行程序的目录（默认`/`），覆盖`Dockerfile`的`WORKDIR`配置 |

设备相关

| 参数 | 作用 |
| :- | :- |
| `--gpus` | 分配GPU，需要事先安装`nvidia-container-runtime`。`'"device=0,2"'`分配GPU0和2，`device=GPU-3a23c669-1f69-c64e-cf85-44e9b07e7a2a`基于UUID指定，`all`分配所有GPU |
| `--device` | 允许容器访问宿主机设备，例如`/dev/snd:/dev/snd`。`/dev/sda:/dev/xvdc:r`将宿主机的`/dev/sda`只读映射到容器的`/dev/xvdc` |

容器的配置可以在创建以后更改（需要停止运行容器），使用`docker update`。可更改参数有`--cpu-shares --cpus --cpuset-cpus --cpuset-mems --memory`等参数

```shell
docker update --cpus 4 alpine-test
# = docker container update --cpus 4 alpine-test
```

启动容器`alpine-test`

```shell
docker start alpine-test
# = docker container start alpine-test
```

显示运行时资源使用状态

```shell
docker stats --all
# = docker container stats --all
docker stats alpine-test
# = docker container stats alpine-test
```

显示容器`top`

```shell
docker top alpine-test
# = docker container top alpine-test 
```

如果想要使用容器的终端，`docker attach`即可

```shell
docker attach alpine-test
# = docker container attach alpine-test
```

也可以直接启动时`--attach`

```shell
docker start --attach -i alpine-test
```

退出detach时需要使用组合键，默认为`CTRL-p CTRL-q`（不适用于非`shell`的情况，例如启动后执行`top`），**此时容器不会停止运行**

停止容器`alpine-test`

```shell
docker stop alpine-test
# = docker container stop alpine-test
```

或`docker kill`，在运行出现异常的情况下有用

```shell
docker kill nginx-test
# = docker container kill nginx-test
```

重启`alpine-test`

```shell
docker restart alpine-test
# = docker container restart alpine-test
```

`docker run`命令只是相当于`create`和`start`的快捷方式，可用参数和`docker create`基本相同，常用于单次执行一个程序

`docker run`有一个常用参数`-d`，表示`detached`，相当于`docker create`的默认模式（在后台运行）。因为`docker run -it`相当于`docker create -it`后`docker start --attach -i`，所以要使用`-d`显式指明`detached`

> `docker run`经常添加`--rm`参数使容器在退出后删除

容器启动在后台运行，执行一个`some-front-daemon`

```shell
docker run -d --rm --name alpine-test alpine:latest some-front-daemon 
```

或不执行`some-front-daemon`，等待`attach`

```shell
docker run -dit --rm --name alpine-test alpine:latest
docker attach alpine-test
```

或直接`attach`到shell

```shell
docker run -it --rm --name alpine-test alpine:latest
```

> `docker`中容器启动后执行的程序也可以通过`Dockerfile`指定，并在打包镜像、创建容器后执行。类似于`alpine`官方镜像这样的镜像由于没有指定启动后执行的服务程序，所以容器启动后会直接退出，必须使用`-it`创建。而我们在前面的示例中打包的镜像`getting-started`由于在`Dockerfile`中使用`CMD`指定了启动后立即执行的`nodejs`服务，所以它不会立即退出

在容器中执行一个程序

```shell
docker exec alpine-test ls / # 直接执行一条命令，列出根目录 
docker exec -it alpine-test sh # 和直接进入shell效果相同
docker exec -d alpine-test some-daemon # 后台运行，不占用当前终端
docker exec -d --user your-username alpine-test ls ～ # 以指定用户运行 
```

可以在容器和宿主机当前目录之间复制文件或目录

```shell
docker cp ./config.yml alpine-test:/app/
docker cp alpine-test:/etc/hosts ~/
```

显示容器相比镜像更改的文件

```shell
docker diff alpine-test
# = docker container diff alpine-test
```

> `A`表示新建，`D`表示删除，`C`表示更改

等待容器退出，并打印退出码。常用于脚本

```shell
docker wait alpine-test
# = docker container wait alpine-test
```

`docker commit`可以将容器实例发生的更改添加到镜像中（不包括卷）。`docker`推荐使用`Dockerfile`以及`docker build`进行这些操作

```shell
docker commit alpine-test username/alpine-modified:latest
# = docker container commit alpine-test username/alpine-modified:latest
```

可以添加作者以及message


```shell
docker commit --author "My Name <user@gmail.com>" -m "updated" alpine-test username/alpine-modified:latest
```

导出一个容器的文件系统，常用于备份（不包含`volume`）

```shell
docker export -o alpinefs.tar alpine-test
# = docker container export -o alpinefs.tar alpine-test
```

导入一个容器

```shell
docker import https://example.com/container.tgz
# = docker container import https://example.com/container.tgz
docker import ./container.tgz
```

> 注意`export import`是用于容器的，而`save load`是用于[镜像](#233-镜像)的

### 2.3.2 docker信息

显示`docker`全局信息

```shell
docker info
# = docker system info
```

`system`为`docker`管理命令

```shell
docker system df # 显示当前docker占用磁盘
docker system prune # 删除所有无用数据
docker system events # 监听工具，监听docker服务器事件，例如attach，容器启动等
```

### 2.3.3 镜像

显示当前本地已有的镜像

```shell
docker images
# = docker image ls
```

在DockerHub查找AlpineLinux（`alpine`），可以过滤掉除官方镜像以外的镜像

```shell
docker search --filter is-official=true alpine
```

下载`alpine`最新镜像`alpine:latest`（`latest`为`tag`）

```shell
docker image pull alpine:latest
```

> 可用的`tag`可以到DockerHub查看，例如`alpine`的位于 https://hub.docker.com/_/alpine/tags

查看镜像的更新记录

```shell
docker image history alpine
```

查看镜像详细信息

```shell
docker image inspect alpine
```

删除`alpine:latest`

```shell
docker image rm alpine:latest
# = docker rmi alpine:latest
```

删除所有未使用的镜像

```shell
docker image prune
```

为本地镜像`0e5574283393`创建一个标签

```shell
docker image tag 0e5574283393 debian-test:v1.0
```

使用`push`上传镜像到DockerHub前先登陆账号，再给要上传的镜像创建标签

```shell
docker login user-id
docker tag nginx-test:latest user-id/nginx:latest
docker image push user-id/nginx:latest
docker logout
```

可以上传一个镜像的所有`tag`

```shell
docker image push --all-tags user-id/nginx
```

打包一个镜像并导出到当前目录

```shell
docker save alpine:latest -o alpine.tar
# = docker image save alpine:latest -o alpine.tar
```

将镜像`alpine.tar`导入到`docker`

```shell
docker load -i alpine.tar
# = docker image load -i alpine.tar
```

构建镜像，当前目录`.`作为上下文，`Dockerfile`位于当前目录


```shell
docker build -t custom:latest .
```

> `-t`指定构建出镜像的`tag`。此外，还可以通过`--platform`（`linux/amd64`）指定平台
>
> 除此之外，上下文也可以是`https://github.com/docker/rootfs.git#container:docker`这样的`git`仓库名，`container`分支，`docker`目录。还可以是一个`.tar.gz`格式的包，可以支持远程下载例如`http://server/context.tar.gz`

删除构建镜像缓存

```shell
docker builder prune
```

### 2.3.4 日志

查看容器`nginx-test`的日志，可用于诊断错误

```shell
docker logs nginx-test
# = docker container logs nginx-test
```

> `docker`的容器日志内容就是基本相当于以交互模式运行容器时，从终端输出的内容，主要有系统信息，服务的启动等
>
> 很多服务程序由于在默认配置下不会将运行时日志输出到标准输出，所以需要更改。`docker`的官方`nginx`和`httpd`镜像都已经更改了日志配置

**日志驱动**

和网络、存储一样，`docker`的日志也有驱动的概念，以实现不同的日志形式。以下为常用日志驱动

| 驱动 | 描述 | 支持的opts |
| :- | :- | :- |
| `none` | 不使用日志 |  |
| `local` | 支持log-rotation的本地日志，`docker`推荐使用 | `max-size max-file compress` |
| `json-file` | json格式 | `max-size max-file compress labels env` |
| `syslog` | 使用系统的`syslog`服务 | `syslog-address syslog-facility tag syslog-format labels env`等 |
| `journald` | 使用系统的`journald`服务 | `tag labels env` |
| `awslogs` | Amazon CloudWatch | 略 |
| `gcplogs` | Google Cloud Platform | 略 |
| `logentries` | Rapid7 Logentries | `logentries-token line-only` |

`docker`默认的日志驱动为`json-file`，日志使用json格式记录存储。但是`json-file`不支持log-rotation（[前面](#21-安装与配置)我们也配置了`json-file`限制了日志大小），目前`docker`推荐使用`local`驱动，该驱动支持log-rotation。使用`json-file`只是历史原因，为兼容考虑

想要更改默认驱动为`local`，更改`/etc/docker/daemon.json`重启`docker`。没有需求可以不添加`log-opts`，默认也行

```json
{
  "log-driver": "local",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
  }
}
```

在创建运行容器时也可以通过`--log-driver --log-opt`指定日志驱动，**它会覆盖我们配置的默认驱动**

```shell
docker run -it --log-driver json-file --log-opt max-size=5m --name alpine-test alpine:latest
```

默认情况下，**容器输出到日志驱动是没有缓冲且受阻塞控制的**。可以将模式改成有缓冲的`non-blocking`模式，并指定缓冲大小，否则在日志压力较大时可能导致一些程序的异常。这适用于所有日志驱动，也可以在`daemon.json`中配置

```shell
docker run -it --log-opt mode=non-blocking --log-opt max-buffer-size=4m --name alpine-test alpine:latest
```

`file-json`使用`--label`和`--env`（`-e`）为该容器的日志添加标签，方便区分

```shell
docker run -dit --label production_status=testing -e os=ubuntu alpine:latest
```

**dual-logging**

`docker`所谓的`dual-logging`就是即便使用非本地日志驱动时，依旧可以在宿主机使用`docker logs`查看日志，因为`docker`在使用非本地日志同时使用`local`驱动将日志记录在本地（默认`"max-size": "20m", "max-file": "5"`）

使用`dual-logging`默认无需增加额外配置，直接使用非本地日志驱动即可，`docker`会自动`dual-logging`。除非通过`--log-opt cache-disabled=true`显式禁用`dual-logging`

**查看docker服务日志**

上述内容都是容器日志，不包含`docker`服务本身的日志

`docker`服务日志通过以下命令查看

```shell
journalctl -xu docker.service
```

### 2.3.5 安全

如果有必要，可以配置`docker`服务器不以`root`运行，原先的配置都是以`root`运行`docker`服务器（容器以非`root`运行）

首先确保配置了`/etc/subuid /etc/subgid`

ArchLinux安装`fuse-overlayfs`

```shell
sudo pacman -S fuse-overlayfs
```

在`/etc/sysctl.conf`加一行

```
kernel.unprivileged_userns_clone=1
```

执行一下

```shell
sudo sysctl --system
```

禁用`docker`

```shell
sudo systemctl disable --now docker.service docker.socket
```

执行以下安装脚本，无需`sudo`，运行完根据提示配置`$PATH`和`$DOCKER_HOST`环境变量

```shell
curl -fsSL https://get.docker.com/rootless | sh
```

会将rootless安装到当前用户家目录`~/bin`

卸载方法省略

以用户身份启动`docker`

```shell
systemctl --user start docker
```

## 2.4 存储管理

`docker`和`lxd`类似，容器实例本身有存储功能，但随着容器被删除这些数据也会消失。除了将数据存放到容器内以外，`docker`一共支持3种类型的额外存储，分别为卷`volume`，`bind mount`，以及`tmpfs`

卷`volume`是持久化存储，只能由`docker`管理，是`docker`最推荐的额外数据存储方式（一般用于数据库等）

> 卷`volume`主要特性：多容器间文件共享（多容器使用同一个卷）；指定名称的卷未创建时自动创建；支持云存储协议；可以备份；空卷挂载到原先有文件的目录时，目录中的文件会被复制到空卷中
>
> 每一个卷都有卷驱动`volume driver`
>
> `docker`建议在应用开发过程中使用`Dockerfile`将文件复制到容器，而不是使用`bind mount`
>
> 默认不给出本地卷类型时，卷放置于宿主机的`/var/lib/docker/volumes`目录。不能使用其他命令（例如`cp rm mkdir`）更改该目录下的东西

`bind mount`也是持久化存储，但不能通过`docker`管理，可以映射主机上的任意目录，可以被宿主机程序访问更改，有时用于容器和宿主机之间共享文件。`bind mount`使用不当会导致严重的安全问题

> `bind mount`主要特性：共享主机文件，`docker`默认将宿主机的`/etc/resolv.conf`映射到容器提供DNS配置

`tmpfs`相当于在宿主机内存中开辟一片存储，是非持久化存储

> `tmpfs`主要特性：用于无需持久化的临时数据；性能较高

### 2.4.1 本地卷

每一个卷都有一个卷驱动`volume driver`。`local`本地卷驱动最常用，同时也是没有显式指定卷驱动时使用的默认卷驱动。`local`驱动支持的文件系统类型`type`（注意这个`type`和`type=volume`的`type`不是同一个，这个`type`在创建`volume`时通过`-o`指定）有`ext4 nfs cifs`以及默认为空（`/var/lib/docker/volumes`）等

**所有类型的卷使用**`docker volume create`**创建后，只需在**`docker run`**命令中通过**`--mount`**选项的**`src`**和**`dst`**指定即可，**`--mount`**无需额外参数**

显示当前已有的卷

```shell
docker volume ls
```

创建卷`my-vol`

```shell
docker volume create my-vol
```

查看`my-vol`信息

```shell
docker volume inspect my-vol
```

```
[
    {
        "CreatedAt": "2023-0xxxxxxxxxxxxxx",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/my-vol/_data",
        "Name": "my-vol",
        "Options": null,
        "Scope": "local"
    }
]
```

删除卷`my-vol`

```shell
docker volume rm my-vol
```

删除所有没用的卷（没有分配给任何一个容器的卷）

```shell
docker volume prune
```

基于`nginx:latest`镜像创建容器实例`nginx-test`并使用刚刚创建的`my-vol`，挂载到容器的`/app`。挂载参数可以使用`--mount`或`-v`（`--volume`）指定

```shell
docker run -d \
> --name nginx-test \
> --mount source=my-vol,target=/app \ # source和src同义，target和dst，destination同义 \
> nginx:latest
```

或

```shell
docker run -d \
> --name nginx-test \
> -v my-vol:/app \
> nginx:latest
```

> `-v`后使用`:`分隔的参数必须按顺序，`my-vol`为卷名，`/app`为卷在容器中的位置。后面还可以加参数，例如`ro`只读

只读挂载卷加参数更改如下

```shell
docker run -d \
> --name nginx-test \
> --mount source=my-vol,target=/app,readonly \
> nginx:latest
```

或

```shell
docker run -d \
> --name nginx-test \
> -v my-vol:/app:ro \
> nginx:latest
```

不事先`docker volume create`，直接创建新卷并使用，需要指定更多参数

```shell
docker run -d \
> --name nginx-test \
> --mount type=volume,volume-driver=local,source=my-vol,target=/app,readonly \
> nginx:latest
```

在`docker compose`（`docker-compose.yml`）中使用卷

```yml
services:
  app:
    image: node:18-alpine
    volumes:
      - my-vol2:/app
volumes:
  my-vol2:
```

> 上述`compose`会在`docker compose up`时自动创建一个卷`my-vol2`并挂载到`/app`

如果`my-vol2`是已有卷，需要指定外部引用

```yml
services:
  app:
    image: node:18-alpine
    volumes:
      - my-vol2:/app
volumes:
  my-vol2:
    external: true
```

创建`NFSv3`卷`vol-nfsv3`，使用NFS服务器的`/home/fs`

```shell
docker volume create --driver local \
> -o type=nfs \
> -o o=addr=192.168.1.182,rw \
> -o device=:/home/fs \
> vol-nfsv3
```

创建`NFSv4`卷

```shell
docker volume create --driver local \
> -o type=nfs \
> -o o=addr=192.168.1.182,rw,nfsvers=4,async \
> -o device=:/home/fs \
> vol-nfsv4
```

创建`CIFS/Samba`卷

```shell
docker volume create --driver local \
> -o type=cifs \
> -o device=//smb-host/fs \
> -o o=addr=smb-host,username=your-name,password=your-secret,file_mode=0777,dir_mode=0777 \
> vol-samba
```

卷也可以是一个**块设备**，下面示例中设`/dev/sda2`为`ext4`格式的磁盘

```shell
docker volume create --driver local \
> -o type=ext4 \
> -o device=/dev/sda2 \
> vol-sda2
```

如果是想使用磁盘映像文件，需要事先创建`loop`设备（例如`/dev/loop0`），再使用上述相同方法创建卷。如下示例`raw.img`为`ext4`格式

```shell
mkfs.ext4 raw.img
sudo losetup -f show raw.img
```

如果想要在创建容器实例同时新建上述类型的卷，`docker run`命令需要使用`volume-opt`指定上述由`-o`指定的参数，如下示例

```shell
docker run -d \
> --name nginx-test \
> --mount 'type=volume,source=vol-nfsv4,target=/app,volume-driver=local,volume-opt=type=nfs,volume-opt=device=:/home/fs,"volume-opt=o=addr=192.168.1.182,rw,nfsvers=4,async"' \
> nginx:latest
```

备份卷可以通过很多种方法，例如通过`bind mount`，将容器中卷的挂载点打成包放入，这里不再讲述

### 2.4.2 第三方卷驱动

其他非本地卷例如`sshfs`需要使用第三方卷驱动

只要对应主机开启`sshd`并且权限允许，容器就可以使用`sshfs`卷

安装`vieux/sshfs`驱动，是一个插件

```shell
docker plugin install --grant-all-permissions vieux/sshfs
```

创建一个`sshfs`卷`ssh-volume`，该卷使用用户名`sshaccess`访问位于主机`sshserver`上的`/home/fs`，`sshaccess`的密码为`sshsecret`

```shell
docker volume create --driver vieux/sshfs \
> -o sshcmd=sshaccess@sshserver:/home/fs \
> -o password=sshsecret \
> vol-sshfs
```

创建容器实例使用`ssh-volume`

```shell
docker run -d \
> --name sshfs-test \
> --mount src=vol-sshfs,dst=/app \
> nginx:latest
```

### 2.4.3 bind mount

`bind mount`直接挂载宿主机上的任意目录

`bind mount`由于不能使用`docker volume`创建和管理，所以通常在创建容器时指定

```shell
docker run -d -it \
> --name nginx-test \
> --mount type=bind,src=/home/repos/dev,dst=/app \
> nginx:latest
```

或

```shell
docker run -d -it \
> --name nginx-test \
> -v /home/repos/dev:/app \
> nginx:latest
```

> 使用`-v`参数时会自动检测给出的`src`是否为宿主机目录还是已有卷名，决定`volume`还是`bind`
>
> 同理，想要只读使用`bind mount`只需相应的添加`readonly`以及`ro`即可

在`docker compose`中使用`bind mount`

```yml
services:
  app:
    image: node:18-alpine
    volumes:
      - type: bind
        source: /home/repos/dev
        target: /app
```

### 2.4.4 tmpfs

`tmpfs`和`volume` `bind mount`有一个重要不同是它不能在多个容器之间共享，且只能在Linux宿主机上使用

```shell
docker run -d -it \
> --name nginx-test \
> --mount type=tmpfs,dst=/app,tmpfs-size=2G \
> nginx:latest
```

或

```shell
docker run -d -it \
> --name nginx-test \
> --tmpfs /app \
> nginx:latest
```

查看容器的信息

```shell
docker inspect nginx-test --format ''
```

### 2.4.5 存储驱动

重点

存储驱动`storage driver`是和`volume`不相关的概念，要和`volume`的`volume driver`区分开

> `volume`适用于存储需要频繁写，长期保存（超出容器生命周期），以及需要在多容器间共享的数据，例如数据库等
>
> `storage driver`主要用于镜像以及容器实例本体
>
> 镜像和容器本体是一种渐进、层叠式的存储结构，类似于`git`的版本控制，或者`qemu`的增量镜像，只通过创建新层（快照）记录相比之前的镜像更改的内容，而原先的层对于其他镜像/容器来说依然可用。这样可以避免不必要的数据冗余，例如在创建多个采用相同镜像的容器实例时，就无需重复原先镜像的数据，共用一份即可。这也是为什么我们无法删除还在应用中的（有容器实例使用的）镜像。`storage driver`的作用就是管理这些渐进层叠式的数据文件
>
> `storage driver`缺点是不适用于存在大量文件写入/更改的应用，且部分应用条件下性能相比原生文件系统会有折损；并且容器实例的数据会随着容器生命周期的结束而删除，无法像`volume`一样超越容器生命周期而存在

![](images/230709a001.jpg)

![](images/230709a002.jpg)

> 由于所有容器实例都是基于镜像创建的，所以容器实例只是相比镜像多出了**一层**`container layer`可读写的容器层，**这也是容器实例相比镜像的主要区别**。容器实例只有最上层是可写的，其余层只可读。同理，创建新镜像时也只有当前步骤创建的新层是可写的，而旧层只能读
>
> `storage driver`采用了写时复制（Copy on Write，CoW）技术，一个文件在需要更改时首先从下层（该文件最近发生更改的层）复制到当前新建层，再进行更改。**在新层中只能访问更改后的文件，该文件的旧版本不可见**。注意，**更改文件的元数据（例如权限等）也会使用CoW**
>
> 因为以上原因，`storage driver`不适用于大量写入的场合（如数据库），因为旧文件实际依然保留，会产生过多的存储开销。这也是实际应用中数据库需要使用`volume`的原因

回到我们之前创建的`Dockerfile`示例

```
# syntax=docker/dockerfile:1

FROM node:18-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
EXPOSE 3000
```

> 尽管`Dockerfile`只是用于镜像构建，但是它其实就是描述了构建镜像时的新建层的过程。镜像构建完成后，新建层的历史就可以通过`docker image history`命令查看
>
> `Dockerfile`的每一行视操作而定，可能会新建层也可能不会新建。只要是执行了**会改变镜像中实体文件内容的操作**（不包括仅创建目录）就会触发新层的创建，例如实体文件的新建、删除、更改，这在`docker image history`中显示为非`0B`的条目（如果是`0B`，就表示没有实际的文件更改，只是镜像对应的元数据更改了）
>
> 我们可以发现`docker image history`的输出中有很多行不显示指纹，而是`<missing>`。这些行表示这些构建步骤是在其他主机完成并从DockerHub拉取的，或是由`BuildKit`构建的

查看`getting-started`中最近创建层的指纹

```shell
docker image inspect --format "{{json .RootFS.Layers}}" getting-started
```

> 可以通过`docker ps -s`查看各容器占用的存储，其中`size`相当于`container layer`占用的存储，而`virtual size`相当于整个容器（包含镜像内容在内）占用的存储。容器的其他占用空间如日志，卷，配置文件等不计算在内

**存储驱动选择**

`docker`支持`overlay2 btrfs zfs devicemapper`等存储驱动，存储驱动是相对宿主机而言的，如果宿主机上有`zfs`格式的磁盘那么就可以使用`zfs`驱动。目前Linux发行版都支持`overlay2`，这也是`docker`推荐使用的驱动，而`devicemapper`适用于拥有较老内核的历史版本，例如想要在较老版本的`CentOS RHEL`宿主机上使用

> `overlay2`支持`xfs ftype=1`以及`ext4`，是最稳定的，且为默认驱动无需配置。`overlay2`相当于直接对宿主机系统目录`/var/lib/docker`进行读写
>
> 和`overlay2`不同，`btrfs`和`zfs`是块设备级别的，且需要较多内存

可以使用以下命令查看当前使用的存储驱动

```shell
docker info
```

**使用**`overlay2`

默认情况下无需配置

从其他存储驱动切换到`overlay2`，通常首先备份`/var/lib/docker`

```shell
systemctl stop docker
cp -au /var/lib/docker /var/lib/docker.bk
```

之后挂载想用的磁盘到`/var/lib/docker`，并修改`/etc/fstab`。修改`/etc/docker/daemon.json`添加如下内容

```json
{
  "storage-driver": "overlay2"
}
```

启动`docker`

```shell
systemctl start docker
```

`overlay2`默认存储的文件位于`/var/lib/docker/overlay2`。在该目录下，一个镜像的每一层都会有一个单独目录存储，可能是镜像层或容器实例的可写层，目录名为指纹，并且在`/var/lib/docker/overlay2/l`下还有缩减版的指纹符号链接，和`/var/lib/docker/overlay2`下的目录一一对应（考虑到`mount`命令限制的命令行长度）

`/var/lib/docker/overlay2`下每一个层目录下通常有`committed merged diff link lower work`等文件和目录。其中`diff`目录中存储了本层被修改的文件（底层为原始的根目录），`link`文件存储的是`/var/lib/docker/overlay2/l`下对应的符号连接名，`lower`指向父层的指纹（组成链表，底层没有`lower`），`work`为`overlay2`当前的工作目录

`overlay2`中的文件映射关系如下

![](images/230709a003.jpg)

**使用**`zfs`

`docker`建议如果没有`zfs`相关使用经验，不要使用

从其他驱动迁移到`zfs`

```shell
systemctl stop docker
cp -au /var/lib/docker /var/lib/docker.bk
rm -rf /var/lib/docker/*
```

创建名为`zpool-docker`的`zpool`，挂载到`/var/lib/docker`

```shell
zpool create -f zpool-docker -m /var/lib/docker /dev/sda4 /dev/sda5
```

配置`/etc/docker/daemon.json`

```json
{
  "storage-driver": "zfs"
}
```

启动`docker`

```shell
systemctl start docker
```

可以向该`zpool`添加设备扩容

```shell
zpool add zpool-docker /dev/sda6
```

## 2.5 网络管理

通过以下命令显示当前已有的网络，可以看到默认的`bridge`（`docker`中的网络设备名和宿主机中的不是一个。宿主机为`docker0`）

```shell
docker network ls
```

所有的容器在没有显式指定使用的网络时都连接到`docker`创建的默认的网桥`bridge`（`docker0`），这个网桥可以在宿主机通过`ip link`看到，它在`docker`服务启动后才会出现。这里不再讲述网桥的概念，可以看`lxd`里[对于网桥的介绍](#111-网络管理)，`docker`的网桥工作原理基本相同

默认情况下，我们创建一个容器时`docker`会自动为其分配IP地址，且不会暴露任何端口，必须通过`-p`参数将端口映射出来

```shell
docker run -d -p 80:80 --name nginx-test nginx # --network bridge 省略
```

> 上述示例将`nginx-test`的`80`端口映射到宿主机的`80`端口，此时`nginx`服务可以在本机通过`localhost`或`127.0.0.1`访问
>
> 可以分别指定`tcp udp`映射，示例`-p 80:80/tcp -p 80:80/udp`
>
> 可以显式指定IP（例如本机有多个网络连接的情况下），示例`-p 192.168.1.122:80:80`
>
> 容器在创建时只能连接到一个网络（可以使用`--network`显式指定）。后续如果想要连接到更多网络，需要通过`docker network connect`命令
>
> 建议非必要时不要将端口暴露到局域网内，可以使用`-p 127.0.0.1:80:80`限制仅宿主机访问

可以使用`docker port`命令查看端口映射情况

```shell
docker port nginx-test
# = docker container port nginx-test
```

或所有端口映射

```shell
docker port -a
```

`docker`的网络配置功能主要还依赖于`iptables`。`docker`会在宿主机安装两张`iptables`表，分别为`DOCKER DOCKER-USER`。`iptables`配置见[笔记](210130a_install-notice.md#11-防火墙iptables)

`docker`默认继承宿主机的DNS配置`/etc/resolv.conf`，并将其映射到容器中。如果用户通过`--network`指定使用自己的网络，那么`docker`将会为容器提供一个DNS服务器

> 创建容器时可以通过`--dns`参数指定想要使用的DNS地址。此外，还可以通过`--hostname`指定容器的主机名（否则容器主机名为一个哈希。`--network-alias`不会指定容器主机名）

`docker`主要支持以下几种网络驱动

| 名称 | 简介 |
| :- | :- |
| `bridge` | 网桥，创建网络时的默认网络类型 |
| `host` | 直接使用主机网络，取消容器的网络隔离（类似于容器内程序直接在宿主机上运行） |
| `overlay` | 用于多台`docker`主机节点之间组网，其中的容器互相访问 |
| `ipvlan` | 见[1.11.1](#1111-容器网络接口) |
| `macvlan` | 见[1.11.1](#1111-容器网络接口) |
| `none` | 无网络配置 |

`docker`的IPv6支持还不是很完善，使用需谨慎

修改`/etc/docker/daemon.json`使能IPv6

```
{
  "experimental": true,
  "ip6tables": true
}
```

`docker network create`创建网络时需要加上`--ipv6`参数

### 2.5.1 网桥

加入默认网桥`bridge`时由于`docker`直接将宿主机的DNS配置给了容器，容器直接使用宿主机的DNS，`docker`**本身不为这些容器提供DNS服务**，所以加入默认网桥`bridge`时容器之间只能使用IP地址访问，想要通过网络名访问只能修改`/etc/hosts`

只有用户自己创建的网桥才支持`docker`提供的定制的DNS服务，此时就可以支持配置`--network-alias`，容器间可以使用这些网络别名互相访问。实际应用中建议不要使用默认网桥

可以查看一个网桥的信息，会显示哪些容器连接到了该网桥

```shell
docker network inspect bridge
```

创建一个网桥

```shell
docker network create --driver bridge my-br0
```

可以指定其他参数，例如分配的IP，子网掩码，网关地址等

```shell
docker network create --driver bridge \
> --subnet 192.168.0.0/16 \
> --gateway 192.168.0.1 \
> my-br0
```

还可以通过`-o`指定更多参数

```shell
docker network create --driver bridge \
> -o "com.docker.network.bridge.name"="br-custom0" \
> my-br0
```

参数解释

| 参数 | 定义 | 默认值 |
| :- | :- | :- |
| `com.docker.network.bridge.name` | 网桥在宿主机系统中的名称 |  |
| `com.docker.network.bridge.enable_ip_masquerade` | 启用NAT | `true` |
| `com.docker.network.bridge.enable_icc` | 允许容器间网络通信 | `true` |
| `com.docker.network.bridge.host_binding_ipv4` | 映射容器端口时的默认IP |  |
| `com.docker.network.driver.mtu` | 网络MTU | `0`无限制 |
| `com.docker.network.container_iface_prefix` | 容器虚拟以太网接口前缀 | `eth` |

删除网桥

```shell
docker network rm my-br0
```

直接创建容器时使用`--network`参数连接到指定网桥（同样适用于`docker run`）

```shell
docker create --name nginx-test \
> --network my-br0 \
> -p 80:80 \
> nginx:latest
```

将运行中容器`nginx-test`连接到网桥

```shell
docker network connect my-br0 nginx-test
```

可以指定IP

```shell
docker network connect --ip 192.168.0.122 my-br0 nginx-test
```

可以使用`--alias`指定（一个或多个）网络别名

```shell
docker network connect --alias www-server my-br0 nginx-test
```

断开容器和网桥的连接

```shell
docker network disconnect my-br0 nginx-test
```

删除所有未使用的网络

```shell
docker network prune
```

### 2.5.2 共享主机网络

主机网络无需创建也不能创建，直接启动容器使用即可

```shell
docker run --rm -d --network host --name nginx-test nginx:latest
```

```shell
docker create --name nginx-test --network host nginx:latest
```

### 2.5.3 macvlan

Macvlan将所有容器桥接（`bridge`，默认行为）到物理网卡。相当于宿主机担当一台交换机，容器都连接到这台交换机上，同时将宿主机的一个物理接口作为交换机的一个接口用于连接外部网络。从宿主机网口收发的数据包会使用不同的MAC（通常一个容器使用一个MAC），需要硬件支持

创建`macvlan`网络`my-macvlan`，所有容器桥接到物理网口`eth0`

```shell
docker network create --driver macvlan \
> -o parent=eth0 \
> my-macvlan
```

可以指定该`macvlan`网络的网关，以及容器加入时分配的地址、掩码

```shell
docker network create --driver macvlan \
> --subnet 192.168.5.0/24 \
> --gateway 192.168.5.1 \
> -o parent=eth0 \
> my-macvlan
```

如果宿主机物理接口连接的网络已有IP被占用，需要排除

```shell
docker network create --driver macvlan \
> --subnet 192.168.5.0/24 \
> --gateway 192.168.5.1 \
> --aux-address="www-server=192.168.5.129" \
> -o parent=eth0 \
> my-macvlan
```

## 2.6 Docker Build

`buildx`需要额外安装

```shell
sudo pacman -S docker-buildx
```

> `docker`正在推进新的`buildx`的应用。使用老的`build`命令会提示更新到`buildx`。安装`buildx`后输入`build`命令默认就调用`docker buildx build`

`docker`的`buildx`架构基本原理非常简单，同样为C/S结构，`buildx`为客户端，BuildKit为服务器。我们通过`buildx`客户端命令让服务器执行`build`操作（一个BuildKit实例，称为一个`builder`）

为了构建镜像，我们需要在客户端`buildx`给出使用的`Dockerfile`，参数，镜像导出（`export`）方式，以及缓存方式，提供给BuildKit服务器。而反过来服务器BuildKit可以在执行构建的过程中向客户端`buildx`请求额外的资源和信息，例如本地文件系统上的build context，Build secrets，SSH连接，以及构建完毕上传时使用到的Registry authentication tokens。

![](images/230709a004.png)

![](images/230709a005.png)

`docker build`基本用法

```shell
docker build -t myimage:latest .
```

> 我们指定构建出的镜像名和标签为`myimage:latest`，而**初始的上下文**为`docker build`执行的当前目录`.`（需要在这个上下文里面寻找`Dockerfile`，需要复制到容器镜像中的源码文件等）
>
> 上下文除了可以是本机的目录以外，也可以是一个远程Git仓库，归档文件或文本文件

`docker`会自动检测我们的平台架构并选择正确的镜像，例如x86平台就使用`linux/amd64`，ARM平台就使用`linux/arm64`

### 2.6.1 Dockerfile

`docker build`默认在执行该命令当前目录下寻找`Dockerfile`，如果需要同目录下多个`Dockerfile`，可以使用`-f`指定使用该文件。`Dockerfile`中的指令**逐行执行**

| 关键字（Command） | 描述 |
| :- | :- |
| `FROM` | 指定基于哪个已有镜像构建新镜像，例如`alpine:latest` |
| `RUN` | 在新镜像上执行一个命令，并保存文件系统的更改，格式为`["executable","param1","param2"]`（非shell下运行，需要可执行文件的完整路径）或`command param1 param2`（shell下运行） |
| `WORKDIR` | `Dockerfile`中，指定之后的`RUN CMD ENTRYPOINT COPY ADD`执行的目录 |
| `COPY` | 将**当前目录下的**文件复制到新建镜像文件系统的指定位置，保存更改，可以指定文件的所有权和权限例如`--chown=admin:wheel` `--chmod=644` |
| `EXPOSE` | 指定暴露的容器端口。可以运行容器时使用`-p`参数将该端口映射到主机的端口 |
| `CMD` | **容器启动后**自动执行的前台程序，格式为`["executable","param1","param2"]`（非shell下运行）或`command param1 param2`（shell下运行），`Dockerfile`文件中唯一，该程序结束退出时，容器也会终止。在`docker run`命令中如果最后添加了指定的命令，它会覆盖`CMD`的设置，转而执行命令行指定的命令 |
| `ENTRYPOINT` | 必须和JSON格式的`CMD`一起使用，和`CMD`一样同样支持两种格式，这里只建议使用JSON格式。`ENTRYPOINT`会被放到所有`CMD`以及`docker run`命令行参数之前，因此无法覆盖`ENTRYPOINT` |
| `ENV` | 设置一个环境变量，形式`VAR=value`，可以在`docker run`时使用`--env VAR=value`更改。`ENV`指定的变量在后面所有的命令中有效，会成为`RUN`中执行的命令的shell环境变量，也会成为容器启动后的环境变量。`ENV`指定的变量也可以在`Dockerfile`中使用`${VAR}`的形式引用 |
| `ARG` | 相比`ENV`更弱，同名的`ENV`会覆盖`ARG`，同时`ARG`不会成为容器运行时的环境变量，只在镜像构建过程有效。`ARG`可以在`docker run`时使用`--build-arg VAR=value`更改。`ARG`通过`VAR=default_value`形式定义，可以不包含默认值。`docker`的构建系统预定义了一些`ARG`，可以更改 |
| `VOLUME` | 创建一个新卷并挂载到容器中指定目录，例如`/var/lib/db`，JSON指定多个`["/var/log/","/var/db"]` |
| `USER` | 接下来`Dockerfile`指令执行的用户身份，默认`root:root`，对之后的`RUN ENTRYPOINT CMD`有效 |
| `TAG` | 指定构建出的镜像名称以及标签，可以被`docker build`命令行`-t`覆盖 |
| `LABEL` | 设置镜像的元数据，例如`version="1.0"` |

> 为防止非必要的变量空间污染，在`Dockerfile`中无需后续引用的变量可以使用例如`RUN VAR=value command`的形式，仅成为临时的shell变量
>
> `CMD`使用JSON格式指定运行的命令是不在shell下运行的，所以JSON格式不能使用环境变量例如`${JAVA_HOME}`，同时必须使用可执行文件的**完整路径**。想要使用shell环境必须`["sh","-c","echo $HOME"]`
>
> 在实际应用中，`ENTRYPOINT`通常用于在`Dockerfile`中指定容器启动后执行的可执行文件路径，例如`/usr/bin/server`，而`CMD`以及`docker run`用于提供命令行参数，其中`CMD`指定默认参数，可以被`docker run`指定的参数覆盖

`RUN`和`COPY`可以支持多行命令

```
RUN <<EOT
  apt install git
  mkdir app/src
  mkdir app/build
EOT
```

此外，`RUN`还可以通过参数设置网络，挂载等，方便构建命令调用的程序使用

```
RUN --mount=type=bind
```

> 可用类型：`bind cache tmpfs secret ssh`

```
RUN --mount=type=cache,target=/root/.cache/build \
  commands
```

> 可用类型：`default none host`

`docker build`相关常用命令行参数

| 参数 | 描述 |
| :- | :- |
| `-t --tag` | 指定镜像的名称与标签，覆盖`Dockerfile`的`TAG` |
| `-f --file` | 指定`Dockerfile`文件 |

基本格式（可以看[示例](#221-创建应用镜像)）

```
# syntax=docker/dockerfile:1

INSTRUCTION1 arguments
INSTRUCTION2 arguments
...
```

python示例

```
# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# install app dependencies
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip install flask==2.1.*

# install app
COPY hello.py /

# final configuration
ENV FLASK_APP=hello
EXPOSE 8000
CMD flask run --host 0.0.0.0 --port 8000
```

> 类似`# syntax=docker/dockerfile:1`这样的称为一个`directive`。`directive`必须出现在`Dockerfile`的最前面。其他的`directive`还有`# escape=\ `等

### 2.6.2 上下文

前文已经简单介绍过了上下文。`docker build`命令是**在构建刚开始**就把上下文传给了BuildKit，所以后续都是在这个上下文里执行，不能再改变，包括`Dockerfile`的读取，使用`COPY`复制的工程以及源码文件，以及其他`docker`会使用到的文件如`.dockerignore`和`docker-compose.yml`等

使用Git仓库类型的上下文时，可以使用以下形式指定Git仓库的分支以及上下文所在的子目录（下例中为`container`分支，`docker`子目录）

```shell
docker build https://github.com/user/myrepo.git#container:docker
```

默认情况下Git仓库的`.git`目录不会下载，需要在`docker build`时加参数`--build-arg BUILDKIT_CONTEXT_KEEP_GIT_DIR=1`

### 2.6.3 多阶段构建

由于开发和部署环境的差异，会用到不同的`docker`镜像，为此传统方法需要维护两个`Dockerfile`，分别用于两种环境。一个`Dockerfile`用于构建可执行的程序（开发），它没有`CMD`；另一个用于为**开发阶段得到的二进制文件**提供运行环境（部署），它通常有`CMD`。例如开发使用`golang:latest`，部署使用`alpine:latest`。甚至很多情况下需要维护多个`Dockerfile`，并通过shell脚本进行顺序构建操作，期间可能会从开发容器中拷贝文件到部署容器中。为解决这种问题便有了多阶段构建

所谓多阶段构建就是一个`Dockerfile`中有多个`FROM`关键字，一个`FROM`就代表一个构建阶段。以下为`docker`官方示例

```
# syntax=docker/dockerfile:1

FROM golang:latest
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go ./
RUN CGO_ENABLED=0 go build -a -installsuffix cgo -o app .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/alexellis/href-counter/app ./
CMD ["./app"]
```

> `Dockerfile`多阶段构建序号从`0`开始。上述示例中我们发现使用`COPY --from=0 /go/src/github.com/alexellis/href-counter/`可以访问`0`阶段镜像的目录

除`docker`给各个阶段的自动编号外，还可以使用`AS`为一个`FROM`开始的阶段赋予名称，之后使用该名称即可

```
# syntax=docker/dockerfile:1

FROM golang:latest AS builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go ./
RUN CGO_ENABLED=0 go build -a -installsuffix cgo -o app .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/alexellis/href-counter/app ./
CMD ["./app"]
```

> `--from`参数不仅可以指定阶段，还可以指定镜像，示例`--from=nginx:latest`

阶段有名称以后就可以使用`--target`指明在执行到该阶段后停止。BuildKit**会分析这些阶段的依赖关系，并且只执行在依赖树中的阶段**

```shell
docker build --target builder -t alexellis2/href-counter:latest .
```

### 2.6.4 Builders

一个`builder`就是一个BuildKit守护进程，它也可以被管理，创建和删除

`builder`也有驱动的概念，驱动会指定该`builder`在哪里运行。`docker`中有一个默认的`builder`，为`default`，使用的驱动为`docker`。`docker`支持的`builder`驱动有`docker docker-container kubernetes remote`

| 驱动 | 解释 |
| :- | :- |
| `docker` | 使用本机`docker`服务内置的BuildKit，支持自动加载镜像，不支持tarball输出，跨平台镜像以及BuildKit配置 |
| `docker-container` | 创建独立的BuildKit容器，支持导出缓存 |
| `kubernetes` | 在K8s集群中创建BuildKit pods |
| `remote` | 连接到远程的BuildKit守护进程 |

查看已有`builder`

```shell
docker buildx ls
```

> `docker build`时可以使用`--builder`指定`builder`

查看`builder`信息

```shell
docker buildx inspect my_builder
```

切换默认`builder`（立即生效）

```shell
docker buildx user my_builder
```

创建新`builder`

```shell
docker buildx create --name=my_builder --driver=docker
```

> 普通应用`docker`驱动已经足够

### 2.6.5 输出

可以将构建结果以不同方式输出

```shell
docker buildx build -t my-image:latest --output type=image .
```

| 输出 | 解释 |
| :- | :- |
| `image` | 输出为容器镜像 |
| `registry` | 输出为容器镜像并推送到远程仓库（例如DockerHub） |
| `local` | 将镜像根文件系统放到本地目录 |
| `tar` | 打包为归档文件 |
| `oci` | 导出为OCI镜像格式 |
| `docker` | 导出为`docker`专用镜像格式 |
| `cacheonly` | 不导出镜像，但会执行构建并生成缓存 |

使用`--load`时相当于使用了`docker`格式，镜像直接添加到本地镜像库并且可以直接`docker run`创建容器

```shell
docker buildx build --tag username/my-image:latest --load .
# = docker buildx build --output type=docker,name=username/my-image:latest .
```

使用`--push`时，相当于输出`image`，并推送到`registry`

```shell
docker buildx build --tag image,name=registry/my-image:latest --push .
# = docker buildx build --output type=image,name=registry/my-image:latest,push=true .
```

导出镜像layout到本地

```shell
docker buildx build --output type=oci,dest=./my-image.tar .
```

导出文件系统到本地

```shell
docker buildx build --output type=tar,dest=/home/my-name/my-fs.tar .
docker buildx build --output type=local,dest=/home/my-name/my-fs/ .
```

## 2.7 Docker Compose

`compose`需要额外安装，配置基于当前目录的`docker-compose.yml`

```shell
sudo pacman -S docker-compose
```

`compose`主要解决了每次启动多容器服务时重复的繁琐操作

默认情况下对于`compose`来说，`docker-compose.yml`所在目录就是该`compose`的工程名，并且会用于命名构建出的镜像以及新建的默认网络

### 2.7.1 基本用法

假设我们的系统需要两个容器，一个提供web服务，一个为`redis`数据库。其中web服务的容器镜像需要通过当前目录的`Dockerfile`构建，而`redis`数据库使用DockerHub现有镜像。现在在开发过程中，我们在容器的`/code`目录挂载服务器所需所有文件，方便动态更改。在当前目录创建`docker-compose.yml`

```yml
services:
  web:
    build: .
    ports:
      - "8080:80"
    volumes:
      - .:/code
    environment:
      BUILD_DEBUG: "true"
  redis:
    container_name: redis-server
    image: "redis:latest"
```

构建并执行服务

```shell
docker compose up -d
```

> `-d`参数指定这些容器在detach模式（后台）下运行
>
> 此后可以执行无需重构建的更新（例如更改网页中的一个字符串），让更改立即生效（例如刷新网页）

此时应该可以看到新创建的镜像

```shell
docker image ls
```

> 默认情况下镜像命名格式为执行`docker-compose.yml`所在目录名+`_`+`service`名称，这里为`web`

以及执行中的镜像

```shell
docker compose ps
```

可以在服务`web`所属容器执行一下`env`命令

```shell
docker compose run web env
```

停止所有容器

```shell
docker compose stop
```

或停止所有容器，同时删除容器

```shell
docker compose down --volumes
```

> `--volumes`表示同时删除所有`docker-compose.yml`中新创建的卷

实际生产环境中，为保证重启速度无缝重部署，需要添加`restart: always`

```yml
services:
  web:
    build: .
    ports:
      - "8080:80"
    volumes:
      - .:/code
    environment:
      BUILD_DEBUG: "true"
    restart: always
  redis:
    image: "redis:latest"
    restart: always
```

和普通的创建容器实例一样，`docker-compose.yml`中也可以通过参数设定CPU资源，系统IO等参数，例如`cpu_count cpu_shares dns deploy.limits.memory`等，不再详述

### 2.7.2 环境变量

`docker-compose.yml`也支持变量的使用，在这里指定的环境变量和`Dockerfile`中的`ENV`是相同的。前文已经给出了直接在`docker-compose.yml`中使用`environment`指定变量的形式。我们也可以在`docker-compose.yml`同目录下使用一个`.env`文件设定变量，`docker`会自动读取文件

```
ALPINE_TAG=3.18
```

在`docker-compose.yml`中作如下引用

```yml
services:
  web2:
    image: 'alpine:${ALPINE_TAG}'
```

在指定`docker compose run`时也可以使用`-e`指定变量

```shell
docker compose run -e VAR=value
```

### 2.7.3 Profile

`docker-compose.yml`可以使用`profile`选择性地启动部分容器，而不是全部

```yml
services:
  frontend:
    image: frontend
    profiles: ["frontend"]

  db:
    image: mysql

  backend:
    image: backend
    profile:
      - backend
```

上述一共定义了三个容器，分别为`frontend db backend`，其中给`frontend`以及`backend`指定了`profile`

只启动数据库

```shell
docker compose up
```

同时启动`frontend`，`backend`和数据库

```shell
docker compose --profile frontend --profile backend up
```

还可以指定依赖关系，这样在指定启动一个容器时依赖的容器也会启动。**这也指定了容器的启动顺序**

```yml
services:
  frontend:
    image: frontend
    profiles: ["frontend"]
    depends_on:
      - backend

  db:
    image: mysql

  backend:
    image: backend
    profile: ["backend"]
    depends_on:
      - db
```

### 2.7.4 使用GPU

使用`deploy`指定，使用一个GPU，并运行`nvidia-smi`

```yml
services:
  test:
    image: nvidia/cuda:10.2-base
    command: nvidia-smi
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

或使用指定GPU

```yml
services:
  test:
    image: tensorflow/tensorflow:latest-gpu
    command: python -c "import tensorflow as tf;tf.test.gpu_device_name()"
    deploy:
      resources:
        reservations:
          devices:
          - driver: nvidia
            device_ids: ['0', '3']
            capabilities: [gpu]
```

### 2.7.5 网络配置

假设我们的`docker-compose.yml`位于目录`myapp`，那么此时我们的工程名为`myapp`，默认`docker compose up`时会创建一个名为`myapp_default`的网桥，并且支持`service`容器之间**直接通过主机名访问**。尽管到**主机端口**的映射通过`ports:`项指定，但是容器之间依旧采用原来的容器端口访问

更改容器服务后`docker compose up`重启时，容器的IP会发生改变，但容器名不变

可以在`docker-compose.yml`中创建自己的网络，并指定容器加入这些网络即可

```yml
services:
  proxy:
    build: ./proxy
    networks:
      - frontend
  app:
    build: ./app
    networks:
      - frontend
      - backend
  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
    name: frontend-1
    # Use a custom driver
    driver: custom-driver-1
  backend:
    name: backend-1
    # Use a custom driver which takes special options
    driver: custom-driver-2
    driver_opts:
      foo: "1"
      bar: "2"
```

> 加入的可以是已有的网络，直接将`name:`设为已有网络名即可

也可以只更改默认网络的配置

```yml
networks:
  default:
    # Use a custom driver
    driver: custom-driver-1
```

使用`host`或`none`网络

```yml
services:
  web:
    networks:
      hostnet: {}

networks:
  hostnet:
    external: true
    name: host
```

```yml
services:
  web:
    ...
    networks:
      nonet: {}

networks:
  nonet:
    external: true
    name: none
```

### 2.7.6 卷

卷已经[示例](#226-compose示例)过

新建`db-data`卷

```yml
services:
  backend:
    image: awesome/database
    volumes:
      - db-data:/etc/data

  backup:
    image: backup-service
    volumes:
      - db-data:/var/lib/backup/data

volumes:
  db-data:
```

使用已有`db-data`卷

```yml
volumes:
  db-data:
    external: true
```

指定驱动以及选项

```yml
volumes:
  db-data:
    driver: foobar
```

```yml
volumes:
  example:
    driver_opts:
      type: "nfs"
      o: "addr=10.40.0.199,nolock,soft,rw"
      device: ":/docker/example"
```

## 3 Kubernetes

K8s K3s

TODO

## 4 containerd

TODO

## 5 Kata Containers

TODO

## 6 QEMU

运行QEMU，利用KVM。这里只关注x86平台运行x86系统

KVM是集成于Linux内核的一个虚拟化模块。QEMU的传统模式使用纯软件模拟一个计算机系统，而启用了KVM以后可以利用CPU的虚拟化扩展，提高虚拟机运行效率

## 6.1 先行检查

首先需要确保硬件开启了虚拟化扩展，x86平台为VT-x或AMD-V，在BIOS打开

检查Linux内核是否包含KVM，应当为`m`或`y`

```
$ zgrep CONFIG_KVM= /proc/config.gz
CONFIG_KVM=m
```

检查KVM模块是否加载。应当同时有`kvm`以及`kvm_amd`或`kvm_intel`。如果只有`kvm`，可能是BIOS没有开启虚拟化

```
$ lsmod | grep kvm
kvm_amd               204800  0
kvm                  1368064  1 kvm_amd
```

## 6.2 QEMU使用简介

直接安装`qemu-full`，这个是提供图形界面支持的（Non-headless，依赖GTK和SDL）

```
$ sudo pacman -S qemu-full
```

`qemu`可以支持完整的计算机系统模拟或仅仅模拟用户程序。这里我们只用到完整的`x86_64`系统模拟，命令`qemu-system-x86_64`（所有的计算机完整系统模拟都是`qemu-system-`加处理器架构）

### 6.2.1 创建磁盘镜像

可以使用`raw`格式（原始的硬盘镜像），也可以使用`qcow2`格式

创建`raw`格式镜像

```
qemu-img create -f raw rhel1.img 32G
```

或直接`fallocate`也可以

```
fallocate -l 32G rhel1.img
```

创建`qcow2`格式镜像。这里的`32G`指的是磁盘映像最大允许大小。`qcow2`格式的镜像是按需分配的，但是性能可能没有`raw`格式的高

```
qemu-img create -f qcow2 rhel1.cow 32G
```

**增量镜像（overlay image）的使用**

`qemu`可以支持在一个基础镜像之上建立一个增量镜像。基础镜像为只读，所有的后续更改在增量镜像上发生，类似于`docker`的镜像，可以方便回滚以及共享镜像

```
qemu-img create -o backing_file=base.img,backing_fmt=raw -f qcow2 rhel1.cow
```

> 后续直接使用`rhel1.cow`即可，基础镜像的路径记录在其中，`qemu`会自动查找并使用`base.img`

如果基础镜像的路径发生变更，内容没有更改，执行以下命令即可切换到新的基础镜像路径（`-u`表示Unsafe模式，仅更改`qcow2`增量镜像中记录的基础镜像路径，而不检查新镜像的内容）

```
qemu-img rebase -u -b /new/path/base.img rhel1.cow
```

如果想要更改基础镜像为另一个不同的镜像（原镜像必须还保留在原处），需要使用Safe模式。`qemu`镜像工具会检查新镜像相比老镜像的更改，将这些更改合并到`rhel1.cow`后才会切换到新的基础镜像（可能会耗费很长时间）

```
qemu-img rebase -b /new/path/base.cow -F qcow2 rhel1.cow
```

> 如果基础镜像格式发生变更，需要`-F`指明

可以使用上述特性，生成两个镜像之间的差分

```
qemu-img create -f qcow2 -b mod.img diff.cow
qemu-img rebase -b base.img diff.cow
```

> 最终`diff.cow`中包含的就是`mod.img`相比`base.img`的增量

**放大缩小镜像**

`raw`和`qcow2`格式都可以用

```
qemu-img resize image.cow +10G
```

> 上述命令只能用于增加镜像可分配空间，操作完成后还需要启动虚拟机扩展分区。注意对于Windows来说可能会导致无法启动，需要备份

```
qemu-img resize --shrink image.cow -10G
```

> 缩小镜像需要添加`--shrink`参数。缩小之前先要在虚拟机中调节分区

**镜像格式转换**

示例，从`raw`格式转`qcow2`格式

```
qemu-img convert -f raw -O qcow2 old.img new.cow
```

### 6.2.2 通过光盘镜像安装

不要使用`root`身份运行`qemu`

Legacy模式启动

```
qemu-system-x86_64 \
-m 4G \
-smp cpus=4 \
-cpu host \
-accel kvm \
-boot order=d \
-cdrom /path/to/dvd.iso \
-drive file=rhel1.cow,format=qcow2
```

> Legacy模式默认使用的SeaBIOS固件位于`/usr/share/qemu/bios-256k.bin`，通过包名`seabios`安装。如果想使用其他固件通过`-bios`指定即可

UEFI启动操作有些不同。需要`edk2-ovmf`包提供的OVMF固件，可以将其拷贝到当前目录后使用（必须可写）

```
cp /usr/share/edk2-ovmf/x64/OVMF.fd .
chmod u+w OVMF.fd
```

启动时添加一些额外参数，使用OVMF固件

```
qemu-system-x86_64 \
-m 4G \
-smp cpus=4 \
-cpu host \
-accel kvm \
-boot order=d \
-cdrom /path/to/dvd.iso \
-drive file=rhel1.cow,format=qcow2 \
-drive if=pflash,format=raw,file=/path/to/OVMF.fd
```

OVMF也提供了分体版本固件`OVMF_CODE.fd`和`OVMF_VARS.fd`，只需拷贝`OVMF_VARS.fd`到当前目录即可

```
cp /usr/share/edk2-ovmf/x64/OVMF_VARS.fd .
chmod u+w OVMF_VARS.fd
```

```
qemu-system-x86_64 \
-m 4G \
-smp cpus=4 \
-cpu host \
-accel kvm \
-boot order=d \
-cdrom /path/to/dvd.iso \
-drive file=rhel1.cow,format=qcow2 \
-drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/copy/of/OVMF_VARS.fd
```

> `qemu`默认只会分配`128M`内存，需要通过`-m`显式指定分配的内存。同时分配的CPU线程数通过`-smp`指定，可以更详细一点`cpus=4,sockets=1,cores=2,thread=2,maxcpus=4`
>
> 具体模拟的CPU架构（支持的指令集）也可以通过`-cpu`指定。可用的CPU通过`-cpu help`查看，`-cpu host`表示使用主机CPU架构（必须开启`kvm`）
>
> `kvm`必须通过`-enable-kvm`或`-accel kvm`开启
>
> `-boot order=d`表示本次优先从`cdrom`启动，之后恢复。也可以更改为`-boot menu=on`，使用BIOS的启动菜单
>
> 如果是Headless模式运行的`qemu`，会开启一个VNC端口，在`5900`
>
> 点击`qemu`窗口后鼠标会被捕获，`Ctrl+Alt+g`释放

**QEMU终端**

`qemu`虚拟机有一个终端，可以通过`Ctrl+Alt+2`切换，输入`help`查看帮助。通过`Ctrl+Alt+1`切换回系统终端。这个终端可以用于更换光盘镜像等操作

### 6.2.3 运行

安装完毕后，执行以下命令，Legacy模式启动

```
qemu-system-x86_64 \
-m 4G \
-smp cpus=4 \
-cpu host \
-accel kvm \
-drive file=rhel1.cow,format=qcow2
```

UEFI启动

```
qemu-system-x86_64 \
-m 4G \
-smp cpus=4 \
-cpu host \
-accel kvm \
-drive file=rhel1.cow,format=qcow2 \
-drive if=pflash,format=raw,file=/path/to/OVMF.fd
```

```
qemu-system-x86_64 \
-m 4G \
-smp cpus=4 \
-cpu host \
-accel kvm \
-drive file=rhel1.cow,format=qcow2 \
-drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/copy/of/OVMF_VARS.fd
```

### 6.2.4 IOMMU的基本配置

如果想要让PCI设备直连虚拟机，需要配置好IOMMU，在GPU服务器以及多网卡的主机上会有用（容器也可以支持类似功能）。没有此需求跳过即可。Intel平台需要支持VT-d，AMD平台需要支持AMD-Vi。确保BIOS已经正确设置

**开启IOMMU**

如果是Intel平台，视情况可能需要添加以下内核参数

```
intel_iommu=on
```

AMD和Intel平台需要加上以下内核参数，防止Linux内核触碰不支持穿透的硬件设备。之后执行一下`grub-mkconfig`并重启，参考[使用内核参数](201219a_shell.md#1210-内核参数)

```
iommu=pt
```

执行以下命令，有相关输出且没有报错表示IOMMU已正确开启

```
dmesg | grep -i -e DMAR -e IOMMU
```

**PCIe设备向QEMU虚拟机的分配以IOMMU组（IOMMU Group）为最小单位**，同一个IOMMU组内的所有PCI设备只能同时分配到一个虚拟机。所有的IOMMU组都在`/sys/kernel/iommu_groups`下，可以通过以下脚本列出每个IOMMU组下的PCIe设备。如果发现有不想同组的设备出现在同一个组，需要尝试更换其他插槽

```shell
for i in `ls /sys/kernel/iommu_groups | sort -n`; do
    echo "IOMMU GROUP $i:"
    for d in /sys/kernel/iommu_groups/$i/devices/*; do
        lspci -nns `basename $d`
    done
done
```

**设备保留：以GPU为例**

主机系统启动时会加载PCI上挂载设备的驱动并与其交互。此后这些PCI设备是无法分配给虚拟机的，如果虚拟机想要使用这些设备，意味着主机系统（或其他虚拟机系统）不能占用它们。解决方案是让其他系统（主机系统或其他虚拟机系统）只为这些PCI设备加载一个占位驱动`vfio-pci`或`pci-stub`，这样的驱动不会有实际的作用，虚拟机就可以使用这些PCI设备。对于大部分有良好虚拟化环境支持的硬件来说（例如某些PCI网卡），它们可以很方便地动态绑定，即无需重启系统就可以从主机脱离并绑定到虚拟机（在启动虚拟机时在命令行显式指定即可，虚拟机程序会自动执行这些操作）。然而GPU由于其驱动的复杂性，不能很好地支持动态绑定，需要手工操作防止冲突。最好的解决方案就是让主机在刚启动时就为GPU加载`vfio-pci`驱动。显卡直连需要GPU的VBIOS支持

> 如果有接显示器的需求，不要在单显卡机器上操作，包括笔记本独显直连模式。可以开启`ssh`后操作

查看所有的PCI设备，显示设备ID（即产品ID，相同的PCI设备会显示相同的ID）

```shell
lspci -nn
```

GPU设备通常显示如下

```
06:00.0 VGA compatible controller: NVIDIA Corporation GM204 [GeForce GTX 970] [10de:13c2] (rev a1)
06:00.1 Audio device: NVIDIA Corporation GM204 High Definition Audio Controller [10de:0fbb] (rev a1)
```

将GPU交由`vfio-pci`接管需要给出GPU的设备ID，最方便的方法是直接设置[内核参数](201219a_shell.md#1210-内核参数)。编辑`grub`传递的内核参数，添加以下内容即可，系统启动时`vfio-pci`就会起作用

```
vfio-pci.ids=10de:13c2,10de:0fbb
```

> 我们已经看过了IOMMU的分组。如果同组内有PCI bridge，不能将该设备ID传给`vfio-pci`。如果同组内有其他PCI设备，并且虚拟机支持动态换绑，那么无需将该设备ID传给`vfio-pci`
>
> 使用`vfio-pci`占位驱动的一个缺陷就是在使用多张相同显卡的环境下缺乏灵活性，因为相同型号显卡使用相同的产品型号ID。只要配置了上述内核参数，主机上所有同型号的显卡都会被`vfio-pci`接管

另一种方法是在`/etc/modprobe.d`下添加`.conf`文件配置，之后需要执行`mkinitcpio -P`重新生成`initramfs`，这是更为推荐的方法

```
options vfio-pci ids=10de:13c2,10de:0fbb
```

**Early Bind：initramfs阶段的设备保留**

`grub`在加载系统时会解压Linux内核（Arch下默认为`/boot/vmlinuz-linux`），外加一个临时的根文件系统`initramfs`到内存（`/boot/initramfs-linux.img`）。Linux内核刚刚启动时无法访问磁盘上的文件系统，会先使用内存中的`initramfs`作为根文件系统。`initramfs`中会有内核驱动模块。想要让`vfio-pci`驱动尽早接管GPU，还需要一些额外处理

为达到上述要求，同样有两种方法

一种方法是在`.conf`中添加以下配置，并重新生成`initramfs`。是较为推荐的方法

```
softdep drm pre: vfio-pci
```

另一种方法是将`vfio-pci`相关内核模块加入到`initramfs`。这会增大`initramfs`，可能会稍稍减缓开机速度

> Linux 6.0以后在`initramfs`阶段加载`vfio-pci`后framebuffer会停止工作，需要注意。可能需要再将显卡驱动加入到`initramfs`

首先将以下内容添加到`/etc/mkinitcpio.conf`的`MODULES`中（必须在任何Early modesetting显卡驱动模块之前）

```
MODULES=(vfio_pci vfio vfio_iommu_type1)
```

同时保证`HOOKS`中包含了`modconf`

```
HOOKS=(modconf)
```

之后执行一下`mkinitcpio -P`即可

> 采用这种方法时，如果先前配置了N卡专用驱动`nvidia`的Early modesetting，只能通过`modprobe`配置指定设备ID

**重启检查**

重启后查看`dmesg`有没有`vfio`相关内容

```
dmesg | grep -i vfio
```

检查显卡是否被`vfio`接管

```
lspci -nnk
```

如果正常，显卡硬件信息会显示

```
Kernel driver in use: vfio-pci
```

### 6.2.5 一些性能调优方法

**CPU绑核**

对于QEMU虚拟机来说，它所模拟的每一个虚拟CPU在主机系统上本质都是一个线程（包括使用KVM时），并且遵守主机系统的调度。而在大部分的Linux系统下，线程会经常性的切换CPU运行，由于Cache问题这会在虚拟机上带来一些性能损失。因此在对性能要求较高的场合下需要绑核，让QEMU虚拟机使用固定的CPU核心。大部分的服务器平台都是NUMA平台，绑核需要综合考虑L1L2L3缓存架构，超线程，以及多路处理器问题

> 绑核操作不一定在所有平台或操作系统都有性能提升，还需要看操作系统的调度器特性，绑核可能会适得其反，造成不正常的卡顿。这种情况下就不必再绑核了

通过`lscpu -e`就可以显示系统内CPU线程和内核，L1L2L3缓存的对应关系。如下是一个支持超线程，且所有核心共享一个L3的AMD处理器。Intel处理器会有所不同，如果是8核16线程，CPU`0`和CPU`8`才是属于核心`0`的两个线程。有些处理器可能不止一个L3，也有可能多个核心会共享L2

```
$ lscpu -e
CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE    MAXMHZ   MINMHZ
  0    0      0    0 0:0:0:0          yes 4546.0000 400.0000
  1    0      0    0 0:0:0:0          yes 4546.0000 400.0000
  2    0      0    1 1:1:1:0          yes 4546.0000 400.0000
  3    0      0    1 1:1:1:0          yes 4546.0000 400.0000
  4    0      0    2 2:2:2:0          yes 4546.0000 400.0000
  5    0      0    2 2:2:2:0          yes 4546.0000 400.0000
  6    0      0    3 3:3:3:0          yes 4546.0000 400.0000
  7    0      0    3 3:3:3:0          yes 4546.0000 400.0000
  8    0      0    4 4:4:4:0          yes 4546.0000 400.0000
  9    0      0    4 4:4:4:0          yes 4546.0000 400.0000
 10    0      0    5 5:5:5:0          yes 4546.0000 400.0000
 11    0      0    5 5:5:5:0          yes 4546.0000 400.0000
 12    0      0    6 6:6:6:0          yes 4546.0000 400.0000
 13    0      0    6 6:6:6:0          yes 4546.0000 400.0000
 14    0      0    7 7:7:7:0          yes 4546.0000 400.0000
 15    0      0    7 7:7:7:0          yes 4546.0000 400.0000
```

> 还有一个查看处理器缓存架构的图形化工具为`lstopo`

**隔离CPU核**

可以通过Bootloader传递内核参数，在系统启动时隔离指定CPU核，防止主机占用虚拟机的CPU资源。主机系统就不会使用这些核心

```
isolcpus=8-9 nohz_full=8-9
```

需要使用如下命令启动`qemu`，开启调度器的`round-robin`

```
chrt -r 1 taskset -c 8-9 qemu-system-x86_64
```

也可以通过`systemd`动态地隔离以及回收CPU

设定允许使用的CPU，其余保留给虚拟机

```
# systemctl set-property --runtime -- user.slice AllowedCPUs=0-7
# systemctl set-property --runtime -- system.slice AllowedCPUs=0-7
# systemctl set-property --runtime -- init.scope AllowedCPUs=0-7
```

回收所有CPU

```
# systemctl set-property --runtime -- user.slice AllowedCPUs=0-9
# systemctl set-property --runtime -- system.slice AllowedCPUs=0-9
# systemctl set-property --runtime -- init.scope AllowedCPUs=0-9
```

**大内存页**

高性能计算中可能会有很大连续空间内存的需求。如果使用的内存页太小，会导致分配的页太多，访问页表和访问内存的延迟会变大，降低性能。同时由于现代CPU中TLB快表缓存是有限的，太多的页会导致TLB频繁换进换出，命中率降低，也会降低访存效率。大内存页对于很多虚拟机应用来说是有利的，但是对于很多数据库负载是不利的，`mongodb`等数据库就要求关闭大内存页功能。在x86平台下Linux可以支持2MiB和1GiB大小的huge page（默认一个页4KiB）

> Linux下使用大内存页有三种常用的方式：一种是**Transparent**（Transparent huge pages，通常简写为THP），一种是**Static**，一种是**Dynamic**
>
> Transparent也即透明模式，该模式在大部分Linux发行版内核中默认打开，无需另外配置，应用程序可以无需显式说明自己想要2MiB大小的页，只要mmap区域是2MiB对齐的，Linux内核会尽量为该程序分配一个2MiB大小的页。只有在找不到可用的2MiB页或遇到其他情况例如mmap域非2MiB对齐时，会给该程序分配4KiB的页
>
> Static也即静态分配模式，该模式需要通过传递内核参数设定，在系统启动时就会分配指定数量和大小的空内存页，并且这些内存页只能由指定的程序使用，普通程序不可使用。由于目前的Linux内核中THP仅支持2MiB大小的内存页，它通常用于1GiB页的分配。Static分配缺乏灵活性，其性能提升相比THP也是微乎其微
>
> Dynamic也即动态分配方式，可以运行时通过`sysctl`内核参数设定。为虚拟机分配的大内存页在虚拟机退出后会自动由系统回收，而启动时同样也是动态地分配

Transparent huge pages

系统自动分配的THP可以通过`/proc/meminfo`以及`/proc/PID/smaps`查看，在`AnonHugePages`

系统当前自动分配的2MiB大内存页占用内存总量。如下，说明系统当前分配了`155`个大内存页

```
$ grep -i anonhugepages /proc/meminfo
AnonHugePages:    317440 kB
```

显示分配给具体进程的大内存页

```
$ grep -P 'AnonHugePages:\s+(?!0)\d+' /proc/830/smaps
AnonHugePages:     22528 kB
AnonHugePages:      2048 kB
AnonHugePages:      2048 kB
AnonHugePages:      2048 kB
AnonHugePages:      2048 kB
```

如果想要禁用THP，需要添加以下启动时内核参数

```
transparent_hugepage=never
```

或在运行时执行以下命令

```
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
```

Static huge pages

使用Static预留分配的大内存页，需要设定如下内核参数，示例分配`256`个2MiB页

```
hugepages=256
```

分配2个1GiB页，需要添加以下参数设定Static内存页的大小

```
default_hugepagesz=1G hugepagesz=1G hugepages=2
```

Dynamic huge pages

使用Dynamic大内存页，通过`vm`相关内核参数设置，使用`sysctl`。`kvm`虚拟机在启动时会自动分配指定数量的大内存页，默认2MiB页

```
vm.nr_hugepages = 0
vm.nr_overcommit_hugepages = 128
```

可以运行时执行以下命令分别设定2MiB和1GiB动态大内存页数量

```
echo 128 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo 2 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
```

## 6.3 QEMU命令行完整参考

仅`x86_64`

## 7 VirtualBox

TODO

## 8 Vagrant

TODO

## 9 libvirt

TODO

## 10 Podman

Podman由RedHat支持，是Docker的替代品，两者大部分功能与用法兼容，可以直接`alias docker='podman'`。上手过Docker以后可以直接上手Podman。主要的一个区别是Podman不是基于daemon的，从设计上看更加简单一些，并且不像`docker`的daemon一样必须以`root`身份运行，一定程度规避了一些安全问题

> 除了`podman`，RedHat还有一个Kubernetes发行版OpenShift

这里只讲述`podman`一些基本用法，以及相对于`docker`在使用上的不同点。其他功能请参考Docker教程

## 10.1 普通用户使用

安装`container-tools`

```
$ dnf install container-tools
```

以普通用户身份执行`podman`需要在`/etc/subuid`和`/etc/subgid`中添加用户名，都配置为如下形式，`username`就是想要使用`podman`的用户名

```
username:1000000:1000000000
```

> `podman`不像`docker`一样会创建一个用户组，普通用户直接执行`podman`就可以了。而针对容器可能运行出错需要自动重启的问题，可以针对每一个容器生成一个`systemd`单元文件，使用`systemd`直接管理，后面会讲述

## 10.2 登录容器仓库

`podman`也可以用DockerHub。这里使用RedHat的容器仓库，可以先到RedHat官网注册一个账号，再继续下述配置（其他容器仓库平台同理）

首先编辑`/etc/containers/registries.conf`（当前用户配置在`~/.config/containers/registries.conf`），搜索镜像就会到这些站点

```
unqualified-search-registries = ["registry.access.redhat.com", "registry.redhat.io"]

short-name-mode = "enforcing"
```

登录站点，按提示输入用户名和密码

```
$ podman login registry.access.redhat.com
$ podman login registry.redhat.io
```

查看登录状态

```
$ podman login registry.redhat.io --get-login
```

## 10.3 容器镜像

### 10.3.1 远程镜像

查找`rhel7`容器镜像

```
$ podman search rhel7
...
registry.redhat.io/rhel7.9  ...
...
```

使用`skopeo`可以在线查询容器镜像信息

```
$ skopeo inspect docker://registry.redhat.io/rhel7.9
```

拉取镜像

```
$ podman pull registry.redhat.io/rhel7.9:latest
```

查看已拉取镜像

```
$ podman images
$ podman inspect registry.redhat.io/rhel7.9:latest
```

### 10.3.2 Containerfile

原先的`Dockerfile`在`podman`中叫做`Containerfile`，除开头没有`# syntax=docker/dockerfile:1`以外其他用法基本相同（例如`FROM RUN CMD`等命令），不再讲述

## 10.4 卷

常见的`volume`的权限问题

由于非`root`容器中的UID是通过主机的`/etc/subuid /etc/subgid`映射到新值的，如果使用主机上的文件目录当作`volume`会遇到权限问题

### 10.4.1 podman unshare

`podman unshare`命令可以为后面的命令包裹上一层UID和GID的转译。后面命令中的UID和GID是容器中的UID和GID，而实际命令执行的是在物理机上经过映射后的UID和GID

查看映射

```
$ podman unshare cat /proc/self/uid_map
$ podman unshare cat /proc/self/gid_map
```

假设在容器中`mysql`的UID为`27`，GID为`27`，那么在物理机上的文件或目录需要是`1000026:1000026`才能作为`volume`被容器中的`mysql`或`mariadb`访问

设定主机目录权限

```
$ podman unshare chown 27:27 /home/username/db_data
```

挂载

```
$ podman run -d --name mariadb01 \
...
-v /home/username/db_data:/var/lib/mysql \
...
```

在开启了SELinux的平台还需要将目录的`type`修改为`container_file_t`。可以使用以下命令在挂载`volume`时自动设置

```
$ podman run -d --name mariadb01 \
...
-v /home/username/db_data:/var/lib/mysql:Z \
...
```

可以使用`ls -Z`验证一下

```
$ ls -Z
...
system_u:object_r:container_file_t:s0:c81,c1000 db_data
...
```

## 10.5 网络

`podman`创建与使用网桥的方法和`docker`相同。默认情况下多个`podman`容器无法互相访问，需要另外创建网络并将容器加入

正常情况下`podman`应该使用`netavark`网络后端。如果不是，那么要修改

```
$ podman info --format {{.Host.NetworkBackend}}
netavark
```

配置文件在`/usr/share/containers/containers.conf`

```
[network]
...
network_backend = "netavark"
...
```

## 10.6 使用systemd管理容器

由于`podman`是daemonless的特性，容器执行默认不会受到监控。需要`systemd`的额外辅助

为现有容器（不会自动删除的容器）创建unit file

```
$ podman generate systemd --name mycontainer --files /home/username/mycontainer.service
```

执行后自动删除容器，最后加`--new`即可

```
$ podman generate systemd --name mycontainer --files /home/username/mycontainer.service --new
```

将该文件放入`~/.config/systemd/user`

```
$ mv mycontainer.service .config/systemd/user/
```

就可以使用`systemctl`启停容器了

```
$ systemctl --user start mycontainer.service
$ systemctl --user stop mycontainer.service
```

一旦使用`systemd`启停，就不能再使用`podman`命令启停该容器了

用户登录时自动启动容器

```
$ systemctl --user enable mycontainer.service
```

或系统启动时自动`linger`，类似于用户自动登录，并启动容器

```
$ loginctl enable-linger
```

> 关闭使用`disable-linger`

## 10.7 补充

### 10.7.1 暂停容器

使用`pause`和`unpause`可以启停容器以及其内所有进程

```
$ podman pause mycontainer
$ podman unpause mycontainer
```

## 11 专题：SR-IOV

## 12 专题：Linux cgroup

## 12.1 cgroup基本概念

查看内核提供的`cgroups`介绍

```
$ man cgroups
```

`cgroup`是Linux下的一个虚拟文件系统

## 12.2 cgroup v1

## 12.3 cgroup v2

## 12.4 namespaces

查看内核提供的`namespaces`介绍

```
$ man namespaces
```

## 12.5 使用cgroup

Arch通过AUR安装`libcgroup`

Alpine下安装`cgroup-tools`

```
$ doas apk add cgroup-tools
```

## 13 IOI容器工具：isolate