# FreeBSD作为桌面系统使用的安装过程以及注意事项

上一次更新日期：2022-04-09

## 简介

记录有关FreeBSD作为桌面系统使用的安装过程，以及注意事项

常用参考

[FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/)

[FreeBSD Manual Pages](https://www.freebsd.org/cgi/man.cgi)

[FreeBSD Wiki](https://wiki.freebsd.org/)

[FreeBSD 论坛](https://forums.freebsd.org/)

[FreshPorts](https://www.freshports.org/)

## 目录

+ [**1**](#1-下载镜像) 下载镜像
+ [**2**](#2-基本安装) 基本安装
    + [**2.1**](#21-磁盘分区) 磁盘分区
        + [**2.1.1**](#211-分区与格式化) 分区与格式化
        + [**2.1.2**](#212-编辑fstab与安装) 编辑fstab与安装
        + [**2.1.3**](#213-在fstab中使用uuid) 在fstab中使用UUID
    + [**2.2**](#22-启动引导) 启动引导
        + [**2.2.1**](#221-单系统引导) 单系统引导
        + [**2.2.2**](#222-双系统多系统引导) 双系统/多系统引导
        + [**2.2.3**](#223-refind引导配置) rEFInd引导配置
    + [**2.3**](#23-个人设置偏好参考不代表建议的选择) 个人设置偏好参考（不代表建议的选择）
+ [**3**](#3-安装后杂项) 安装后杂项
    + [**3.1**](#31-改镜像源) 改镜像源
    + [**3.2**](#32-安装图形界面) 安装图形界面
        + [**3.2.1**](#321-安装显卡驱动) 安装显卡驱动
        + [**3.2.2**](#322-安装x) 安装X
        + [**3.2.3**](#323-安装中文字体) 安装中文字体
        + [**3.2.4**](#324-安装dewm以及配置) 安装DE/WM以及配置
        + [**3.2.5**](#325-图标) 图标
    + [**3.3**](#33-禁用蜂鸣器) 禁用蜂鸣器
    + [**3.4**](#34-网络配置无线网卡驱动) 网络配置，无线网卡驱动
    + [**3.5**](#35-声音配置声卡驱动) 声音配置，声卡驱动
    + [**3.6**](#36-输入法) 输入法
    + [**3.7**](#37-添加ext文件系统支持) 添加ext文件系统支持
    + [**3.8**](#38-doas) doas
+ [**4**](#4-zfs使用简记) ZFS使用简记
+ [**5**](#5-服务管理) 服务管理

## 平台配置

> CPU：Intel Celeron J3160(4) @ 1.6GHz
>
> GPU：Intel HD Graphics 400 (Gen8)
>
> 内存：2 x 2GB DDR3
>
> 硬盘：ZHITAI 256G SATA SSD & Seagate 500G 2.5" 5400rpm HDD
>
> 启动模式：UEFI x64
>
> 磁盘分区格式：GPT


## 1 下载镜像

[FreeBSD 13.0 RELEASE官网镜像下载](https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/13.0/)

使用U盘启动安装，下载memstick安装镜像，使用`xz -dk`解压后，再使用`dd`命令将`.img`镜像刻录到u盘


## 2 基本安装

建议使用较老的硬件。Intel3代到9代酷睿核显平台是比较理想的选择

从Intel的H7x/B7x（差不多也就是3代酷睿时代，2012年左右）开始绝大部分Intelx86平台都支持UEFI启动，这里就只记录UEFI启动模式的安装方法。Legacy模式基本不用太复杂的操作就不赘述了

安装前建议将CMOS时钟设置成UTC时间。开机进启动项选择U盘启动，到Bootloader界面，按B启动多用户模式

基本安装操作非常简单，大部分步骤照着bsdinstall的提示走就行了

UEFI模式安装的主要难点在于磁盘分区和启动引导的解决，但是UEFI启动对于双系统乃至多系统用户来说会方便很多


## 2.1 磁盘分区

### 2.1.1 分区与格式化

bsdinstall自带的磁盘分区界面不太友好，这里提供使用Shell分区的方法，便于灵活操作分区

UEFI启动模式需要一个ESP分区，一般为FAT或FAT32格式

如果是空磁盘先创建一个GPT分区表，这里假设磁盘为ada0

```shell
gpart create -s gpt ada0
```

创建分区，假设创建一个200M的ESP分区和一个32G的主分区（`/dev/ada0p1`和`/dev/ada0p2`）

```shell
gpart add -t efi -s 200M ada0
gpart add -t freebsd-ufs -s 32G ada0
```

格式化分区，其中EFI分区格式化为FAT32，根目录分区格式化为UFS2

```shell
newfs_msdos -F 32 -c 1 /dev/ada0p1
newfs -U -L FreeBSD /dev/ada0p2
```

如果是SSD，可以使用`tunefs`打开UFS2的TRIM功能

```shell
tunefs -t enable /dev/ada0p2
```

如果想要创建swap分区的可以如以下操作，比如创建一个2G的swap分区（ada0p3）

```shell
gpart add -t freebsd-swap -s 2G ada0
```

swap分区可以通过`swapon`挂载，这里先不必挂载

```shell
swapon /dev/ada0p3
```

### 2.1.2 编辑fstab与安装

最后使用`ee`编辑fstab，文件位于`/tmp/bsdinstall_etc/fstab`

附：个人fstab参考。内存小所以分了swap

```
/dev/ada0p3       /         ufs       rw              0 1
/dev/ada1p3       none      swap      sw              0 0
/dev/ada1p5       /var      ufs       rw              0 2
/dev/ada1p8       /home     ufs       rw              0 2
tmpfs             /tmp      tmpfs     rw,mode=1777    0 0
```

最后挂载分区到`/mnt`，如果想要将其他分区挂载到`/home`，就要创建目录挂载，以下为例

```shell
mount /dev/ada0p2 /mnt
mkdir /mnt/home
mount /dev/ada1p1 /mnt/home
```

`exit`退出Shell，bsdinstall即开始自动安装

### 2.1.3 在fstab中使用UUID

使用`gpart`查看UUID，其中的rawuuid就是我们想要的UUID

```
gpart list /dev/ada0 | less
```

删除原来的入口，添加UUID入口

```
/dev/gptid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  /   ufs   rw      0 1
```

开启内核启动参数，使能对UFS的UUID的识别

```
kern.geom.label.ufsid.enable="1"
```

## 2.2 启动引导

启动引导问题可以到所有安装都结束以后再进入Shell处理，只要有ESP分区就可以

将`loader.efi`拷贝到ESP分区下的`EFI/FreeBSD`，也可以叫其他的文件名

```shell
mount -t msdosfs /dev/ada0p1 /mnt
mkdir -p /mnt/EFI/FreeBSD
cp /boot/loader.efi /mnt/EFI/FreeBSD
```

### 2.2.1 单系统引导

使用`efibootmgr`将`loader.efi`注册到BIOS的启动项中。`efibootmgr`用法见[Alpine](240706a_alpine.md#191-refind)


### 2.2.2 双系统/多系统引导

大部分用户一般都会在已经安装了其他操作系统的电脑上安装FreeBSD作为尝试

硬盘原来已经安装了ArchLinux，这里用GRUB来chainload FreeBSD的bootloader（原理和UEFI模式手动配置Windows双启动相同）

重启进ArchLinux配置`/etc/grub.d/40_custom`添加启动入口如下，将XXXX-XXXX替换为ESP分区的UUID（可以通过`blkid`命令获取），**而hints参数对于不同机器配置可能会不一样**，其他hints的获取具体可以参考[ArchWiki](https://wiki.archlinux.org/index.php/GRUB#Windows_installed_in_UEFI/GPT_mode)

```
# /etc/grub.d/40_custom
menuentry "FreeBSD Bootloader" {
    insmod part_gpt
    insmod fat
    insmod chain
    search --no-floppy --fs-uuid --set=root --hint-bios=hd0,gpt1 --hint-efi=hd0,gpt1 --hint-baremetal=ahci0,gpt1 XXXX-XXXX
    chainloader /EFI/FreeBSD/BOOTX64.efi
}
```

再重新生成grub配置文件即可

```shell
grub-mkconfig -o /boot/grub/grub.cfg
```

重启进入GRUB界面就应该看到`FreeBSD Bootloader`选项了，可以正常引导FreeBSD

### 2.2.3 rEFInd引导配置

配置`refind.conf`添加一个入口。假设`loader.efi`在`/EFI/freebsd/`

```
menuentry "FreeBSD" {
    icon /EFI/refind/icons/os_freebsd.png
    loader /EFI/freebsd/loader.efi
}
```

## 2.3 个人设置偏好参考（不代表建议的选择）

安装部分：一般选择kernel-dbg，src，作为纯64位环境使用所以不使用lib32。如果之后有运行wine的需求，建议勾上lib32

服务启动：一般开启moused，ntpd，powerd，dumpdev。有需要可以开启sshd远程访问

安全特性：一般开启clear_tmp，disable_syslogd，disable_sendmail，secure_console，disable_ddtrace


## 3 安装后杂项

## 3.1 改镜像源

FreeBSD使用ports和pkg两种方法安装软件包，pkg是已经编译好的，ports是源码，需要自己编译

出于某种原因，FreeBSD官方对于镜像站管控非常严格，中国大陆目前还没有官方镜像，以下列出部分亚太地区的官方镜像

+ 台湾镜像 pkg0.twn.freebsd.org

+ 日本镜像 pkg0.kwc.freebsd.org

+ 马来西亚镜像 pkg0.kul.freebsd.org

> 现在FreeBSD官方已经改善大陆地区的访问情况，直接使用官方源也可

几个国内的非官方镜像站：

+ 中科大镜像 mirrors.ustc.edu.cn 有pkg和ports，有Release安装镜像（首选）

+ 网易镜像 mirrors.163.com 有pkg和ports，有Release安装镜像

+ 兰大镜像 mirror.lzu.edu.cn 有安装镜像可用

+ 北交大镜像 mirror.bjtu.edu.cn 安装镜像比较全，有Release，Current，Stable安装镜像

修改举例：

修改pkg镜像：添加`/usr/local/etc/pkg/repos/mymirror.conf`如下（可以直接从`/etc/pkg/FreeBSD.conf`复制修改）

```
# 使用freebsd.cn，最新latest，否则quarterly
freebsdcn: {
  url: "pkg+http://pkg.freebsd.cn/${ABI}/latest", 
  mirror_type: "srv",
  signature_type: "none",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}

# 禁用原/etc/pkg/FreeBSD.conf
FreeBSD: {
  enabled: no
}
```

2024.08.10更新：freebsd.cn已经关闭，使用中科大镜像源。直接创建`/usr/local/etc/pkg/repos/ustc.conf`，在FreeBSD 14中配置如下。需要事先安装`security/ca_root_nss`

```
ustc: {
  url: "https://mirrors.ustc.edu.cn/freebsd-pkg/${ABI}/latest",
  signature_type: "none",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}

FreeBSD: {
  enabled: no
}
```

USTC Ports配置见 https://mirrors.ustc.edu.cn/help/freebsd-ports.html

首次使用`pkg`会自动安装。改镜像源以后必须运行`pkg update -f`更新索引

修改ports源`/etc/make.conf`，4为使用的线程数，根据需要更改

```
# 启用线程数
FETCH_CMD=axel -n 4 -a
DISABLE_SIZE=yes
MASTER_SITE_OVERRIDE?=http://ports.freebsd.cn/distfiles/${DIST_SUBDIR}/
```

修改portsnap源`/etc/portsnap.conf`。也可以不改使用默认的

```
SERVERNAME=portsnap.freebsd.cn
```

修改后运行`portsnap fetch`获取，**如果之前bsdinstall安装时没有选择Ports，第一次需要再运行**`portsnap extract`。以后更新只要`portsnap fetch update`即可


## 3.2 安装图形界面

### 3.2.1 安装显卡驱动

安装`drm-kmod`，Intel集显平台可以不安装`xf86-video-intel`（原因参考[ArchWiki](https://wiki.archlinux.org/index.php/Intel_graphics#Installation)）

```shell
pkg install drm-fbsd13-kmod
```

之后通过`kldload`加载intel的驱动模块查看驱动是否工作正常

```shell
kldload i915kms
```

出现如下显示代表模块加载成功。如果没有出现类似输出或者出现卡死的情况，代表驱动可能不支持该显卡

![模块加载](images/210115a001.jpg)

如果没有问题，编辑`/etc/rc.conf`添加一行，在启动时加载模块

```
# Load i915kms
kld_list="i915kms"
```

编辑`/boot/loader.conf`，使能vt

```
kern.vty=vt
```

> FreeBSD的显卡驱动相比Linux要稍显落后，包括Intel的核显驱动。这次使用的Celeron J3160属于Intel的低功耗SoC产品线，经测试在`drm-fbsd13-kmod`之前的驱动中不被正常支持（13.0更新了来自Linux的显卡驱动，然而同属Braswell的N3160早在11.2核显就可以正常工作，见[FreeBSD论坛相关贴](https://forums.freebsd.org/threads/xcfe-login-gui-doesnt-show-up.66419/)）。建议安装FreeBSD之前先考察显卡驱动的支持状况，尤其是使用类似产品的用户（Intel的低功耗奔腾、赛扬、凌动系列，一般使用Nxxxx/Jxxxx/Zxxxx命名方式）

> 附：[2018年FreeBSD论坛的英特尔集显驱动讨论](https://forums.freebsd.org/threads/how-to-use-the-old-or-the-new-i915kms-driver-for-intel-integrated-graphics-with-xorg.66732/)（仅供参考，实际现在新版驱动已经变化）

> 想要查看自己的显卡或其他硬件是否确实被FreeBSD支持，这里推荐一个[网站](https://bsd-hardware.info)

安装3D库（mesa）

```shell
pkg install mesa-libs mesa-dri
```

安装intel硬件视频解码支持

```shell
pkg install libva-intel-media-driver # 适用于HD5000以及更新的显卡
```

或

```shell
pkg install libva-intel-driver # 旧驱动，最高支持到UHD630
```

最后注意必须要将用户添加到`video`或`wheel`组才能访问3D加速，示例

```shell
pw groupmod video -m me
```


### 3.2.2 安装X

```shell
pkg install xorg
```

此时`startx`，可以启动TWM，如下，说明xorg可以使用，关闭X只要在左侧窗口`exit`即可

![启动X](images/210115a002.jpg)


### 3.2.3 安装中文字体

```shell
pkg install wqy-fonts # 安装文泉驿字体
```


### 3.2.4 安装DE/WM以及配置

个人一般不使用DM，通过tty界面登录后startx，这里只安装DE

安装xfce

```shell
pkg install xfce xfce4-goodies
```

使能dbus，在`/etc/rc.conf`

```
dbus_enable="YES"
```

编辑`~/.xinitrc`，`source`一下xinitrc

```
. /usr/local/etc/xdg/xfce4/xinitrc
```

重启，登陆后直接`startx`就可以启动xfce了

![](images/210115a003.jpg)

注意，`startx`之后X默认使用的虚拟终端为`ttyv8`，切换到其他虚拟终端后通过`Ctrl+Alt+F9`返回图形界面


### 3.2.5 图标

安装Papirus扁平风格图标

```shell
pkg install papirus-icon-theme
```


## 3.3 禁用蜂鸣器

FreeBSD默认开启主板蜂鸣器

编辑`/boot/loader.conf`，添加一行

```
kern.vt.enable_bell=0
```


## 3.4 网络配置，无线网卡驱动

主板的minipcie有一张Realtek的RTL8188EE网卡

编辑`/etc/rc.conf`，创建`wlan0`。这里是`rtwn0`，可以通过`sysctl net.wlan.devices`获取名称。注意如果使用`SYNCDHCP`选项会拖慢开机

```
wlans_rtwn0="wlan0"
ifconfig_wlan0="WPA DHCP"
```

在`/etc/wpa_supplicant.conf`根据ssid和密码添加配置

```
network={
  ssid="myssid"
  psk="mypasswd"
}
```

之后重启`netif`即可看到`wlan0`了

```
service netif restart
```


## 3.5 声音配置，声卡驱动

主板集成声卡ALC662以及Intel的HDMI输出声卡。在`/boot/loader.conf`添加

```
snd_hda_load="YES"
sysctlinfo_load="YES"
```

调节音量使用终端工具`mixertui`，使用和`alsamixer`类似

```
pkg install mixertui
```


## 3.6 输入法

安装`fcitx`，添加中文和日语输入支持。确保在`rc.conf`开启了dbus

```shell
pkg install zh-fcitx zh-fcitx-configtool zh-fcitx-libpinyin ja-fcitx-mozc fcitx-m17n
```

如果使用的是`sh`，那么编辑`.shrc`如下，添加几行设置环境变量（更加建议在`~/.xinitrc`中添加这些变量）。`csh`使用`setenv`

```shell
# fcitx env setup
export XMODIFIERS='@im=fcitx'
export GTK_IM_MODULE=fcitx
export GTK2_IM_MODULE=fcitx
export GTK3_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export QT4_IM_MODULE=fcitx
```

自启动

```shell
mkdir ~/.config/autostart
cp /usr/local/share/applications/fcitx.desktop ~/.config/autostart/
```

重启进入fcitx设置添加中文日语输入法即可


## 3.7 添加ext文件系统支持

```
pkg install fusefs-ext2
```

建议只读方式挂载ext4分区

```
kldload ext2fs
mount -t ext2fs -o ro /dev/adaXpX /mnt
```

## 3.8 doas

安装`doas`

```
pkg install doas
```

创建并编辑`/usr/local/etc/doas.conf`

```
cp /usr/local/etc/doas.conf.sample /usr/local/etc/doas.conf
ee /usr/local/etc/doas.conf
```

只保留`wheel`组的`doas`权限

```
permit nopass :wheel
```

## 4 ZFS使用简记

见[210130a](210130a_install-notice.md#22-存储与文件系统)

## 5 服务管理

见[210130a](210130a_install-notice.md#23-服务)