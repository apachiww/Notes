# 编译构建一个Linux系统，使用QEMU模拟ARMv7运行

## 目录

+ [**简易版**](#简易版)
+ [**1**](#1-环境) 环境
+ [**2**](#2-下载) 下载
+ [**3**](#3-安装工具链) 安装工具链
+ [**4**](#4-busybox以及根目录) Busybox以及根目录
    + [**4.1**](#41-交叉编译busybox) 交叉编译Busybox
    + [**4.2**](#42-创建基本目录) 创建基本目录
    + [**4.3**](#43-创建设备节点) 创建设备节点
    + [**4.4**](#44-创建fstab) 创建fstab
    + [**4.5**](#45-创建inittab) 创建inittab
    + [**4.6**](#46-创建init脚本) 创建init脚本
    + [**4.7**](#47-使用动态链接的情况下拷贝库文件) 使用动态链接的情况下拷贝库文件
+ [**5**](#5-编译内核) 编译内核
+ [**6**](#6-制作镜像文件) 制作镜像文件
+ [**7**](#7-启动qemu) 启动QEMU
+ [**基于LFS**](#基于lfs)
+ [**1**](#1-需要的软件包) 需要的软件包
+ [**2**](#2-构建gnu工具链) 构建GNU工具链
    + [**2.1**](#21-手动编译) 手动编译
    + [**2.2**](#22-基于crosstool-ng) 基于Crosstool-NG
+ [**基于Buildroot**](#基于buildroot)
+ [**基于AlpineLinux**](#基于alpinelinux)
+ [**基于ArchLinuxARM**](#基于archlinuxarm)
+ [**基于Debian**](#基于debian)
+ [**U-Boot**](#u-boot)
+ [**其他常用工具**](#其他常用工具)
+ [**1**](#1-命令行串口工具minicom) 命令行串口工具：minicom

# 简易版

## 1 环境

ArchLinux with kernel version 5.4.46-1-lts

gcc-arm-none-linux-gnueabihf 9.2 （需另外下载）

qemu-arm 5.0.0

## 2 下载

[Busybox 1.30.1](https://busybox.net/downloads/busybox-1.30.1.tar.bz2) Busybox源码，其他版本号也可，只要是稳定的，较新的

[Linux 5.4.63](http://mirrors.ustc.edu.cn/kernel.org/linux/kernel/v5.x/linux-5.4.63.tar.gz) 内核源码，其他版本也可，中科大镜像

[gcc-arm-none-linux-gnueabihf 9.2](https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz) 交叉编译工具链

## 3 安装工具链

ArchLinux官方仓库的arm工具链是`arm-none-eabi-`，这个工具链是用于裸机程序的，不能用于Linux内核以及应用程序的构建编译，可以使用以上提供的工具链，开箱即用

其他有些发行版仓库默认就有工具链，直接安装即可

## 4 Busybox以及根目录

## 4.1 交叉编译Busybox

```
cd /path/to/busybox/source
export ARCH=arm
export CROSS_COMPILE=/path/to/toolchain/bin/arm-none-linux-gnueabihf-
make menuconfig
make -j12
make install
```
注意：`menuconfig`可以选择设置`busybox`为静态链接（一般不动），`make -jx`视CPU核心数自定

## 4.2 创建基本目录

编译完成以后，在`./_install`可以找到编译好的文件，就是之后整个文件系统的根目录，在`./_install`下创建以下目录

```
mkdir etc proc sys tmp dev lib
```

完成后，`./_install`下出现`bin sbin usr mkdir etc proc sys tmp dev lib`

## 4.3 创建设备节点

在`./_install/dev/`下创建节点

```
sudo mknod -m 666 tty1 c 4 1
sudo mknod -m 666 tty2 c 4 2
sudo mknod -m 666 tty3 c 4 3
sudo mknod -m 666 tty4 c 4 4
sudo mknod -m 666 console c 5 1
sudo mknod -m 666 null 1 3
```

## 4.4 创建fstab

`./_install/etc/fstab`

```
#Device	mountpoint	type	option	dump	fsckorder
proc	/proc	proc	defaults	0	0
temps	/tmp	proc	defaults	0	0
none	/tmp	ramfs	defaults	0	0
sysfs	/sys	sysfs	defaults	0	0
mdev	/dev	ramfs	defaults	0	0
```

## 4.5 创建inittab

`./_install/etc/inittab`

```
::sysinit:/etc/init.d/rcS
::askfirst:/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/swapoff -a
::shutdown:/bin/umount -a -r
::restart:/sbin/init
tty2::askfirst:/bin/sh
tty3::askfirst:/bin/sh
tty4::askfirst:/bin/sh
```

## 4.6 创建init脚本

创建`./_install/etc/init.d/rcS`，并且`chmod 777`

```
mount -a
echo "/sbin/mdev" > /proc/sys/kernel/hotplug
/sbin/mdev -s
mount -a
```

## 4.7 使用动态链接的情况下拷贝库文件

查看需要的库文件

```
/path/to/toolchain/bin/arm-none-linux-gnueabihf-readelf -d busybox | grep NEEDED
```

一般可以得到`libc.so.6 libm.so.6 libresolv.so.2`，需要添加上`ld-linux.so.3`

```
cp /path/to/toolchain/arm-none-linux-gnueabihf/libc/lib/ld-linux-armhf.so.3 _install/lib
cp /path/to/toolchain/arm-none-linux-gnueabihf/libc/lib/libc.so.6 _install/lib
cp /path/to/toolchain/arm-none-linux-gnueabihf/libc/lib/libm.so.6 _install/lib
cp /path/to/toolchain/arm-none-linux-gnueabihf/libc/lib/libresolv.so.2 _install/lib
```

## 5 编译内核

```
cd /path/to/kernel/source
export ARCH=arm
export CROSS_COMPILE=/path/to/toolchain/bin/arm-none-linux-gnueabihf-
make vexpress_defconfig
make menuconfig
make -j12
```

可能需要先安装`flex`和`bison`

```
sudo pacman -S flex bison
```

编译完成后，将`zImage`以及`vexpress`的`.dtb`设备树文件拷贝出来方便使用

```
cp arch/arm/boot/zImage ./
cp arch/arm/boot/dts/*.dtb ./dtbs
```

安装模块，在`lib`下创建`modules`目录

```
make modules_install INSTALL_MOD_PATH=/path/to/busybox/_install/
```

## 6 制作镜像文件

使用dd创建一个32M的文件，并格式化为ext3

```
dd if=/dev/zero of=rootfs.ext3 bs=1M count=32
mkfs.ext3 rootfs.ext3
```

挂载镜像

```
sudo mount -o loop rootfs.ext3 /mountpath   
```

拷贝文件到挂载点，卸载

```
sudo cp -rf /path/to/busybox/_install/* /mountpath
sudo umount /mountpath
```

## 7 启动QEMU

当前目录应该有的文件

```
zImage

rootfs.ext3

vexpress-v2p-ca9.dtb
```

启动命令较长，最好写成启动脚本

```
qemu-system-arm \
        -M vexpress-a9 \
        -kernel ./zImage \
        -nographic \
        -m 512M \                       #内存容量
        -smp 4 \                        #CPU核心数，1～4
        -sd ./rootfs.ext3 \
        -dtb ./vexpress-v2p-ca9.dtb \
        #以下为内核启动参数
        -append "init=/linuxrc root=/dev/mmcblk0 rw rootwait earlyprintk console=ttyAMA0"
```

# 基于LFS

LFS 12.0

BLFS 12.0

参考[LFS](https://www.linuxfromscratch.org/lfs/)，[BLFS](https://www.linuxfromscratch.org/blfs/)，[CLFS](https://trac.clfs.org/)

首先创建一个`docker`容器`arch-lfs`，并将宿主机目录`~/repos/lfs`挂载到容器的`/home/lfs`

```
docker image pull archlinux:latest
docker create -it --name arch-lfs -v /home/rev/repos/lfs:/home/lfs archlinux:latest
docker start arch-lfs
docker attach arch-lfs
```

设置`root`密码，创建一个普通用户`lfs`备用（`home`就是宿主机的`~/repos/lfs`），以及一些其他操作

```
passwd
useradd -m lfs
passwd lfs
pacman-key --init
pacman -Syu sudo vi
usermod -a -G wheel lfs
visudo
```

> 以下所有操作均在`arch-lfs`容器中以用户`lfs`的身份执行

## 1 需要的软件包

LFS需要下载以下在LSB 5.0中（Linux Standard Base 5.0）要求的软件包

```
Core: bash, bc, binutils, coreutils, diffutils, file, findutils, gawk, grep, gzip, m4, man-db, ncurses, procps, psmisc, sed, shadow, tar, util-linux, zlib

Desktop: N/A

Runtime Languages: Perl, Python

Imaging: N/A

Gtk3 and Graphics: N/A
```

BLFS需要下载

```
Core: at, batch, cpio, ed, fcrontab, lsb-tools, nspr, nss, pam, pax, sendmail (postfix, exim), time
```

## 2 构建GNU工具链

## 2.1 手动编译

## 2.2 基于Crosstool-NG

# 使用Buildroot

# AlpineLinux

# Fedora

# Debian

# U-Boot

# 其他常用工具

## 1 命令行串口工具：minicom