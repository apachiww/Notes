# LoongArch笔记

https://www.loongson.cn/index.php/download/index

# 目录

## 1 ISA概览

LoongArch的基础ISA为**Loongson Base**，并且在此基础上有4个扩展，分别为**LBT**二进制翻译扩展（Loongson Binary Translation），**LVZ**虚拟化扩展（Loongson Virtualization），**LSX**128位向量扩展（Loongson SIMD Extension），**LASX**256位向量扩展（Loongson Advanced SIMD Extension）

LoongArch也有LA32和LA64两个版本。LA64仅支持在应用层面兼容LA32。本笔记只讲述LA64

指令编码方面，LoongArch所有指令采用固定的32位编码，且指令在内存中必须4Byte对齐，否则触发异常

