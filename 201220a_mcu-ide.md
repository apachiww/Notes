# MCU开发环境搭建与使用

基于开源工具，适用于Linux

Tier 1 : 8051，STM8，AVR，ARM，RISC-V

Tier 2 : PIC，DS390，HC08，Z80

## 目录

## 1 方案一：二进制安装

AVR工具链：[avr-gcc](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio/gcc-compilers#) | [使用说明](https://gcc.gnu.org/wiki/avr-gcc)

SDCC工具链：[sdcc](https://sdcc.sourceforge.net/) | [使用说明](https://sdcc.sourceforge.net/doc/sdccman.pdf)

ARMv7-M工具链：[arm-none-eabi-gcc](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) Atmel Build: [arm-none-eabi-gcc](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio/gcc-compilers#)

## 1.1 AVR

## 1.2 SDCC

## 1.3 ARM

## 2 方案二：从源码编译

适用于当前平台没有提供二进制包的情况，尤其在一些ARM或RISC-V单板机上开发时

环境：

ArchLinux amd64 kernel 6.3.2

gcc 13.1.1

glibc 2.37

gnu make 4.4.1

采用不污染系统目录的部署方式

## 2.1 AVR

参考 https://www.nongnu.org/avr-libc/user-manual/install_tools.html

所有文件安装于`/home/username/local/toolchain-avr`

### 2.1.1 下载

| 文件 | 版本 | 说明 |
| :- | :- | :- |
| [gcc](https://ftp.gnu.org/gnu/gcc/) | 7.5.0 |  |
| [binutils](https://ftp.gnu.org/gnu/binutils/) | 2.40 | 可以使用和gcc相近时间的版本 |
| [avr-libc](https://download.savannah.gnu.org/releases/avr-libc/) | 2.1.0 | 同时下载文档 |
| [avrdude](https://github.com/avrdudes/avrdude/releases) | 7.0.0 | 同时下载文档 |

| 可选文件 | 版本 | 说明 |
| :- | :- | :- |
| [gdb](https://ftp.gnu.org/gnu/gdb/) | 8.3.1 | 只能搭配模拟器使用，可以使用和gcc相近时间的版本 |
| [simulavr](https://git.savannah.nongnu.org/git/simulavr.git) | 1.1.0 | AVR模拟器，使用`git`克隆到本地后回退版本，同时下载文档 |

### 2.1.2 编译与安装

创建AVR工具链家目录，以及源码目录，将下载的软件包全部放到`src`

```shell
mkdir ~/local/toolchain-avr
cd ~/local/toolchain-avr
mkdir src
```

配置变量：

```shell
PREFIX=/home/username/local/toolchain-avr
export PREFIX
PATH=$PATH:$PREFIX/bin
export PATH
```

编译安装`binutils`

```shell
cd binutils-2.40
mkdir _build
cd _build
../configure --prefix=$PREFIX --target=avr --disable-nls
make
make install
```

编译安装`avr-gcc`

```shell
cd gcc-7.5.0
mkdir _build
cd _build
../configure --prefix=$PREFIX --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2
make
make install
```

编译安装`avr-libc`

```shell
cd avr-libc-2.1.0
./configure --prefix=$PREFIX --build=`./config.guess` --host=avr --with-debug-info=DEBUG_INFO
make
make install
```

编译安装`avrdude`

```shell
cd avrdude-7.0
mkdir _build
cd _build
../configure --prefix=$PREFIX
make
make install
```

编译安装`gdb`

可能先需要在包管理器安装`boost`

```shell
cd gdb-8.3.1
mkdir _build
cd _build
../configure --prefix=$PREFIX --target=avr
make
make install
```

编译安装`simulavr`

首先回退到`release-1.1.0`

```shell
cd simulavr
git reset release-1.1.0
```

```shell
make build
cmake --build build --target progdoc
cmake --build build --target install
cd build/install/usr/
cp -r * $PREFIX/
```

所有编译安装过程完成后，`/home/username/local/toolchain-avr`应当有如下目录

```
avr  bin  etc  include  lib  libexec  share  src
```

### 2.1.3 配置



### 2.1.4 添加MCU支持

[atpack](http://packs.download.atmel.com/)（选择MCU型号，下载后直接`unzip`解压）

## 2.2 SDCC

SDCC可以支持8051，STM8，PIC，Z80等架构

所有文件安装于`/home/username/local/toolchain-sdcc`

### 2.2.1 下载

| 文件 | 版本 | 说明 |
| :- | :- | :- |
| [sdcc](https://sourceforge.net/projects/sdcc/files/sdcc/) | 4.2.0 | 同时下载文档 |

| 可选文件 | 版本 | 说明 |
| :- | :- | :- |
| [gputils](https://sourceforge.net/projects/gputils/files/gputils/) | 1.5.2 | 提供PIC单片机支持，同时下载文档 |
| [gpsim](https://sourceforge.net/projects/gpsim/files/gpsim/) | 0.31.0 | PIC模拟器，同时下载文档 |

### 2.2.2 编译与安装

创建SDCC工具链家目录，以及源码目录，将下载的软件包全部放到`src`

```shell
mkdir ~/local/toolchain-sdcc
cd ~/local/toolchain-sdcc
mkdir src
```

配置变量：

```shell
PREFIX=/home/username/local/toolchain-sdcc
export PREFIX
PATH=$PATH:$PREFIX/bin
export PATH
```

编译安装`sdcc`（无PIC14/PIC16支持，不安装`gputils`）

```shell
cd sdcc-4.2.0
mkdir _build
cd _build
../configure --prefix=$PREFIX --disable-pic14-port --disable-pic16-port
make
make install
```

如果想要PIC14/PIC16支持需要先安装`gputils`和`gpsim`，在编译`sdcc`前首先进行如下操作。之后配置`sdcc`时去除`--disable-pic14-port --disable-pic16-port`参数

```shell
cd gputils-1.5.2
mkdir _build
cd _build
../configure --prefix=$PREFIX
make
make install
```

```shell
cd gpsim-0.31.0
./configure --prefix=$PREFIX
make
make install
```

所有编译安装过程完成后，`/home/username/local/toolchain-sdcc`应当有如下目录

```
bin  include  lib  share  src
```

### 2.2.3 配置



## 2.3 ARM

~~`arm-none-eabi-gcc`工具链，基于Linaro ABE构建系统~~

~~参考 https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads Release Note~~

~~ABE构建系统 https://wiki-archive.linaro.org/ABE~~

`arm-none-eabi-gcc`工具链

参考ArchLinux的PKGBUILD，需要依照依赖关系按序构建、安装各软件包

[arm-none-eabi-gcc](https://gitlab.archlinux.org/archlinux/packaging/packages/arm-none-eabi-gcc)

[arm-none-eabi-binutils](https://gitlab.archlinux.org/archlinux/packaging/packages/arm-none-eabi-binutils)

[arm-none-eabi-newlib](https://gitlab.archlinux.org/archlinux/packaging/packages/arm-none-eabi-newlib)

[arm-none-eabi-gdb](https://gitlab.archlinux.org/archlinux/packaging/packages/arm-none-eabi-gdb)

所有文件安装于`/home/username/local/toolchain-arm`

依赖关系

```
arm-none-eabi-gcc
    arm-none-eabi-binutils(run)
    libisl(run)（注意gdb安装完以后回来处理一下）
        gmp(run)
    libmpc(run)
        mpfr(run)
            gmp(run)
    arm-none-eabi-newlib(make optional)
    gmp(make)
    mpfr(make)
arm-none-eabi-gdb
    expat
    guile
    libelf
    mpfr
    ncurses
    python
    xz
    readline
    texinfo
    boost
```

> 虽然ABE已经过时，这里还是不得不吐槽一下Linaro。如果看过ABE脚本的源码，你会感叹一个本可以很简单的构建工具是如何因为混乱的设计，质量低下的代码，成为垃圾堆的。尽管基于shell的设计确实导致了一些局限性，但是这不是滥用函数嵌套和全局变量，写死判断的原因。ABE似乎从一开始就没有合理安排设计，却尝试自动处理太多的事情，导致开发者自己也难以维护，即便是在最常用的Linux下也无法很体面地处理构建过程

### 2.3.1 下载

| 文件 | 版本 | 说明 |
| :- | :- | :- |
|  |  |  |
| [openocd](https://sourceforge.net/p/openocd/code/ci/master/tree/) | 0.12.0 | 调试下载工具，使用`git`克隆后回退版本 |

| 可选文件 | 版本 | 说明 |
| :- | :- | :- |
| [libopencm3](https://github.com/libopencm3/libopencm3.git) |  | 开源的ARM单片机库，支持ST，TI，NXP，Atmel等厂家的单片机 |

### 2.3.2 编译与安装

创建ARM工具链家目录，以及源码目录，将下载的软件包全部放到`src`

```shell
mkdir ~/local/toolchain-arm
cd ~/local/toolchain-arm
mkdir src
```

配置变量：

```shell
PREFIX=/home/username/local/toolchain-arm
export PREFIX
PATH=$PATH:$PREFIX/bin
export PATH
```

复制`git-new-workdir`到`/usr/local/bin`

```shell
chmod +x git-new-workdir
sudo cp git-new-workdir /usr/local/bin/
```

在`abe`仓库上一级目录创建构建目录，并配置`abe`，编译安装`arm-none-eabi-gcc`。`configure`时根据报错在包管理器补全软件依赖

```shell
mkdir _build
cd _build
../abe/configure
../abe/abe.sh --manifest ../arm-gnu-toolchain-arm-none-eabi-abe-manifest.txt --build all
```

## 2 8051单片机

## 2.1 工具链：sdcc

### 2.1.1 sdcc的目录结构与组成

Windows下SDCC的目录如下

![目录](images/201220a001.png)

| Windows目录 | Linux安装路径 | FreeBSD安装路径 | 内容 |
| :-: | :-: | :-: | :-: |
| bin | /usr/bin | /usr/local/bin | 二进制文件，SDCC的各种工具，包括编译器，汇编器，链接器，调试器，模拟器，库文件工具，hex文件转换工具等 |
| include | /usr/share/sdcc/include | /usr/local/share/sdcc/include | 头文件 |
| lib | /usr/share/sdcc/lib | /usr/local/share/sdcc/lib | 库文件 |
| non-free/include | /usr/share/sdcc/non-free/include | /usr/local/share/sdcc/non-free/include | 非自由许可证头文件 |
| non-free/lib | /usr/share/sdcc/non-free/lib | /usr/local/share/sdcc/non-free/lib | 非自由许可证库文件 |

命令：

| 命令 | 作用 |
| :-: | :-: |
| `sdcc` | 主要的编译器，将根据不同的指令集生成不同的汇编代码 |
| `sdcpp` | 预处理器 |
| `sdas8051 sdas390 sdasz80 sdasgb sdas6808 sdasstm8` | 不同系统的汇编器 |
| `sdld sdldz80 sdldgb sdld6808` | 链接器 |
| `sdcdb` | 调试器 |
| `s51 sz80 shc08 sstm8`  | 各系统的ucSim模拟器 |
| `sdar sdranlib sdnm sdobjcopy` | 用于库文件的操作 |
| `packihx` | 将.ihx文件转换为.hex文件用于烧录（实际使用中可以不转换，.ihx文件可以直接用于烧录），输出到标准输出 |
| `makebin` | 将.hex转换为二进制.bin文件，输出到标准输出 |


### 2.1.2 SDCC的工作流程简介

在最为简单的情况下，`sdcc`调用`sdcpp`进行预处理，之后编译为汇编代码，然后调用对应`sdas`和`sdld`编译出目标代码

包含的头文件，**如果使用了`-I`参数进行指定，那么会优先到指定的目录下查找头文件，之后再到安装的`include`以及`non-free/include`下面找**。而类似的对于库文件来说，如果使用`-L`参数指定，那么同样会优先到指定的目录下查找


### 2.1.3 SDCC编译方法

**`sdcc`参数**

| 命令行参数 | 作用 |
| :-: | :-: |
| `--std-sdcc99` | c99标准，带sdcc扩展 |
| `--std-sdcc11` | c11标准（默认选项），带sdcc扩展 |
| `-mmcs51` | 指定为8051指令集，默认选项 |
| `-E` | 仅预处理，处理结果输出到标准输出 |
| `-S` | 仅预处理和编译，生成`.asm` |
| `-c` | 预处理、编译和汇编，但不链接，生成`.rel`，`.lst`，`.sym` |
| `-o` | 指定输出文件名或输出到目录，目录名必须带`/` |
| `--debug` | 如果需要使用`sdcdb`和模拟器调试，那么编译时在最后添加该选项 |
| `-V`或`-v` | 显示过程 |
| `--opt-code-size` | 优化程序大小 |
| `--opt-code-speed` | 优化程序速度 |
| `-Wp option1,option2` | 向`sdcpp`传参 |
| `-Wa option1,option2` | 向汇编器传参 |
| `-Wl option1,option2` | 向链接器传参 |

**`sdcpp`预处理参数**

| 命令行参数 | 作用 |
| :-: | :-: |
| `-I` | 添加头文件路径 |
| `-Dmy_macro=xxx` | 添加宏定义 |
| `-Umy_macro` | 去除宏定义 |
| `-M`或`-MM` | 从标准输出显示每个目标文件的文件依赖，`-M`显示全部 |
| `-dM` | 显示最终有用的宏 |
| `-dD` | 显示所有宏 |
| `-dN` | 显示所有宏，但是不显示宏内容 |

**链接器参数**

| 命令行参数 | 作用 |
| :-: | :-: |
| `-L` | 添加库文件路径 |
| `--xram-loc 0x8000` | 指定外部RAM起始位置为`0x8000` |
| `--code-loc` | 指定代码区起始位置 |
| `--stack-loc` | 指定堆栈起始位置 |
| `--xstack-loc` | 指定外部堆栈起始位置 |
| `--data-loc` | 指定内部RAM数据区起始位置 |
| `--idata-loc` | 指定间接寻址RAM起始位置 |
| `--bit-loc` | bit寻址起始位置 |
| `-i` | 单独使用`sdld`时，指定输出`.ihx`文件 |
| `-y` | 单独使用`sdld`时，指定输出`.cdb`文件 |


**mcs8051专有参数**

| 命令行参数 | 作用 |
| :-: | :-: |
| `--model-small` `--model-medium` `--model-large` `--model--huge` | 指定内存模型 |
| `--xstack` | 使用pseudo stack |
| `--iram-size` | 链接器检测内部RAM是否在限制以内 |
| `--xram-size` | 链接器检测外部RAM是否在限制以内 |
| `--code-size` | 链接器检测代码大小是否在限制以内 |
| `--stack-size` | 链接器检测堆栈大小 |

**`sdcc -c main.c`编译后生成各文件作用**

| 后缀名 | 作用 |
| :-: | :-: |
| `.asm` | `sdcc`通过预处理和编译生成的汇编源文件，如果使用的是`sdcc -S`，那么就只会生成这个文件 |
| `.rel` | 汇编器的输出，作为链接器的输入 |
| `.lst` | 汇编器生成的汇编列表文件 |
| `.sym` | 汇编器生成的符号列表 |

**如果是`sdcc main.c`，相比不链接多出以下文件**

| 后缀名 | 作用 |
| :-: | :-: |
| `.ihx` | 加载模块，Intel的hex格式文件 |
| `.lk` | 链接器命令行参数 |
| `.map` | 链接器的输出，加载模块的memory map |
| `.mem` | 内存使用统计 |
| `.rst` | 链接器输出，添加了linkedit信息的汇编列表文件 |

**`--debug`模式，相比普通模式会多出以下文件**

| 后缀名 | 作用 |
| :-: | :-: |
| `.cdb` | 调试信息文件，在 |
| `.adb` | 包含调试信息，用于生成.cdb文件的中间文件，在编译阶段生成 |
| `.omf` | absolute object module format，包含调试信息（AOMF51格式），用于第三方工具 |

**最后输出文件的处理**

| 命令 | 作用 |
| :-: | :-: |
| `packihx` | 将`.ihx`转换为标准`.hex`文件，输出到标准输出（实测可以不用转换，直接烧录`.ihx`文件） |
| `makebin` | 生成`.bin`二进制文件，输出到标准输出 |

**简单的多文件编译方法**

> 假设有main.c，lib1.c，lib2.c三个文件的工程
> 可以有如下两种编译方法

```shell
sdcc -c lib1.c
sdcc -c lib2.c
sdcc main.c lib1.rel lib2.rel
```

```shell
sdcc -c lib1.c
sdcc -c lib2.c
sdcc -c main.c
sdcc main.rel lib1.rel lib2.rel
```

### 2.1.4 使用库

`sdcc`同样支持`.lib`库的使用，生成`.lib`库时最好将不同的功能模块写到不同源文件。**`.lib`文件的作用和一般PC平台GCC中使用到的`.a`库文件类似，GCC中`.a`包含了多个`.o`文件，而SDCC的`.lib`包含了多个`.rel`文件**

**用于SDCC库操作的命令全部来自`sdbinutils`**，功能和常用GNU工具链中的相应命令基本相同

```shell
sdcc main.c mylib.lib -L libdir
```

可以使用`sdar`创建`.lib`库文件

```shell
sdar -rc mylib.lib module1.rel module2.rel module3.rel
```

**`sdbinutils`包括`sdar` `sdnm` `sdobjcopy` `sdranlib`**

**`sdar`用法**

`sdar`用于创建库以及管理库成员

```shell
sdar -options mylib.lib file1.rel file2.rel
```

| 命令行参数 | 作用 |
| :-: | :-: |
| `p` | 显示库内容 |
| `t` | 显示文件成员 |
| `r[a\|b][f][u]` | 替换或添加文件成员，其中`a`或`b`为成员名，分别代表某个成员之后和之前，`f`截断输入文件名，`u`仅更新改变的成员 |
| `d` | 删除文件成员 |
| `m[a\|b]` | 移动文件成员 |
| `x[o]` | 提取文件成员，`o`保留原始日期 |
| `s` | 相当于`ranlib` |
| `q[f]` | 快速添加文件成员 |
| `c` | 通用参数，需要创建库时不提示 |
| `T` | 通用参数，创建thin archive |
| `v` | 通用参数，显示过程 |

**`sdnm`用法**

`sdnm`用于列出一个目标文件里的符号

| 命令行参数 | 作用 |
| :-: | :-: |
| `a` | 过滤参数，显示调试标记 |
| `D` | 过滤参数，显示动态标记而不是普通标记 |
| `--defined-only` | 过滤参数，仅显示已定义 |
| `u` | 过滤参数，仅显示未定义 |
| `--special-syms` | 过滤参数，显示特殊标记 |
| `--synthetic` | 过滤参数，显示synthetic标记 |
| `g` | 过滤参数，仅显示外部标记 |
| `l` | 显示每个标记的文件名与行号 |
| `n` | 按地址排序 |
| `S` | 显示已定义符号所占空间 |


**`sdobjcopy`用法**

`sdobjcopy`用于将一种目标文件中的内容复制到另一种目标文件中，也可以用于将一种目标文件格式转换成为另一种目标文件格式

`sdobjcopy`支持的文件格式有`asxxxx` `symbolsrec` `verilog` `tekhex` `binary` `ihex`

```shell
sdobjcopy -options infile outfile
```

| 命令行参数 | 作用 |
| :-: | :-: |
| `-I bfdname` | 指定输入文件格式，可以是以上支持的文件格式的一种 |
| `-O bfdname` | 指定输出文件格式 |
| `-F bfdname` | 指定输入输出文件格式 |
| `-p` | 保留时间戳 |
| `-B arch` | 指定输出指令集架构 |
| `-D` | 产生的文件不可逆转，`-U`可逆转 |
| `-j name` | 仅拷贝名为`name`的section |
| `-R name` | 在输出中去除`name` |
| `-S` `--strip-all` | 除去所有`symbol`和重定位信息 |
| `-g` `--strip-debug` | 除去所有调试信息 |
| `--strip-dwo` | 除去所有DWO |
| `--strip-symbol sym` | 不复制指定标记 |
| `-K sym` | 保留指定标记 |
| `-G sym` | 指定某个为全局标记，其他为局部标记 |
| `-L sym` | 指定某个为局部标记 |
| `-W sym` | 弱化标记 |
| `--globalize-symbol=sym` | 指定某个为全局标记 |
| `-x` | 不拷贝非全局 |
| `-X` | 不拷贝局部 |
| `-i interleave` | 每隔interleave字节拷贝1byte |
| `-b byte` | 和`-i`一起使用，拷贝每个interleave中的第byte字节（0到i-1），一般用于srec的输出 |


**`sdranlib`用法**

`ranlib`用于更新库文件的符号索引，一般在追加新的成员之后，本质是`sdar`的另一种形式

| 命令行参数 | 作用 |
| :-: | :-: |
| `-t` | 更新时间戳 |


### 2.1.5 基于sdcdb的调试

**`sdcdb`目前基本无法使用，建议使用VM8051**

如果想要调试，就必须在编译时加上`--debug`选项，生成`.cdb`文件

假设调试`sample.c`，已经编译完成，`sdcdb`会自动启动相应模拟器

```shell
sdcdb -cpu 8051 sample
```

**`sdcdb`命令行参数**

| 命令行参数 | 作用 |
| :-: | :-: |
| `--directory=` | 指定查找目录，调试器会查找`.c` `.ihx` `.cdb` |
| `-cd` | 到指定目录 |
| `-cpu` | 指定cpu类型 |
| `-X` | 指定晶振频率 |
| `-s` `-S` `-k` | 模拟器参数 |


**`sdcdb`交互命令**

大部分命令和`gdb`类似

| 命令 | 作用 | 使用方法 |
| :-: | :-: | :-: |
| `break` | 设置断点 | `break [file:]{line|func}` |
| `clear` | 清除断点 | `clear [file:]{line|func}` |
| `continue` | 断点后继续 |  |
| `finish` | 执行到当前函数末尾 |  |
| `delete` | 删除断点n，不指定断点则删除所有 | `delete [n]` |
| `info` | 最重要的命令，显示各种信息，后加`break`显示当前所有断点，`stack`显示函数调用堆栈，`frame`显示当前执行frame，`registers`显示所有寄存器内容 | `info [break|stack|frame|registers]` |
| `step` | 单步调试 |  |
| `next` | 单步调试，经过子程序调用 |  |
| `run` | 启动调试程序 |  |
| `ptype` | 显示变量类型 | `ptype var` |
| `print` | 显示变量值 | `print var` |
| `file` | 加载文件 | `file filename` |
| `frame` | 显示当前`frame`信息 |  |
| `set srcmode` | 切换C源码或汇编源码调试模式 |  |
| `!` | 模拟器命令 | `! cmd` |
| `quit` | 退出调试 |  |


### 2.1.6 基于VM8051的调试

直接启动即可

```shell
vm8051 out.ihx
```

使用说明见[VM8051Guide](src/201220a01/VM8051Guide.pdf)


## 2.2 STC的89C51系列开发（STC89C52RC）

### 2.2.1 扩展关键字

SDCC扩展的关键字如下，**分为变量声明和寄存器声明两种**，和Keil C51类似，区别是在前面都要加上`__`双下划线

| 变量声明关键字 | 作用 |
| :-: | :-: |
| __bit | 单bit变量，置于内部可位寻址区，一般放在0x20\~0x2F，对于位地址0x00\~0x7F |
| __data | 将变量置于内部RAM的低128Byte地址空间中，可以直接或间接寻址，一般是放在0x30\~0x7F。**是small内存模式下默认的变量地址空间** |
| __idata | 将变量置于内部RAM中，间接寻址，一般是放在0x80\~0xFF |
| __pdata | 将变量置于外部RAM的低256Byte地址空间中，使用Ri间接寻址，地址从0x00到0xFF。**是medium内存模式下默认的变量地址空间** |
| __xdata | 将变量置于外部RAM中，使用DPTR间接寻址，地址从0x0000到0xFFFF。**是large内存模式下默认的变量地址空间** |
| __code | 将数据置于ROM中，使用DPTR间接寻址，地址从0x0000到0xFFFF |

示例

```c
__data unsigned char a = 0;
__xdata int b = 0;
__bit c = 0;
```

| 寄存器声明关键字 | 作用 |
| :-: | :-: |
| __sfr | 8bit长度特殊寄存器 |
| __sfr16 | 16bit长度特殊寄存器 |
| __sfr32 | 32bit长度特殊寄存器 |
| __sbit | 可位寻址寄存器地址 |

寄存器常量通过`__at`关键字进行规定，这和Keil C51不同，**其实就是给一个地址处的寄存器规定一个符号，比如P0**。一般寄存器常量已经在对应头文件中有声明，用户无需操作。**16bit寄存器需要分别指定高位和低位地址（如果寄存器访问有严格顺序规定最好不要使用__sfr16声明，因为编译器优化有可能会导致乱序访问）**，示例如下

```c
__sfr __at (0x80) P0;
__sbit __at (0x81) P0_1;
__sfr16 __at (0x8C8A) TMR0;
```

### 2.2.2 指针

和普通变量相同，指针也可以通过声明指定存放的位置，本质是间接寻址。指针可以不规定指向的数据类型，也可以使用指向函数的指针

示例

```c
__xdata unsigned char* __data p1;
__data unsigned char* __xdata p2;
__xdata unsigned char* __code p3;
unsigned char* __xdata p4;
char (*__data fp)(void);
```


### 2.2.3 中断声明

SDCC中断号与其对应中断如下

![](images/201220a002.png)

中断的声明如下

```c
void time_isr (void) __interrupt 0 __using 1
{
    // Interrupt service code
}
```

其中`__interrupt`关键词使得编译器在中断向量表中插入到这个函数的跳转指令（这里是中断0），`__using`关键词可以用于指定这个中断使用的工作寄存器组（0\~3），这样在保存现场时不用压栈所有通用寄存器，只要压栈ACC、B等关键寄存器即可（也可以不指定，但是会额外增加压栈时间导致中断响应延迟增加，这在高频率中断中可能会产生问题）。这和ARMv7 Cortex-A系列的FIQ快速中断原理类似

**中断注意事项**

> 1. 如果中断使用到了其他函数内使用到的变量，这些变量声明需要添加`volatile`关键字

```c
volatile __data char i;
```

> 2. 8位单片机访问一些16位或更长的变量时往往需要使用多于一条指令，这就是操作的非原子性，此时发生中断将会发生异常，建议关中断

> 3. 中断调用要注意栈溢出

> 4. 尽量不要在中断中或有中断发生的main中使用不可重入函数，这包括一些需要外部浮点函数库的数学运算。如果要使用，最好将这些不可重入函数使用`--stack-auto`参数重新编译，并且源代码需要使用`--int-long-reent`重新编译


### 2.2.4 常用技巧

**由于8051的体系结构限制，所有IO寄存器（所有SFR）只能使用直接寻址方式，所以不能使用IO引脚号作为函数的参数**（因为所有访问IO的指令，比如设置P0`MOV 80H, #01H`在编译时就已经定死无法更改），也不存在IO变量，这极大限制了8051代码的灵活性以及代码复用。而像Arduino这样基于AVR的单片机可以使用IO号作为函数的参数

这里提供一些变通的方法

**使用宏定义**

```c
#define PIN_D0 P0_0
#define PIN_D1 P0_1

void init() {
    PIN_D0 = 1;
    PIN_D1 = 0;
}
```

因为编译器处理流程是预处理-编译-汇编-链接，所以如果是自己设计的函数库，头文件分别放在./inc以及./src下，宏定义也必须放在相应头文件中而不是main.c中（独立的宏定义可以通过在用户区添加一个共用头文件实现，但是需要修改Makefile，目前的Makefile较为简单还无法实现qwq，计划改进工程模板以及Makefile支持更加复杂的文件依赖，或者引入Makefile的自动依赖推导）

从软件工程的角度看，使用宏定义不是一种完美的代码复用方案，因为需要更改原来的代码再次编译，这也不利于库文件以及可重定位文件的应用，因而8051开发中库文件一般只用在不涉及IO的场合。但是使用宏定义执行效率最高，并且一般的廉价8051单片机资源极其有限，所以宏定义还是最适合的方案

**定义IO函数**

可以定义专门的函数用于SFR操作，但是会用到switch或if判断，降低效率

```c
void io_func(unsigned char io, unsigned char s) {
    switch(io) {
        case 0:
            P0_0 = s;
            break;
        case 1:
            P0_1 = s;
            break;
        // ...
    }
}
```

**使用函数指针**

如果使用函数指针，需要定义额外的函数（可以额外定义一套.c和.h）用以不同的IO读写，消耗程序空间，并且函数调用也会额外增加开销，如果增加判断语句会进一步降低效率，综合来看效率不如以上方案，并且代码繁琐。这种方案一般很少采用


## 3 ARM单片机

## 3.1 工具链：arm-none-eabi-gcc


## 3.2 工具链使用：llvm