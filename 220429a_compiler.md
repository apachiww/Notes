# ELF文件格式，链接器原理，编译原理

## 参考资料

《深入理解计算机系统》，Randal E. Bryant，David R. O'Hallaron

[耶鲁大学CS422讲义](src/210731a01/ELF_Format.pdf)

[FreeBSD ELF相关代码](https://cgit.freebsd.org/src/tree/sys?h=stable/13)。平台共用代码位于`sys/elf32`，`sys/elf64`。x86位于`x86/include/elf.h`，ARM位于`arm/include/elf.h`以及`arm64/include/elf.h`

## 0 序言

平时我们使用IDE开发一个程序，或者开发一个简单的控制台程序，基本不会意识到程序构建过程中链接的存在，也不会去关心二进制程序底层是如何运作的。例如使用C++配合Qt开发程序，在IDE窗口点击构建按钮，我们创建的大量源码文件以及头文件貌似自然而然就结合在一起成为了一个可执行文件，执行我们想要的功能

链接无处不在，大型工程的构建离不开链接（同样也离不开构建系统例如`Make`）。链接器方便了程序构建的模块化，开发者可以将不同功能的代码分开，降低代码耦合度，减轻管理维护负担，同时闭源代码的发布也成为可能。此外，在操作系统的支持下，共享库的动态链接机制也使得程序映像变得更小

## 1 CS422笔记：ELF文件结构

ELF文件格式由UNIX System Laboratories提出，作为ABI标准的一部分，后缀`.elf`，用以替代`a.out`等较老的二进制文件格式。Linux，FreeBSD等现代的类UNIX系统都广泛采用了这种文件格式，但是具体实现会略有不同

## 1.1 ELF文件的种类

ELF文件主要分为3种：**可重定位文件**（relocatable），**可执行文件**（executable）和**共享目标文件**（shared object）

ELF文件设计的目标主要有2个，一个是被工具链中的链接器`ld`读取并和其他文件链接，另一个是被操作系统的加载程序加载到内存中并被执行

此外，ELF文件适用于不同字长的硬件平台，从8位机到目前常见的64位机都可以使用。以下基于32位架构讲解


## 1.2 ELF文件结构概览

ELF文件结构如下（区块的顺序会有所不同，不一定是下面展示的那样）

![](images/220429a001.PNG)

> `ELF header`位于ELF文件开头，主要记录了ELF文件的结构，处理器架构，`Program header table`和`Section header table`在文件中的位置等基本信息
>
> **可重定位文件**一般有`Section header table`以及多个`Section`，`Section`是给链接器看的，其中可能包含机器指令，只读数据，`switch`跳转表，变量，重定位信息等内容。这些文件不一定有`Program header table`
>
> **可执行文件**一般有`Program header table`以及多个`Segment`，`Segment`是给操作系统加载器看的，告诉加载器如何在内存中创建一个进程映像，一个`Segment`可能由1个或多个链接过程中的`Section`组成。可执行文件不一定有`Section header table`
>
> **共享目标文件**一般会同时拥有`Section header table`和`Program header table`

FreeBSD中ELF32基本数据类型定义如下

```c
/*
 * ELF definitions common to all 32-bit architectures.
 */

typedef uint32_t	Elf32_Addr;
typedef uint16_t	Elf32_Half;
typedef uint32_t	Elf32_Off;
typedef int32_t		Elf32_Sword;
typedef uint32_t	Elf32_Word;
typedef uint64_t	Elf32_Lword;

typedef Elf32_Word	Elf32_Hashelt;

/* Non-standard class-dependent datatype used for abstraction. */
typedef Elf32_Word	Elf32_Size;
typedef Elf32_Sword	Elf32_Ssize;
```

> 其中`Elf32_Addr`为32位地址，`Elf32_Off`为32位地址偏移，`Elf32_Half`为无符号半字数据，`Elf32_Sword`为有符号单字数据，`Elf32_Word`为无符号单字数据，`Elf32_Lword`为无符号双字数据
>
> 在ELF32文件中数据一般是4字节对齐的，可以发现`Elf32_Half`总是连续偶数个出现


## 1.3 ELF文件头

FreeBSD中ELF头定义如下。取自`elf32.h`

```c
/*
 * ELF header.
 */

typedef struct {
	unsigned char	e_ident[EI_NIDENT];	/* File identification. */
	Elf32_Half	e_type;		/* File type. */
	Elf32_Half	e_machine;	/* Machine architecture. */
	Elf32_Word	e_version;	/* ELF format version. */
	Elf32_Addr	e_entry;	/* Entry point. */
	Elf32_Off	e_phoff;	/* Program header file offset. */
	Elf32_Off	e_shoff;	/* Section header file offset. */
	Elf32_Word	e_flags;	/* Architecture-specific flags. */
	Elf32_Half	e_ehsize;	/* Size of ELF header in bytes. */
	Elf32_Half	e_phentsize;	/* Size of program header entry. */
	Elf32_Half	e_phnum;	/* Number of program header entries. */
	Elf32_Half	e_shentsize;	/* Size of section header entry. */
	Elf32_Half	e_shnum;	/* Number of section header entries. */
	Elf32_Half	e_shstrndx;	/* Section name strings section. */
} Elf32_Ehdr;
```

`e_entry`表示程序入口的虚拟地址（没有入口则设为`0`），`e_ehsize`表示ELF头的大小

其中，`EI_NIDENT`定义为16（位于`sys/elf_common.h`）

```c
#define	EI_NIDENT	16	/* Size of e_ident array. */
```

### 1.3.1 ELF Identification

ELF32文件使用长度16字节的`e_ident`表示一些架构无关的信息，为Identification，其中前7字节定义如下。之后需要加上占位符`EI_PAD`

| 下标 | 名称 | 作用 |
| :-: | :-: | :-: |
| `e_ident[0]` | `EI_MAG0` | 魔法数`0x7F` |
| `e_ident[1]` | `EI_MAG1` | 魔法数`0x45`（`E`） |
| `e_ident[2]` | `EI_MAG2` | 魔法数`0x4C`（`L`） |
| `e_ident[3]` | `EI_MAG3` | 魔法数`0x46`（`F`） |
| `e_ident[4]` | `EI_CLASS` | 表示机器字长，`0`表示`ELFCLASSNONE`无效，`1`表示`ELFCLASS32`为32位目标文件，`2`表示`ELFCLASS64`为64位目标文件 |
| `e_ident[5]` | `EI_DATA` | 表大小端，`0`表示`ELFDATANONE`无效，`1`表示`ELFDATA2LSB`小端（Little-Endian），`2`表示`ELFDATA2MSB`大端（Big-Endian） |
| `e_ident[6]` | `EI_VERSION` | 文件版本，值和`e_version`相同，只能为`1`（`EV_CURRENT`） |

FreeBSD中定义如下，添加了几个变量

```c
#define	EI_MAG0		0	/* Magic number, byte 0. */
#define	EI_MAG1		1	/* Magic number, byte 1. */
#define	EI_MAG2		2	/* Magic number, byte 2. */
#define	EI_MAG3		3	/* Magic number, byte 3. */
#define	EI_CLASS	4	/* Class of machine. */
#define	EI_DATA		5	/* Data format. */
#define	EI_VERSION	6	/* ELF format version. */
#define	EI_OSABI	7	/* Operating system / ABI identification */
#define	EI_ABIVERSION	8	/* ABI version */
#define	OLD_EI_BRAND	8	/* Start of architecture identification. */
#define	EI_PAD		9	/* Start of padding (per SVR4 ABI). */
```


### 1.3.2 文件类型

`e_type`表示文件的类型，是重定位文件，可执行文件还是共享目标文件。可以取以下值

| 名称 | 值 | 含义 |
| :-: | :-: | :-: |
| `ET_NONE` | `0x0000` | 无效 |
| `ET_REL` | `0x0001` | 可重定位文件 |
| `ET_EXEC` | `0x0002` | 可执行文件 |
| `ET_DYN` | `0x0003` | 共享目标文件 |
| `ET_CORE` | `0x0004` | 核心文件。保留，没有明确定义该种文件格式 |
| `ET_LOPROC` | `0xFF00` |  |
| `ET_HIPROC` | `0xFFFF` |  |

FreeBSD中定义如下

```c
/* Values for e_type. */
#define	ET_NONE		0	/* Unknown type. */
#define	ET_REL		1	/* Relocatable. */
#define	ET_EXEC		2	/* Executable. */
#define	ET_DYN		3	/* Shared object. */
#define	ET_CORE		4	/* Core file. */
#define	ET_LOOS		0xfe00	/* First operating system specific. */
#define	ET_HIOS		0xfeff	/* Last operating system-specific. */
#define	ET_LOPROC	0xff00	/* First processor-specific. */
#define	ET_HIPROC	0xffff	/* Last processor-specific. */
```


### 1.3.3 机器类型

`e_machine`指定机器指令集类型

| 名称 | 值 | 含义 |
| :-: | :-: | :-: |
| `EM_NONE` | `0` | 无效 |
| `EM_SPARC` | `2` | SPARC |
| `EM_386` | `3` | i386 |
| `EM_68K` | `4` | MC68000 |
| `EM_MIPS` | `8` | MIPS RS3000 |

常见的CPU定义如下

```c
/* Values for e_machine. */
#define	EM_NONE		0	/* Unknown machine. */
#define	EM_SPARC	2	/* Sun SPARC. */
#define	EM_386		3	/* Intel i386. */
#define	EM_68K		4	/* Motorola 68000. */
#define	EM_MIPS		8	/* MIPS R3000 Big-Endian only. */
#define	EM_MIPS_RS3_LE	10	/* MIPS R3000 Little-Endian. */
#define	EM_PARISC	15	/* HP PA-RISC. */
#define	EM_SPARC32PLUS	18	/* SPARC v8plus. */
#define	EM_PPC		20	/* PowerPC 32-bit. */
#define	EM_PPC64	21	/* PowerPC 64-bit. */
#define	EM_ARM		40	/* ARM. */
#define	EM_SPARCV9	43	/* SPARC v9 64-bit. */
#define	EM_IA_64	50	/* Intel IA-64 Processor. */
#define	EM_X86_64	62	/* Advanced Micro Devices x86-64 */
#define	EM_AMD64	EM_X86_64	/* Advanced Micro Devices x86-64 (compat) */
#define	EM_AVR		83	/* Atmel AVR 8-bit microcontroller. */
#define	EM_XTENSA	94	/* Tensilica Xtensa Architecture. */
#define	EM_MSP430	105	/* Texas Instruments embedded microcontroller msp430. */
#define	EM_BLACKFIN	106	/* Analog Devices Blackfin (DSP) processor. */
#define	EM_SEP		108	/* Sharp embedded microprocessor. */
#define	EM_AARCH64	183	/* AArch64 (64-bit ARM) */
#define	EM_RISCV	243	/* RISC-V */
```


### 1.3.4 Header Table相关

`e_phoff`和`e_shoff`分别表示`Program header table`和`Section header table`在ELF文件中的偏移

`e_phnum`和`e_shnum`分别表示两种表包含的Entry数量，如果没有就为`0`

`e_phentsize`和`e_shentsize`分别表示两种表中每一个Entry的大小（和`num`相乘就是表的大小）

`e_shstrndex`表示`Section header table`中指向`section name string table`的入口项，该表用于存储所有的`Section`名称。如果没有该表那么该变量赋值为`SHN_UNDEF`（为`0`）

```c
#define	SHN_UNDEF	     0		/* Undefined, missing, irrelevant. */
```


### 1.3.5 机器特性

`e_flags`存储特定CPU架构的相关信息，只在部分RISC平台如ARM，MIPS，PowerPC，RISC-V，SPARC下有定义，i386以及AMD64下该变量为`0`

部分RISC-V代码如下

```c
/**
 * e_flags
 */
#define	EF_RISCV_RVC		0x00000001
#define	EF_RISCV_FLOAT_ABI_MASK	0x00000006
#define	EF_RISCV_FLOAT_ABI_SOFT	0x00000000
#define	EF_RISCV_FLOAT_ABI_SINGLE 0x000002
#define	EF_RISCV_FLOAT_ABI_DOUBLE 0x000004
#define	EF_RISCV_FLOAT_ABI_QUAD	0x00000006
#define	EF_RISCV_RVE		0x00000008
#define	EF_RISCV_TSO		0x00000010
```


## 1.4 Sections

Section是目标文件的基本组成部分。每一个Section在`Section header table`中只有1个header描述它，并且不是所有header都会对应1个Section。一个Section在文件中永远是连续的，且各自之间不能重叠。目标文件中可能有一些空间没有被利用，这些空间称之为`inactive space`


### 1.4.1 Section头

`Section header table`中每一个入口（每一个项）都是一个结构体，存储了一个Section的名称（在`section name string table`中的下标），类型，在内存中的地址，在文件中的偏移、大小等等必要信息，定义如下

```c
/*
 * Section header.
 */

typedef struct {
	Elf32_Word	sh_name;	/* Section name (index into the
					   section header string table). */
	Elf32_Word	sh_type;	/* Section type. */
	Elf32_Word	sh_flags;	/* Section flags. */
	Elf32_Addr	sh_addr;	/* Address in memory image. */
	Elf32_Off	sh_offset;	/* Offset in file. */
	Elf32_Word	sh_size;	/* Size in bytes. */
	Elf32_Word	sh_link;	/* Index of a related section. */
	Elf32_Word	sh_info;	/* Depends on section type. */
	Elf32_Word	sh_addralign;	/* Alignment in bytes. */
	Elf32_Word	sh_entsize;	/* Size of each entry in section. */
} Elf32_Shdr;
```

> `sh_name`为该Section的名称，其值为`String table`的下标。`String table`位置由一个特殊的header指定，这个header在`Section header table`中的下标由ELF头的`e_shstrndex`指定。字符串表示例如下

![](images/220429a002.PNG)

通过下标引用字符串得到的结果如下

![](images/220429a003.PNG)

> 字符串表下标从0开始，`sh_name`一般表示字符串中第1个字符在表格中的位置（也可以不是第1个字符）。每一个字符串以`\0`结尾。引用下标`0`得到`none`，引用其他`\0`所在下标得到空字符串。
>
> 同一个字符串可以被引用多次，也可能未被引用


### 1.4.2


## 1. 实例分析

使用`readelf`，`objdump`以及16进制编辑器对目标文件进行分析


## 2 CSAPP第7章：链接

## 2.1 链接基本概念

### 2.1.1 编译器基本工作流程

我们平时使用GCC编译一个程序（`gcc main.c -o test`），事实上要经过**预处理器**、**编译器**、**汇编器**以及**链接器**共4个工具的处理，这4种工具分别对应`cpp`，`cc`，`as`以及`ld`。我们使用的`gcc`命令事实上不是编译器本体，只是一个外壳，用来调用上述的四种工具。像`gcc`这样的命令被称为**驱动器（driver）**

> 其中，预处理器`cpp`处理源码中的宏以及文件包含，输出`.i`预处理后的源文件
>
> 之后编译器`cc`将源码文件编译成为ascii码格式的`.s`汇编文件，其中存储了之后构建二进制文件所需的汇编代码，符号，常量等
>
> 汇编器`as`会将汇编代码文件`.s`翻译成为二进制的`.o`可重定位目标文件，此时的`.o`文件是可以直接被计算机CPU识别的二进制文件。多个`.o`文件可以使用`ar`打包成为一个`.a`库文件（此外还可以选择生成动态链接库等格式）
>
> 最后如果是使用静态链接，就需要使用到链接器`ld`。`ld`会将多个`.o`可重定位目标文件链接成为一个可执行文件。通过shell执行该文件时会调用操作系统的加载器，将可执行文件加载到内存中并运行
>
> 运行时动态链接使用`.so`共享目标文件格式，由操作系统加载到内存并链接


### 2.1.2 目标文件

在Linux下的目标文件使用ELF（`.elf`）（Executable and Linkable Format）格式，尽管实际文件格式的定义有所不同。链接这些目标文件就是链接器的根本任务

> 3种目标文件如下：
>
> **可重定位目标文件**：只能使用**静态链接**的方式应用到程序中，一般为`.o`文件，可以使用`ar`打包成为一个`.a`库文件
>
> **可执行目标文件**：可以直接被操作系统加载器加载到内存中执行的文件
>
> **共享目标文件**：可以在程序被加载或执行时动态地加载到内存中并链接的文件，一般为`.so`后缀

不同机器、不同操作系统的目标文件格式是不同的。同样是在x86平台，Windows下的`.exe`和`.dll`放到Linux环境下当然是不能直接使用的

也是由于以上原因，在Linux下会出现`wine`用于模拟Windows的运行环境（当然wine远不止二进制兼容），FreeBSD会提供针对Linux的ABI兼容选项，而Windows下会有`mingw`和`msys2`这样的第三方类Unix环境出现


## 2.2 目标文件结构

ELF文件可以看作一个映像，其中主要包含了程序运行所需的数据和指令，ELF文件的格式大致如下

![](images/210731a001.png)


### 2.2.1 ELF头

ELF头由一个16字节的序列开始。这个16字节的序列会给出目标机器的字长以及字节序（大小端）等等信息

在这16字节之后都是一些基本信息，包括**ELF头大小**，**文件类型（可重定位、可执行、可共享）**，**机器类型（使用的ISA）**，**节头部表的偏移地址**，以及**节头部表中条目大小和数量**

节头部表一般位于ELF文件结尾，其中每一项（一个Entry）都用于描述不同节（Section）的位置和大小


### 2.2.2 节（Section）

ELF文件中的节依照存储数据的类型分为很多种

> `.text`：程序的二进制机器代码，最重要的部分之一
>
> `.rodata`：只读数据，比如在`printf()`中使用到的字符串常量，以及`switch`语句中使用到的跳转表等（很多CPU都支持`switch`专用的跳转指令）
>
> `.data`：**已经初始化的全局、静态变量**，在ELF文件中占有实际空间
>
> `.bss`：**未初始化或初始化为0的全局、静态变量**。这里面的数据仅仅是各个变量的占位符，这些变量在ELF文件中不会占有实际的数据空间，直到运行时才会分配空间。区分`.data`和`.bss`是为了提高存储效率。运行时的**局部变量**存储于**栈**中所以不会出现在`.data`和`.bss`中
>
> `.symtab`：符号表，最重要的部分之一，用于存储在程序中定义、引用的**函数**以及**全局变量**的信息。**不包含局部变量**
>
> `.rel.text`：重定位信息（`rel`就是relocation的缩写），位置列表。可以理解为全局变量以及函数的地址，在重定位时需要修改这些地址。局部函数由于一般采用相对地址跳转所以不修改
>
> `.rel.data`：重定位信息，存储当前模块引用或定义的全局变量的信息
>
> `.debug`：调试符号表，存储程序中各种变量以及类型定义，包括局部变量，以及在本模块定义或引用的全局变量。另外还有原始的C源文件，用于调试时代码的定位
>
> `.line`：代码映射列表，只有使用`-g`选项时可用。存储`.debug`中C源文件代码和`.text`中机器码的映射，C代码的调试依赖于`.line`
>
> `.strtab`：字符串表，存储了`.symtab`以及`.debug`中的符号表以及节名。每一个字符串以null（0x00）结尾


### 2.2.3 符号与符号表

每一个可重定位模块都有符号表以及对应存储的符号

> 符号分为以下3种：
>
> **全局链接器符号**：非`static`定义的函数和全局变量，在本模块定义并可以被其他模块引用
>
> **外部符号**：`extern`声明的函数和全局变量，在其他模块定义并被本模块引用
>
> **局部符号（本地链接器符号）**：使用`static`定义的函数和全局变量，只在本模块定义与引用，其他模块无法访问