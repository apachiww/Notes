# 关于在PC端编译构建并使用QEMU虚拟机运行Linux（ARM）的记录(ARMv7 Cortex A9/A7)

~~这个其实基本就是Linux From Scratch(LFS)~~

## 1. 环境

ArchLinux with kernel version 5.4.46-1-lts

gcc-arm-none-linux-gnueabihf 9.2 （需另外下载）

qemu-arm 5.0.0

## 2. 下载

[Busybox 1.30.1](https://busybox.net/downloads/busybox-1.30.1.tar.bz2) Busybox源码，其他版本号也可，只要是稳定的，较新的

[Linux 5.4.63](http://mirrors.ustc.edu.cn/kernel.org/linux/kernel/v5.x/linux-5.4.63.tar.gz) 内核源码，其他版本也可，中科大镜像

[gcc-arm-none-linux-gnueabihf 9.2](https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz) 交叉编译工具链

## 3. 安装工具链

ArchLinux官方仓库的arm工具链是`arm-none-eabi-`，这个工具链是用于裸机程序的，不能用于Linux内核以及应用程序的构建编译，可以使用以上提供的工具链，开箱即用

其他有些发行版仓库默认就有工具链，直接安装即可

## 4. Busybox以及根目录

+ 交叉编译Busybox

    ```shell
    cd /path/to/busybox/source
    export ARCH=arm
    export CROSS_COMPILE=/path/to/toolchain/bin/arm-none-linux-gnueabihf-
    make menuconfig
    make -j12
    make install
    ```
    注意：`menuconfig`可以选择设置`busybox`为静态链接（一般不动），`make -jx`视CPU核心数自定

+ 创建基本目录

    编译完成以后，在`./_install`可以找到编译好的文件，就是之后整个文件系统的根目录，在`./_install`下创建以下目录

    ```shell
    mkdir etc proc sys tmp dev lib
    ```

    完成后，`./_install`下出现`bin sbin usr mkdir etc proc sys tmp dev lib`

+ 创建设备节点

    在`./_install/dev/`下创建节点

    ```shell
    sudo mknod -m 666 tty1 c 4 1
    sudo mknod -m 666 tty2 c 4 2
    sudo mknod -m 666 tty3 c 4 3
    sudo mknod -m 666 tty4 c 4 4
    sudo mknod -m 666 console c 5 1
    sudo mknod -m 666 null 1 3
    ```

+ 创建fstab

    `./_install/etc/fstab`

    ```fs
    #Device	mountpoint	type	option	dump	fsckorder
    proc	/proc	proc	defaults	0	0
    temps	/tmp	proc	defaults	0	0
    none	/tmp	ramfs	defaults	0	0
    sysfs	/sys	sysfs	defaults	0	0
    mdev	/dev	ramfs	defaults	0	0
    ```

+ 创建inittab

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

+ 创建init脚本

    创建`./_install/etc/init.d/rcS`，并且`chmod 777`

    ```shell
    mount -a
    echo "/sbin/mdev" > /proc/sys/kernel/hotplug
    /sbin/mdev -s
    mount -a
    ```

+ 使用动态链接的情况下拷贝库文件

    查看需要的库文件

    ```shell
    /path/to/toolchain/bin/arm-none-linux-gnueabihf-readelf -d busybox | grep NEEDED
    ```

    一般可以得到`libc.so.6 libm.so.6 libresolv.so.2`，需要添加上`ld-linux.so.3`

    ```shell
    cp /path/to/toolchain/arm-none-linux-gnueabihf/libc/lib/ld-linux-armhf.so.3 _install/lib
    cp /path/to/toolchain/arm-none-linux-gnueabihf/libc/lib/libc.so.6 _install/lib
    cp /path/to/toolchain/arm-none-linux-gnueabihf/libc/lib/libm.so.6 _install/lib
    cp /path/to/toolchain/arm-none-linux-gnueabihf/libc/lib/libresolv.so.2 _install/lib
    ```

## 5. 内核

+ 交叉编译Kernel

    ```shell
    cd /path/to/kernel/source
    export ARCH=arm
    export CROSS_COMPILE=/path/to/toolchain/bin/arm-none-linux-gnueabihf-
    make vexpress_defconfig
    make menuconfig
    make -j12
    ```

+ 可能需要先安装`flex`和`bison`

    ```shell
    sudo pacman -S flex bison
    ```

+ 编译完成后，将`zImage`以及`vexpress`的`.dtb`设备树文件拷贝出来方便使用

    ```shell
    cp arch/arm/boot/zImage ./
    cp arch/arm/boot/dts/*.dtb ./dtbs
    ```

+ 安装模块，在`lib`下创建`modules`目录

    ```shell
    make modules_install INSTALL_MOD_PATH=/path/to/busybox/_install/
    ```

## 6. 制作镜像文件

+ 使用dd创建一个32M的文件，并格式化为ext3

    ```shell
    dd if=/dev/zero of=rootfs.ext3 bs=1M count=32
    mkfs.ext3 rootfs.ext3
    ```

+ 挂载镜像

    ```shell
    sudo mount -o loop rootfs.ext3 /mountpath   
    ```

+ 拷贝文件到挂载点，卸载

    ```shell
    sudo cp -rf /path/to/busybox/_install/* /mountpath
    sudo umount /mountpath
    ```

## 7. QEMU，启动

+ 当前目录应该有的文件

    zImage

    rootfs.ext3

    vexpress-v2p-ca9.dtb

+ 启动命令较长，最好写成启动脚本

    ```shell
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

+ 启动成功

    经过测试运行流畅，功能虽然少但是运行正常，其他的东西可以以后扩充

## 8. 使用Raspbian

参考自<a href="https://azeria-labs.com/emulate-raspberry-pi-with-qemu/" target="_blank">azeria-labs教程</a>，直接使用树莓派的Raspbian Jessie，便于搭建开发环境

+ 下载

    Raspbian清华大学镜像站<a href="https://mirrors.tuna.tsinghua.edu.cn/raspberry-pi-os-images/raspbian/images/" target="_blank">下载</a>，建议Jessie

    内核<a href="https://raw.githubusercontent.com/dhruvvyas90/qemu-rpi-kernel/master/kernel-qemu-4.4.34-jessie" target="_blank">下载</a> 

+ 解压raspbian镜像，使用`fdisk`查看分区，并挂载

    应该可以看到两个分区，将img2的起始sector乘512得到offset

    这里使用137216示例

    ```shell
    sudo mount -v -o offset=70254592 -t ext4 /path/to/img /mountpath
    ```

+ 修改镜像文件

    编辑`ld.so.preload`，注释掉所有行

    ```shell
    sudo vim /mountpath/etc/ld.so.preload
    ```

    编辑fstab，将所有`mmcblk`分区更改为sda1，sda2

    ```shell
    sudo vim /mountpath/etc/fstab
    ```

    卸载镜像

    ```shell
    sudo umount /mountpath
    ```

+ 启动qemu

    ```shell
    qemu-system-arm -kernel /path/to/kernel-qemu -cpu arm1176 -m 256 -M versatilepb -serial stdio -append "root=/dev/sda2 rootfstype=ext4 rw" -hda /path/to/jessie-image.img -redir tcp:5022::22 -no-reboot
    ```

+ 后记

    经过尝试以上方法最后成功启动，但是实际运行非常卡顿。有更好的办法以后再补充。