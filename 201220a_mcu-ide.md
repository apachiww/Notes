# 基于VSCode以及开源工具链的通用MCU开发环境，适用于Windows，Linux，FreeBSD

**本环境要求最好有Linux基础，~~主要面向经常使用Linux或FreeBSD的Windows用户~~**

支持的MCU：8051（Atmel，STC），ARM（ST，TI，Atmel）

未来添加对于AVR（Atmel）的支持，适用于Arduino

上次编辑于：2021.05.31


## 1 环境搭建

### 1.1 基本环境

### 1.1.1 编辑器

安装VSCode（步骤略，一般Linux下VSCode的开源许可证版本为OSS）


### 1.1.2 Windows下的MSYS2安装

如果是Windows，安装[MSYS2](https://www.msys2.org/)（一个Windows下的类Unix软件集合，类似并**包含了mingw软件集，集成`pacman`包管理器**，可以下载安装各种开源软件比如Git，Make，GCC，LLVM，CMake，像ArchLinux一样使用Windows）

**首先配置Windows环境变量**，这样可以直接使用`bash`，也可以`Win+R`调出`msys2`或`mingw64`

设MSYS2安装在`D:\msys64`，那么

1. 在`Path`变量末尾添加`D:\msys64\usr\bin`（为了能运行基本的软件如`bash`，`make`等）
2. 添加`D:\msys64\mingw64\bin`和`D:\msys64\mingw32\bin`（为了使用mingw下的软件，比如mingw版的arm工具链）
3. 添加`D:\msys64`（`Win+R`调出`msys2`和`mingw64`）

**使用方法1（直接运行bash，推荐）**：如果配置正常，`Win+R`运行，输入`bash`启动，此时`bash`继承了Windows的`Path`环境变量，现在既可以使用MSYS2下已经安装的软件，也可以使用Windows的命令

**使用方法2（常规方法，在msys2或mingw64下运行bash）**：`Win+R`运行，可以直接启动`msys2`并提供一个`bash`操作界面，但是注意`msys2`中的`$PATH`不是继承于Windows下`Path`环境变量，所以要用到其他命令时需要配置`$PATH`

其他更多有关MSYS2常规的配置（比如改镜像源，pacman更新）此处省略


### 1.2 工具链以及环境配置

### 1.2.1 安装基本工具

考虑到跨平台，所以安装`cmake`和`make`，有需要的话安装`git`

**Windows**

通过MSYS2安装

```shell
pacman -S cmake make
```

**ArchLinux**

```shell
pacman -S cmake make
```

**FreeBSD**

```shell
pkg install cmake gmake make
```


### 1.2.2 8051工具链

使用[SDCC](http://sdcc.sourceforge.net/)，官方[手册](http://sdcc.sourceforge.net/doc/sdccman.pdf)

SDCC是一个适用于8051，PIC，STM8等MCU的工具集

一般的Linux发行版也可以通过官方仓库安装，但是可能版本较老

**Windows**

[下载](https://sourceforge.net/projects/sdcc/files/sdcc-win64/)页面

安装完成后，允许SDCC自动配置环境变量

此时启动`bash`，输入`sdcc`，正常情况下会有输出


**ArchLinux**

```shell
pacman -S sdcc
```

开箱即用

**FreeBSD**

```shell
pkg install sdcc
```

开箱即用


### 1.2.3 ARM（Cortex-M）工具链

可以直接通过官方仓库安装

**Windows**

`Win+R`，打开`bash`

```shell
pacman -S mingw-w64-x86_64-arm-none-eabi-toolchain
```

安装了包含`arm-none-eabi-gdb`在内的工具

**ArchLinux**

```shell
pacman -S arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-gdb
```

**FreeBSD**

~~FreeBSD正在去GNU化~~，官方仓库只有`arm-none-eabi-gcc`，可以使用`llvm`工具链作为替代（目前最新的Keil已经转向`llvm`）

```shell
pkg install llvm
```


### 1.2.4 OpenOCD

OpenOCD是一个开源的调试服务器，在使用`gdb`调试中不可或缺

[官网](openocd.org)

[GNU toolchains](https://gnutoolchains.com/arm-eabi/openocd/)

[参考文档](http://openocd.org/documentation/)

**Windows**

MSYS2官方库有OpenOCD软件包，这里还是使用传统方法安装

OpenOCD Windows [下载](https://www.gnutoolchains.com/arm-eabi/openocd/)

假设解压到`D:\OpenOCD`下

添加`D:\OpenOCD\bin`到`Path`

**ArchLinux**

```shell
pacman -S openocd
```

**FreeBSD**

```shell
pkg install openocd
```


### 1.3 硬件驱动

如果是在Linux或者FreeBSD下，各种调试器驱动在安装完OpenOCD之后就已经可以用了，而Windows下调试器驱动需要手动安装

### 1.3.1 串口

常用串口VCP驱动汇总

CH340 [南京沁恒](http://www.wch.cn/products/CH340.html)

CP2102 [Silicon Labs](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers)

FT232 [FTDI](https://ftdichip.com/drivers/vcp-drivers/)


### 1.3.2 调试器

CMSIS-DAP（开源） [ARM](https://www.keil.com/support/man/docs/dapdebug/dapdebug_introduction.htm)Keil官方 

CMSIS-DAP [Github1](https://github.com/RadioOperator/STM32F103C8T6_CMSIS-DAP_SWO)，[Github2](https://github.com/wuxx/nanoDAP)，需要自己编译烧录

ST-Link [ST](https://www.st.com/zh/development-tools/stsw-link009.html#get-software)

J-Link [SEGGER](https://www.segger.com/downloads/jlink/#J-LinkSoftwareAndDocumentationPack)

[OpenOCD](https://gnutoolchains.com/arm-eabi/openocd/)也有以上部分调试器驱动，使用OpenOCD可以跳过这一步


## 2 开发：8051

### 2.1 STC的89C51系列开发（STC89C52RC）

## 3 开发：ARM

### 3.1 ST的STM32系列开发（STM32F103C8T6，STM32F407VET6，STM32F401CCU6）（Third party boards）

### 3.2 Atmel的SAM系列开发（SAM3X8E）（Arduino DUE）

### 3.3 TI的Tiva系列开发（TM4C123GH6PM）（TI EK-TM4C123GXL）

## 4 开发：AVR

暂无