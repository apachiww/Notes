# FreeBSD作为桌面系统使用的安装过程以及注意事项

上一次更新日期：2021-01-17

## 简介

记录有关FreeBSD作为桌面系统使用的安装过程，以及注意事项

## 测试平台

> CPU：Intel Celeron J3160(4) @ 1.6GHz \
  GPU：Intel HD Graphics 400 \
  内存：2 x 2GB DDR3 \
  硬盘：KIOXIA 240G SATA SSD & Seagate 500G 5400rpm HDD \
  启动模式：UEFI x64 \
  磁盘分区格式：GPT

# 13.0-RELEASE

## 1 下载镜像

[北交大镜像站](https://mirror.bjtu.edu.cn/freebsd/snapshots/ISO-IMAGES/12.2/)

使用U盘启动安装，下载memstick安装镜像，使用`xz -dk`解压后，再使用`dd`命令将.img镜像刻录到u盘

## 2 基本安装

现在所有新的x86PC都支持UEFI启动。其实UEFI启动比传统Legacy模式好用多了，这里就只记录UEFI启动模式的安装方法

安装前建议将RTC时钟设置成UTC时间。开机进启动项选择U盘启动，到Bootloader界面，按B启动多用户模式

基本安装没什么好说的，照着bsdinstall的提示一步一步走就行了

主要问题在于磁盘分区和启动引导的解决，另外有一些设置杂项的个人偏好，其他基本默认就行

### 2.1 磁盘分区

bsdinstall自带的磁盘分区界面操作太蛋疼了，建议选择Shell分区

UEFI启动模式需要一个ESP分区，一般为FAT32格式

如果是空磁盘先创建一个GPT分区表，这里假设磁盘为ada0

```shell
gpart create -s gpt ada0
```

创建分区，假设创建一个200M的ESP分区和一个32G的主分区（/dev/ada0p1和/dev/ada0p2）

```shell
gpart add -t efi -s 200M ada0
gpart add -t freebsd-ufs -s 32G ada0
```

格式化分区

```shell
newfs_msdos -F 32 -c 1 /dev/ada0p1
newfs -U -L FreeBSD /dev/ada0p2
```

如果想要创建swap分区的可以如以下操作，比如创建一个2G的swap分区（ada0p3）并挂载

```shell
gpart add -t freebsd-swap -s 2G ada0
swapon /dev/ada0p3
```

最后别忘了生成**fstab**

```shell
echo "/dev/ada0p2 / ufs rw 1 1" >> /tmp/bsdinstall_etc/fstab
```

如果有swap需要加上一条

```shell
echo "/dev/ada0p3 none swap sw 0 0" >> /tmp/bsdinstall_etc/fstab
```

`exit`退出Shell，bsdinstall即开始自动安装

### 2.2 启动引导

先将loader.efi拷贝到ESP分区下的EFI/FreeBSD/BOOTX64.efi

```shell
mount -t msdosfs /dev/ada0p1 /mnt
mkdir -p /mnt/EFI/FreeBSD
cp /boot/loader.efi /mnt/EFI/FreeBSD/BOOTX64.efi
```

### 2.2.1 单系统引导

使用efibootmgr将其注册到BIOS的启动项中，名字这里叫FreeBSDBoot，也可以叫其他的

```shell
efibootmgr -c -l /mnt/EFI/FreeBSD/BOOTX64.efi -L FreeBSDBoot
```

这时候efibootmgr会输出创建启动项的序号，比如0001，需要将0001设为active态（由*标记）

```shell
efibootmgr -B 0001
```

卸载ESP分区

```shell
umount /mnt
```

### 2.2.2 双系统/多系统引导

其实硬盘原来已经装了ArchLinux，这里用最笨的方法，用GRUB来chainload FreeBSD的bootloader

进ArchLinux配置/etc/grub.d/40_custom如下，将XXXX-XXXX更换为ESP分区的UUID

```
if [ ${grub_platform} == "efi"]; then
    menuentry "FreeBSD Bootloader" {
        insmod part_gpt
        insmod fat
        insmod chain
        search --no-floppy --fs-uuid --set=root --hint-ieee1275='ieee1275//disk@0,gpt1' --hint-bios=hd0,gpt1 --hint-efi=hd0,gpt1 --hint-baremetal=ahci0,gpt1 XXXX-XXXX
        chainloader /EFI/FreeBSD/BOOTX64.efi
    }
```

再重新生成grub配置文件`grub-mkconfig -o /boot/grub/grub.cfg`即可

### 2.3 个人设置偏好参考（不代表建议的选择）

~~选择困难症ww~~

安装部分：一般只选择kernel-dbg，ports，src三项，去掉lib32兼容库

服务启动：一般开启moused，ntpd，powerd，dumpdev。有需要可以开启sshd远程访问

安全特性：一般开启clear_tmp，disable_syslogd，disable_sendmail，secure_console，disable_ddtrace

## 3 安装后杂项

### 3.1 改镜像源

FreeBSD使用ports和pkg两种方法安装软件包，pkg是已经编译好的，ports是源码，需要自己编译

出于某种原因，FreeBSD官方对于镜像站管控非常严格，中国大陆目前还没有官方镜像，以下列出部分亚太地区的官方镜像

+ 台湾镜像 pkg0.twn.freebsd.org

+ 日本镜像 pkg0.kwc.freebsd.org

+ 马来西亚镜像 pkg0.kul.freebsd.org

这里再列举少数几个国内的非官方镜像站：

+ 北交大镜像 mirror.bjtu.edu.cn 有反向代理的pkg，portsnap，update（但是目前好像不能用），但是安装镜像比较全，有Release，Current，Stable安装镜像

+ 中科大镜像 mirrors.ustc.edu.cn 有pkg和ports，但是只有Release安装镜像

+ 网易镜像 mirrors.163.com 有pkg和ports，有Release安装镜像，目前Current和Stable镜像无法下载

+ chinafreebsd镜像 freebsd.cn 据说是私人搭建的镜像（还活着），有ports，portsnap，pkg，update，但没有安装镜像。速度较快，可以设为默认镜像

修改举例：

修改pkg镜像：添加/usr/local/etc/pkg/repos/mymirror.conf如下（可以直接从/etc/pkg/FreeBSD.conf复制修改）

```
# 使用网易163源，最新latest，否则quarterly
163:{
　　url: "pkg+http://mirrors.163.com/freebsd-pkg/${ABI}/latest", 
　　mirror_type: "srv",
　　signature_type: "none",
　　fingerprints: "/usr/share/keys/pkg",
　　enabled: yes
　　}

# 禁用原/etc/pkg/FreeBSD.conf
FreeBSD:{
  enabled: no
}
```

首次使用pkg会自动安装，安装完成以后运行`pkg update -f`更新索引

修改ports源，/etc/make.conf

```
# 启用线程数
FETCH_CMD=axel -n 4 -a
DISABLE_SIZE=yes
MASTER_SITE_OVERRIDE?=http://mirrors.163.com/freebsd-ports/distfiles/${DIST_SUBDIR}/
```

修改portsnap源，/etc/portsnap.conf

```
SERVERNAME=portsnap.freebsd.cn
```

修改后运行`portsnap fetch`获取安装包，第一次需要再运行`portsnap extract`。以后更新只要`portsnap fetch update`即可

### 3.2 安装图形界面

### 3.2.1 安装显卡驱动

安装intel显卡kms`pkg install drm-kmod`。

> 显卡驱动是作为普通用户想将FreeBSD作为桌面系统使用需要克服的最大困难之一，FreeBSD的显卡驱动相比linux要稍显落后（好像就是直接从Linux移植而来），包括intel的核显驱动。这次使用的Celeron J3160属于intel的低功耗SoC产品线，在RELEASE-13.0之前不被正常支持（13.0更新了来自Linux的显卡驱动，很奇怪的是同属Braswell的N3160据说早在11.2核显就可以正常工作，按理应该没区别，FreeBSD论坛[链接](https://forums.freebsd.org/threads/xcfe-login-gui-doesnt-show-up.66419/)）。建议安装FreeBSD之前先考察显卡驱动的支持状况。

> 附：有人之前在FreeBSD论坛写了一篇文章讨论intel不同产品线的核显的区别，大概也顺带批评了intel的SoC产品线的混乱，[链接](https://forums.freebsd.org/threads/how-to-use-the-old-or-the-new-i915kms-driver-for-intel-integrated-graphics-with-xorg.66732/)

想要查看自己的显卡或平台是否确实被FreeBSD支持，这里推荐一个[网站](https://bsd-hardware.info)