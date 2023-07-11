# Linux容器的使用

# 1 LXC

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

> 使用`lxc exec`直接以`root`身份执行命令

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

容器所有的配置选项（不限于安全选项）可以通过`lxc config set arch-01 ...`的形式进行设置，通过`lxc config show arch-01 --expanded`查看，也可以`lxc config edit arch-01`编辑所有选项

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

> 有关容器实例的配置选项都放在`config: {}`中，而设备相关都位于`devices:`

创建一个新的`profile`，这里是`arch-common`

```shell
lxc profile create arch-common
```

可以单个设置容器实例的变量，或设备的变量

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

前面创建的容器都是非特权容器，通常具有更高的安全性。无特殊需求应尽量使用非特权容器。特权容器的`root`就相当于宿主机的`root`

```shell
lxc config set arch-01 security.privileged=true
```

## 1.9 设备

可以向一个容器实例添加一些设备`device`，可用的设备类型如下

| ID | 名称 | 描述 |
| :- | :- | :- |
| 0 | `none` |  |
| 1 | `nic` | 网络接口 |
| 2 | `disk` | 存储 |
| 3 | `unix-char` | UNIX字符设备 |
| 4 | `unix-block` | UNIX块设备 |
| 5 | `usb` | USB设备 |
| 6 | `gpu` | 显卡 |
| 7 | `infiniband` | 光纤高速互联设备，常见于集群 |
| 8 | `unix-hotplug` | UNIX热插拔设备 |
| 9 | `tpm` | TPM安全模块 |

### 1.9.1 添加与删除

格式

```shell
lxc config device add instance_name device_name device_type key1=value1 key2=value2
```

示例，将宿主机的`/home/username/opt`挂载到`arch-01`的`/opt`，在容器内`ls /opt`可以看到内容

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

如果使用了`profile`，它可能会带入我们不想要的设备。添加一个类型为`none`同名设备即可覆盖

## 1.10 存储池管理

## 1.11 网络管理

# 2 Docker

# 3 Kubernetes

又称K8s