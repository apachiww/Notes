# AlpineLinux作为桌面系统使用的安装过程以及注意事项

可以参考视频 BV1PF4m1T7Zh

手动安装步骤参考官方文档 https://docs.alpinelinux.org/user-handbook/0.1a/Installing/manual.html

## 目录

+ [**1**](#1-基本安装流程) 基本安装流程
    + [**1.1**](#11-键盘) 键盘
    + [**1.2**](#12-主机名和hosts) 主机名和hosts
    + [**1.3**](#13-网络配置) 网络配置
        + [**1.3.1**](#131-改源) 改源
    + [**1.4**](#14-时区) 时区
    + [**1.5**](#15-用户配置) 用户配置
    + [**1.6**](#16-ntp时钟同步配置) NTP时钟同步配置
    + [**1.7**](#17-磁盘分区) 磁盘分区
    + [**1.8**](#18-正式安装) 正式安装
        + [**1.8.1**](#181-chroot) chroot
        + [**1.8.2**](#182-fstab) fstab
    + [**1.9**](#19-启动引导) 启动引导
        + [**1.9.1**](#191-refind) rEFInd
        + [**1.9.2**](#192-grub) GRUB
+ [**2**](#2-安装后杂项) 安装后杂项
    + [**2.1**](#21-openrc配置) OpenRC配置
    + [**2.2**](#22-refind界面美化) rEFInd界面美化
    + [**2.3**](#23-图形界面sway) 图形界面：Sway
        + [**2.3.1**](#231-显卡与声卡) 显卡与声卡
        + [**2.3.2**](#232-基本安装) 基本安装
        + [**2.3.3**](#233-配置) 配置
        + [**2.3.4**](#234-网络管理) 网络管理
        + [**2.3.5**](#235-输入法) 输入法
    + [**2.4**](#24-图形界面wayfire) 图形界面：Wayfire
+ [**3**](#3-入门) 入门
    + [**3.1**](#31-服务管理) 服务管理
        + [**3.1.1**](#311-基本概念) 基本概念
        + [**3.1.2**](#312-rc-service) rc-service
        + [**3.1.3**](#313-rc-update) rc-update
        + [**3.1.4**](#314-rc-status) rc-status
        + [**3.1.5**](#315-openrc) openrc
        + [**3.1.6**](#316-runlevel-stacking) runlevel stacking
    + [**3.2**](#32-包管理) 包管理
        + [**3.2.1**](#321-基本功能) 基本功能
        + [**3.2.2**](#322-其他高级用法) 其他高级用法

## 1 基本安装流程

## 1.1 键盘

```
setup-keymap us us
```

会在当前tmpfs中`/etc/conf.d/loadkmap`添加`KEYMAP`配置，同时创建`/etc/keymap`目录，安装`kbd-bkeymaps`，将`/usr/share/bkeymaps/us/us.bmap.gz`放到里面

## 1.2 主机名和hosts

```
setup-hostname xxx
```

这个命令检查名称`xxx`合法性并写入到`/etc/hostname`

更改`/etc/hosts`

```
127.0.0.1   localhost localhost.localdomain xxx xxx.localdomain
::1         localhost localhost.localdomain xxx xxx.localdomain
```

重启`hostname`服务，可以看到主机名生效

```
rc-service hostname restart
```

## 1.3 网络配置

```
setup-interfaces
```

会依次询问配置的接口（`eth0`或`wlan0`），是否使用DHCP。这里使用DHCP。如果使用无线网还会有额外操作。结束输入`done`

> Alpine的网络接口配置文件位于`/etc/network/interfaces`。这里先了解一下，不用配置

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

配置完成后启动`networking`

```
rc-service networking start
```

看一下DHCP是否成功获取到IP

```
ip address
```

### 1.3.1 改源

`/etc/apk/repositories`。可以添加本地路径源，示例（也可以使用release版本对应的源）

> 改源可以一开始就做好

```
/media/cdrom/apks
https://mirrors.ustc.edu.cn/alpine/latest-stable/main
https://mirrors.ustc.edu.cn/alpine/latest-stable/community
```

使用`edge`源，可以有很多目前`latest-release`没有的包（不要和`latest-stable`混用，两者取其一即可）。但是要注意`edge`源滚动更新可能容易滚挂

```
https://mirrors.ustc.edu.cn/alpine/edge/main
https://mirrors.ustc.edu.cn/alpine/edge/community
https://mirrors.ustc.edu.cn/alpine/edge/testing
```

## 1.4 时区

直接执行`setup-timezone`，根据提示输入时区即可

```
setup-timezone
```

> 该命令本质上是将`/usr/share/zoneinfo`下的文件复制到`/etc/zoneinfo`，再将同样的文件链接到`/etc/localtime`

## 1.5 用户配置

配置root密码直接执行`passwd`

```
passwd
```

## 1.6 NTP时钟同步配置

直接执行`setup-ntp`，选择使用`chronyd`

```
setup-ntp
```

## 1.7 磁盘分区

使用UEFI模式启动。多系统不要使用`setup-disk`进行分区与格式化操作。这里只分一个`ext4`的`/`和一个`vfat`的ESP，内核和`initramfs`放在`ext4`分区中（不给`/boot`专门分区）。AlpineLinux中的`fdisk`是`busybox`的版本，使用方法和传统的`fdisk`不一样

安装分区工具（`cfdisk`或`parted`）与格式化工具

```
apk add cfdisk parted e2fsprogs
```

`cfdisk`是图形化界面操作不再展示。如果执行时提示动态库问题，`apk upgrade`一下就好。这里使用`parted`

```
alias pt="parted -s --align=optimal"
pt /dev/sda mklabel gpt
pt /dev/sda mkpart '""' 2048s 411647s
pt /dev/sda mkpart '""' 411648s 252069887s
```

> 第一个分区从2048扇区开始，一个LBA大小512B。假设ESP大小200M那么扇区范围`2048s`到`411647s`。依次类推。也可以直接使用`MiB`等单位
>
> 如果有需要，可以使用`set 1 esp on`将`/dev/sda1`设为`EFI System`。不设定也没问题。其他常用的有`swap`，`lvm`等

分好区以后使用`fdisk`再检查一下

```
fdisk -l /dev/sda
```

格式化分区

```
mkfs.vfat /dev/sda1
mkfs.ext4 /dev/sda2
```

## 1.8 正式安装

挂载分区

> 可以先不挂载ESP分区，可以到`setup-disk`以后安装UEFI引导时再挂载，否则`setup-disk`会将ESP挂载点也添加到`/etc/fstab`

```
mount -t ext4 /dev/sda2 /mnt
mkdir -p /mnt/boot/efi
mount -t vfat /dev/sda1 /mnt/boot/efi
```

执行系统安装，先不安装`grub`

```
BOOTLOADER=none setup-disk -m sys /mnt
```

### 1.8.1 chroot

Alpine没有像Arch一样提供`arch-chroot`。想要使用`chroot`时，获取较为完全的功能要按需挂载以下文件系统，假设新的根分区挂载到`/mnt`

```
cd /mnt
mount -t proc /proc proc/
mount -t sysfs /sys sys/
mount -o bind /dev dev/
mount --rbind /run run/
mount --rbind /sys/firmware/efi/efivars sys/firmware/efi/efivars/
cp /etc/resolv.conf etc/resolv.conf
chroot .
```

### 1.8.2 fstab

如果有需要，可以删除以下所示`/mnt/etc/fstab`中的ESP分区挂载项

```
UUID=xxxx-xxxx  /boot/efi   vfat ...
```

## 1.9 启动引导

### 1.9.1 rEFInd

这里只讲述Alpine下安装rEFInd的方法。也可以从其他系统安装与配置

在安装环境中直接执行`chroot`到`/mnt`下。可以不用挂载`/proc`等

> 也可以不`chroot`，直接在livecd环境下安装

```
chroot /mnt
```

Alpine的`latest-stable`源暂时没有`refind`。需要添加`edge/testing`源

```
https://mirrors.ustc.edu.cn/alpine/edge/testing
```

然后安装

```
apk update && apk add refind
```

手动复制`refind.efi`到ESP分区

```
mkdir -p /boot/efi/EFI/refind
cp /usr/share/refind/refind_x64.efi /boot/efi/EFI/refind/
```

> UEFI的Fallback可执行EFI文件路径与名称为`/EFI/BOOT/bootx64.efi`

复制文件系统驱动到ESP分区

```
mkdir /boot/efi/EFI/refind/drivers_x64
cp /usr/share/refind/drivers_x86_64/ext*.efi /boot/efi/EFI/refind/drivers_x64
```

复制样本配置文件到ESP

```
cp /usr/share/refind/refind.conf-sample /boot/efi/EFI/refind/refind.conf
```

可以复制图标文件到ESP。后面会有界面主题配置方法，使用更好看的图标，可以只创建目录而不复制

```
cp -r /usr/share/refind/icons /boot/efi/EFI/refind
```

退出`chroot`，使用`efibootmgr`将`refind.efi`添加到启动项开头。添加完成以后记得再执行一下`efibootmgr`检查一下`PARTUUID`是否和ESP的一致

```
apk add efibootmgr
efibootmgr -c -d /dev/sda -p 1 -l /EFI/refind/refind_x64.efi -L "rEFInd"
```

编辑配置文件

```
vim /mnt/boot/efi/EFI/refind/refind.conf
```

保证`refind`正常引导Alpine需要的最小配置示例。其中分辨率依照实际调整（有可能不支持屏幕物理分辨率，尤其在开启CSM的平台）。可以使用例如`include os.conf`包含其他配置文件。分别使用`lsblk -dno PARTUUID /dev/sdax`（`volume`项）和`lsblk -dno UUID /dev/sdax`（`options`项）查看`PARTUUID`和`UUID`

```
timeout 5
use_nvram false
icons_dir icons
scanfor manual
default_selection 1

menuentry "Alpine" {
    icon    /EFI/refind/icons/os_linux.png
    volume  xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    loader  /boot/vmlinuz-lts
    initrd  /boot/initramfs-lts
    options "root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx ro modules=sd-mod,usb-storage,ext4 rootfstype=ext4 loglevel=3"
}
```

仅文字模式

```
timeout 5
use_nvram false
textonly
scanfor manual
default_selection 1
menuentry "Alpine" {
    volume  xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    loader  /boot/vmlinuz-lts
    initrd  /boot/initramfs-lts
    options "root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx ro modules=sd-mod,usb-storage,ext4 rootfstype=ext4 loglevel=3"
}
```

### 1.9.2 GRUB

执行`chroot`

```
cd /mnt
mount -t proc /proc proc/
mount -t sysfs /sys sys/
mount -o bind /dev dev/
mount --rbind /sys/firmware/efi/efivars sys/firmware/efi/efivars/
chroot .
```

假设ESP依旧挂载到`/boot/efi`，安装`grub`本体到`/boot/efi/EFI/grub`

```
apk update && apk add grub-efi efibootmgr
grub-install --target=x86_64-efi --boot-directory=/boot/efi --efi-directory=/boot/efi --bootloader-id=grub --no-nvram
```

删除trigger调用`grub-mkconfig`生成的`grub`配置

```
rm -rf /boot/grub
```

在`/etc/default/grub`添加一行

```
GRUB_DISABLE_OS_PROBER=true
```

删除文件`30_uefi-firmware`和`30_os-prober`

```
rm /etc/grub.d/30_uefi-firmware
rm /etc/grub.d/30_os-prober
```

生成配置

```
grub-mkconfig -o /boot/efi/grub/grub.cfg
```

修改该文件，找到`menuentry 'Alpine...`的地方，修改入口为以下内容。其中`UUID`都为文件系统`UUID`（`lsblk -dno UUID /dev/sdxx`），`hdx,gpty`表示第`x`个磁盘（从`0`开始），第`y`个GPT分区（从`1`开始）

```
load_video
insmod gzio
insmod part_gpt
insmod ext2
set root='hdx,gptx'
search --no-floppy --fs-uuid --set=root xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
echo 'Loading Linux lts ...'
linux /boot/vmlinuz-lts root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx ro modules=sd-mod,usb-storage,ext4 rootfstype=ext4 loglevel=3
echo 'Loading initial ramdisk ...'
initrd /boot/initramfs-lts
```

安装`efibootmgr`添加`grub`到BIOS启动项

```
apk add efibootmgr
efibootmgr -c -d /dev/sda -p 1 -l /EFI/grub/grubx64.efi -L "GRUB"
```

## 2 安装后杂项

## 2.1 OpenRC配置

编辑`/etc/rc.conf`开启并行启动。但是通常加速作用不是很大

```
rc_parallel="YES"
```

建议开openrc日志

```
rc_logger="YES"
```

有些服务例如`chronyd`和`networking`可能拖慢开机速度。`chronyd`依赖于`networking`。可以禁用`chronyd`自启动，这种情况下`networking`也不会启动。需要手动启动

```
rc-update del chronyd
```

建议开`acpid`

```
rc-update add acpid
```

默认的系统日志服务是`busybox`的`syslog`，在`boot`阶段启动。读系统日志到`/var/log/messages`

```
$ tail -5 /var/log/messages
```

## 2.2 rEFInd界面美化

主要是更换图标与背景

创建主题目录

```
mkdir -p /boot/efi/EFI/refind/themes/custom
```

参考 https://github.com/evanpurkhiser/rEFInd-minimal

主题备份 https://github.com/apachiww/refind-bk

将文件拷贝至`/boot/efi/EFI/refind/themes/custom`，在`refind.conf`末尾添加一行包含该文件

```
include themes/custom/theme.conf
```

删除以下行

```
icons_dir icons
```

最后修改入口项图标路径。其他所有入口项同理

```
menuentry "Alpine" {
    icon    /EFI/refind/themes/custom/icons/os_alpine.png
    volume  xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    loader  /boot/vmlinuz-lts
    initrd  /boot/initramfs-lts
    options "root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx ro modules=sd-mod,usb-storage,ext4 rootfstype=ext4 loglevel=3"
}
```

`theme.conf`中主要包含以下内容，包含了背景的设定

```
hideui singleuser,hints,arrows,label,badges
icons_dir themes/custom/icons
banner themes/custom/background/bk.png
banner_scale fillscreen
selection_big themes/custom/selection_big.png
selection_small themes/custom/selection_small.png
showtools shutdown
```

## 2.3 图形界面：Sway

最新dotfile https://github.com/apachiww/dotfiles/tree/main/snap-240904-thinkpadt440p-alpine 。可使用`sway`或`wayfire`

### 2.3.1 显卡与声卡

Intel核显3D与编解码驱动。平台Haswell，Thinkpad T440p

```
apk add mesa mesa-utils mesa-vulkan-intel libva-intel-driver libva-utils linux-firmware-i915 mesa-dri-gallium mesa-va-gallium igt-gpu-tools
```

> Broadwell及以后的CPU要使用`intel-media-driver`代替`libva-intel-driver`
>
> AMD显卡平台（从GCN开始）安装`mesa-vulkan-ati`提供Vulkan支持，还需要`libva`，`linux-firmware-amdgpu`（GCN前的显卡安装`linux-firmware-radeon`，且没有Vulkan支持）。此外GCN1需要在内核启动命令行添加参数`radeon.si_support=0 amdgpu.si_support=1`，GCN2需要添加参数`radeon.cik_support=0 amdgpu.cik_support=1`，否则`radeon`驱动会先于`amdgpu`加载，导致无法使用Vulkan。使用`lspci -k`可以查看当前使用的驱动

将用户加入`video`组。后续可执行`vainfo`查看是否可访问视频编解码

```
adduser xxx video
```

ALSA

```
apk add alsa-utils alsaconf sof-firmware
```

将用户加入`audio`

```
adduser xxx audio
```

此时尝试执行一下`alsamixer`。如果默认声卡不是ALC模拟声卡，可以修改默认声卡

```
vim /usr/share/alsa/alsa.conf
```

设定声卡序号

```
defaults.ctl.card 1
defaults.pcm.card 1
```

ALSA服务默认不启动，需要另外配置启动

```
rc-service alsa start
```

```
rc-update add alsa
```

第一次启动时由于还没有音量设定缓存会报警告。重启一下`alsa`即可

### 2.3.2 基本安装

可以使用Alpine自带的`setup-desktop`安装`sway`

```
setup-desktop sway
```

> 上述命令安装`elogind, polkit-elogind, eudev`（被调用的`setup-wayland`）`dmenu, font-dejavu , foot, grim, i3status, sway, swayidle, swaylockd, util-linux-login, wl-clipboard, wmenu, xwayland, firefox`（`setup-desktop sway`）。上述命令会将系统`mdev`切换至`udev`（`setup-devd udev`），同时将`elogind polkit`设为开机启动。
>
> 如果没有需求，可以删除`swayidle swaylockd swaylock`

支持桌面背景需要再安装`swaybg`

```
apk add swaybg
```

安装`dbus`并设定为开机启动。`dbus-x11`提供`waybar`所需的`dbus-launch`命令

```
apk add dbus dbus-x11
rc-service dbus start
rc-update add dbus
```

安装其他一些基础功能与附加小组件，包括字体，图标等。使用`doas`替代`sudo`

```
apk add man-db man-pages bash bash-completion font-jetbrains-mono font-droid-sans-mono-nerd font-noto-emoji font-wqy-zenhei adwaita-icon-theme papirus-icon-theme fuzzel mako waybar doas doasedit foot-extra-terminfo nemo wpa_supplicant usbutils pciutils
```

修改shell为`bash`

```
usermod xxx -s /bin/bash
```

在用户家目录添加`.bash_profile`和`.bashrc`

```
# ~/.bash_profile

[[ -f ~/.bashrc ]] && . ~/.bashrc
```

```
# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
```

添加`.config/sway/launch.sh`。可以使用`export`设定一些图形环境需要的环境变量。启动`sway`通过该脚本启动。必须加上`dbus-run-session`，否则通过`xwayland`运行的程序无法使用输入法

```
#!/bin/bash

exec dbus-run-session sway
```

### 2.3.3 配置

swaywm配置教程见 https://github.com/swaywm/sway/wiki ，基于`/etc/sway/config`示例配置简单更改就可以使用

粘贴板配置

安装`cliphist wl-clipboard`，在`sway`配置文件添加。此外按需调整`foot`终端的复制粘贴快捷键

```
exec wl-paste --type text --watch cliphist store
exec wl-paste --type image --watch cliphist store
```

截图软件配置

安装`grimshot slurp swappy`，创建截屏脚本`.config/sway/screenshot.sh`

```
#!/bin/bash

grim -g "$(slurp)" - | swappy -f -
```

在`sway`配置文件添加快捷键设定

```
bindsym Print exec ~/.config/sway/screenshot.sh
```

修改鼠标光标，在`sway`配置文件添加，大小按需调节

```
seat seat0 xcursor_theme Adwaita 18
```

添加`waybar`。配置完成后在`sway`配置文件添加一行

```
exec waybar
```

命令行补全，例如`doas`。在`.bashrc`添加

```
complete -F _command doas
```

查看显示器输出，外接显示器可能需要查看并按需修改配置

```
swaymsg -t get_outputs
```

也可以使用`wlr-randr`

```
wlr-randr
```

设置`nemo`默认使用的Terminal为`foot`

```
$ gsettings set org.cinnamon.desktop.default-applications.terminal exec foot
```

### 2.3.4 网络管理

DNS配置在`/etc/resolv.conf`。`networking`启动后会自动配置好

前文已经讲过以太网接口的配置。这里再给一个静态地址配置示例

```
iface eth0 inet static
    address 192.168.1.4
    netmask 255.255.255.0
    gateway 192.168.1.1
```

**无线网**

前面已经禁用`networking`自启动。禁用`wpa_supplicant`自启动

```
rc-update del wpa_supplicant boot
```

无线网卡可以通过`rfkill`开启或关闭

```
rfkill list
rfkill block 1
rfkill unblock 1
```

开`wlan0`。再次执行`ip link`可以看到`<>`中出现`UP`

```
ip link set wlan0 up
```

此时可以使用`iw`扫描AP

```
iw dev wlan0 scan
```

使用`wpa_passphrase`存储无线密码配置到`/etc/wpa_supplicant/wpa_supplicant.conf`。如果有必要，可以删除其中的密码明文

```
wpa_passphrase 'SSID' 'Passwd' > /etc/wpa_supplicant/wpa_supplicant.conf
```

手动启动`wpa_supplicant`作为服务运行

```
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

在`wlan0`启动`dhcp`

```
udhcpc -i wlan0
```

上述过程没有问题后，将无线网加入`/etc/network/interfaces`，`networking`启动时自动配置该接口。`wpa_supplicant`需要在`networking`前启动

```
auto wlan0
iface wlan0 inet dhcp
```

`wpa_supplicant`默认不会在网络发生变化时重新获取IP。如果要实现网络变化时通知`udhcpc`，需要修改`wpa_supplicant`启动命令行，使用`/etc/wpa_supplicant/wpa_cli.sh`

```
### /etc/conf.d/wpa_cli

WPACLI_OPTS="-a /etc/wpa_supplicant/wpa_cli.sh"
```

此外需要额外启动`wpa_cli`

### 2.3.5 输入法

> 必须使用`sway 1.10`及以上版本，否则输入法没有候选框

安装`fcitx`必须使用`edge`源

```
https://mirrors.ustc.edu.cn/alpine/edge/main
https://mirrors.ustc.edu.cn/alpine/edge/community
```

安装`fcitx5`

```
apk add fcitx5 fcitx5-chinese-addons fcitx5-configtool fcitx5-qt fcitx5-gtk xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
```

在`sway`配置文件添加启动

```
exec fcitx5
```

添加环境变量（不加也可以使用）

```
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx
```

当前Chromium及其衍生Electron应用例如code-oss默认使用`text-input-v1`，`text-input-v3`需要手动开启支持

Chromium在搜索栏输入`chrome://flags`，找到`Wayland text-input-v3`开启即可，默认不开启

code-oss暂不支持设定，只能通过命令行参数解决，其他Electron应用同理

```
alias code-oss='code-oss --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3'
```

## 2.4 图形界面：Wayfire

显卡和声卡配置基本同前

安装`wayfire`

```
apk add wayfire wf-shell
```

复制配置文件。按需配置

```
mkdir .config/wayfire
cp /usr/share/wayfire/wayfire.ini.default .config/wayfire/wayfire.ini
ln -s /abs/path/to/wayfire.ini ~/.config/wayfire.ini
```

启动脚本同理`~/.config/wayfire/launch.sh`

```
#!/bin/bash

exec dbus-run-session wayfire
```

## 3 入门

## 3.1 服务管理

`openrc`使用方法简介

### 3.1.1 基本概念

`openrc`中每个runlevel在`/etc/runlevels`下都有一个目录，而`/etc/init.d`中存放了启停管理每个服务需要的脚本，这些脚本由`openrc-run`解析。在`/etc/runlevels`下创建到`/etc/init.d`中脚本的软链接代表在该runlevel下启动该服务

默认有`default shutdown nonetwork sysinit boot`共计`5`个runlevel，以及`hotplugged needed/wanted manual`3个dynamic runlevel。开机会经过`sysinit boot`先进行一些初始化任务，一直到`default`。根据依赖，`needed/wanted`会启动`sysfs cgroups fsck root localmount`等服务。而关机会经过`shutdown`，执行一些关机断电前的准备工作

`hotplugged`和设备热插拔有关

**文件目录**

`/etc/runlevels`中包含了所有可用的runlevel，每个目录代表一个runlevel。需要使用`install -d`创建新的目录来创建runlevel，创建后使用`rc-status -l`就可以看到

`/etc/rc.conf`是`openrc`的全局配置文件，其中包含了并行启动，openrc日志开关，默认启动的runlevel等。openrc日志默认存在`/var/log/rc.log`

`/etc/init.d`包含了启停管理每个服务需要的脚本

`/etc/conf.d`包含了每个服务相关的配置

### 3.1.2 rc-service

启停服务，查询状态

```
$ rc-service chronyd status
$ rc-service chronyd start
$ rc-service chronyd stop
```

重启

```
$ rc-service networking restart
```

强制停止由于崩溃无法停止的服务，使用`zap`

```
$ rc-service some-crashed-service zap
```

### 3.1.3 rc-update

查询所有Enabled服务以及运行的runlevel

```
$ rc-update show
```

查询所有服务，包括没有Enable的

```
$ rc-update show -v
```

将服务添加至某个runlevel。不指定runlevel默认添加到`default`

```
$ rc-update add chronyd default
```

将服务从当前runlevel删除

```
$ rc-update del chronyd
```

从所有runlevel删除

```
$ rc-update del chronyd -a
```

从指定runlevel删除

```
$ rc-update del chronyd default
```

### 3.1.4 rc-status

列出当前runlevel的服务和状态

```
$ rc-status
```

列出所有服务状态（包括没有Enable的）

```
$ rc-status -s
```

列出当前所有runlevel的服务和状态

```
$ rc-status -a
```

显示当前runlevel

```
$ rc-status -r
```

列出所有runlevel

```
$ rc-status -l
```

列出指定runlevel的服务以及状态。不指定默认列出当前runlevel以及Dynamic runlevel的状态

```
$ rc-status boot
```

### 3.1.5 openrc

可以直接使用`openrc`命令切换到某个runlevel

```
$ openrc default
```

直接执行`openrc`会强制恢复当前runlevel，即停止不该启动的服务，并重新启动意外停止的服务

```
$ openrc
```

### 3.1.6 runlevel stacking

所谓runlevel stacking就是让一个runlevel继承另一个runlevel的所有服务，在此基础上再添加新的服务。当切换到该runlevel时，只会启动添加的新服务，而原先继承来的服务会维持运行

创建新runlevel，名称为`gui`（必须以`root`身份执行）

```
$ install -d /etc/runlevels/gui
$ rc-status -l
default
shutdown
nonetwork
sysinit
boot
gui
```

让`gui`继承`default`的所有服务，就是把`default`这个runlevel添加到`gui`，再添加`gui`需要另外启动的服务例如`dbus`

```
$ rc-update -s add default gui
$ rc-update add dbus gui
```

从`default`切换到`gui`

```
$ openrc gui
```

**异步启动**

适用于某些服务启动慢，拖慢整体开机速度的问题

添加一个名为`async`的runlevel。叫任何名字都可以

```
$ install -d /etc/runlevels/async
$ rc-status -l
default
async
shutdown
nonetwork
sysinit
boot
```

让`async`继承`default`的服务

```
$ rc-update -s add default async
```

将启动慢的服务添加到`async`，例如`networking`

```
$ rc-update del networking default
$ rc-update add networking async
```

最后是最关键的操作，编辑`/etc/inittab`，添加一行，实现异步启动，`default`执行完以后才会执行

```
...
::wait:/sbin/openrc default
::once:/sbin/openrc async -q

# Set up a couple of getty's
...
```

> Alpine默认使用`busybox`作为`init`程序（`/sbin/init`），读取该`inittab`。其他发行版使用`sysvinit`较多

## 3.2 包管理

`apk`使用方法简介

### 3.2.1 基本功能

**安装卸载**

更新快照

```
$ apk update
```

安装卸载

```
$ apk add vim
$ apk del vim
```

安装自编译包

```
$ apk add --allow-untrusted /path/to/file.apk
```

> 和其他包管理不同，`apk`会自动删除orphan并维持依赖的最简

**查询信息**

查询包名，以及带简介

```
$ apk search glmark2
$ apk search -v glmark2
```

列出包所有信息，仅列出包含文件，列出依赖/被依赖，或者查看某个文件是哪个包安装的

```
$ apk info -a glmark2
$ apk info -L glmark2
$ apk info -R glmark2
$ apk info -r glmark2
$ apk info --who-owns /usr/bin/glmark2
```

**更新**

仅下载包但不更新。更新直接`apk add`即可

```
$ apk fetch chrony
```

全系统更新

```
$ apk upgrade
```

模拟更新，dry-run

```
$ apk upgrade -s
```

`upgrade`后有时会有报`error`，可以尝试自动`fix`

```
$ apk fix
```

### 3.2.2 其他高级用法

**包依赖图**

打印包依赖图，格式`graphviz`

```
$ apk dot glmark2
```

**版本号**

检查一个包是否可更新

```
$ apk version chrony
Installed:                                Available:
chrony-4.6.1-r0                         = 4.6.1-r0 
```

检查一个包会如何更新（版本号，源地址）

```
$ apk policy chrony
chrony policy:
  4.6.1-r0:
    lib/apk/db/installed
  4.6.1-r0:
    https://mirrors.ustc.edu.cn/alpine/edge/main
```

**防止更新**

保持软件包在某个版本或更低，`upgrade`不会更新

```
$ apk add glmark2=2023.01-r1
```

```
$ apk add 'glmark2<2023.01-r1'
```

**包缓存**

`apk`默认会保留所有旧包在`cache`，可以删除

```
$ apk -v cache clean 
```

重新下载

```
$ apk cache download
```

**密钥问题**

Alpine有大版本更新时容易遇到密钥问题，可以如下解决

```
$ apk update --allow-untrusted
$ apk fix --upgrade --allow-untrusted alpine-keys
```