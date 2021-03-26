# Octave/Matlab的使用

## 参考书籍

*MATLAB for Engineers (Second Edition), Holly Moore, America, 2010*


## 1 基本矩阵以及向量操作

### 1.1 定义

定义矩阵

```matlab
A = [1, 3, 2; 3, 3, 3];
B = [1, 3, 2
     3, 3, 3];
C = [1, 4, 5; B];
```

全零/全一矩阵

```matlab
zeros(m);
zeros(m, n);
ones(m, n);
```

随机矩阵

```matlab
A = randn(2, 3);
```

单位矩阵

```matlab
eye(3); %3*3的单位阵
```

引用，修改值

```matlab
A(1,2) = 2;
% A(2) = 2;效果相同
```

扩展矩阵，将B扩展为3*3矩阵，指定最后一位为7，其余为0

```matlab
B(3,3) = 7;
```

### 1.2 冒号

用法1：定义等差矩阵

创建一个整数1到8的矩阵

```matlab
% H = [1,2,3,4,5,6,7,8]
H = 1:8
```

也可以使用linspace实现相似功能

```matlab
G = linspace(1,8,8);
```

用法2：通配行或列

```matlab
% 指定提取M的第8列
M[:, 8]
% 提取M的第8列，第2行到第5行
M[2:5, 8]
```

用法3：将矩阵所有列拼接转为一个列矢量

```matlab
M(:)
```


### 1.3 矩阵操作

### 1.3.1 对角

对角操作有两种，一种是提取方阵的对角线，另一种是构建对角阵

提取对角线

```matlab
A = [1, 3, 4; 9, 1, 7; 4, 5, 9];
B = diag(A); %B是一个列向量，为A对角线上的数字
```

构建对角阵

```matlab
A = [1, 4, 4];
B = diag(A); %B以1，4，4为对角线的对角阵
```

### 1.3.2 翻转

```matlab
fliplr(A); %将A左右翻转
flipud(A); %将A上下翻转
```


### 1.4 矩阵运算

### 1.4.1 转置

转置直接添加`'`符号即可

```matlab
A'
```

### 1.4.2 乘法，点乘

数乘向量

```matlab
x = [1:5];
y = 5;
A = x * y;
```

向量点积

```matlab
A = [1, 2, 2];
B = [3, 1, 0];
C = A .* B;
```

向量矩阵，x纵向扩展，y横向扩展，扩展后的向量宽度和x相同，高度和y相同

```matlab
[p, q] = meshgrid(x, y);
```

矩阵乘法

```matlab
A = [1, 2; 1, 3; 2, 3];
B = [6, 3, 3; 4, 5, 7];
C = A * B;
```

### 1.4.3 矩阵幂

使用`^`运算符

```matlab
A^2
```


### 1.4.4 逆阵

逆阵必须作用于方阵

可以使用`^-1`

```matlab
B = A^-1;
```

也可以使用`inv`

```matlab
inv(A);
```

### 1.4.5 行列式

使用`det`

```matlab
det(A);
```

### 1.4.6 向量叉积

使用`cross`

```matlab
cross(A,B);
```


### 1.4.7 方程组求解

有3种方法，先介绍逆阵法，基本原理就是

$$
X = A^{-1}B
$$

```matlab
X = inv(A)*B;
```

第二种，使用消元法，直接使用`/`运算符

```matlab
X = A/B;
```

第三种，使用行阶梯阵（也是消元）

```matlab
C = [A, B];
rref(C);
```


## 2 绘图

### 2.1 二维坐标图

### 2.1.1 基本绘图

设X，Y为两个长度相同的向量。可以使用`plot`直接绘制二维坐标图

```matlab
plot(X,Y);
```

添加标题/变量单位/栅格

```matlab
plot(X,Y);
title('Test 1');
xlabel('Time, s'), ylabel('Distance, m');
grid;
```


### 2.1.2 创建多个图形窗口

创建Figure 2图形窗口

```matlab
figure(2)
```


### 2.1.3 绘制多条曲线

可以使用`hold on`保持之前的图形，防止其被覆盖

```matlab
plot(X, Y1);
hold on;
plot(X, Y2);
```

而`hold off`可以使得之前绘制的图形被覆盖

也可以一次绘制两条曲线

```matlab
plot(X, Y1, X, Y2);
```

也可以将两个向量合并为一个矩阵

```matlab
Y = [Y1; Y2];
plot[X, Y];
```


### 2.1.4 绘图风格

可以在plot中指定绘图曲线样式，点形状，以及颜色

示例

```matlab
plot(X, Y, 'bx-'); % 绘制蓝色实线，点为x形
```

可用样式

```

           b     blue          .     point              -     solid
           g     green         o     circle             :     dotted
           r     red           x     x-mark             -.    dashdot 
           c     cyan          +     plus               --    dashed   
           m     magenta       *     star             (none)  no line
           y     yellow        s     square
           k     black         d     diamond
           w     white         v     triangle (down)
                               ^     triangle (up)
                               <     triangle (left)
                               >     triangle (right)
                               p     pentagram
                               h     hexagram
```


### 2.1.5 固定坐标显示

可以使用`axis`固定或取消固定坐标的缩放

```matlab
axis
```


### 2.1.6 子图

使用`subplot`命令将一个窗口分为多个子图区域

```matlab
subplot(2, 2, 1); % 在2*2窗口的第1个小窗口绘制图形
```


### 2.1.7 极坐标图

使用`polar`绘制极坐标图

```matlab
Y = sin(X);
polar(X, Y);
```


### 2.1.8 对数图

使用`semilogx` `semilogy` `loglog`创建对数坐标

```matlab
semilogx(X, Y);
semilogy(X, Y);
loglog(X, Y);
```


### 2.1.9 双y轴

使用`plotyy`

```matlab
plotyy(X, Y1, X, Y2);
```


### 2.2 三维坐标图

### 2.2.1 三维线图

使用`plot3`绘制三维线图

```matlab
plot3(X, Y, Z);
```


### 2.2.2 曲面图

使用`mesh`或`surf`绘制三维曲面

可以只使用一个二维矩阵z，矩阵中的元素的位置代表图形在mesh图中的x，y坐标，元素的值代表z坐标

```matlab
mesh(z);
xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');
```

也可以指定x，y的值，但是x，y的长度一定要和z对应

```matlab
x = linspace(1, 50, 10);
y = linspace(500, 1000, 3);
mesh(x, y, z);
```

而`surf`创建的是着色的三维曲面图，颜色由z决定

`surf`的样式可以改变，如下

```matlab
shading interp; % 去除网格，模糊显示
shading flat; % 单去除网格
```

使用`colormap`控制曲面图颜色

```matlab
colormap(gray); % 灰色
```


### 2.2.3 等高图

等高图使用`contour`绘制

```matlab
contour(X, Y, Z);
```

