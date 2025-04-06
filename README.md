# 笔记

~~My ADHD notes~~

> 个人学习归纳，备忘。不保证质量，完成度和准确性
>
> Learning is a lifelong deal. 长期慢更

## 快速传送门

### Linux运维

|  |
| :- |
| [Shell脚本](201219a_shell.md#2-shell脚本基础) |
| [文件管理](201219a_shell.md#11-文件管理) |
| [系统管理](201219a_shell.md#12-系统管理) |
| [Awk脚本，正则表达式](201219a_shell.md#31-awk编程) |
| [iptables](210130a_install-notice.md#1-安全专题防火墙iptables) |
| [nftables](210130a_install-notice.md#8-安全专题防火墙nftables) |
| [ufw](210130a_install-notice.md#9-安全专题防火墙前端ufw) |
| [firewalld](210130a_install-notice.md#10-安全专题防火墙前端firewalld) |
| [SELinux](210130a_install-notice.md#5-安全专题selinux) |
| [AppArmor](210130a_install-notice.md#6-安全专题apparmor) |
| [Ansible](210130a_install-notice.md#7-运维工具ansible) |

### 容器与虚拟化

|  |
| :- |
| [Docker](230709a_container.md#2-docker) |
| [LXD](230709a_container.md#1-lxd) |
| [Kubernetes](230709a_container.md#3-kubernetes) |
| [podman](230709a_container.md#10-podman) |
| [QEMU KVM](230709a_container.md#6-qemu) |
| [cgroup](230709a_container.md#12-专题linux-cgroup) |

### 嵌入式与通用底层

|  |
| :- |
| [ARMv7-M指令集](201020a_stm32.md#16-isa详解指令集) |
| [LFS和Buildroot](200908b_qemu-arm.md#基于lfs) |
| [Tcl编程](201219a_shell.md#33-tcl编程) |
| [ELF文件格式，程序链接与运行原理](220429a_compiler.md#1-elf文件结构) |
| [ld链接脚本](201020a_stm32.md#4-ld链接器脚本) |
| [IEEE754浮点数](200920c_verilog.md#51-IEEE754浮点数标准) |

### 工具

|  |
| :- |
| [Git教程](201219a_shell.md#35-git使用) |
| [Makefile](201219b_makefile.md#1-简介) |
| [GPG与数据加密](201219a_shell.md#1130-gpg) |
| [OpenSSL命令行使用与SSL证书](221112a_network.md#556-附加说明openssl) |

### 硬件通信

|  |
| :- |
| [RS232串口](210524a_8051.md#8-补充rs232串口通信) |

## 列表

> 章节目录生成 [index-gen.awk](index-gen.awk)
>
> `./index-gen.awk note.md`

| No. | Content | Done |
| :- | :- | :-: |
| [200908a](200908a_sdram.md) | 计算机存储：SDRAM | 100% |
| [200908b](200908b_qemu-arm.md) | Linux From Scratch (ARMv7)，并使用QEMU运行 | 30% |
| [200920a](200920a_arm-assembly.md) | ARMv7-A ARMv8-A体系结构，内存架构 | 10% |
| [200920b](200920b_dsp.md) | 信号与系统，DSP数字信号处理 | 1% |
| [200920c](200920c_verilog.md) | 数字逻辑以及Verilog，FPGA开发 | 95% |
| [201002a](201002a_linear-algebra.md) | 线性代数，矩阵计算 | 50% |
| [201002b](201002b_calculus.md) | 高数，数学分析 | 0% |
| [201002c](201002c_complex.md) | 复变函数 | 0% |
| [201020a](201020a_stm32.md) | ARMv7-M体系结构以及STM32单片机开发 | 70% |
| [201219a](201219a_shell.md) | Linux命令行，Shell脚本，Awk字符串处理，Tcl编程，Expect，Git教程 | 100% |
| [201219b](201219b_makefile.md) | Makefile的用法，基于cmake和GNU make | 90% |
| [201220a](201220a_mcu-ide.md) | MCU开发环境构建 | 10% |
| [201220b](201220b_crack.md) | CTF相关实用技能摘录 | 0% |
| [201220c](201220c_metasploit.md) | Metasploit渗透测试 | 0% |
| [201225a](201225a_ssd.md) | 计算机存储：固态硬盘工作原理与优化方法 | 100% |
| [201230a](201230a_cryptography.md) | 加密算法，密码学 | 0% |
| [210108a](210108a_autocad.md) | AutoCAD基本操作 | 100% |
| [210110a](210110a_computer-arch.md) | 计算机体系结构以及处理器的设计 | 1% |
| [210111a](210111a_qt.md) | Qt应用开发 | 0% |
| [210115a](210115a_freebsd.md) | FreeBSD安装与日常使用 | 100% |
| [210130a](210130a_install-notice.md) | 类Unix管理维护以及安全优化，SELinux | 40% |
| [210316a](210316a_computer-graphics.md) | 计算机图形学，Vulkan，OpenGL（GLSL） | 0% |
| [210317a](210317a_parallel.md) | Linux并发编程，C++11线程库，CUDA | 0% |
| [210320a](210320a_3drebuild.md) | 卫星遥感 | 100% |
| [210409a](210409a_haskell.md) | 函数式编程，Haskell | 30% |
| [210501a](210501a_famitracker.md) | 计算机音乐，和声理论，FamiTracker，经典计算机音乐集成电路解析 | 0% |
| [210515c](210515c_nginx.md) | Nginx/Apache/H2O Web服务原理以及部署 | 0% |
| [210524a](210524a_8051.md) | 8051单片机 | 100% |
| [210625a](210625a_uefi.md) | UEFI | 10% |
| [210702a](210702a_avr.md) | AVR单片机开发 | 50% |
| [210729a](210729a_ai.md) | 机器学习，深度学习，强化学习，常用模型、框架和算法 | 0% |
| [210731a](210731a_llvm.md) | 编译原理与LLVM | 0% |
| [210731b](210731b_usb.md) | USB协议 | 30% |
| [210808a](210808a_lcd.md) | LCD驱动 | 50% |
| [210811a](210811a_sata.md) | 计算机常用存储设备接口协议 | 0% |
| [210904b](210904b_power.md) | 开关电源，DC-DC | 2% |
| [211017a](211017a_analog.md) | 模电，无线电 | 0% |
| [211211a](211211a_codestyle-and-licence.md) | 代码规范，开源协议 | 50% |
| [220420a](220420a_tribblix.md) | Tribblix、Slackware安装与日常使用 | 0% |
| [220429a](220429a_compiler.md) | 二进制ELF文件格式，链接器原理 | 100% |
| [221019a](221019a_bsd-impl.md) | FreeBSD设计与实现 | 0% |
| [221112a](221112a_network.md) | 计算机网络 | 80% |
| [221116a](221116a_wacom.md) | Wacom数位板手动配置 | 100% |
| [230323a](230323a_ncnn.md) | ncnn和MNN | 0% |
| [230411a](230411a_unix-programming.md) | Linux/Unix系统编程 | 0% |
| [230513a](230513a_texlive.md) | Texlive安装与使用 | 0% |
| [230526a](230526a_driver.md) | Linux驱动开发，设备树 | 0% |
| [230709a](230709a_container.md) | Linux容器和虚拟化工具，LXD（Incus），Docker，CRI-O，Kata Containers，VirtualBox，QEMU（+KVM），K8s/K3s，Vagrant等工具的使用，cgroup | 30% |
| [230719a](230719a_js.md) | 基于Node.js和React全栈开发 | 0% |
| [230813a](230813a_auto.md) | 自动控制算法 | 0% |
| [231101a](231101a_riscv.md) | RISC-V体系结构，SBI | 0% |
| [231104a](231104a_database.md) | 数据库 | 0% |
| [231126a](231126a_pcb.md) | 高速PCB设计 | 0% |
| [240706a](240706a_alpine.md) | AlpineLinux安装与日常使用 | 100% |
| [240813a](240813a_fat.md) | 磁盘分区表与FAT文件系统 | 80% |
| [250107a](250107a_loongarch.md) | LoongArch学习笔记 | 0% |
| [250118a](250118a_plan9port.md) | Plan 9 port试用 | 0% |
| [250302a](250302a_void.md) | VoidLinux安装与日常使用 | 100% |
| [250404a](250404a_init.md) | s6和dinit的使用 | 0% |

## 参考书收藏

1. 《数字逻辑基础与Verilog设计（第2版）》，Stephen Brown，Zvonko Vrannesic著，机械工业出版社
2. 《Linux命令行与Shell脚本编程大全（第3版）》，Richard Blum，Christine Bresnahan著，人民邮电出版社
3. 《计算机体系结构量化研究方法（第5版）》，John L. Hennessy，David A. Patterson著，人民邮电出版社
4. 《C++ Primer（第5版）》，Stanley B. Lippman，Josee Lajoie，Babara E. Moo著，电子工业出版社
5. 《Ruby on Rails教程（第4版）》，Michael Hartl著，人民邮电出版社
6. 《信号与系统》，Alan V. Oppenheim，Alan S. Willsky，S. Hamid Nawab著，电子工业出版社
7. 《Linux内核设计与实现》，Robert Love著，机械工业出版社
8. 《CPU自制入门》，水头一寿，米泽辽，藤田裕士著，人民邮电出版社
9. 《Lua程序设计（第4版）》，Roberto lerusalimschy著，电子工业出版社
10. 《Ruby基础教程（第2版）》，高桥征义，后藤裕藏著，人民邮电出版社
11. 《ARM Cortex-M3与Cortex-M4权威指南（第3版）》，Joseph Yiu著，清华大学出版社
12. 《计算机图形学（第2版）》，Peter Shirley著，人民邮电出版社
13. 《Vulkan应用开发指南》，Graham Sellers，John Kessenich著，人民邮电出版社
14. 《Vulkan学习指南》，Parminder Singh著，机械工业出版社
15. 《三维计算机视觉技术和算法导论》，Boguslaw lyganek，J. Paulsiebert著，国防工业出版社
16. 《深入理解计算机系统》，Randal E. Bryant，David R. O'Hallaron著，机械工业出版社
17. 《深度学习》，Ian Goodfellow，Yoshua Bengio，Aaron Courville著，网络资源
18. 《UEFI原理与编程》，戴正华著，机械工业出版社
19. 《LLVM Cookbook》，Mayur Pandey，Suyog Sarda著，电子工业出版社
20. 《LLVM编译器实战教程》，Bruno Cardoso Lopes，Rafael Auler著，机械工业出版社
21. 《Haskell函数式程序设计》，Richard Bird著，机械工业出版社
22. 《C++并发编程实战》，Anthony Williams著，人民邮电出版社
23. 《精通开关电源（第3版）》，Keith Billings，Taylor Morey著，人民邮电出版社
24. 《新概念模拟电路》，杨建国著，网络资源
25. 《矩阵计算（第4版）》，Gene H. Golub，Charles F. Van Loan著，人民邮电出版社
26. 《精神分析引论》，Sigmond Freud著
27. 《The Design and Implementation of the FreeBSD Operating System (2nd Edition)》，McKusick M.K.，Neville-Neil G.V.著
28. 《Programming in Haskell (Second Edition)》，Graham Hutton著
29. 《Compilers: Principles, Techniques and Tools (Second Edition)》，Alfred V. Aho，Monica S. Lam，Ravi Sethi，Jeffrey D. Ullman著
30. 《OpenSSL Cookbook (Second Edition)》，Ivan Ristić著
31. 《HTTP权威指南》，David Gourley，Brian Totty著
32. 《Linux/UNIX系统编程手册》，Michael Kerrisk著
33. 《深入理解Linux内核》，Daniel P. Bovet，Marco Cesati著

## Recipe

🍥 C C++ Go Java Rust Ruby Python Lua Node.js Zig Scala Dart Forth

🍣 Haskell | Erlang OCaml Agda

🍜 CSS HTML JavaScript

🍙 Shell Awk Tcl

🍱 Verilog

🍓 Vulkan OpenGL | GLSL

🍡 MySQL PostgreSQL SQLite

🍢 MongoDB Redis Geode

🍇 Rails(Ruby) Express(Node.js) Spring(Java) Gin(Go)

🍎 React Vue

🍒 WebAssembly

🍈 Docker LXD Kubernetes QEMU

🍐 Makefile

🥥 Matlab

🍉 Qt wxWidgets SDL

🥑 ARM AVR 8051 RISC-V

🫐 FPGA

🥭 FreeRTOS RT-Thread

🍌 KiCAD FreeCAD

🍍 AlpineLinux ArchLinux Debian Fedora RHEL Slackware FreeBSD Tribblix Haiku