# Make原理和使用

基于GNU Make

http://www.gnu.org/software/make/

主要参考GNU Make官方文档

## 1 简介

## 1.1 Make是什么

Make的思想起源于软件工程，随着编译技术的发展，以及软件本身的进化，一个软件的源文件结构不断变得复杂，程序员发现面对成千上万的源文件，手动编译一个程序变得不再现实，于是寻求一种可以根据规则自动进行文件处理与生成的工具。这就是**Make**

Make分为很多种，它们几乎应用在目前所有的开发环境中，已经成为目前计算机软件的重要基础设施。除目前最常用的**GNU Make**外，BSD也拥有遵循自己开源协议的**BSD Make**，常用的C++应用框架Qt拥有**QMake**，Ruby有自己的实现**Rake**，微软VS有自己集成的make工具，GNU Make有一个加强版**Remake**，还有跨平台的makefile生成工具**CMake**等。我们在一般的IDE中接触不到make，因为IDE往往会隐藏底层的构建过程

Make本质就是根据一系列规则判断文件依赖，之后通过一系列处理步骤，生成或更新这些文件，并且一般支持自动推导依赖，以及可以根据文件的时间戳判断哪些文件需要更新（假设源文件时间戳比目标文件新，那么就代表这个目标文件需要更新）

Make几乎可以算作是通用的文件处理脚本工具，Makefile就是它的脚本。在Linux、BSD等类UNIX环境中各种强大工具的支撑下，它不仅可以用于各种语言编写的程序编译与构建，甚至可以用于图片和音频的批处理


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

**第一个阶段**make会首先预处理Makefile，将Makefile通过`include`包含的文件拷贝到此处，之后展开所有的变量，显式规则（explicit rules）以及隐式规则（implicit rules），并构建文件依赖树。

文件包含用法如下

```makefile
include share.mk
```

**第二个阶段**make会判断哪些文件需要更新，并运行相应的构建方法（recipes）更新文件

对于这两个阶段的理解非常重要，之后有关变量的展开和这两个过程息息相关


## 2.2 Makefile的解析过程

> 这里首先引入有关于变量展开的几个概念：
>
> **立即展开（immediate）** 指的是该变量在第1阶段就得到展开。此时只是进行文件依赖的推导，并未执行实际的操作
>
> **延迟展开（deferred）** 指的是该变量在第2阶段才被展开，或者在一个立即（immediate）的上下文中被引用而被强制展开

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
| `imm = def` | 递归展开变量，也是其他一些make软件支持的赋值方法。这种赋值**会将所有变量层层递归展开**，比如`TEST = hello` `ME = ${TEST}`，那么最后`TEST`和`ME`都是`hello`。**缺点**是容易导致无限递归，并且如果使用了函数，这些函数每次都会执行，拖慢速度 |
| `imm := imm` | 一般变量，克服了以上赋值方法的缺点，不允许递归。 |
| `imm ::= imm` | 同`:=`，是POSIX标准规定的 |
| `imm ?= def` |  |
| `imm += def imm += imm` |  |
| `imm != imm` |  |


### 3.1.2 自动变量（Automatic Variables）




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

这只在大型工程中有少量应用，尤其是使用`#include`调用了大量库的情况下

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

隐式规则和静态规则比较相似，和之前所有的规则相对，前文所述的规则都是显式规则


## 3.4 构建操作（Recipes）

有关recipe的写法

## 3.5 条件判断


## 3.6 使用自带函数


## 3.7 示例

## 4 用于生成Makefile的工具之：CMake

## 5 用于生成Makefile的工具之：automake和autoconf

## 6 BSD Make

FreeBSD拥有自己的一套完整的工具链。它使用BSD Make作为默认make工具，GNU Make在FreeBSD仓库中被称为gmake