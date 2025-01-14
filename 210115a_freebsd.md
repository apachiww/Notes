# FreeBSD作为桌面系统使用的安装过程以及注意事项

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
        + [**2.2.2**](#222-双系统多系统引导grub) 双系统/多系统引导：grub
        + [**2.2.3**](#223-refind引导配置) rEFInd引导配置
    + [**2.3**](#23-设置参考不代表建议的选择) 设置参考（不代表建议的选择）
+ [**3**](#3-安装后杂项) 安装后杂项
    + [**3.1**](#31-改镜像源) 改镜像源
        + [**3.1.1**](#311-pkg) pkg
        + [**3.1.2**](#312-ports) ports
    + [**3.2**](#32-x11) X11
        + [**3.2.1**](#321-安装显卡驱动) 安装显卡驱动
        + [**3.2.2**](#322-安装x) 安装X
        + [**3.2.3**](#323-安装中文字体) 安装中文字体
        + [**3.2.4**](#324-安装dewm以及配置) 安装DE/WM以及配置
        + [**3.2.5**](#325-图标) 图标
        + [**3.2.6**](#326-输入法) 输入法
        + [**3.2.7**](#327-声音配置声卡驱动) 声音配置，声卡驱动
    + [**3.3**](#33-wayland) Wayland
        + [**3.3.1**](#331-显卡驱动) 显卡驱动
        + [**3.3.2**](#332-基础组件) 基础组件
        + [**3.3.3**](#333-安装sway) 安装Sway
        + [**3.3.4**](#334-音频) 音频
        + [**3.3.5**](#335-输入法) 输入法
    + [**3.4**](#34-杂项) 杂项
        + [**3.4.1**](#341-关蜂鸣器) 关蜂鸣器
        + [**3.4.2**](#342-无线网络连接) 无线网络连接
        + [**3.4.3**](#343-网络管理) 网络管理
        + [**3.4.4**](#344-添加ext文件系统支持) 添加ext文件系统支持
        + [**3.4.5**](#345-doas) doas
+ [**4**](#4-zfs) ZFS
+ [**5**](#5-服务管理) 服务管理

## 1 下载镜像

[FreeBSD 14.2](https://www.freebsd.org/releases/14.2R/announce/)

使用U盘启动安装，下载memstick安装镜像，使用`xz -dk`解压后，再使用`dd`命令将`.img`镜像刻录到u盘

## 2 基本安装

x86 UEFI启动

安装前建议将CMOS时钟设置成UTC时间。开机进启动项选择U盘启动，到Bootloader界面，按B启动多用户模式

基本安装操作非常简单，大部分步骤照着bsdinstall的提示走就行了

UEFI模式安装的主要难点在于磁盘分区和启动引导的解决，但是UEFI启动对于双系统乃至多系统用户来说会方便很多


## 2.1 磁盘分区

### 2.1.1 分区与格式化

bsdinstall自带的磁盘分区功能缺乏灵活性。这里提供使用Shell分区的方法（在界面选择最后一项Shell），便于灵活操作分区

首先UEFI启动模式需要一个ESP分区，一般为FAT或FAT32格式

如果是空磁盘先创建一个GPT分区表，这里假设磁盘为ada0

```
$ gpart create -s gpt ada0
```

创建分区，假设创建一个200M的ESP分区和一个32G的主分区（`/dev/ada0p1`和`/dev/ada0p2`）

> NVME硬盘在`/dev/nda0pX`

```
$ gpart add -t efi -s 200M ada0
$ gpart add -t freebsd-ufs -s 32G ada0
```

格式化分区，其中EFI分区格式化为FAT32，根目录分区格式化为UFS2

```
$ newfs_msdos -F 32 -c 1 /dev/ada0p1
$ newfs -U -L FreeBSD /dev/ada0p2
```

如果是SSD，可以使用`tunefs`打开UFS2的TRIM功能

```
$ tunefs -t enable /dev/ada0p2
```

如果想要创建swap分区（可选）

```
$ gpart add -t freebsd-swap -s 2G ada0
```

swap分区可以通过`swapon`挂载，这里先不必挂载

```
$ swapon /dev/ada0pX
```

### 2.1.2 编辑fstab与安装

最后使用`ee`编辑fstab，文件位于`/tmp/bsdinstall_etc/fstab`

示例，SSD`/dev/ada0p3`挂载到`/`，HDD`/dev/ada1p8`挂载到`/home`

```
/dev/ada0p3       /         ufs       rw              0 1
/dev/ada1p8       /home     ufs       rw              0 2
/dev/ada1p3       none      swap      sw              0 0
tmpfs             /tmp      tmpfs     rw,mode=1777    0 0
```

最后挂载数据分区到`/mnt`，如果想要将其他分区挂载到`/home`，就要创建目录挂载，示例

```
$ mount /dev/ada0p3 /mnt
$ mkdir /mnt/home
$ mount /dev/ada1p8 /mnt/home
```

`exit`退出Shell，bsdinstall即开始自动安装已选组件

### 2.1.3 在fstab中使用UUID

如果后续想要在`/etc/fstab`中使用UUID，可以如下操作

使用`gpart`查看UUID，其中的rawuuid就是我们想要的UUID

```
$ gpart list /dev/ada0 | less
```

删除`/etc/fstab`中该分区原来的入口，添加UUID入口，示例

```
/dev/gptid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  /   ufs   rw      0 1
```

开启内核启动参数，使能对UFS的UUID的识别（在`/boot/loader.conf`）

```
kern.geom.label.ufsid.enable="1"
```

此时重启，顺利进入系统则说明成功改为UUID访问

## 2.2 启动引导

启动引导问题可以到所有安装都结束以后再进入Shell处理，只要有ESP分区就可以

首先将安装介质的`loader.efi`拷贝到ESP分区下的`EFI/FreeBSD`，也可以叫其他的文件名

```
$ mount -t msdosfs /dev/ada0p1 /mnt
$ mkdir -p /mnt/EFI/freebsd
$ cp /boot/loader.efi /mnt/EFI/freebsd
```

### 2.2.1 单系统引导

直接使用`efibootmgr`将`loader.efi`注册到BIOS的启动项中。`efibootmgr`用法见[Alpine安装教程](240706a_alpine.md#191-refind)


### 2.2.2 双系统/多系统引导：grub

大部分用户一般都会在已经安装了其他操作系统的电脑上安装FreeBSD作为尝试

这里用GRUB来chainload FreeBSD的bootloader（原理和UEFI模式手动配置Windows双启动相同）

重启进ArchLinux配置`/etc/grub.d/40_custom`添加启动入口如下，将XXXX-XXXX替换为ESP分区的UUID（可以通过`blkid`命令获取），**而hints参数对于不同机器配置可能会不一样**，其他hints的获取具体可以参考[ArchWiki](https://wiki.archlinux.org/index.php/GRUB#Windows_installed_in_UEFI/GPT_mode)

```
# /etc/grub.d/40_custom
menuentry "FreeBSD Bootloader" {
    insmod part_gpt
    insmod fat
    insmod chain
    search --no-floppy --fs-uuid --set=root --hint-bios=hd0,gpt1 --hint-efi=hd0,gpt1 --hint-baremetal=ahci0,gpt1 XXXX-XXXX
    chainloader /EFI/freebsd/loader.efi
}
```

再执行`grub-mkconfig`重新生成grub配置文件即可。重启进入GRUB界面就应该看到`FreeBSD Bootloader`入口了，可以正常引导FreeBSD

### 2.2.3 rEFInd引导配置

配置`refind.conf`添加一个入口。假设`loader.efi`在`/EFI/freebsd/`

```
menuentry "FreeBSD" {
    icon /EFI/refind/icons/os_freebsd.png
    loader /EFI/freebsd/loader.efi
}
```

## 2.3 设置参考（不代表建议的选择）

基本组件：作为纯64位环境使用所以不使用lib32相关的项。不安装ports。如果之后有运行wine的需求，可以勾上lib32

服务启动：一般开启moused，ntpd，powerd，dumpdev。有需要可以开启sshd远程访问

安全特性：一般开启clear_tmp，disable_syslogd，secure_console，disable_ddtrace


## 3 安装后杂项

## 3.1 改镜像源

### 3.1.1 pkg

FreeBSD使用ports和pkg两种方法安装软件包，pkg是已经编译好的，ports是源码，需要自己编译

出于某种原因，FreeBSD官方对于镜像站管控非常严格，中国大陆目前还没有官方镜像，以下列出部分亚太地区的官方镜像

+ 台湾镜像 pkg0.twn.freebsd.org

+ 日本镜像 pkg0.kwc.freebsd.org

+ 马来西亚镜像 pkg0.kul.freebsd.org

> 直接使用官方源也可

几个国内的非官方镜像站：

+ 中科大镜像 mirrors.ustc.edu.cn

+ 网易镜像 mirrors.163.com

+ 兰大镜像 mirror.lzu.edu.cn

+ 北交大镜像 mirror.bjtu.edu.cn

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

如果使用中科大镜像源，可以创建`/usr/local/etc/pkg/repos/ustc.conf`，在FreeBSD 14中配置如下。需要事先安装`security/ca_root_nss`

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

首次使用`pkg`会自动安装。改镜像源以后必须运行`pkg update -f`更新索引

### 3.1.2 ports

> 不建议`ports`和`pkg`混用。如果要同时使用需要保证`pkg`和`ports`的release branch同步

USTC Ports配置见 https://mirrors.ustc.edu.cn/help/freebsd-ports.html

修改ports源`/etc/make.conf`，4为使用的线程数，根据需要更改

```
# 启用线程数
FETCH_CMD=axel -n 4 -a
DISABLE_SIZE=yes
MASTER_SITE_OVERRIDE?=http://mirrors.ustc.edu.cn/freebsd-ports/distfiles/${DIST_SUBDIR}/
```

## 3.2 X11

FreeBSD 13, Xfce

### 3.2.1 安装显卡驱动

安装`drm-kmod`，Intel集显平台可以不安装`xf86-video-intel`（原因参考[ArchWiki](https://wiki.archlinux.org/index.php/Intel_graphics#Installation)）

```
$ pkg install drm-fbsd13-kmod
```

之后通过`kldload`加载intel的驱动模块查看驱动是否工作正常

```
$ kldload i915kms
```

出现如下显示代表模块加载成功。如果没有出现类似输出或者出现卡死的情况，代表驱动可能不支持该显卡

![](images/210115a001.jpg)

如果没有问题，编辑`/etc/rc.conf`添加一行，在启动时加载模块

```
# Load i915kms
kld_list="i915kms"
```

编辑`/boot/loader.conf`，使能vt

```
kern.vty=vt
```

> 想要查看自己的显卡或其他硬件是否确实被FreeBSD支持，可以到[bsd-hardware](https://bsd-hardware.info)查看

安装3D库（mesa）

```
$ pkg install mesa-libs mesa-dri
```

安装intel硬件视频解码支持

```
$ pkg install libva-intel-media-driver # 适用于HD5000以及更新的显卡
```

或

```
$ pkg install libva-intel-driver # 旧驱动，最高支持到UHD630
```

最后注意必须要将用户添加到`video`或`wheel`组才能访问3D加速，示例

```
$ pw groupmod video -m me
```

### 3.2.2 安装X

```
$ pkg install xorg
```

此时`startx`，可以启动TWM，如下，说明xorg可以使用，关闭X只要在左侧窗口`exit`即可

![](images/210115a002.jpg)

### 3.2.3 安装中文字体

```
$ pkg install wqy-fonts # 安装文泉驿字体
```

### 3.2.4 安装DE/WM以及配置

安装xfce

```
$ pkg install xfce xfce4-goodies
```

使能`dbus`，在`/etc/rc.conf`

```
dbus_enable="YES"
```

编辑`~/.xinitrc`，`source`一下`xinitrc`

```
. /usr/local/etc/xdg/xfce4/xinitrc
```

重启，登陆后直接`startx`就可以启动xfce了

![](images/210115a003.jpg)

注意，`startx`之后X默认使用的虚拟终端为`ttyv8`，切换到其他虚拟终端后通过`Ctrl+Alt+F9`返回x

### 3.2.5 图标

安装Papirus扁平风格图标

```
$ pkg install papirus-icon-theme
```

### 3.2.6 输入法

安装`fcitx`，添加中文和日语输入支持。确保在`rc.conf`开启了dbus

```
$ pkg install zh-fcitx zh-fcitx-configtool zh-fcitx-libpinyin ja-fcitx-mozc fcitx-m17n
```

如果使用的是`sh`，那么编辑`.shrc`如下，添加几行设置环境变量（更加建议在`~/.xinitrc`中添加这些变量）。`csh`使用`setenv`

```
# fcitx env setup
export XMODIFIERS='@im=fcitx'
export GTK_IM_MODULE=fcitx
export GTK2_IM_MODULE=fcitx
export GTK3_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export QT4_IM_MODULE=fcitx
```

自启动

```
$ mkdir ~/.config/autostart
$ cp /usr/local/share/applications/fcitx.desktop ~/.config/autostart/
```

重启进入fcitx设置添加中文日语输入法即可

### 3.2.7 声音配置，声卡驱动

主板集成声卡ALC662以及Intel的HDMI输出声卡。在`/boot/loader.conf`添加

```
snd_hda_load="YES"
sysctlinfo_load="YES"
```

调节音量使用终端工具`mixertui`，使用和`alsamixer`类似

```
$ pkg install mixertui
```

## 3.3 Wayland

FreeBSD 14.2, Sway 1.10

### 3.3.1 显卡驱动

将用户加入`video`

```
$ pw groupmod video -m USERNAME
```

Intel Gen9.5 核显（UHD630）上`drm-61-kmod`会导致黑屏，安装`drm-515-kmod`（驱动从linux移植来，数字代表linux版本）

```
$ pkg install drm-515-kmod mesa-dri mesa-gallium-va mesa-libs libva-intel-media-driver libva-utils
```

```
$ sysrc kld_list+=i915kms
```

### 3.3.2 基础组件

```
$ pkg install wayland seatd dbus mixertui e2fsprogs bash bash-completion
```

```
$ sysrc seatd_enable="YES"
$ sysrc dbus_enable="YES"
$ service seatd start
$ service dbus start
```

### 3.3.3 安装Sway

```
$ pkg install sway swaybg swayimg waybar swappy grim slurp fuzzel mako foot wl-clipboard jetbrains-mono droid-fonts-ttf noto-emoji wqy-fonts papirus-icon-theme adwaita-icon-theme nemo usbutils pciutils xeyes wlr-randr qt5-wayland qt6-wayland xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk obs-studio wlrobs 
```

dotfiles见 https://github.com/apachiww/dotfiles

配置完成后应当可以正常启动`sway`

### 3.3.4 音频

检查声卡驱动是否成功加载

```
$ dmesg | grep pcm
```

如果没有成功加载，尝试以下操作

```
$ kldload snd_driver
$ echo 'snd_driver_load="YES"' >> /boot/loader.conf
```

使用`beep`测试一下

```
$ beep
```

调节音量，`mixer`命令行使用方法，可以绑定到`sway`快捷键（FreeBSD目前不支持Fn音量功能键）

```
$ mixer vol=+2%
$ mixer vol=-2%
```

静音

```
$ mixer vol.mute=toggle
$ mixer mic.mute=toggle
```

### 3.3.5 输入法

```
$ pkg install fcitx5 fcitx5-configtool zh-fcitx5-chinese-addons fcitx5-gtk-common fcitx5-gtk4
```

启动方式见`sway`配置文件

## 3.4 杂项

### 3.4.1 关蜂鸣器

编辑`/boot/loader.conf`，添加一行

```
kern.vt.enable_bell=0
```

### 3.4.2 无线网络连接

以RTL8188EE网卡为例

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
$ service netif restart
```

### 3.4.3 网络管理

`dhclient`背景启动

```
$ sysrc background_dhclient="YES"
```

### 3.4.4 添加ext文件系统支持

```
$ pkg install fusefs-ext2
```

建议只读方式挂载ext4分区

```
$ kldload ext2fs
$ mount -t ext2fs -o ro /dev/adaXpX /mnt
```

### 3.4.5 doas

安装`doas`

```
$ pkg install doas
```

创建并编辑`/usr/local/etc/doas.conf`

```
$ cp /usr/local/etc/doas.conf.sample /usr/local/etc/doas.conf
$ ee /usr/local/etc/doas.conf
```

只保留`wheel`组的`doas`权限

```
permit nopass :wheel
```

## 4 ZFS

见[210130a](210130a_install-notice.md#22-存储与文件系统)

## 5 服务管理

见[210130a](210130a_install-notice.md#23-服务)