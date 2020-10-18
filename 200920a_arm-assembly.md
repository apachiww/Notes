# ARM体系结构以及汇编，Application Level and System Level(ARMv7 Cortex-A)

## 1. 参考

[azeria-labs 官网](https://azeria-labs.com)

[ARM Developer 官网](https://developer.arm.com)

[ARMv7 ISA 官方文档](https://developer.arm.com/documentation/ddi0406/cd/?search=5eec7399e24a5e02d07b2754) 直接下载[链接](https://documentation-service.arm.com/static/5f1074ce0daa596235e834b5?token=)

## 2. 环境

OS： Debian 10 (buster) armv7l on Linux Deploy

Kernel version： 3.4.0

CPU： Qualcomm MSM8974PRO-AC (SnapDragon 801)

## 3. GDB使用方法

+ **基本使用方法**

    ```shell
    gdb <可执行文件名>
    ```

## 4. 寄存器介绍

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
    | USR | 10000 | PL0 |  | 用户模式 |
    | SYS | 11111 | PL1 |  | 系统模式 | 
    | FIQ | 10001 | PL1 |  | 快速中断 | 
    | IRQ | 10010 | PL1 |  | 普通中断 |
    | SVC | 10011 | PL1 |  | 管理模式 |
    | MON | 10110 | PL1 | 需要带安全扩展的处理器，安全状态 | 监视模式 |
    | ABT | 10111 | PL1 |  | 数据异常/预取指异常 |
    | UND | 11011 | PL1 |  | 未定义指令 |
    | HYP | 11010 | PL2 | 需要带虚拟扩展的处理器，运行在非安全状态 | 超级管理 |

    *注：在有虚拟化扩展的ARMv7 CPU中有PL0到PL2三级优先级，其他的只有PL0和PL1两级。常见的ARM CPU中，Cortex-a7 Cortex-a15 Cortex-a17带虚拟化扩展，而Cortex-a9 Cortex-a8等较老的IP不带虚拟化扩展，**本学习记录只针对没有虚拟化扩展的CPU，对于虚拟化不会过多的去涉及（一般用不上）*** 

+ **各模式下的寄存器**

    ![寄存器表（截自ARM官方文档）](images/200920a001.png "寄存器表（截自ARM官方文档）")

    *注：上图中，空白部分不是代表没有该寄存器，而是代表和User模式下用的是同一个寄存器*

## 5. 内存系统架构（VMSAv7 A-Profile）

在VMSAv7中，内存由MMU进行管理，MMU可以通过CP15控制，MMU包含了MPU的内存保护功能

在支持**安全扩展**以及**虚拟化扩展**的CPU中，安全模式下PL1和PL0提供1级MMU，非安全模式下PL1和PL0提供2级MMU，PL2提供1级MMU

在仅支持**安全扩展**不支持**虚拟化扩展**的CPU中，没有PL2，在安全以及非安全模式下PL1和PL0都仅提供1级MMU

+ **内存类型**

    | 类型 | 注释 | Cache设置 |
    | :-: | :-: | :-: |
    | Normal | 普通内存，可以设置读写或读，一般是RAM，ROM，Flash。可以标记为Shared或Non-Shared，Shared通过一定技术保证cache和内存的一致（可以多个处理器访问），Non-Shared没有特殊要求（单处理器访问）。共享访问实际是MPU的功能。 | 可以是Cacheable Write-Through或Cacheable Write-Back或Noncacheable，和该区域是否是共享内存无关联 |
    | Device | 设备内存，一般是IO，控制寄存器等外设。对于设备的访问需要内存屏障（Memory Barrier）以保证访问顺序符合预期（无论读写）（现代引入乱序执行技术的CPU会导致访问乱序，多CPU系统因此受影响较大），通常系统总线（访问WatchDog和中断控制器）是Shared，外设是Non-Shared | Device类型内存不会被记入Cache |
    | Strongly-Ordered | 强顺序， ARMv8中被废除，强制要求所有都严格按顺序读写，都是Shared | Strongly-Ordered内存不会被记入Cache |

    *注：Write-Through即写入到Cache的内容同步写回到内存，速度较慢，Write-Back即一般写回，只更新Cache不更新内存，只有到Cache被换出时才被写回，速度快，但存在同步问题*
    
    *在ARM预取指操作中，预取指最多可能先行于当前执行指令64字节*

    *非显式的访存即除访存指令之外对内存的访问操作，如取指，缓存交换，Tranlation Table Walk*

+ **显式内存屏障（Explicit Memory Barrier）**

    指令，尤其访存指令，实际执行可能是乱序的，这可能由两个因素引入，一个是编译器优化，另外一个是现代CPU引入的乱序执行技术。对于一般的单处理器一般不会有问题，但是对于多处理器多线程的环境或其他执行顺序敏感的程序来说可能得到意想不到的结果，内存屏障就是为了解决这个问题

    ARM CPU内存屏障用于解决乱序执行带来的问题，有两种，分为Data Memory Barrier和Drain Write Buffer，另外有一个Flush Prefetch Buffer，内存屏障通过操作CP15的c7寄存器实现

    **Data Memory Barrier：** 保证当前指令之前的所有显式内存访问指令完成后才执行本指令，当前指令完成后才执行之后的访存任务，类似在当前指令增加了一个屏障

    **Drain Write Buffer：** 

## 6. 中断控制（GIC）

## 7. 基本汇编格式

## 指令集参考

+ **算术**

    | 助记符 | 基本格式 | 示例 | 作用简记 | 备注 |
    | :-: | :-: | :-: | :-: | :-: |

+ **寄存器操作** 

+ **内存读写**

+ **协处理器**

+ **模式切换**

+ **VFP浮点扩展**

+ **NEON SIMD扩展**

## 一些常用算法示例