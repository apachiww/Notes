# ChimeraLinux作为桌面系统使用的安装过程以及注意事项

ChimeraLinux是相对较为年轻的一个发行版，诞生于2021年中。从[历史](https://chimera-linux.org/docs/history)看和FreeBSD，VoidLinux，AlpineLinux都有或多或少的关系

Chimera目前算不上是一个非常成熟的发行版，软件生态有一定局限性

主要尝试体验`dinit`。当前ChimeraLinux使用了FreeBSD的工具链（`llvm-clang elftoolchain`），`bsdutils`，Alpine的包管理`apk`，同时也是一个`musl-only`的发行版，可以说确实是非常hybrid

此外ChimeraLinux还实现了一个`turnstiled`用于管理用户服务，也是一个特色，作用类似`systemd`的`logind`。`turnstiled`目前仍在开发中，也被一些其他非`systemd`的发行版移植到它们的仓库中

## 目录

+ [**1**](#1-基本安装流程) 基本安装流程
    + [**1.1**](#11-磁盘分区与格式化) 磁盘分区与格式化
    + [**1.2**](#12-正式安装) 正式安装
    + [**1.3**](#13-启动引导) 启动引导
+ [**2**](#2-入门) 入门
    + [**2.1**](#21-服务管理) 服务管理
        + [**2.1.1**](#211-一些基本概念) 一些基本概念
        + [**2.1.2**](#212-文件) 文件
        + [**2.1.3**](#213-dinitctl命令) dinitctl命令
        + [**2.1.4**](#214-turnstiled) turnstiled
        + [**2.1.5**](#215-rclocal) rc.local
    + [**2.2**](#22-包管理) 包管理
    + [**2.3**](#23-日志) 日志
+ [**3**](#3-安装后杂项) 安装后杂项
    + [**3.1**](#31-doas) doas
    + [**3.2**](#32-图形界面sway) 图形界面：Sway
        + [**3.2.1**](#321-显卡与声卡) 显卡与声卡
        + [**3.2.2**](#322-基本安装) 基本安装
+ [**4**](#4-root-on-zfs) Root on ZFS

## 1 基本安装流程

目前Chimera在中国还没有镜像站，访问速度可能较慢，[镜像列表](https://chimera-linux.org/docs/apk/mirrors)，下载[chimera-linux-x86_64-LIVE-20250214-base.iso](https://repo.chimera-linux.org/live/latest/)，方便定制

## 1.1 磁盘分区与格式化

分两个区，一个给ESP一个给`/`。先wipe一下再`fdisk`分区

```
$ wipefs -a /dev/sda
$ fdisk /dev/sda
```

格式化

```
$ mkfs.vfat -F32 /dev/sda1
$ mkfs.ext4 /dev/sda2
```

挂载到`/mnt`。`/mnt`权限应当是`rwxr-xr-x`

```
$ mount /dev/sda2 /mnt
$ mkdir -p /mnt/boot/efi
$ mount /dev/sda1 /mnt/boot/efi
```

> 可以先不挂载ESP，后面安装GRUB的时候再挂载

## 1.2 正式安装

仅本地安装

```
$ chimera-bootstrap -l /mnt
```

联网从repo下载安装（最新，推荐）

```
$ chimera-bootstrap /mnt
```

`chroot`

```
$ chimera-chroot /mnt
$ apk update -f
$ apk upgrade --available
```

如果先前使用的本地安装，可以先删除Live system的组件

```
$ apk del base-live
```

安装LTS内核

```
$ apk add linux-lts
```

或支持ZFS的内核

```
$ apk add linux-lts-zfs-bin
```

新一点的Stable内核

```
$ apk add linux-stable
```

或

```
$ apk add linux-stable-zfs-bin
```

可以生成`/etc/fstab`

```
$ genfstab -U / >> /etc/fstab
```

改`root`密码

```
$ passwd
```

设定`/etc/hostname`

```
$ vim /etc/hostname
```

设置时区和CMOS时钟（UTC）

```
$ rm /etc/localtime
$ ln -sf /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
$ echo utc > /etc/hwclock
```

设置keymap，应当已经设定好了`KMAP=us`

```
$ vim /etc/default/keyboard
```

重新生成`initramfs`

```
$ update-initramfs -c -k all
```

## 1.3 启动引导

安装GRUB并使用`update-grub`自动生成`/boot/grub/grub.cfg`。安装完可以用`efibootmgr`看一下是否注册到启动项

```
$ apk add grub-x86_64-efi
$ grub-install --target=x86_64-efi --bootloader-id=chimera_grub --efi-directory=/boot/efi
$ update-grub
```

此时退出`chroot`并重启应当可以正常引导

## 2 入门

## 2.1 服务管理

目前使用`dinit`的发行版

Chimera: https://chimera-linux.org/docs/configuration/services

Artix: https://wiki.artixlinux.org/Main/Dinit

eweOS: https://os-wiki.ewe.moe/dev/topic/sysutils/dinit

### 2.1.1 一些基本概念

`dinit`将服务归为5类，分别为`process` `bgprocess` `scripted` `internal` `triggered`

+ `process`指普通进程类服务，`dinit`对其有完整的监控和管理功能

+ `bgprocess`指后台进程类服务，这类服务拥有daemon特性或者是从一个父进程fork出来的，`dinit`会获取到这个服务的PID，并且尽可能去监控以及管理这个服务。这类服务只有在父进程fork并terminate时才会被认为是完全启动

+ `scripted`指只会运行一次并退出（one-shot），不会持续运行的服务，典型的如`early-hostname`，设定主机名。这类服务运行一次正常退出后状态即`STARTED`

+ `internal`内部类型本身不会执行实际的进程或脚本，这类服务的文件和`systemd`类似，通常以`.target`结尾。这类服务可以方便依赖的管理，也可以说是一个想要达成的目标环境。其中包含的依赖才是关键

+ `triggered`触发类型有点类似`internal`，但是需要在接收到外部触发后才会启动

`dinit`中的服务有3种依赖关系，分别为`depends-on` `depends-ms` `waits-for`

+ `depends-on`是硬依赖，当前服务启动时`depends-on`的服务也必须是`STARTED`的状态。也就是说，当前服务必须在`depends-on`的服务之后启动。启动当前服务时会先启动`depends-on`的服务；而运行时停止`depends-on`的服务时会先停止当前服务

+ `waits-for`是软依赖，当前服务启动时`waits-for`的服务可以不是`STARTED`的状态。启动当前服务前只是会尝试去启动`waits-for`的服务，但是`waits-for`服务启动失败不会影响当前服务启动；而停止`waits-for`的服务不会停止当前服务

+ `depends-ms`（milestone）类似于`depends-on`，但区别是`depends-ms`的服务只有启动失败时才会阻止当前服务启动，如果`depends-ms`的服务启动成功后又停止，此时当前服务还在运行，那么当前服务不会被停止。也就是说相比`depends-on`只会有启动依赖，但是没有运行时依赖

### 2.1.2 文件

> 管理`dinit`只需通过`dinitctl`即可，通常无需关心这些文件。除非想自己编写服务

ChimeraLinux下`dinit`服务原文件可能会放在这些目录：

系统身份服务：`/etc/dinit.d` `/usr/lib/dinit.d` `/usr/local/lib/dinit.d`（不常用，用于仓库以外的软件）

用户身份服务（用于`turnstiled`）：`/etc/dinit.d/user` `/usr/lib/dinit.d/user` `/usr/local/lib/dinit.d/user`（不常用，用于仓库以外的软件）`~/.config/dinit.d`（仅对当前用户有效）

其中`/usr/lib/dinit.d`主要放一些系统关键服务（包括`early`阶段需要的服务，也有一些是通过`apk`安装的），`/etc/dinit.d`主要放一些系统身份运行的服务（例如`chronyd` `turnstiled`，大部分通过`apk`安装的非核心服务也会放到这里）

`/usr/lib/dinit.d/user`主要放用户身份运行的全局服务（对所有用户可用，例如`wireplumber` `pipewire`等）。`/etc/dinit.d/user`使用较少。`~/.config/dinit.d`用于放仅对当前用户可用的服务

> 看上去服务应该放到`/etc/dinit.d`还是`/usr/lib/dinit.d`实际上没有明确的界定，这两个目录都会被`dinit`扫描，但是可以确定的是`early`阶段所需服务都在`/usr/lib/dinit.d`，而大部分通过`apk`安装的非系统核心服务会放到`/etc/dinit.d`。`dinit`说`/etc/dinit.d`是默认的system location

通常`dinit`服务文件需要通过另外的`packagename-dinit`包安装，例如`chrony`，服务文件通过`chrony-dinit`安装

**自启动**

上述所有5类目录下都可以创建一个`boot.d`子目录，里面存放一些指向服务文件的软链接，表示Enable即会自启动。`boot.d`中的软链接不一定指向`boot.d`同级目录下的服务文件，也可以指向其他的

不同位置的`boot.d`也会有不同的作用

可以确定的是用户通过`dinitctl enable`使能的系统服务软链接会放到`/etc/dinit.d/boot.d`下。此外通过`apk`可以安装名为`packagename-dinit-link`的包，它的作用就是在`/usr/lib/dinit.d/boot.d`或`/usr/lib/dinit.d/user/boot.d`下创建软链接表示**强制**Enable，此时用户通过`dinitctl enable` `dinitctl disable`启用或禁用无效。目前Chimera只有`chrony dbus elogind nyagetty pipewire wireplumber udev`这些核心服务拥有相应的`dinit-link`包，用于防止意外禁用

```
$ apk info -L chrony-dinit
chrony-dinit-4.6.1-r0 contains:
etc/dinit.d/chrony
etc/dinit.d/chronyd

$ apk info -L chrony-dinit-links
chrony-dinit-links-4.6.1-r0 contains:
usr/lib/dinit.d/boot.d/chrony

$ apk info -L wireplumber-dinit
wireplumber-dinit-0.5.8-r0 contains:
usr/lib/dinit.d/user/wireplumber

$ apk info -L wireplumber-dinit-links
wireplumber-dinit-links-0.5.8-r0 contains:
usr/lib/dinit.d/user/boot.d/wireplumber
```

**服务文件格式**

详细关键字定义见 https://davmac.org/projects/dinit/man-pages-html/dinit-service.5.html

示例

```
# chronyd service, cannot handle readiness on its own
type            = process
command         = /usr/bin/chronyd -n -u _chrony
depends-on      = network.target
depends-on      = local.target
smooth-recovery = true
```

```
# turnstiled service
type        = process
before      = login.target
depends-on  = local.target
command     = /usr/bin/turnstiled
logfile     = /var/log/turnstiled.log
```

```
# setup the hostname
type        = scripted
command     = /usr/lib/dinit.d/early/scripts/hostname.sh
depends-on  = early-devices.target
```

```
# Virtual service for others to depend on; bring up networking daemons

type        = internal
depends-on  = pre-network.target
```

特殊服务，`boot`

```
# This is the primary entry point. It triggers startup
# of every other service. In addition to that it also
# provides the user-enabled service directory.

type            = internal
depends-on      = system
waits-for.d     = /etc/dinit.d/boot.d
```

常用关键字定义

| 关键字 | 定义 | 值 |
| :- | :- | :- |
| `type` | 服务类型，必需 | `process` `bgprocess` `scripted` `internal` `triggered` |
| `command` | 启动该服务需要执行的命令 |  |
| `depends-on` | 硬依赖，见前 |  |
| `waits-for` | 软依赖，见前 |  |
| `depends-ms` | 依赖，见前 |  |
| `after` | 非依赖关系，仅仅限制当前服务启动时，如果指定服务也在启动，会等待指定服务启动完成后再启动。如果指定服务未启动，那么启动当前服务不会启动`after`指定的服务 |  |
| `before` | 非依赖关系，仅仅限制当前服务启动时，如果指定服务想要启动，指定服务等待当前服务启动完成后再启动。相当于在指定服务文件里添加`after =`当前服务，作用等价 |  |
| `chain-to` | 非依赖关系，当前服务正常停止后启动指定服务 |  |
| `stop-command` | 停止该服务需要执行的命令，可选，仅适用于`process` `bgprocess` `scripted`。默认情况下停止服务只会向进程发信号 |  |
| `run-as` | 以指定用户身份执行 | UID或用户名，指定用户名时会使用当前用户的默认用户组，指定UID时会使用运行`dinit`时的用户组 |
| `restart` | 服务停止后是否重启 | `yes` `true` `on-failure` `no` `false`，`on-failure`表示仅在异常退出（状态码不为`0`）或被信号强制停止（`SIGTERM SIGINT SIGHUP SIGUSR1 SIGUSR2`以外的信号）时才重启。`yes`表示因为依赖服务停止或直接`dinitctl stop`停止也会重启 |
| `smooth-recovery` | 仅适用于`process` `bgprocess`，当前服务意外退出时立即自动重启，但是不会重启依赖当前服务的服务 | `yes` `true` `no` `false` |
| `restart-delay` | 两次重启行为之间的最小时间间隔 | `XXX.YYYY`单位秒，默认`0.2` |
| `restart-limit-interval` | 限制重启最长超时，如果在此时间内没有启动说明可能有问题，超过一定次数不再重启 | `XXX.YYYY`单位秒，默认`10` |
| `restart-limit-count` | 上述超时最多允许的次数 | 默认`3`次 |
| `start-timeout` | 启动超时，超时后给进程发`SIGINT`让其试图停止，发送`SIGINT`后因为进程标记为`stopping`状态所以进入`stop-timeout`再开始新的倒计时 | `XXX.YYY`单位秒，默认`60` |
| `stop-timeout` | 停止超时，超时后给进程发`SIGKILL`强制停止 | `XXX.YYY`单位秒，默认`10` |
| `term-signal` | 想让进程停止时发送的信号 | `TERM` `KILL` `HUP`等 |
| `logfile` | 服务日志文件的路径，日志即通过stdout和stderr打印出来的内容 |  |
| `consumer-of` | 当前服务接受指定服务的stdout到自己的stdin，作用相当于管道 |  |
| `options` | 可选参数，见下 |  |

| Options | 定义 |
| :- | :- |
| `runs-on-console` | 当前服务需要使用终端，即将stdin和stdout定向到`dinit`使用的标准输入输出设备。该选项需要独占终端，如果当前有其他进程在占用，当前进程需要等待 |
| `starts-on-console` | 仅在启动阶段占用终端，仅适用于`bgprocess` `scripted`。需要独占终端 |
| `shares-console` | 不可与前两者混用。非独占式使用终端，可以避免等待 |

### 2.1.3 dinitctl命令

启停服务

```
$ dinitctl start sshd
$ dinitctl stop sshd
```

> `start`指强制启动，服务会被标记为`[+]`由用户显式启动（`explicit activation`），此时该服务交由用户管理，并且不会因为依赖服务停止而自动停止

唤醒服务

```
$ dinitctl wake chronyd
```

> 唤醒服务和`start`显式启动不同，服务不会标记为`[+]`显式启动，并且会在依赖服务停止时自动停止

可以消除显式启动服务的`explicit`标记，这样服务会随着依赖服务的停止而自动停止

```
$ dinitctl release sshd
```

使用过`start` `stop`后回归正常状态，归还给`dinit`自动管理

```
$ dinitctl unpin chronyd
```

重启服务

```
$ dinitctl restart sshd
```

> `restart`以后的效果和`start`相同，都是显式启动

列出所有服务状态

```
$ dinitctl list
[[+]     ] boot
[{+}     ] system
```

符号定义

```
[{+}     ] 服务已启动
[{ }<<   ] 服务正在启动
[   <<{ }] 服务正在启动，启动后立即停止
[{ }>>   ] 服务正在停止，停止后立即重启
[   >>{ }] 服务正在停止
[     {-}] 服务已停止
[[+]     ] 显式启动，用户强制启动（或系统默认启动项）而非由于依赖关系启动
[{s}     ] 启动被跳过
[     {X}] 启动失败或运行时出错退出
```

查看服务状态，如果是进程类服务会显示PID

```
$ dinitctl status chronyd
Service: chronyd
    State: STARTED
    Activation: start due to dependent(s)
    Process ID: 419
$ dinitctl status boot
Service: boot
    State: STARTED
    Activation: explicitly started
```

给服务发送信号

```
$ dinitctl signal TERM sshd
```

启用服务，本质上是在`boot`服务添加`waits-for`，即在`/etc/dinit.d/boot.d`下创建软链接

```
$ dinitctl enable sshd
```

禁用服务

```
$ dinitctl disable sshd
```

添加依赖，前者依赖后者。示例，在`hostapd`添加`depends-on = ifupdown`

```
$ dinitctl add-dep need hostapd ifupdown
```

> 依赖类型可以是`need` `milestone` `waits-for`，分别对应`depends-on` `depends-ms` `waits-for`
>
> 被依赖的服务当前需要是`STARTED`状态

删除依赖

```
$ dinitctl rm-dep need hostapd ifupdown
```

卸载服务文件，服务需要是`STOPPED`且没有依赖它的服务文件

```
$ dinitctl unload mysrv
```

重载服务文件，修改一些服务文件中的配置后需要执行，但是所有配置不一定立即生效

```
$ dinitctl reload mysrv
```

触发/清除触发`triggered`服务

```
$ dinitctl trigger mysrv
$ dinitctl untrigger mysrv
```

### 2.1.4 turnstiled

`turnstiled`用于管理用户服务，配置文件在`/etc/turnstile/turnstiled.conf`。通常用户无需干预

`turnstiled`会扫描各`dinit.d`目录下的`user`目录来确认需要运行的服务，以及使用什么用户身份去执行

这些目录中的服务文件有效：`/etc/dinit.d/user` `/usr/lib/dinit.d/user` `/usr/local/lib/dinit.d/user` `~/.config/dinit.d`，Enable的服务放在这些目录的`boot.d`下

默认情况下用户logout会终结其所有服务。`turnstile`提供了`linger`功能，这样用户logout时服务不会停止

要为用户`user-name`开启`linger`，创建以下空文件即可。关闭只需删除该空文件

```
$ touch /var/lib/turnstiled/linger/user-name
```

### 2.1.5 rc.local

`/etc/rc.local`会在`early`阶段结束以后执行，可以和后续的服务启动并行执行。如果有些任务无法通过`dinit`实现，可以写在这里

## 2.2 包管理

镜像配置可以放在`/etc/apk/repositories.d`，该目录默认不存在需要创建

示例，在上述目录放一个`00-chimera-linux-org.list`

```
set CHIMERA_REPO_URL=https://repo.chimera-linux.org
```

其他见[Alpine笔记](240706a_alpine.md#32-包管理)

## 2.3 日志

可以使能`syslog-ng`开启日志功能

```
$ dinitctl enable syslog-ng
```

日志记录在`/var/log/messages`

## 3 安装后杂项

## 3.1 doas

```
$ apk add opendoas
```

再依据添加的用户改`/etc/doas.conf`

## 3.2 图形界面：Sway

dotfiles https://github.com/apachiww/dotfiles

注意ChimeraLinux下无需通过`dbus-run-session`运行`sway`

### 3.2.1 显卡与声卡

Intel平台，UHD630

```
$ apk add mesa mesa-dri mesa-gbm-libs mesa-libgallium mesa-vulkan mesa-gl-libs mesa-demos vulkan-tools libva-utils intel-media-driver
```

将用户加入`video`组

确保声卡固件安装

```
$ apk add firmware-sof
```

Chimera默认使用`pipewire`和`wireplumber`且默认开启，带`pulseaudio`兼容，所以无需将用户加入`audio`组

### 3.2.2 基本安装

基础组件

```
$ apk add elogind polkit elogind-polkit wmenu sway swaybg sway-backgrounds xwayland dbus dbus-x11 man-pages bash-completion
```

网络管理

```
$ apk add networkmanager
$ dinitctl enable networkmanager
```

应用程序

```
$ apk add foot foot-terminfo grim swappy slurp fuzzel mako dolphin waybar wl-clipboard firefox chromium imv zathura
```

字体

```
$ apk add fonts-source-code-pro-otf fonts-source-sans-otf fonts-noto-extra fonts-noto fonts-dejavu
```

图标

```
$ apk add papirus-icon-theme adwaita-icon-theme
```

输入法（暂无中文）

```
$ apk add fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt
```

## 4 Root on ZFS

和其他发行版类似，可以参考[Void笔记](250302a_void.md)或[官网](https://chimera-linux.org/docs/installation/partitioning/zfs)，只要在`chimera-bootstrap`之前分好区挂载好就行。普通方案分3个区，一个ESP一个`/boot`一个ZFS，或者使用ZFSBootMenu的两分区方案。最后检查一下GRUB或rEFInd传的参数是否正确就行