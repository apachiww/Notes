# Make原理和使用

基于GNU Make，涵盖现代高级工具如CMake，autotools，Ninja的使用

http://www.gnu.org/software/make/

主要参考GNU Make官方文档

## 1 简介

## 1.1 Make是什么

Make的思想起源于软件工程，随着编译技术的发展，以及软件本身的进化，一个软件的源文件结构不断变得复杂，程序员发现面对成千上万多种多样的源文件，手动编译一个程序变得不再现实，于是寻求一种可以根据规则自动进行文件处理的工具。这就是**Make**

Make分为很多种，**它们几乎应用在目前所有的开发环境中，已经成为目前计算机软件开发领域的重要基础设施，学习Make对于理解工程代码的管理非常重要，这和多文件大型工程的开发与管理密切相关**。除目前最常用的**GNU Make**外，FreeBSD的软件中也有使用自家开源许可证的**BSD Make**，常用的C++应用框架Qt拥有**QMake**，Ruby有自己的实现**Rake**，微软的VS有**msbuild.exe**和**nmake**，GNU Make有一个加强版**Remake**，还有常用的makefile工具**automake**和**autoconf**，近几年有流行的**Ninja**，还有强大的跨平台工具**CMake**等（类似CMake和automake这些工具**一般被称为元构建系统meta-build system**，它们不会直接和构建过程打交道，而是生成其他构建系统的脚本。Ninja有专用的元构建系统GN）。我们在一般的IDE中接触不到make，因为IDE为方便用户，往往会隐藏底层的构建过程

Make本质就是根据给定规则推导判断文件依赖，之后通过一系列处理步骤，生成或更新这些文件，一般根据文件的时间戳判断哪些文件需要更新（假设源文件时间戳比目标文件新，那么就代表这个目标文件需要重新构建）

Make几乎可以算作是通用的文件处理脚本工具，Makefile就是它的脚本。在Linux、BSD等类UNIX环境中各种强大工具的支撑下，它不仅可以用于各种语言编写的程序编译与构建，甚至可以用于图片和音频等文件的处理

学习Make建议**结合实际的项目进行理解**，可以参考各种开源项目，尤其是一些跨平台项目


## 1.2 GNU GCC工具链

GCC编译一个程序的过程分为**预处理、编译、汇编、链接**4大步骤

在我们日常编写一个单源码程序（比如一个控制台程序）时，我们只要在文件中包含我们需要的标准库头文件即可。执行`gcc test.c -o test`会自动完成这一系列所需过程

但是在实际情况中，尤其是在大型工程中，这种情况会变得异常复杂。一方面，一些公司出于商业保护、专利保护、copyright等原因，或者一些软件作者单纯不想开放他的源码（这是可以理解的，比如他们不想使自己的成果在未经允许的情况下被他人修改后利用或随意进行二次发布），**他们往往只会提供一个闭源的二进制库以及一个头文件，而不是完整的源代码**。这些闭源代码只能通过**链接**应用到我们的程序中，反汇编是破译这些程序的唯一方法。另外，为了减少程序的重复，操作系统提供了动态库加载技术，很多程序会使用共享的动态链接库。并且在实际中头文件和源代码的关系也是错综复杂的，为方便大型工程的管理以及简化开发（使用一个库，直接引用一个头文件即可，无需再次逐个声明函数，这个头文件同时被库和应用程序使用），实际工程中都将头文件（声明）和源文件（实现）分开

比如，一个软件作者可以写一个库，文件为`test1.c`、`test2.c`以及头文件`test.h`，经过编译汇编得到可重定位文件`test1.o`和`test2.o`，再使用`ar`打包变成库文件`test.a`，发布时只提供`test.h`以及`test.a`，使用时在编译最后阶段链接即可

预处理使用`cpp`，编译使用`cc`，汇编使用`as`，链接使用`ld`。实际使用中这些程序都可以统一通过`gcc`调用，并且`gcc`会自动产生一些参数，比如`ld`所需的参数可以在被`gcc`调用时自动生成


## 2 Make执行流程

一些基础概念

GNU Make 官方文档 http://www.gnu.org/software/make/manual/

## 2.1 两个阶段

Make的主要任务，主要是文件依赖的推导，以及自动调用文件构建命令

GNU Make的执行过程大致分为两个阶段（Phase）

**第一个阶段**make会首先预处理Makefile，将Makefile通过`include`包含的文件拷贝到此处，之后展开处于immediate上下文的所有的变量，对显式规则（explicit rules）以及隐式规则（implicit rules）进行解析，并构建文件依赖树。

文件包含用法如下，使用`include`关键字

```makefile
include share.mk
```

**第二个阶段**make会根据依赖树以及文件时间戳判断哪些文件需要更新，并运行相应的构建方法（recipes）更新文件

**对于这两个阶段的理解非常重要**，之后有关变量的展开和这两个过程息息相关


## 2.2 Makefile的解析过程

> 这里首先引入有关于变量展开上下文的几个概念：
>
> **立即展开（immediate）** 指的是该变量在**第一阶段**就得到展开。此时只是进行文件依赖的推导，并未执行实际的操作
>
> **延迟展开（deferred）** 指的是该变量在**第二阶段**才被展开。处于延迟（deferred）上下文中的变量也会因为在一个立即（immediate）的上下文中被引用而被强制展开

Makefile的解析流程如下

> 1. 读取Makefile一整行，去除注释
>
> 2. 如果行以recipe的前缀符号开头（一般是制表符），那么代表此时处在一个recipe的上下文，将该行加入当前的recipe并继续读取下一行
>
> 3. 将所有处于immediate的上下文变量展开
>
> 4. 扫描行中的`=`或`:`符，如果有就代表该行是变量规定（macro assignment）或规则（rule）
>
> 5. 进行相应操作，读取下一行


## 3 Makefile格式以及编写

Makefile的基本组成单位是**规则**（**rules**），而每一个**规则**都是基于**目标**（**targets**）定义的，**目标**可以是一个文件，也可以是使用Make命令行时指定的操作，如`install`，`clean`等（称为**伪目标**）。每一个**目标**都可以有**依赖**（**prerequisites**），在C工程中常见的有库文件，可重定位文件以及源码等。**目标**也会有对应的**构建方法**（**recipe**），一般是用于构建该**目标**的命令行


## 3.1 Makefile变量

变量的引用通过形如`${var}`或`$(var)`

以下`imm`和`def`指变量的类型（immediate或deferred）

建议先看[3.2规则](201219b_makefile.md#32-规则Rule)


### 3.1.1 变量的赋值

变量的赋值有以下几种

| 形式 | 解释 |
| :-: | :-: |
| `imm = def` | 递归展开变量，也是其他一些make软件支持的赋值方法。这种赋值**会将所有变量层层递归展开**。**make首先会记录这些变量所有的上下文，在最终才会将所有这些变量统一展开**。比如`TEST = hello` `ME = ${TEST}`，那么最后`TEST`和`ME`都是`hello`。**缺点**是容易导致无限递归，并且如果使用了函数，这些函数每次都会执行，拖慢速度 |
| `imm := imm` | 一般变量，克服了以上赋值方法的缺点。这种变量的使用和一般的编程语言中的类似，赋值就是当前的值（其实就是立即展开，展开时间比`=`早）。而不像`=`一样在最终逐层展开，得到的是变量最终的值 |
| `imm ::= imm` | 同`:=`，是POSIX标准规定的 |
| `imm ?= def` | 如果变量还未被定义，就会进行赋值，否则不会执行赋值 |
| `imm += def imm += imm` | 将一个变量追加到末尾。如果变量之前未被定义过，那么创建的**默认变量类型为可递归展开变量**；如果变量之前已经使用`=`或`:=`定义过，那么经过`+=`处理之后的变量依然遵循原来的类型 |
| `imm != imm` | 执行右边的shell指令，并且将执行结果赋值给左边的变量。也可以使用函数`$(shell )`代替 |
| 命令行赋值 `make VAR=hello` | 以这种方式赋值的变量会覆盖Makefile中的赋值，Makefile中所有该变量的赋值操作均无效 |
| 多行赋值 `define` | 见下 |

**变量的字符替换**

指定字符替换，示例

```makefile
# 将一个变量中所有a替换成为b
OBJ = $(VAR:a=b)
```

替换后缀，使用通配符`%`

```makefile
# 将一个变量中所有.c后缀替换成为.o
OBJ = $(VAR:%.c=%.o)
```

**关键字`override`**

可以使用`override`强制赋值，这个赋值会**覆盖通过命令行参数规定的变量**

```makefile
override VAR = hello
```

**使用`define`赋值多行变量**

```makefile
define CMD =
echo hello
echo world
endef
```

**注销变量**

取消变量可以通过直接赋空值（之后可以再引用，为空值）

```makefile
VAR :=
```

也可以使用`undefine`直接销毁（之后不可再引用）

```makefile
undefine VAR
```

**目标专属变量**

默认情况下所有的Makefile变量都是全局的。定义一个目标专属的变量可以使用如下方法

```makefile
target : variable-assignment
```

示例

```makefile
test.o : CC = gcc
```

除了可以对一个目标定义其专属的变量，还可以定义一类文件专属的变量

```makefile
target-pattern : variable-assignment
```

示例

```makefile
%.o : VAR = hello
```


### 3.1.2 内建特殊变量

| 变量 | 解释 |
| :-: | :-: |
| `MAKEFILE_LIST` | 通过该变量可以获取当前所有已经包含的makefile文件名 |
| `.DEFAULT_GOAL` | 通过该变量可以获取当前的默认目标，或者设置默认目标，如`.DEFAULT_GOAL := hello` |
| `RECIPEPREFIX` | 设置recipe的默认前缀（默认为制表符），如设置为`>`，`RECIPEPREFIX = >` |
| `SHELL` | 指定执行recipe使用的shell，如`SHELL := /bin/bash` |


### 3.1.3 自动变量（Automatic Variables）

**自动变量只在一条rule后的recipe中有效**，除非使用二次展开

| 变量名 | 解释 |
| :-: | :-: |
| `$@` | 引用规则的targets域，也即target文件名。如果有多个目标，那么引用的就是当前导致recipe被执行的目标 |
| `$%` | 引用规则的targets域，用于`ar`创建的`.a`库文件目标，列出其中的`.o`成员名 |
| `$<` | 引用规则的prerequisites域，第一个依赖 |
| `$?` | 引用规则的prerequisites域，当前比目标文件新的依赖文件（一般需要更新） |
| `$^` | 引用规则的prerequisites域，所有的依赖列表，不包括order-only顺序依赖 |
| `$|` | 引用规则的prerequisites域，所有的order-only顺序依赖 |
| `$+` | 引用规则的prerequisites域，所有的依赖列表，和`$^`不同的是`$+`有重复显示 |
| `$*` | 在静态格式规则以及隐式规则中表示当前的stem，如`%.c`匹配`hello.c`，那么stem就是`hello` |


## 3.2 规则（Rule）

### 3.2.1 规则基本格式

规则（rule）是Makefile最核心的部分，**由目标文件（targets），依赖文件（prerequisites）以及构建方法（recipe）三要素构成**，格式如下

```makefile
targets : prerequisites
    recipe

targets : prerequisites ; recipe
    recipe
```

**recipe行开头需要使用制表符作为前缀来标记该行为recipe**

`targets`代表要生成的**目标文件名**，可以有1个也可以有多个；`prerequisites`代表依赖的文件，一般有多个；`recipe`代表构建方法，一般是shell命令，紧跟在下一行，**以制表符开头（也可通过`.RECIPEPREFIX`指定其他符号）**，也可以在同一行，使用`;`分隔

变量展开示意如下

```makefile
imm : imm
    def

imm : imm ; def
    def
```


### 3.2.2 依赖（prerequisites）类型

依赖分为两种，一种是如上文所说的依赖，被称为**普通依赖（normal prerequisites）**。这种依赖的实质，就是当一个target目标文件有任何依赖（prerequisites）文件被更新，此时有依赖文件的时间戳比目标文件新，所以就代表目标文件需要被重新构建，运行对应recipe

还有第二种依赖，被称为**顺序依赖（order-only prerequisites）**

> 个人理解：事实上make的解析过程可以分为两种不同的过程来理解（当然Make真正的执行流程不完全是这样）。一种是**自上向下**的过程，比如我们在运行`make all`时，此时由目标文件向依赖文件解析，如果某些依赖文件不存在，那么就运行对应的recipe创建，**这经常发生在第一次执行make时，是目标文件（此时可能不存在）导致的依赖文件的更改**。之后还有一个**自下向上**的过程，make会检查那些依赖文件的时间戳，如果它们比目标文件新就代表要对目标文件进行更新，**这经常发生在第一次执行make以后，用户更改了一些源文件，是依赖文件（一般已经存在）导致的目标文件的更改**
>
> 这样可以解释**顺序依赖**的原理

**顺序依赖**可以理解为，当目标文件的依赖文件不存在时，会运行对应recipe创建。而当之后依赖文件被更新后，**顺序依赖不会像普通依赖一样对目标文件进行重新构建**

可以使用`|`后加依赖指定一个顺序依赖，格式如下

```makefile
targets : | order-only prerequisites
    recipe

targets : normal prerequisites | order-only prerequisites
    recipe
```

顺序依赖一般用于目录的创建，**因为目录的时间戳随内含文件时间戳的变化而变化，所以需要加以限制，防止依赖该目录的文件因为该目录中一个文件的更改而全部被重复构建**

```makefile
all : ${GEN}

${GEN} : | ${TMP_DIR}

${TMP_DIR} :
    @mkdir ${TMP_DIR}
```


### 3.2.3 使用通配符（wildcard）

通配符以及通配函数`$(wildcard )`的使用

和shell一样，Makefile中常用的通配符有`*`和`?`

在recipe中通配符实际是给shell执行的，比如`rm -rf *`，本质和这里的通配符不一样，这里不再示例。通配符只在rule中的targets以及prerequisites有效，会自动展开，**在变量赋值中使用通配符是无效的**

Rule中使用统配符示例

```makefile
test : *.c
```

如果想要在变量的赋值中使用通配符，只能通过函数。`$(wildcard *.c)`会匹配当前所有`.c`文件，并且将结果返回

```makefile
OBJ := $(wildcard *.o)
```

> **建议**
>
> 由于通配符在匹配文件失败时（如文件不存在），会直接将例如`*.c`作为文件名，所以尽量避免使用`*`通配符，如下例，虽然`OBJ`变量最后会展开，但是在`.c`文件不存在时会发生异常

```makefile
OBJ := *.c

test : ${OBJ}
    recipe
```


### 3.2.4 伪目标（Phony）

**划重点**

`.PHONY`一般用于标记`all clean install`等在使用make时的命令。由于**这些命令不是实际存在的文件**，所以需要通过`.PHONY`标记

示例

```makefile
.PHONY : clean all

all : ${OBJ}

clean :
    @rm -f *.o
```

这样可以使用`make clean`清除生成的文件

类似`clean`这样没有依赖的目标也可以看作空目标，这样它的recipe在每次`clean`被调用时会强制执行


### 3.2.5 目录搜索

可以使用`VPATH`变量指定搜索的路径，如果一个文件在当前目录下找不到，就会到指定目录下进行查找

以下示例指定两个查找的目录`./inc`和`/usr/local/include`

```makefile
VPATH = inc:/usr/local/include
```

另外可以使用`vpath`关键词指定一类文件的搜索路径

```makefile
vpath pattern dir
```

示例

```makefile
vpath %.c ../src
vpath %.h ../inc
vpath %.h /usr/local/include
```

**库搜索**

make默认可以通过`-lname`指定依赖一个库`libname.a`或`libname.so`

示例

```makefile
test : test.c -lfftw
    gcc $^ -o $@
```

会依次在当前目录以及指定目录查找`libfftw.so`以及`libfftw.a`文件


### 3.2.6 内建特殊目标

| 名称 | 用途 |
| :-: | :-: |
| `.PHONY`          | 指定伪目标     |
| `.DEFAULT`        | 指定所有未指定规则的文件的recipe   |
| `.INTERMEDIATE`   | 指定该文件为中间文件   |
| `.SECONDARY`      | 类似`.INTERMEDIATE`，但是不会自动删除文件 |
| `.SECONDEXPANSION`     | 在此之后的所有依赖在make读入所有Makefile之后会被二次展开      |
| `.NOPARALLEL`          | 禁止并行执行，`make -jx`失效 |
| `.ONESHELL`       | 每个target的recipe使用一个shell执行 |

`.SECONDEXPANSION`：之前解释过make的执行过程分为两个阶段，第一个阶段会进行文件的读入，变量的展开以及依赖的分析；第二个阶段会执行文件操作。在第一个阶段中立即变量（immediate）只会得到一次展开。而使用`.SECONDEXPANSION`，在此之后的变量在两个阶段之间还会得到第二次展开

示例，此时的变量需要使用两个`$`符

```makefile
test1_OBJ := add.o sub.o
test2_OBJ := mul.o div.o

.SECONDEXPANSION :
test1 test2 : $${$$@_OBJ}
```

第一次展开使得变量成为`${$@_OBJ}`，之后的第二次展开使变量变成了`test1_OBJ test2_OBJ`。

二次展开的意义就在于，**这使得在原本的immediate上下文中使用自动变量如`$@`和`$*`成为可能（这些变量原本只有在第一阶段之后才能获得它们的值，所以一般只用于recipe）**


### 3.2.7 单规则多目标

可以在规则的targets域填写多个目标名

示例

```makefile
test1.o test2.o : test.h
```

recipe一般会使用`$@`自动变量，这样所有的目标都会通过同一个recipe生成

```makefile
test1.o test2.o : test.h
    touch $@
```


### 3.2.8 单目标多规则

一个目标可以有多条规则对应，但是只能有一个recipe。make会自动将对应目标文件的所有prerequisites加入到一个总列表中

```makefile
test.o : test1.h
test.o : test2.h
```

常用的用途就是添加依赖规则

```makefile
OBJ := test1.o test2.o test3.o

test1.o : test1.h
test2.o : test2.h
test3.o : test3.h
${OBJ} : test.h
```


### 3.2.9 静态格式规则（Static Pattern Rules）

非常重要，**划重点**

示例

```makefile
OBJ := test1.o test2.o

${OBJ} : %.o : %.c
    cc -c $< -o $@
```

通过这种方式，就可以只写一条规则，而进行大量目标和源文件格式相同的编译

```makefile
targets : target-pattern : prereq-patterns
    recipe
```

> 这种规则的执行过程如下：首先在targets域需要**逐个指定所有的文件名（不可以使用通配符）**，之后将这些文件名和target-pattern进行匹配，**提取stem（假设一个文件名为`test.c`，而pattern是`%.c`，那么stem就是`test`）**。之后将这个stem替换到prereq-patterms中的`%`处。这样**目标文件和依赖文件之间是一一对应的关系**


### 3.2.10 双冒号规则

双冒号规则一般很少使用

```makefile
test1.o :: test1.c
    recipe

test1.o :: test2.c
    recipe
```

和单冒号规则不同，如果同一个目标文件出现在多条规则中，**这些规则相互独立，并且依赖文件和recipe也不相关（而在之前单目标多规则中说过所有的依赖文件都会被加入到同一个总列表）**。所以这些recipe都是单独执行的

同时，**同一个目标文件如果已经在普通规则（单冒号）中出现过，它不可以再用于双冒号规则**。反之亦然


### 3.2.11 使用编译器自动获取依赖

这只在大型工程中有少量应用，尤其是在源文件中使用`#include`调用了大量库的情况下

一般的C编译器可以使用`-M`或`-MM`输出文件依赖

```shell
gcc -MM main.c
```

根据文档，GNU Make建议为每一个文件创建一个依赖文件，如`main.c`，它的依赖（prerequisites）描述文件为`main.d`

这里直接使用GNU Make官方文档的示例

创建`.d`文件的规则

```makefile
%.d : %.c
    @set -e; rm -f $@; \
    $(CC) -M $(CPPFLAGS) $< > $@.$$$$; \
    sed ’s,\($*\)\.o[ :]*,\1.o $@ : ,g’ < $@.$$$$ > $@; \
    rm -f $@.$$$$
```

在开头引入文件

```makefile
sources = foo.c bar.c
include $(sources:.c=.d)
```


## 3.3 隐式规则（Implicit rules）

**实际应用中，建议不要使用隐式规则，因为这容易导致问题并且难以排查**

隐式规则和静态规则比较相似（其实就是make自动推导出来的静态规则），和之前所有的规则相对，前文所述的规则都是显式规则

隐式规则其实是make中自带的一些文件的处理方法，make会根据文件依赖以及后缀名自动推导recipe

隐式规则规定了一些预定义的变量，这是比较重要的，因为这是makefile中事实上的变量命名习惯

| 变量名 | 解释 |
| :-: | :-: |
| `AR` | 库文件命令，gcc为`ar` |
| `AS` | 汇编命令，gcc为`as` |
| `CC` | 编译器命令，gcc为`gcc` |
| `CXX` | C++编译器命令，gcc为`g++` |
| `CPP` | 预处理器命令，gcc为`cpp` |
| `RM` | 删除命令，默认为`rm -f` |
| `ARFLAGS` | `AR`的命令行参数 |
| `ASFLAGS` | `AS`的命令行参数 |
| `CFLAGS` | `CC`的命令行参数 |
| `CPPFLAGS` | `CPP`的命令行参数 |
| `CXXFLAGS` | `CXX`的命令行参数 |
| `LDFLAGS` | 调用链接器`ld`时的命令行参数 |
| `LDLIBS` | 调用链接器`ld`时指定库参数以及名称 |

这里只简单介绍一下，只需要懂得基本的原理

例如，设要编译一个程序`hello`，其有目标文件`test1.o`依赖于`test1.c`，`test2.o`依赖于`test2.c`，没有指定`.c`到`.o`的编译命令，如下

```makefile
SRC := test1.c test2.c

OBJS := $(SRC:.c=.o)

hello : $(OBJS)
    $(CC) $^ -o $@
```

make检查时发现没有对应两个`.o`文件的规则，所以根据内部隐式规则会自动使用以下recipe生成`.o`文件

```makefile
%.o : %.c
    $(CC) $(CPPFLAGS) $(CFLAGS) -c $^ -o $@
```


## 3.4 构建操作（Recipe）

有关recipe的写法

### 3.4.1 recipe基本格式

如果没有特殊指定，recipe的每一行都以制表符开头。反之，任何以制表符开头的行都被认为是一个recipe，空行也是如此。所有的recipe在经过处理以后就会被传送给shell处理

一般在recipe开头添加一个`@`，否则make会输出（类似于echo）当前执行的recipe命令，容易和其他信息混淆。而在前面添加`-`，可以使make忽略这些命令的报错继续执行

```makefile
test.o : test.c
    @echo "Building..."
    @gcc -c test.c -o test.o
    -rm -rf tmp/
```

每一条recipe只能占一行，可以使用`\`分隔达到使用多行的目的，尤其是shell中的结构化语句

```makefile
all :
    @echo hello \
        hello
    @echo "hello \
        hello"
```

相当于调用了

```shell
echo hello \
        hello
echo "hello \
        hello"
```

实际shell执行了

```shell
echo hello hello
echo "hello     hello"
```

输出

```shell
hello hello
hello   hello
```

> **Recipe的执行流程**： 
>
> 在recipe的调用中，每一个新的recipe命令都是以制表符开头。所以make传送给shell的命令**本质就是去除掉制表符前缀的字符串（变量已经展开）**，其他行（多行命令除第一行以外的所有行）开头的制表符**不会去除**，因此在recipe中命令换行之后其实可以顶格写。同时用于表示多行命令的`\`以及换行符都**不会被去除**，原样传递给shell执行
>
> 在一般的shell中，如果遇到`\`，在不同上下文中shell的处理方法不同。如果`\`在双引号`""`上下文，那么shell会自动去除`\`以及之后的一个制表符。如果`\`不在引号上下文，那么shell会自动去除`\`以及之后的多个制表符。
>
> 这也是上文中双引号内多了一个制表符的原因


### 3.4.2 recipe中的变量

recipe中的变量都是在makefile执行的第二个阶段被展开，之后由shell执行

如果recipe中需要使用到`$`，那么就需要使用`$$`代替，防止被展开。同时在shell中结构化语句需要写在同一行，或者使用`\`

```makefile
LIST := one two three

all :
    for i in ${LIST}; do \
        echo $$i; \
    done
```


### 3.4.3 recipe调用shell的方式

每一行recipe都会调用一个单独的shell，所以类似`cd`这样的命令是无效的

如果想要使得**所有**recipe在一个shell中执行，只需在makefile的任意位置使用`.ONESHELL`特殊目标即可

```makefile
.ONESHELL :
```


### 3.4.4 recipe的并行执行

make支持根据文件之间的依赖关系自动并行调用recipe，限制使用的线程数使用`make -jx`指定，如`make -j4`。如果使用`make -j`的话make会自动调用所有CPU核心

在并行执行下时make的输出可能会混乱，可以使用`make -O`或`make --output-sync`强制顺序输出。`line`以一行为单位，`target`以一个目标为单位，`recurse`以一次make调用为单位

示例

```shell
make -j16 -Oline
make -j16 --output-sync=line

make -j16 -Otarget
make -j16 --output-sync=target

make -j16 -Orecurse
make -j16 --output-sync=recurse
```


### 3.4.5 中断make

make在中断时会删除当前未构建完毕的文件。可以使用特殊目标`.PRECIOUS`规定在中断时不可删除的文件

```makefile
.PRECIOUS : test1.o test2.o
```


## 3.5 条件判断

makefile中`if-else`的基本格式如下。判断结构可以用在recipe上下文，也可以用在一般的上下文如赋值

```makefile
ifeq (${VAR}, hello)
    OBJECT = hello
else ifeq (${VAR}, test)
    OBJECT = test
else
    OBJECT = null
endif

ifeq (${VAR}, test)
    DEBUG = false
endif

all :
ifeq (${VAR}, hello)
    gcc test.c -o hello
else
    gcc test.c -o test
endif
```

测试一个变量是否为空

```makefile
ifeq (${strip ${VAR}},)
    CHECK = empty
endif
```

一个变量是否已经定义

```makefile
ifdef ${VAR1}
    TARGET = test1
endif

ifndef ${VAR2}
    TARGET = test2
endif
```


## 3.6 使用自带函数

**划重点**

make中的函数一般通过`$(func arg1,arg2)`或`${func arg1,arg2}`形式调用

### 3.6.1 字符串函数

| 函数 | 解释 |
| :-: | :-: |
| `$(substr from,to,text)` | 将`text`中所有的`from`改为`to` |
| `$(patsubstr pattern,replacement,text)` | 可以使用`%`通配符。将`text`中所有匹配的`pattern`替换为`replacement`，示例`$(patsubstr %.c,%.o,test.c hello.c)`。和化简格式`$(VAR:%.c=%.o)`等价 |
| `$(strip string)` | 去除字符串内所有开头以及结尾的空格符 |
| `$(findstring find,string)` | 在`string`中查找`find`，如果找到返回该目标，未找到返回空 |
| `$(filter pattern...,text)` | 过滤特定格式字符串，在`text`中只有pattern中指定的字符串才会通过，示例`$(filter %.c %.h,test.c test.h hello.c hello.o)`，其中`hello.o`会被过滤 |
| `$(filter-out pattern...,text)` | 和`filter`相反 |
| `$(sort list)` | 单词排序 |
| `$(word n,text)` | 返回字符串中第n个单词 |
| `$(wordlist start,end,text)` | 返回从`start`到`end`的单词列表 |
| `$(words text)` | 返回`text`中的单词数量 |
| `$(firstword string)` | 返回第一个单词 |
| `$(lastword string)` | 返回最后一个单词 |


### 3.6.2 文件名函数

| 函数 | 解释 |
| :-: | :-: |
| `$(dir names...)` | 提取文件的目录，如`/usr/local/include/` |
| `$(notdir names...)` | 和`dir`相反，提取文件名 |
| `$(suffix names...)` | 提取文件名后缀，如`.c` |
| `$(basename names...)` | 和`suffix`相反，去除后缀，保留文件名和路径 |
| `$(addsuffix suffix,names...)` | 添加后缀，示例`$(addsuffix .o,test1 test2)` |
| `$(addprefix prefix,names...)` | 去除后缀，示例`$(addprefix /usr/local/include/,test1.h test2.h)` |
| `$(join list1,list2)` | 将`list2`每一个元素连接到`list1`之后，示例`$(join test1 test2,.c .o)`得到`test1.c test2.o` |
| `$(wildcard pattern)` | 通配函数，返回所有符合`pattern`的文件名，示例`$(wildcard ./src/*.c)` |
| `$(realpath names...)` | 返回文件的实际路径 |
| `$(abspath names...)` | 返回文件的绝对路径，不解析符号链接 |


### 3.6.3 foreach函数

`foreach`函数可以看作是一个循环，依次将一系列的值赋值给变量，之后将`text`展开

格式

```makefile
$(foreach var,list,text)
```

示例

```makefile
$(foreach var,src1 src2,$(wildcard $(var)/*.c))
```

这样可以返回`src1/`以及`src2/`下的所有`.c`文件名


### 3.6.4 shell函数

`shell`函数可以将执行的shell命令的标准输出赋值给一个变量

示例

```makefile
INFO := $(shell uname)
```


### 3.6.5 file函数

`file`可以用于recipe中读写文件，可以覆写，也可以追加到文件末尾

格式

```makefile
$(file op filename[,text])
```

使用`>`覆写，`>>`追加，`<`读文件

示例

```makefile
$(file >make.txt,hello)
```


### 3.6.6 call函数

`call`可以用于创建函数并调用

格式

```makefile
$(call variable,param,param,...)
```

示例，创建一个`reverse`函数，颠倒2个参数

```makefile
reverse = $(2) $(1)
test = $(call reverse,a,b)
```

在makefile中一个函数的参数可以通过`$(1) $(2)`等引用，`$(0)`引用的是函数名本身


### 3.6.7 警告函数

| 函数 | 解释 |
| :-: | :-: |
| `$(error text)` | 引发错误，显示`text`错误信息，make终止执行 |
| `$(warning text)` | 引发警告，显示`text`错误信息，make继续执行 |
| `$(info text)` | 显示一条`text`信息 |


## 4 现代构建工具之Ninja

Ninja名称来源于日语「忍者」，是一个专注于提高构建速度、缩短构建时间的类Make构建系统，在大型工程中相对于Make有明显的速度提升。Ninja最初是作者为提高Google Chrome的构建速度而设计，目前Ninja已经在很多开源项目（如LLVM）中得到了广泛应用。Ninja的默认构建脚本在当前目录下的`build.ninja`

Ninja官网 https://ninja-build.org/

Ninja作者的文章 http://aosabook.org/en/posa/ninja.html

Ninja在设计上是可读的（Human Readable），但是较为繁琐不适合人工手写（设计理念：如果说Make是高级语言，Ninja就是汇编语言），**一般结合其他Make生成工具（元构建系统）如CMake使用**

Ninja相对于Make，只支持非常简单直接的规则描述，支持隐式规则。构建命令的更改也会导致文件的重新构建。Ninja在运行时会自动创建需要的目录，而不像Make需要使用一个顺序依赖。同时Ninja在运行时默认总是使用最多的CPU核心数，并行执行的输出都会通过缓冲自动按顺序输出

在Ninja中，**edge**基本相当于Make的**recipe**


## 4.1 Ninja的基本用法

和Make一样，Ninja使用时直接在当前目录执行`ninja`即可，用法基本是相同的，也可以通过`-j`参数指定使用的线程数量

Ninja支持使用shell环境变量`NINJA_STATUS`指定其执行时输出信息格式

示例

```shell
NINJA_STATUS = [%u/%r/%f] # 默认使用[%f/%t]
```

环境变量`NINJA_STATUS`可用输出信息

| Format | 释义 |
| :-: | :-: |
| `%s` | 当前已经启动的edge数量 |
| `%t` | 完成本次构建需要的edge数量 |
| `%p` | 当前已经启动的edge的比例 |
| `%r` | 当前正在运行的edge的数量 |
| `%u` | 当前剩余未运行的edge的数量 |
| `%f` | 当前已经完成的edge的数量 |
| `%o` | 平均每秒完成edge数量（速度） |
| `%c` | 1秒内完成edge的数量（实时速度） |
| `%%` | 显示一个`%` |

另外Ninja支持一些有用的小工具，可以在使用时通过命令行参数`-t`调用

| 工具名 | 作用 | 示例 |
| :-: | :-: | :-: |
| `browse` | 启动一个端口（默认8000），调用浏览器显示依赖图 | `ninja -t browse --port=8080 mytarget` |
| `graph` | 生成`graphviz`可用的文件 | `ninja -t browse --port=8000 --no-browser mytarget` |
| `targets` | 用于显示适用于一种规则的目标文件，或按深度显示目标文件 | `ninja -t targets rule myrulename` `ninja -t targets depth 5` |
| `commands` | 用于显示指定目标文件的构建命令 | `ninja -t commands mytarget` |
| `clean` | 清除生成的文件 | `ninja -t clean` |
| `cleandead` | 清除已经不包含在当前`build.ninja`中的文件 | `ninja -t cleandead` |
| `deps` | 显示`.ninja_deps`中所有的依赖 | `ninja -t deps` |
| `restat` | 更新`.ninja_log`中记录到的文件的时间戳 | `ninja -t restat` |
| `rules` | 显示所有的rule规则名称 | `ninja -t rules` |


## 4.2 Ninja语法简记

一般日常使用中没有必要自己写`build.ninja`，这里只做一些简单的解释

以Ninja官网示例为例

```
cflags = -Wall

rule cc
  command = gcc $cflags -c $in -o $out

build foo.o: cc foo.c
```

> 在Ninja中，变量通过`$var`的形式引用，通过`=`直接赋值。
>
> 使用`rule`关键字指定一种规则，这种规则需要有一个名称（这里是`cc`），以及构建相应目标文件的shell命令（通过`command`指定）
>
> 而`build`关键字用于指定文件的依赖关系（Build Statement），需要指定对应目标文件使用的rule以及依赖文件名。可以在`build`关键字之后指定**专有变量**，例如
>
> ```
> build special.o: cc special.c
>    cflags = -Wall
> ```

Ninja也支持`phony`的使用，如下示例，可以为一个目标创建一个别名（本身不是实际存在的文件）

```
build foo: phony dir/to/foo
```

可以使用关键字`default`指定默认的构建目标

```
default test.o hello.o 
```


## 5 元构建系统之CMake

CMake是一个非常强大的跨平台的构建工具，一般用于生成其他make工具（GNU Make或Ninja等）的脚本，在默认情况下检查当前目录下的`CMakeLists.txt`作为输入，可以生成Buildsystem（一般是其他Make软件的脚本）

官方网站 https://cmake.org/

> 2021.9.13注：说实话CMake官方的教程以及示例写的不太好，这里推荐另外一个教程，可以参考 https://cliutils.gitlab.io/modern-cmake/
>
> 参考[文档](src/201219b01/modern-cmake.pdf)


## 5.1 CMake的基本用法

在构建之前首先需要生成构建系统（如Makefile或build.ninja等），可以使用`-G`命令行指定想要使用的构建系统。不指定**默认使用通用的Makefile**，可以用于`gmake`，`nmake`等。**构建系统文件依据CMakeLists.txt在当前目录下生成**，注意一旦指定一个构建目录的构建系统以后就**不可再次更改**，想要更改只能删除文件

```shell
cd ~/repos/hello    # ~/repos/hello为CMakeLists.txt所在目录，也是整个工程的目录
cmake .             # 默认生成Makefile，这里的.用于指示CMakeLists.txt所在路径
cmake . -G Ninja    # 指定使用ninja，会在当前目录下生成build.ninja
cmake . -G "Visual Studio 2019"                     # 指定生成VS的工程文件
cmake . -G "Visual Studio 2019" -A x64 -Thost=x64   # 使用VS时可以通过-A指定目标CPU架构，使用-T指定使用的工具链（这里指定使用64位工具链）
```

在通过命令行调用`CMake`时可以使用`-D`指定变量，使用`-U`销毁变量，如下例

```shell
cmake . -G Ninja -DCMAKE_BUILD_TYPE=Debug
```

命令行常用变量如下

| 变量 | 释义 |
| :-: | :-: |
| `CMAKE_PREFIX_PATH` | 指定依赖包的查找路径。适用于CMake的依赖包一般和第三方闭源库一起发行，向CMake指示这些二进制文件以及头文件的处理与使用方法 |
| `CMAKE_MODULE_PATH` | 指定附加CMake模块的路径 |
| `CMAKE_BUILD_TYPE` | 设置本次构建的类型，可以是`Debug`或`Release`，只对Make和Ninja有效，对VS和XCode无效 |
| `CMAKE_INSTALL_PREFIX` | 指定安装路径，使用`install`目标进行软件的安装时使用。在类Unix上默认是`/usr/local` |
| `CMAKE_TOOLCHAIN_FILE` | 指定CMake的工具链参数文件 |
| `BUILD_SHARED_LIBS` | 选择是否构建共享库 |
| `CMAKE_EXPORT_COMPILE_COMMANDS` | 生成适用于clang工具链的`compile_commands.json`文件 |

> `CMAKE_MAKE_PROGRAM`用于指定直接使用`--build`运行构建过程时调用的构建工具，可以是`make`，`ninja`等

在生成构建系统之后就可以**进行真正的构建过程**了，可以使用`cmake --build`让cmake自动调用`make`或`ninja`（需要设定），也可以手动执行`make`或`ninja`（因为当前目录已经有Makefile了）

```shell
cmake --build .
cmake --build . --target install # 使用install目标调用软件安装的过程
```

> 在第二行命令中使用到了一个内建的目标`install`，CMake还有其他的一些内建目标，如下

| 内建目标名 | 释义 |
| :-: | :-: |
| `all` | 相当于Makefile和build.ninja中的默认目标all，构建所有文件 |
| `help` | 列出可用的构建目标 |
| `clean` | 清除所有生成的文件 |
| `test` | 运行测试 |
| `install` | 安装软件 |
| `package` | 创建一个二进制包 |
| `package_source` | 创建一个源码包 |

除此之外，CMake支持Cache，记录构建时使用到的各种参数（如工具链名称，工具链路径，依赖，命令行参数等），在第一次运行时会生成一个`CMakeCache.txt`用于存储这些信息的键值对，可以使用命令行工具`ccmake`编辑其中的键值对

CMake还支持使用预设，CMake读取`CMakePresets.txt`以及`CMakeUserPresets.txt`获取预设参数，一般包含构建目录，环境变量，Cache变量等

> 一般一个预设文件里面会有多个预设配置，每一个预设都有一个名称，可以在调用`cmake`的时候通过`--preset`参数指定，如下示例
>
> ```shell
> cmake -S ~/repos/hello --preset=ninja-release # 调用了名称为ninja-release的配置
> ```
>
> ```shell
> cmake -S ~/repos/hello --list-presets # 列出源文件目录预设文件中的所有预设配置的名称
> ```


## 5.2 编写脚本CMakeLists.txt

CMake相比Make处于更加高级的层面，所以不能用写Makefile的思维去写CMakeLists.txt

CMakeLists.txt由**命令**和**变量**两大基本要素构成。CMakeLists.txt唯一的基本构成单位称为**命令**（commands），形式类似于一般编程语言中常见的函数形式`func()`，其中的参数使用空格分隔。而**变量**（variables）一般用于控制行为，提供信息等，分为用户定义的临时变量和CMake的内建变量

和Make不同，CMake将CMakeLists.txt中所有命令逐条执行，CMake只是相当于一个脚本解释器

> CMake所有的命令参考见 https://cmake.org/cmake/help/v3.21/manual/cmake-commands.7.html
>
> CMake所有的内建变量参考见 https://cmake.org/cmake/help/v3.21/manual/cmake-variables.7.html

**快捷入门**

一个简单的示例如下

```cmake
# 首先指定要求的最低CMake版本
cmake_minimum_required(VERSION 3.10)

# 其次设定工程名，可以添加VERSION指定版本
project(Hello VERSION 1.31)
# 版本号也可以通过变量设定
# set(Hello_VERSION_MAJOR 1)
# set(Hello_VERSION_MINOR 31)

# 指定使用的C++版本，设置为C++11，注意需要在所有add_executable()之前指定
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_SRANDARD_REQUIRED True)

# 可以指定一个用于版本号管理的头文件，将版本号传入，头文件示例见下
configure_file(helloconf.h.in helloconf.h)

# 最重要的命令之一，设定生成的可执行文件名称，这里是Test，由main.cpp得出
add_executable(Test main.cpp)
```

编写一个`helloconf.h.in`如下，使用CMake中的`configure_file()`命令会自动将所有使用`@@`括起来的文字替换为指定的版本号并输出为`helloconf.h`，这里分别为`1`和`31`。在`main.cpp`开头添加`#include "helloconf.h"`这样就可以在程序中使用版本号

```c
#define VERSION_MAJOR @Hello_VERSION_MAJOR@ // 主版本号，自动替换为1
#define VERSION_MINOR @Hello_VERSION_MINOR@ // 次要版本号，自动替换为31
```

如果最终生成的Test由多个源文件构建（比如主进程代码在`main.cpp`，调用两个函数分别在`add.cpp`和`abs.cpp`，这两个函数声明在头文件`mylib.h`），那么就需要将这些文件都添加到Test的依赖中，把最后一行`add_executable()`更改如下

```cmake
add_executable(Test main.cpp add.cpp abs.cpp)
```

也可以使用`aux_source_directory()`命令，使用该命令可以查找一个目录下所有的源文件，存储到一个变量中，之后在`add_executable()`中引用这个变量

```cmake
aux_source_directory(. ALL_SRC)
add_executable(Test ${ALL_SRC})
```

如果想要在工程中使用静态库，可以将所有的源文件存入一个目录。这里设`add.cpp`和`abs.cpp`以及`mylib.h`都在`./lib`目录下，要编译出一个名为`Myfunc`的静态库文件，就要在`lib`目录下创建一个子CMakeLists.txt，如下所示

```cmake
add_library(Myfunc add.cpp abs.cpp)
```

然后在主CMakeLists.txt中添加如下内容

```cmake
add_subdirectory(lib)

add_executable(Test main.cpp)

target_link_libraries(Test Myfunc)
```

这样CMake会自动在子目录`lib`中编译出库文件`libMyfunc.a`，最后再和`main.cpp.o`链接

**编译选项**

CMake可以使用`option()`指定一个选项（**也相当于在C语言中使用`#define`关键字定义，但是需要在`*.in`中配置**），形式如下

```cmake
option(USE_MYLIB "Use the tailored library" ON)
option(ENABLE_OPTIMIZATION "Optimize the code" OFF)
```

其中，括号内第一个参数为用户自定义的一个选项，第二个参数为该选项的描述，第三个参数可以是`ON`或`OFF`，指定该选项的有效与否。之后`if()`条件判断命令的使用涉及到这里的设定。`if()`语句的一个示例如下

```cmake
if(ENABLE_OPTIMIZATION)
    # Commands
endif(ENABLE_OPTIMIZATION)
```

这个选项在编译的C代码中使用方法如下，用于条件编译

```c
#include "helloconf.h"

#ifdef ENABLE_OPTIMIZATION
    #define USE_FAST_FUNCTION
#endif
```

需要在`helloconf.h.in`添加如下内容，CMake会自动处理`helloconf.h`，决定是否定义`ENABLE_OPTIMIZATION`

```c
#cmakedefine ENABLE_OPTIMIZATION
```

这些选项可以使用`ccmake`图形界面配置更改`ON`或`OFF`，也可以使用`cmake -i`配置

**安装**

可以指定生成目标文件的安装目录，使用`install()`命令指定。目标文件可以是可执行文件，也可以是库文件或头文件等

```cmake
install(TARGETS Test DESTINATION bin)
install(FILES "test.h" DESTINATION include)
```

这样CMake默认将文件安装到`/usr/local/`下的`bin`或`include`，默认安装的路径前缀可以通过变量`CMAKE_INSTALL_PREFIX`设定

**测试**

CMake可以使用`add_test()`指定一次测试，也可以使用`set_tests_properties()`检验测试结果的正确性

测试在对应`CMakeLists.txt`中的写法如下

```cmake
# 首先启动测试
enable_testing()

# 首先确保程序能正常运行，使用add_test()会检测程序运行后是否返回0。括号内第一个参数为本次测试的名称，第二个参数为测试的可执行文件以及对应的命令行参数（其实就是测试使用的命令行）
add_test(test_run Test)

# 其次可以测试不同的输入，并使用set_tests_properties()检测输出是否符合预期
add_test(test_1 Test --use-aux-out)
# 括号内第一个参数为对应的测试名，使用PROPERTIES指定结果，这里是使用正则表达式进行匹配
set_tests_properties(test_1 PROPERTIES PASS_REGULAR_EXPRESSION "[A-Z]*")
```

如果测试数量过多，可以使用宏实现

```cmake
macro(exe_test arg1 arg2 out)
    add_test(test_${arg1}_${arg2} Test ${arg1} ${arg2})
    set_tests_properties(test_${arg1}_${arg2} PROPERTIES PASS_REGULAR_EXPRESSION ${out})
endmacro(exe_test)

exe_test(1 2 "is 3")
exe_test(5 6 "is 11")
```

**添加GDB调试功能**

想要使用调试器，只要在编译时指定必要的参数即可

```cmake
set(CMAKE_BUILD_TYPE "Debug")

# $ENV{CXXFLAGS}是一个环境变量
set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g -ggdb")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall")
```

## 5.3 常用命令（Commands）

详细命令参考列表

### 5.3.1 基本脚本控制相关命令

**变量设定**

使用`set()`进行变量的设定

```cmake
# 定义一个普通变量，这个变量也可以是CMake的内建变量
set(VAR_NAME var-value)

# 定义一个缓存入口变量，类型可以是BOOL，FILEPATH，PATH，STRING，INTERNAL
set(VAR_NAME var-value CACHE BOOL)

# 定义一个环境变量，之后环境变量通过$ENV{}引用
set(ENV{VAR_NAME} var-value)
```

如果想要撤销一个变量，用`unset()`即可

```cmake
# 撤销一个普通变量
unset(VAR_NAME)

# 撤销一个缓存变量
unset(VAR_NAME CACHE)

# 撤销一个环境变量
unset(ENV{VAR_NAME})
```

**列表变量（List）**

列表变量本质和普通变量相同，各元素使用空格或`;`隔开，可以使用`list()`命令进行处理

```cmake
# 获取一个列表当前的长度
list(LENGTH listname OUT_VAR)

# 获取一个列表变量中的部分变量
list(GET listname index1 index2 OUT_VAR)

# 获取一个由列表元素以及连接字符串构成的字符串
list(JOIN listname gluestring OUT_VAR)

# 获取一个子串，从10开始的连续2个
list(SUBLIST listname 10 2 OUT_VAR)

# 查找一个元素，获取index
list(FIND listname value OUT_VAR)

# 正则表达式过滤元素。可以使用EXCLUDE进行反选
list(FILTER listname INCLUDE REGEX reg)

# 插入到位置10
list(INSERT listname 10 element1 element2)
# 插入到位置0
list(PREPEND listname element1 element2)

# 删除末尾一个元素
list(POP_BACK listname)

# 删除开头一个元素
list(POP_FRONT listname)

# 移除元素
list(REMOVE_ITEM listname value1 value2)
# 移除指定目录元素
list(REMOVE_AT listname index1 index2)
# 移除重复元素
list(REMOVE_DUPLICATES listname)

# 列表颠倒
list(REVERSE listname)

# 列表排序。通过ORDER指定顺序，可以指定大小写敏感，还可以在COMPARE使用FILE_BASENAME指定按文件名路径排序
list(SORT listname COMPARE STRING CASE SENSITIVE ORDER ASCENDING)

# 对列表中每一个元素进行处理，在开头添加value
list(TRANSFORM listname PREPEND value)
# 改大写
list(TRANSFORM listname TOUPPER)
# 删除空格
list(TRANSFORM listname STRIP)
# 正则表达式替换
list(TRANSFORM listname REPLACE reg reg_replace)
```

**条件判断**

CMake中的条件判断如下

```cmake
if(condition)
    commands()
elseif(condition)
    commands()
else(condition)
    commands()
endif(condition)
```

> 其中`else()`和`endif()`中的条件可以不填写，如果填写就必须填写和`if()`完全相同的条件

`condition`为`ON`，`YES`，`TRUE`，`Y`，`1`或非0数值时表达式为真，为`OFF`，`NO`，`FALSE`，`N`，`0`，`IGNORE`，`NOTFOUND`或空值时为假。`condition`也可以是一个包含这些值的变量。条件表达式可以使用括号，关键字有`EXISTS COMMAND DEFINED`，可以使用`EQUAL LESS LESS_EQUAL GREATER GREATOR_EQUAL STREQUAL STRLESS STRLESS_EQUAL VERSION_EQUAL MATCHES`等关键字做比较运算，还可以使用`NOT AND OR`指定逻辑关系

示例

```cmake
# 逻辑运算符以及括号的使用
if(NOT (condition1 AND condition2))

# 检测命令是否存在
if(COMMAND command-name)

# 检测一条策略是否存在
if(POLICY policy-id)

# 检测一个目标文件是否已经定义（使用add_executable()或add_library()定义）
if(TARGET target-name)

# 检测一个变量是否已经定义
if(DEFINED var)

# 检测一个文件是否存在
if(EXISTS path/to/file)

# 检测是否是一个目录
if(IS_DIRECTORY path/to/dir)

# 检测是否是一个符号链接
if(IS_SYMLINK path/to/slink)

# 检测是否是一个绝对路径
if(IS_ABSOLUTE path)

# 正则表达式匹配
if(var MATCHES regex)

# 数值比较
if(var1 LESS var2)

# 字符串比较
if(str1 STRGREATER str2)

# 版本比较
if(ver1 VERSION_LESS ver2)
```

另外，表达式中使用变量的方法也要注意。如果变量使用`${}`引用，变量会被递归展开。如果直接写变量名就不会递归展开

```cmake
set(var1 TRUE)
set(var2 "var1")

# 下面的var2值为TRUE
if(${var2})
```

**while循环**

`while()`循环的一般形式如下

```cmake
while(condition)
    commands()
endwhile()
```

在一个`while()`循环中也可以使用`break()`或`continue()`语句跳出或跳过

**foreach循环**

`foreach()`相当于C++11中的范围for

```cmake
# items是一个列表，其中的各个元素使用空格或";"分隔
foreach(TMP_VAR items)
    commands()
endforeach()

# 将3到52依次赋值给TMP_VAR执行
foreach(TMP_VAR RANGE 3 52)
    commands()
endforeach()

# 将多个列表中赋值给TMP_VAR执行，列表本质就是一个带空格或使用";"的变量，代表多个值
foreach(TMP_VAR IN LISTS list1 list2 ITEMS item1 item2)
    commands()
endforeach()
```

**函数**

用户可以通过`function()`定义自己的函数，使用方法如下

```cmake
function(func_name arg1 arg2 arg3)
    commands()
    return() # 函数需要在当前处理过程结束以后显式地调用return()返回
endfunction()

# 之后就可以调用函数了
func_name(ARG_1 ARG_2 ARG_3)
```

> 另外，向函数传入的参数数量可以通过`ARGC`获取，而所有参数也可以依次通过`ARGV0 ARGV1`等引用

**宏**

可以通过`macro()`命令定义一个宏。宏和函数非常相似。区别是CMake会将宏复制到调用的位置执行（类似于C语言中的宏），所以不需要返回

```cmake
macro(mac_name arg1 arg2 arg3)
    commands()
endmacro()
```

> 宏和函数另外一个区别是变量的使用。在函数中的变量是实际存在的，直接通过`VAR`的形式引用即可；而宏中的变量是在执行时替换得来，变量要通过`${VAR}`的形式引用

**查找文件**

可以使用`find_file()`查找文件，使用`find_library()`查找一个库文件，使用`find_path()`查找包含一个文件的目录，使用`find_program()`查找一个文件

```cmake
# 查找并返回指定文件的绝对路径，赋值给FIND_RESULT，使用NAMES指定多个可能的文件名
find_file(FIND_RESULT NAMES file_name1 file_name2)
# 可以使用PATHS或HINTS指定除默认外可能的查找路径
find_file(FIND_RESULT NAMES file_name1 file_name2 PATHS /usr/bin /home/me/bin)
```

```cmake
# 查找一个库文件的绝对路径，用法同理
find_library(FIND_RESULT NAMES lib_name1 lib_name2 PATHS /usr/lib home/me/lib)
```

```cmake
# 查找一个可执行文件的绝对路径，用法同理
find_program(FIND_RESULT NAMES bin_name1 bin_name2 PATHS /usr/bin home/me/bin)
```

```cmake
# 查找返回一个文件包含的路径
find_path(FIND_RESULT NAMES file_name1 file_name2 PATHS /home/me/files /usr/lib)
```

**显示消息**

可以使用`message()`显示一条信息

```cmake
# 显示的信息使用""双引号括起来，在此之前可以使用一个关键字指定信息的类型，比如FATAL_ERROR等
message(FATAL_ERROR "Fatal error occurred")
```

> 显示的信息有以下几类，不同类型的信息有不同的处理方法

| 信息类型 | 处理方式 |
| :-: | :-: |
| `FATAL_ERROR` | 致命错误，CMake停止正在执行的所有任务 |
| `SEND_ERROR` | 错误触发，CMake继续运行，跳过失败的过程 |
| `WARNING` | 显示警告信息，CMake继续执行 |
| `AUTHOR_WARNING` | 显示警告信息，CMake继续执行 |
| `NOTICE` | 通过标准错误显示的信息 |
| `STATUS` | **最常用**，显示一条任意信息 |
| `VERBOSE` | 一些在通常情况下没有特殊指定就不需要显示的信息，一般是一些细节信息 |
| `DEBUG` | 提供给本软件开发者和维护者看的信息 |
| `TRACE` | 非常详细的信息 |

**指定选项**

选项一般写在CMakeLists.txt靠前的位置，用于为用户提供可配置的选项，使用`option()`进行指定，用户可以设置这些选项的开关（在使用`ccmake`时也会在图形界面中显示）

```cmake
option(USE_FAST_ALGORITHM "Use the optimized algorithm" OFF)
```

**数学运算**

可以使用`math()`进行一些数学运算。在CMake中所有整型变量的长度都是64位

```cmake
# 第一个参数为EXPR关键字，计算表达式使用""括起来，计算的最终结果存储在表达式前的变量中。最终使用OUTPUT_FORMAT指定输出格式，可以是DECIMAL十进制或HEXADECIMAL十六进制
math(EXPR calc_result "3 * ( 6 + 0x0A )" OUTPUT_FORMAT DECIMAL)
```

**字符串操作**

字符串操作使用命令`string()`，有非常多的功能

`string()`中的一些基本命令如下

```cmake
# 添加到字符串末尾
string(APPEND MY_STRING word1 word2)

# 添加到字符串开头
string(PREPEND MY_STRING word1 word2)

# 连接并输出到一个字符串变量
string(CONCAT OUT_STRING word1 word2)

# 将所有输入连接，连接处字符使用glue_word
string(JOIN glue_word OUT_STRING word1 word2)

# 将一个字符串转为小写
string(TOLOWER MY_STRING OUT_STRING)

# 将一个字符串转为大写
string(TOUPPER MY_STRING OUT_STRING)

# 计算一个字符串的长度并输出到一个变量
string(LENGTH MY_STRING OUT_VAR)

# 截取从str_begin开始的str_length个字符
string(SUBSTRING MY_STRING str_begin str_length OUT_STRING)

# 删除一个字符串开头和结尾的空格
string(STRIP MY_STRING OUT_STRING)

# 将一个字符串重复count次
string(REPEAT MY_STRING count OUT_STRING)
```

使用`string()`进行**查找替换**的命令如下

```cmake
# 在一个字符串里面查找子字符串首次出现的位置，未找到返回-1，可以在最后添加REVERSE指定查找最后一次出现的位置
string(FIND string substring OUT_VAR)

# 将所有输入字符串中的match_string替换为replace_string并输出到一个变量
string(REPLACE match_string replace_string OUT_STRING input1 input2)

# 使用正则表达式reg匹配所有输入字符串并输出（匹配单次）
string(REGEX MATCH reg OUT_STRING input1 input2)

# 使用正则表达式reg匹配所有输入字符串并输出为列表（匹配所有）
string(REGEX MATCHALL reg OUT_STRING input1 input2)

# 将所有指定表达式匹配处替换为replace表达式
string(REGEX REPLACE reg replace OUT_STRING input1 input2)
```

字符串**比较**的命令如下

```cmake
# 比较两个字符串并将True或False输出到一个变量
string(COMPARE LESS_EQUAL MY_STRING1 MY_STRING2 OUT_VAR)

# 比较关键字还有GREATER_EQUAL LESS GREATER EQUAL NOTEQUAL
```

计算字符串**哈希（Hash）**

```cmake
string(MD5 OUT_VAR input)

# 可用的哈希算法还有SHA1 SHA224 SHA256 SHA384 SHA512 SHA3_224等
```

字符串**生成**

```cmake
# 返回一个随机字符串，使用LENGTH指定长度，使用ALPHABET指定字符集，使用RANDOMSEED指定使用的随机种子
string(RANDOM LENGTH 10 ALPHABET 0123456789ABCDEF RAMDOMSEED seed OUT_STRING)

# 生成日期字符串，可以使用UTC指定使用UTC时间，格式参考shell的date
string(TIMESTAMP %Y-%b-%m-%d-%H-%M-%S OUT_STRING UTC)
```

**包含文件**

```cmake
# 通过include可以包含一个文件。可以在文件名之后加上OPTIONAL说明是一个可有可无的文件，文件不存在时CMake不会报错。
include(file OPTIONAL)
```

**文件处理**

```cmake
# 读取文件，从filename文件读取，从第15字节开始读取20字节，并存入变量
file(READ filename MY_VAR OFFSET 15 LIMIT 20)
# 仅读取文件中的字符串，限制读取10个字节，可以使用正则表达式过滤
file(STRINGS filename MY_VAR LIMIT_INPUT 10 REGEX reg)

# 计算文件哈希
file(HASH filename MY_VAR)

# 获取文件时间戳
file(TIMESTAMP filename MY_VAR)

# 写文件
file(WRITE filename my_content)

# 在文件末尾添加
file(APPEND filename my_content)

# Touch文件，更新访问时间戳
file(TOUCH filename)
file(TOUCH_NOCREATE filename)

# 创建目录
file(MAKE_DIRECTORY dir1 dir2)

# 删除文件或目录
file(REMOVE filename)
file(REMOVE_RECURSE filename)

# 更改文件名
file(RENAME oldname newname)

# 复制文件
file(COPY_FILE oldname newname)
file(COPY filename DESTINATION dir)
file(INSTALL filename DESTINATION dir)

# 获取文件大小
file(SIZE filename MY_VAR)
```


### 5.3.2 工程相关命令

**指定最小的CMake版本**

```cmake
cmake_minimum_required(VERSION 3.10)
```

**指定工程名**

```cmake
# 版本号可以省略，之后使用内建变量指定
project(hello VERSION 1.10)
```

**二进制文件编译链接操作相关**

```cmake
# 添加要构建的可执行文件名，可以另外定义RUNTIME_OUTPUT_DIRECTORY指定生成可执行文件的路径
add_executable(exe_name src1 src2)

# 添加要构建的库文件名，注意最后生成的库文件名为lib_name.lib或liblib_name.a，可以指定生成的库文件类型为STATIC（静态链接库），SHARED（共享动态链接库），MODULE等。
# 如果将内建变量BUILD_SHARED_LIBS配置为ON，那么会默认构建动态链接库。可以通过ARCHIVE_OUTPUT_DIRECTORY指定库文件输出路径，LIBRARY_OUTPUT_DIRECTORY指定中间.o文件输出路径
add_library(lib_name STATIC src1 src2)

# 如果只想创建单个.o库文件，可以使用OBJECT指定
add_library(lib_name OBJECT src1 src2)
# 想要引用.o库文件需要使用以下格式，也可以使用下面介绍的target_link_libraries()
add_executable(exe_name $<TARGET_OBJECTS:libname>)
# 还可以使用IMPORTED从别处指定现成的库，路径可以通过IMPORTED_LOCATION指定，也可以使用OBJECT指定库文件类型是.o
add_library(lib_name STATIC IMPORTED)

# 将一个目标文件和其他库文件（可以是库文件的名称，实际文件名或完整路径）链接，构建的target必须是已经使用add_library()或add_executable()构建完成的目标文件
target_link_libraries(target_name lib_1 lib_2)
target_link_libraries(target_name PUBLIC lib_1 lib_2)

# 指定顶层目标文件的依赖关系
add_dependencies(target_name target1 target2)
```

**宏定义相关**

```cmake
# 指定全局宏，使用VAR=value的格式指定
add_compile_definitions(ALGO_TYPE=fftw EXEC_ROUNDS=3)

# 指定一个特定目标的宏，可以是PUBLIC，PRIVATE或INTERFACE指定生效范围
target_compile_definitions(target_name PUBLIC MY_DEF)
target_compile_definitions(target_name PUBLIC MY_DEF=value)
```

> CMake中的`PUBLIC`，`PRIVATE`以及`INTERFACE`关键字在`target_*()`命令中常用。众所周知想要调用一个库文件，需要提供对应的**头文件**。而在一个实际的工程中，库与库之间的头文件往往有多层包含，这就引出了层与层包含之间的关系。
>
> 如果使用`PRIVATE`关键字，一个库文件（设libB）的.h头文件引用了另一个库文件（设libA）的头文件，假设在上面还有库（libC）引用这个库（libB）文件，那么在libC中是不能使用libA的函数的，因为在头文件中没有包含，相当于libA是libB的私有库，libC不知道libA的存在
>
> 如果使用`INTERFACE`关键字则恰恰相反，libA可以使用libC的功能而libB只能使用libA一部分如结构体。这实质上是通过libB的头文件向libC提供libA的功能，而libB本身不使用libA中的函数。相当于跳过libB
>
> 如果使用`PUBLIC`关键字就是最通常的情况，相当于以上两种情况的结合，头文件之间是递归包含，libC和libB都可以使用libA中的函数，而libC还可以使用libB中的函数

**路径相关**

```cmake
# 向一个目标文件添加头文件查找的目录（按顺序查找），使用BEFORE在开头添加（查找优先级最高）
target_include_directories(target_name AFTER PUBLIC include/dir)

# 查找一个目录下的所有源码文件并存入变量
aux_source_directory(src/dir OUT_VAR)

# 指定一个构建过程使用的源码目录以及生成二进制文件的目录。不指定默认都是使用当前目录
add_subdirectory(src/dir bin/dir)
```

**编译、链接选项相关**

```cmake
# 指定编译时要添加的命令行参数
add_compile_options(-Wall -O3)

# 指定特定目标文件编译选项，可以添加BEFORE关键字指定在开头添加
target_compile_options(target_name BEFORE PUBLIC -Wall)

# 指定链接器的命令行参数
# 注意该命令不能用于.o文件，因为.o文件不会使用到链接器
add_link_options(-Wl)
```

**属性相关**

在CMake中，可以设置工程全局、目录、目标文件、源文件、测试、变量以及缓存变量对应的属性

```cmake
# 定义一个属性，其中INHERITED是可选项，表示在引用一个未设置的属性时直接自动继承上一级对象的属性。DOCS用于指定描述，接字符串
define_property(GLOBAL PROPERTY property_name INHERITED BRIEF_DOCS "Brief doc" FULL_DOCS "Full doc")

# 在一个对象上设置一个属性，可以是GLOBAL，DIRECTORY，TARGET，SOURCE，INSTALL，TEST，CACHE。除GLOBAL外所有对象的属性设定都要指定具体的对象名。APPEND为可选项，指在已有属性之后添加
set_property(GLOBAL PROPERTY property_name APPEND value1 value2)
set_property(DIRECTORY dir_name PROPERTY property_name value1 value2)

# 获取一个属性。最后的SET是可选项，结果返回True或False，用于检查一个属性是否已经设置
# 除SET以外还可以使用DEFINED，用于检查一个属性是否已经定义。如果是BRIEF_DOCS或FULL_DOCS就会返回属性的对应描述
get_property(MY_VAR TARGET target_name PROPERTY property_name SET)

# 设定源代码文件的属性
set_source_files_properties(src_file PROPERTIES property1 value1 property2 value2)
# 同时设定一些源代码路径的属性
set_source_files_properties(src_file DIRECTORY src_dir1 PROPERTIES property1 value1 property2 value2)
# 同时设定包含指定目标文件的目录属性
set_source_files_properties(src_file TARGET_DIRECTORY target1 PROPERTIES property1 value1 property2 value2)

# 获取源文件的属性
get_source_file_property(MY_VAR filename property_name)
get_source_file_property(MY_VAR filename DIRECTORY src_dir property_name)
get_source_file_property(MY_VAR filename TARGET_DIRECTORY target property_name)

# 设置目标文件的属性
set_target_properties(target1 target2 PROPERTIES property1 value1 property2 value2)

# 获取目标文件的属性
get_target_property(MY_VAR target_name property_name)

# 设置当前目录的属性以及子目录的属性
set_directory_properties(PROPERTIES property1 value1 property2 value2)

# 获取当前目录属性
get_directory_property(MY_VAR property_name)
# 指定目录
get_directory_property(MY_VAR DIRECTORY dir_name property_name)
```

**自定义目标与命令**

```cmake
# 使用自定义命令创建一个文件，不依赖于其他文件
add_custom_command(OUTPUT output_file COMMAND cmd1 ARGS arg1 arg2 COMMAND cmd2 ARGS arg1 arg2)
# 可以使用MAIN_DEPENDENCY，DEPENDS指定依赖
add_custom_command(OUTPUT output_file COMMAND cmd1 ARGS arg1 arg2 MAIN_DEPENDENCY depend DEPENDENCY depend1 depend2)

# 使用以下命令可以创建一个无依赖目标，在每一次引用相应目标时都会执行对应命令行，相当于Makefile中的伪目标。ALL是可选参数，使用ALL可以强制每一次执行构建时都运行指定命令行
add_custom_target(target_name ALL cmd1 arg1 COMMAND cmd2 arg2)
```

**安装相关**

文件的安装使用`install()`命令，详细用法参考之前提供的参考教程

**测试相关**

```cmake
# 添加一个测试，可以使用WORKING_DIRECTORY指定运行测试的工作目录
add_test(NAME test_name COMMAND run_command)

# 使能测试
enable_testing()
```


## 5.4 常用内建变量（Variables）




## 6 元构建系统之autotools