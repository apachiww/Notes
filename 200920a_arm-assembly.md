# ARM汇编，Application Level and System Level(ARMv7 Cortex-A)

## 环境

OS： Debian 10 (buster) armv7l on Linux Deploy

Kernel version： 3.4.0

CPU： Qualcomm MSM8974PRO-AC (SnapDragon 801)

## GDB使用方法

+ **基本使用方法**

    ```shell
    gdb <可执行文件名>
    ```

## 寄存器介绍

使用ARMv7指令集的处理器都是32位处理器，部分带大地址扩展

+ **数据类型**

    **Byte**：字节，8bit，在arm指令助记符后加b(unsigned byte)或sb(signed byte)

    **Halfword**：半字，16bit，h或sh

    **Word**：字，不加后缀

+ **大小端**

    ARMv7可以通过CPSR设置**Little Endian**或**Big Endian**

+ **通用寄存器**

    | 名称 | 类型 | 注释 |  
    | :-: | :-: | :-: |
    | R0 | 通用 | 习惯上一般用于作为Accumulator，或者函数调用的结果存储，以及函数的第一个参数 |
    | R1 | 通用 | 函数调用第二个参数 |
    | R2 | 通用 | 函数调用第三个参数 |
    | R3 | 通用 | 函数调用第四个参数 |
    | R4 | 通用 |  |
    | R5 | 通用 |  |
    | R6 | 通用 |  |
    | R7 | 通用 | 存储Syscall Number |
    | R8 | 通用 |  |
    | R9 | 通用 |  |
    | R10 | 通用 |  |
    | R11(FP) | 通用 | =Frame Pointer |
    | R12(IP) | 通用 | =Intra Procedure Call |
    | R13(SP) | 堆栈寄存器 | =Stack Pointer |
    | R14(LR) | 连接寄存器 | =Link Register |
    | R15(PC) | 程序计数器 | =Program Counter |

+ **CPSR寄存器定义**

    | bit | 31 | 30 | 29 | 28 | 27 | [26:25] | 24 | [23:20] | [19:16] | [15:10] | 9 | 8 | 7 | 6 | 5 | [4:0] |
    | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
    | 符号 | N | Z | C | V | Q | IT[1:0] | J | Reserved | GE[3:0] | IT[7:2] | E | A | I | F | T | M[4:0] |
    | 注释 | Negative | Zero | Carry | Overflow | DSP Overflow | Thumb If-Then | Jazelle |  | SIMD Greater than/Equal | Thumb If-Then | Endianness(0=Little 1=Big) | Abort Mask | IRQ Mask | FIQ Mask | Thumb | Mode |

    M[4:0]运行状态定义

    | 模式 | M[4:0] | 优先级 | 状态 | 注释 |
    | :-: | :-: | :-: | :-: | :-: |
    | USR | 10000 | PL0 |  | 用户状态 |
    | SYS | 11111 | PL1 |  | 系统模式 | 
    | FIQ | 10001 | PL1 |  | 快速中断 | 
    | IRQ | 10010 | PL1 |  | 普通中断 |
    | SVC | 10011 | PL1 |  | 管理模式 |
    | MON | 10110 | PL1 | 带安全扩展，安全状态 | 监视模式 |
    | ABT | 10111 | PL1 |  | 数据异常/预取指异常 |
    | UND | 11011 | PL1 |  | 未定义指令 |
    | HYP | 11010 | PL2 | 虚拟扩展，非安全状态 | 超级管理 |

    *注：在有虚拟化扩展的ARMv7 CPU中有PL0到PL2三级优先级，其他的只有PL0~PL1两级。常见的ARM CPU中，Cortex-a7 Cortex-a15 Cortex-a17带虚拟化扩展，而Cortex-a9 Cortex-a8等较老的IP不带虚拟化扩展，**本学习记录只针对没有虚拟化扩展的CPU*** 

## 内存架构(A Profile VMSAv7)

## 基本汇编格式

## 指令集

+ **算术**

+ **寄存器操作** 

+ ****