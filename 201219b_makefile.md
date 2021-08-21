# Make原理和使用

基于GNU Make，涵盖现代高级工具如CMake，autoconf和automake，Ninja的使用

http://www.gnu.org/software/make/

主要参考GNU Make官方文档

## 1 简介

## 1.1 Make是什么

Make的思想起源于软件工程，随着编译技术的发展，以及软件本身的进化，一个软件的源文件结构不断变得复杂，程序员发现面对成千上万多种多样的源文件，手动编译一个程序变得不再现实，于是寻求一种可以根据规则自动进行文件处理的工具。这就是**Make**

Make分为很多种，**它们几乎应用在目前所有的开发环境中，已经成为目前计算机软件的重要基础设施，学习Make的原理非常重要，这和多文件大型工程的开发与管理密切相关**。除目前最常用的**GNU Make**外，BSD也拥有遵循自己开源协议的**BSD Make**，常用的C++应用框架Qt拥有**QMake**，Ruby有自己的实现**Rake**，微软的VS有**msbuild.exe**，GNU Make有一个加强版**Remake**，还有常用的makefile工具**automake**和**autoconf**，近几年有流行的**Ninja**，还有强大的跨平台工具**CMake**等。我们在一般的IDE中接触不到make，因为IDE为方便用户，往往会隐藏底层的构建过程

Make本质就是根据给定规则推导判断文件依赖，之后通过一系列处理步骤，生成或更新这些文件，一般根据文件的时间戳判断哪些文件需要更新（假设源文件时间戳比目标文件新，那么就代表这个目标文件需要更新）

Make几乎可以算作是通用的文件处理脚本工具，Makefile就是它的脚本。在Linux、BSD等类UNIX环境中各种强大工具的支撑下，它不仅可以用于各种语言编写的程序编译与构建，甚至可以用于图片和音频文件的批处理


## 1.2 GNU GCC工具链

GCC编译一个程序的过程分为**预处理、编译、汇编、链接**4大步骤

在我们日常编写一个单源码程序（比如一个控制台程序）时，我们只要在文件中包含我们需要的标准库头文件即可。执行`gcc test.c -o test`会自动完成这一系列所需过程

但是在实际情况中，尤其是在大型工程中，这种情况会变得异常复杂。一方面，一些公司出于商业保护、专利保护、copyright等原因，或者一些软件作者单纯不想开放他的源码（这是可以理解的，比如他们不想使自己的成果在未经允许的情况下被他人修改后利用或随意进行二次发布），**他们往往只会提供一个闭源的二进制库以及一个头文件，而不是完整的源代码**。这些闭源代码只能通过**链接**应用到我们的程序中，反汇编是破译这些程序的唯一方法。另外，为了减少程序的重复，操作系统提供了动态库加载技术，很多程序会使用共享的动态链接库。并且在实际中头文件和源代码的关系也是错综复杂的，为方便大型工程的管理以及简化开发（使用一个库，直接引用一个头文件即可，无需再次逐个声明函数，这个头文件同时被库和应用程序使用），实际工程中都将头文件（声明）和源文件（实现）分开

比如，一个软件作者可以写一个库，文件为`test1.c`、`test2.c`以及头文件`test.h`，经过编译汇编得到可重定位文件`test1.o`和`test2.o`，再使用`ar`打包变成库文件`test.a`，发布时只提供`test.h`以及`test.a`，使用时在编译最后阶段链接即可

预处理使用`cpp`，编译使用`gcc`，汇编使用`as`，链接使用`ld`。实际使用中这些程序都可以统一通过`gcc`调用，并且`gcc`会自动产生一些参数，比如`ld`所需的参数可以在被`gcc`调用时自动生成


## 2 Make执行流程

一些基础概念

## 2.1 两个阶段

Make的主要任务，主要是文件依赖的推导，以及自动调用文件构建命令

GNU Make的执行过程大致分为两个阶段（Phase）

**第一个阶段**make会首先预处理Makefile，将Makefile通过`include`包含的文件拷贝到此处，之后展开处于immediate上下文的所有的变量，对显式规则（explicit rules）以及隐式规则（implicit rules）进行解析，并构建文件依赖树。

文件包含用法如下，使用`include`关键字

```makefile
include share.mk
```

**第二个阶段**make会判断哪些文件需要更新，并运行相应的构建方法（recipes）更新文件

对于这两个阶段的理解非常重要，之后有关变量的展开和这两个过程息息相关


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

## 3.1 Makefile变量

变量的引用通过形如`${var}`或`$(var)`

以下`imm`和`def`指变量的类型（immediate或deferred）


### 3.1.1 变量的赋值

变量的赋值有以下几种

| 形式 | 解释 |
| :-: | :-: |
| `imm = def` | 递归展开变量，也是其他一些make软件支持的赋值方法。这种赋值**会将所有变量层层递归展开**。make首先会记录这些变量所有的上下文，在最终才会统一展开。比如`TEST = hello` `ME = ${TEST}`，那么最后`TEST`和`ME`都是`hello`。**缺点**是容易导致无限递归，并且如果使用了函数，这些函数每次都会执行，拖慢速度 |
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
# 将所有a替换成为b
OBJ = ${var:a=b}
```

替换后缀，使用通配符`%`

```makefile
# 将.c后缀替换成为.o
OBJ = ${var:%.c=%.o}
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

取消变量可以通过直接赋空值

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

在此之前先看[3.2 规则](201219b_makefile.md#32-规则Rule)

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

`targets`代表要生成的**目标文件名**，一般为1个也可以有多个；`prerequisites`代表依赖的文件，一般有多个；`recipe`代表构建方法，一般是shell命令，紧跟在下一行，**以制表符开头（也可通过`.RECIPEPREFIX`指定其他符号）**，也可以在同一行，使用`;`分隔

变量展开示意如下

```makefile
imm : imm
    def

imm : imm ; def
    def
```


### 3.2.2 依赖（prerequisites）类型

依赖分为两种，一种是如上文所说的**普通依赖（normal prerequisites）**。这种依赖的实质，就是当一个target目标文件有任何依赖（prerequisites）文件被更新，此时有依赖文件的时间戳比目标文件新，所以就代表目标文件需要被重新构建，运行对应recipe

还有第二种依赖，被称为**顺序依赖（order-only prerequisites）**

> 个人理解：事实上make中文件依赖的解析可以分为两种过程。一种是**自上向下**的过程，比如我们在运行`make all`时，此时由目标文件向依赖文件解析，如果某些依赖文件不存在，那么就运行对应的recipe创建，**这经常发生在第一次执行make时，是目标文件（此时可能不存在）导致的依赖文件的更改**。之后还有一个**自下向上**的过程，make会检查那些依赖文件的时间戳，如果它们比目标文件新就代表要对目标文件进行更新，**这经常发生在第一次执行make以后，用户更改了一些源文件，是依赖文件（一般已经存在）导致的目标文件的更改**

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
> 由于通配符在匹配文件失败时（如文件不存在），会直接将例如`*.c`作为文件名，所以尽量避免使用通配符，如下例，虽然`OBJ`变量最后会展开，但是在`.c`文件不存在时会发生异常

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

`.SECONDEXPANSION`解释：之前解释过make的执行过程分为两个阶段，第一个阶段会进行文件的读入，变量的展开以及依赖的分析；第二个阶段会执行文件操作。在第一个阶段中立即变量（immediate）只会得到一次展开。而使用`.SECONDEXPANSION`，在此之后的变量在两个阶段之间还会得到第二次展开

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
%.d: %.c
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

**实际应用中，建议不要使用隐式规则，因为这容易导致问题并且难以排查**

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
> 在一般的shell中，如果遇到`\`，不同上下文处理方法不同。如果`\`在双引号`""`上下文，那么shell会自动去除`\`以及之后的一个制表符。如果`\`不在引号上下文，那么shell会自动去除`\`以及之后的多个制表符。
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

make支持根据文件之间的依赖关系自动并行调用recipe，限制使用的线程数使用`make -jx`指定，如`make -j4`

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
| `$(patsubstr pattern,replacement,text)` | 可以使用`%`通配符。将`text`中所有匹配的`pattern`替换为`replacement`，示例`$(patsubstr %.c,%.o,test.c hello.c)`。和化简格式`$(var:.c=.o)`等价 |
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


## 4 用于生成Makefile的工具之CMake

CMake在默认情况下检查当前目录下的`CMakeLists.txt`作为输入

## 4.1 CMake简介

https://cmake.org/

CMake是一个跨平台的构建工具


## 5 用于生成Makefile的工具之automake和autoconf


## 6 现代构建系统之Ninja：初探

https://ninja-build.org/