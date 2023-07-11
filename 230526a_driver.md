# Linux设备驱动，设备树

## 参考

Linux Device Driver Development (2nd Edition), John Madieu

## 1 

## 7 设备树

参考文档可以在[devicetree.org](https://www.devicetree.org/)下载 | [本地文档](src/210731b01/devicetree-specification-v0.3.pdf)

**设备树**是在没有BIOS/ACPI的平台中常用的设备描述文件，操作系统内核需要设备树文件来管理CPU，内存，外设等硬件

Bootloader可以在加载操作系统时将存储的静态设备树加载到内存传递给内核，也可以自动生成设备树。如果Bootloader不支持上述特性，那么设备树也可以安装在操作系统中

## 7.1 设备树文件格式

设备树顾名思义，其数据结构为树状结构，其中每一个元素称为树中的一个**节点**（node），每一个节点会包含**属性**（properties）和**子节点**（child nodes），每一个属性都是**键值对**（name-value pairs）

设备树有两种存在形式，一种是二进制形式，被操作系统使用；一种是文本形式，便于人工编辑

文本形式的设备树源文件后缀`.dts`，需要通过**设备树编译器**`dtc`编译为`.dtb`二进制格式。和C一样，设备树也可以使用`#include`包含其他设备树文件