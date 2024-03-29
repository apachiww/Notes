# 线性代数笔记

## 0 LaTeX Cheatsheet

LaTeX常用示例

### 0.1 字符，上下标

### 0.1.1 希腊字母

| 编码 | 显示 |
| :-: | :-: |
| `\alpha\Alpha` | $ \alpha\Alpha $ |
| `\beta\Beta` | $ \beta\Beta $ |
| `\gamma\Gamma` | $ \gamma\Gamma $ |
| `\delta\Delta` | $ \delta\Delta $ |
| `\epsilon\varepsilon\Epsilon` | $ \epsilon\varepsilon\Epsilon $ |
| `\zeta\Zeta` | $ \zeta\Zeta $ |
| `\eta\Eta` | $ \eta\Eta $ |
| `\theta\vartheta\Theta` | $ \theta\vartheta\Theta $ |
| `\iota\Iota` | $ \iota\Iota $ |
| `\kappa\Kappa` | $ \kappa\Kappa $ |
| `\lambda\Lambda` | $ \lambda\Lambda $ |
| `\mu\Mu` | $ \mu\Mu $ |
| `\nu\Nu` | $ \nu\Nu $ |
| `\xi\Xi` | $ \xi\Xi $ |
| `\omicron\Omicron` | $ \omicron\Omicron $ |
| `\pi\Pi` | $ \pi\Pi $ |
| `\rho\varrho\Rho` | $ \rho\varrho\Rho $ |
| `\sigma\Sigma` | $ \sigma\Sigma $ |
| `\tau\Tau` | $ \tau\Tau $ |
| `\upsilon\Upsilon` | $ \upsilon\Upsilon $ |
| `\phi\varphi\Phi` | $ \phi\varphi\Phi $ |
| `\chi\Chi` | $ \chi\Chi $ |
| `\psi\Psi` | $ \psi\Psi $ |
| `\omega\Omega` | $ \omega\Omega $ |


### 0.1.2 符号

| 编码 | 显示 |
| :-: | :-: |
| `\pm` | $ \pm $ |
| `\times` | $ \times $ |
| `\div` | $ \div $ |
| `\cdot` | $ \cdot $ |
| `\geq` | $ \geq $ |
| `\leq` | $ \leq $ |
| `\neq` | $ \neq $ |
| `\approx` | $ \approx $ |
| `\equiv` | $ \equiv $ |
| `\cap` | $ \cap $ |
| `\cup` | $ \cup $ |
| `\in` | $ \in $ |
| `\notin` | $ \notin $ |
| `\subset` | $ \subset $ |
| `\subseteq` | $ \subseteq $ |
| `\supset` | $ \supset $ |
| `\supseteq` | $ \supseteq $ |
| `\mathbb{R}` | $ \mathbb{R} $ |
| `\mathbb{N}` | $ \mathbb{N} $ |
| `\complement` | $ \complement $ |
| `\partial` | $ \partial $ |
| `\nabla` | $ \nabla $ |
| `\log` | $ \log $ |
| `\sin` | $ \sin $ |
| `\cos` | $ \cos $ |
| `\tan` | $ \tan $ |
| `\cot` | $ \cot $ |
| `\infty` | $ \infty $ |


### 0.1.3 上下标

示例

```
x_1^2+x_2^2+y_1+h^2+k_{ab}
```

显示如下

$$ x_1^2+x_2^2+y_1+h^2+k_{ab} $$


### 0.1.4 省略号

示例

```
x_1+x_2+\dots+x_k \quad 1,2,\cdots,n \quad \vdots \quad \ddots
```

显示如下

$$ x_1+x_2+\dots+x_k \quad 1,2,\cdots,n \quad \vdots \quad \ddots $$


### 0.1.5 根号，求和，连乘，极限，积分，分数

**根号**

```
\sqrt{x^3+e^x}
```

```
\sqrt[3]{23}
```

显示如下

$$
\sqrt{x^3+e^x}
$$

$$
\sqrt[3]{23}
$$

**求和**

```
\sum_{i=1}^n a_i
```

显示如下

$$ \sum_{i=1}^n a_i $$

**连乘**

```
\prod_{i=1}^n a_i
```

显示如下

$$ \prod_{i=1}^n a_i $$

**极限**

```
\lim_{x\to0} x^2
```

显示如下

$$ \lim_{x\to0} x^2 $$

**积分**

```
\int_{-\infty}^0 x^2dx 
\iint
\oint
\oiint
```

显示如下

$$
\int_{-\infty}^0 x^2dx
$$

$$
\iint
$$

$$
\oint
$$

$$
\oiint
$$

**分数**

```
\dfrac{xy}{2} \frac{xy}{2}
```

```
行间公式 $ \tfrac{xy}{2} $
```

显示如下

$$ \dfrac{xy}{2} \frac{xy}{2} $$

行间公式 $ \tfrac{xy}{2} $


### 0.1.6 大括号

**花括号**

需要添加转义符

```
\Big\lbrace \Big\rbrace
```

显示如下

$$ 
\Big\lbrace
\Big\rbrace
$$

**方括号**

```
\Big[ \Big]
```

显示如下

$$
\Big[
\Big]
$$

**圆括号**

```
\Big( \Big)
```

显示如下

$$ \Big( \Big) $$

**尖括号**

```
\Big\langle \Big\rangle
```

显示如下

$$ \Big\langle \Big\rangle $$

**竖线**

```
\Big\lvert \Big\rvert
\Big\lVert \Big\rVert
```

显示如下

$$ \Big\lvert \Big\rvert $$

$$ \Big\lVert \Big\rVert $$

### 0.2 箭头，顶标底标

**箭头**

```
\leftarrow \quad \rightarrow \quad \leftrightarrow \quad \longrightarrow \quad \Rightarrow
```

显示如下

$$ \leftarrow \quad \rightarrow \quad \leftrightarrow \quad \longrightarrow \quad \Rightarrow $$

**顶标**

| 编码 | 显示 |
| :-: | :-: |
| `\bar{x}` | $ \bar{x} $ |
| `\vec{x}` | $ \vec{x} $ |
| `\mathring{x}` | $ \mathring{x} $ |
| `\dot{x}` | $ \dot{x} $ |
| `\hat{x}` | $ \hat{x} $ |
| `\check{x}` | $ \check{x} $ | 
| `\tilde{x}` | $ \tilde{x} $ |
| `\breve{x}` | $ \breve{x} $ |
| `\overline{xyz}` | $ \overline{xyz} $ |
| `\overleftrightarrow{xyz}` | $ \overleftrightarrow{xyz} $ |
| `\underline{xyz}` | $ \underline{xyz} $ |
| `\widehat{xyz}` | $ \widehat{xyz} $ |

### 0.3 矩阵

```
\begin{pmatrix}
x_1 & x_2 \\
x_3 & x_4 \\
\end{pmatrix}

pmatrix：圆括号
bmatrix：方括号
Bmatrix：花括号
vmatrix：直线
Vmatrix：双直线
```

显示如下

$$
\begin{pmatrix}
x_1 & x_2 \\
x_3 & x_4 \\
\end{pmatrix}
$$

$$
\begin{bmatrix}
x_1 & x_2 \\
x_3 & x_4 \\
\end{bmatrix}
$$

$$
\begin{Bmatrix}
x_1 & x_2 \\
x_3 & x_4 \\
\end{Bmatrix}
$$

$$
\begin{vmatrix}
x_1 & x_2 \\
x_3 & x_4 \\
\end{vmatrix}
$$

$$
\begin{Vmatrix}
x_1 & x_2 \\
x_3 & x_4 \\
\end{Vmatrix}
$$


### 0.4 大括号

```
y=\begin{cases}
1+2x \\
2+3z \\
\end{cases}
```

显示如下

$$
y=\begin{cases}
1+2x \\
2+3z \\
\end{cases}
$$


## 1 基本概念入门

从方程组入手的线性代数

设有这样一个三元方程组

$$
\begin{cases}
2x-y=0 \\
x+2y-z=-1 \\
-3y+4z=4 \\
\end{cases}
$$

表示为矩阵如下

$$
\begin{bmatrix}
2 & -1 & 0 \\
1 & 2 & -1 \\
0 & -3 & 4 \\
\end{bmatrix}
\begin{bmatrix}
x \\
y \\
z \\
\end{bmatrix}=
\begin{bmatrix}
0 \\
-1 \\
4 \\
\end{bmatrix}
$$

它的行图像是三个面，相交于一点$(x,y,z)$（也即方程组的解）

列图像为三个向量，解$x,y,z$为三个向量的分量

$$
x\begin{bmatrix}
2 \\
1 \\
0 \\
\end{bmatrix}
+y\begin{bmatrix}
-1 \\
2 \\
-3 \\
\end{bmatrix}
+z\begin{bmatrix}
0 \\
-1 \\
4 \\
\end{bmatrix}
=\begin{bmatrix}
0 \\
-1 \\
4 \\
\end{bmatrix}
$$

以上3个列向量不在同一平面以内，所以这个矩阵**可逆（Invertible）**，是**非奇异**的。而如果三个列向量在同一平面以内，则矩阵**不可逆**，是**奇异（Singular）** 的。


### 1.2 矩阵乘法

两个矩阵相乘$M_a \times M_b$，$M_a$的列数一定等于$M_b$的行数

$$
\begin{bmatrix}
a_{11} & a_{12} & a_{13} \\
a_{21} & a_{22} & a_{23} \\
\end{bmatrix}
\cdot\begin{bmatrix}
b_{11} & b_{12} \\
b_{21} & b_{22} \\
b_{31} & b_{32} \\
\end{bmatrix}
=\begin{bmatrix}
a_{11}b_{11}+a_{12}b_{21}+a_{13}b_{31} & a_{11}b_{12}+a_{12}b_{22}+a_{13}b_{32} \\
a_{21}b_{11}+a_{22}b_{21}+a_{23}b_{31} & a_{21}b_{12}+a_{22}b_{22}+a_{23}b_{32} \\
\end{bmatrix}
$$

矩阵乘法的作用可以这样理解：矩阵$M_b$通过矩阵$M_a$转化，$M_a$一行中的三个值分别代表$M_b$中一列中三个值的分量，相加以后得到结果中一行里的两个值。反过来理解也是类似，这就是线性组合

角度1：

**结果$M_c$的每一行都是$M_b$中所有行的线性组合，$M_c$的每一列都是$M_a$中所有列的线性组合**

角度2：

$$
\begin{bmatrix}
3 & 8 \\
2 & 3 \\
7 & 1 \\
\end{bmatrix}
\begin{bmatrix}
2 & 3 \\
8 & 7 \\
\end{bmatrix}
=\begin{bmatrix}
3 \\
2 \\
7 \\
\end{bmatrix}
\begin{bmatrix}
2 & 3 \\
\end{bmatrix}
+\begin{bmatrix}
8 \\
3 \\
1 \\
\end{bmatrix}
\begin{bmatrix}
8 & 7 \\
\end{bmatrix}
$$

角度3：

行空间，可以理解为结果$M_c$中的所有行都来自于$M_b$的每一行的线性组合

列空间同理

角度4：

分块运算，设$M_a$和$M_b$都是方阵，各自分为4个小矩阵

$$
\begin{bmatrix}
A_{11} & A_{12} \\
A_{21} & A_{22} \\
\end{bmatrix}
\begin{bmatrix}
B_{11} & B_{12} \\
B_{21} & B_{22} \\
\end{bmatrix}
=\begin{bmatrix}
A_{11}B_{11} + A_{12}B_{21} & A_{11}B_{12} + A_{12}B_{22} \\
A_{21}B_{11} + A_{22}B_{21} & A_{21}B_{12} + A_{22}B_{22}\\
\end{bmatrix}
$$


### 1.3 矩阵消元以及回代

示例

$$
\begin{bmatrix}
3 & 15 & 1 \\
12 & 5 & 5 \\
6 & 8 & 9 \\
\end{bmatrix}
\Rightarrow\begin{bmatrix}
3 & 15 & 1 \\
0 & -55 & 1 \\
0 & -22 & 7 \\
\end{bmatrix}
\Rightarrow\begin{bmatrix}
3 & 15 & 1 \\
0 & -55 & 1 \\
0 & 0 & 32/5 \\
\end{bmatrix}
$$

回代就是将右侧列向量添加入矩阵（形成**增广阵**）

假设原右侧向量为$\begin{bmatrix} 2 \\ 3 \\ 3 \end{bmatrix}$，那么最终回代结果为

$$
\begin{bmatrix}
3 & 15 & 1 & 2 \\
0 & -55 & 1 & -5 \\
0 & 0 & 32/5 & 9/5 \\
\end{bmatrix}
$$


### 1.4 逆矩阵

$$
A^{-1}A=I
$$

对于**方阵**来说，它的**左逆矩阵**和**右逆矩阵**相同

矩阵是否有逆的一种判断方法和解释：

$$
A=\begin{bmatrix}
1 & 3 \\
2 & 6 \\
\end{bmatrix}
$$

该矩阵无逆矩阵，原因如下：

若存在$A^{-1}$，那么$A^{-1}A$为$I$。然而$A$的两列呈线性关系，无论怎样的组合都最多只会导致$I$中一列全为0

另外也可以这样看：如果$Ax=0$，这里的$x$除了$\begin{bmatrix} 0 \\ 0 \end{bmatrix}$另外有解$\begin{bmatrix} 3 \\ -1 \end{bmatrix}$。假设$A^{-1}$存在，从一开始的等式推出此时$A^{-1}Ax=0$，而由逆矩阵性质可知$A^{-1}Ax=x$，所以必得$x=\begin{bmatrix} 0 \\ 0 \end{bmatrix}$，这与$x=\begin{bmatrix} 3 \\ -1 \end{bmatrix}$矛盾

### 1.4.1 高斯-若尔当求逆阵

设原矩阵如下

$$
M_a=
\begin{bmatrix}
1 & 2 \\
3 & 7 \\
\end{bmatrix}
$$

增广阵，右侧添加单位阵$I$

$$
\begin{bmatrix}
1 & 2 & 1 & 0 \\
3 & 7 & 0 & 1 \\
\end{bmatrix}
\Rightarrow
\begin{bmatrix}
1 & 2 & 1 & 0 \\
0 & 1 & -3 & 1 \\
\end{bmatrix}
\Rightarrow
\begin{bmatrix}
1 & 0 & 7 & -2 \\
0 & 1 & -3 & 1 \\
\end{bmatrix}
$$

那么$M_a$的逆矩阵为

$$
M_a^{-1}=
\begin{bmatrix}
7 & -2 \\
-3 & 1 \\
\end{bmatrix}
$$

### 1.4.2 AB逆阵

两个矩阵$A$和$B$乘积的逆阵如下

$$
(AB)^{-1}=B^{-1}A^{-1}
$$


### 1.4.3 转置和逆

$$
(A^T)^{-1}=(A^{-1})^T
$$

$$
(AB)^T=B^TA^T
$$


### 1.5 LU分解

LU分解，就是将$A$分解为$L$下三角阵和$U$上三角阵

$$
A=LU
$$

可以将$U$拆成$DU$，那么$A=LDU$

示例

$$
\begin{bmatrix}
3 & 5 & 12 \\
21 & 16 & 18 \\
15 & 8 & 4 \\
\end{bmatrix}
=\begin{bmatrix}
1 & 0 & 0 \\
7 & 1 & 0 \\
5 & 17/19 & 1 \\
\end{bmatrix}
\begin{bmatrix}
3 & 5 & 12 \\
0 & -19 & -66 \\
0 & 0 & 58/19 \\
\end{bmatrix}
$$

> LU分解实际上就是和一般的解方程类似，将一个矩阵分解成为一个上三角矩阵和一个下三角矩阵的左乘积。可以这样看：下三角矩阵的每一列都代表了原先矩阵中一行用于消元而乘上的系数。比如第1行，需要分别乘上7以及5并与第2行以及第3行相减，而之后第2行需要乘上17/19并与第3行相减。以此类推


### 1.6 置换矩阵（Permutations）

示例，$PA$交换$A$的23两行

$$
P=
\begin{bmatrix}
1 & 0 & 0 \\
0 & 0 & 1 \\
0 & 1 & 0 \\
\end{bmatrix}
$$

置换矩阵的逆$P^{-1}=P^T$（因为是标准正交阵）


### 1.7 行列式

### 1.7.1 行列式性质

> 在说行列式之前，首先回忆一下高中学过的排列组合
>
> 一般我们说从$n$张不同的扑克中取出$r$张，如果抽出的顺序也算，那么一共有$A_n^r$种抽法（从5张扑克抽出3张，有5\*4\*3 = 60种抽法）。如果不算抽出顺序，那么就是$C_n^r = \dfrac{A_n^r}{r!}$种抽法（有5\*4\*3 / 6 = 10种抽法）。而$r$张扑克可以有$r!$种排列方式。而如果假设所有扑克（n种）都有无数张且抽得的概率相同，那么抽$r$次可以有$n^r$种情况

行列式的基本定义如下

$$
\det(A) = \sum_{j_1 j_2 \cdots j_n}(-1)^{\tau(j_1 j_2 \cdots j_n)} a_{1 j_1} a_{2 j_2} \cdots a_{n j_n}
$$

> 行列式各项如果不计算符号其实就是由$1 \cdots n$自由排列组合，从而得到$a_{1 j_1} a_{2 j_2} \cdots a_{n j_n}$的连乘积，一共有$n!$项。而$(-1)^{\tau(j_1 j_2 \cdots j_n)}$中，$\tau()$代表逆序对运算，原理简单具体不再表述

行列式有以下几个基本性质

> 1. **互换行列式两行，行列式变号，绝对值不变**$\Rightarrow$**如果一个行列式有两行相同，那么这个行列式一定等于0**
> 2. **行列式可以提取一行的公因子，加到外面**$\Rightarrow$**如果一个行列式有两行成比例，那么这个行列式一定等于0**
> 3. **将行列式一行乘以一个常数加到另外一行，行列式数值不变**
> 4. **两个只有一行不同的行列式相加，结果产生的行列式中将这不同的两行相加**$\Rightarrow$**行列式中一行如果可以拆成两个元素之和，那么这个行列式可以拆成两个行列式之和**
> 5. **行列式转置后值不变**

补充性质

> 1. **一个行列式可以通过有限次消元转变为三角行列式（将一行乘以一个常数加到另外一行）**
> 2. **上三角矩阵和下三角矩阵的值都是对角线数字乘积**$\Rightarrow$**一个对角线带两个方块子阵的行列式值为对角线数字乘积**


### 1.7.2 代数余子式

代数余子式

$$
A_{ij}=(-1)^{i+j} \cdot M_{ij}
$$

其中$M_{ij}$为去掉第$i$行和第$j$列的余子式

行列式展开定理

$$
a_{j1}A_{i1}+a_{j2}A_{i2}+a_{j3}A_{i3}+\cdots+a_{jn}A_{in}=\begin{cases} 0 \quad (i \neq j) \\ D \quad (i=j) \end{cases} 
$$

$$
a_{1j}A_{1i}+a_{2j}A_{2i}+a_{3j}A_{3i}+\cdots+a_{nj}A_{ni}=\begin{cases} 0 \quad (i \neq j) \\ D \quad (i=j) \end{cases} 
$$


### 1.8 向量

### 1.8.1 向量数量积和向量积

向量**数量积**结果是一个标量

设$\vec{a}$和$\vec{b}$是两个向量

$$
\vec{a} \cdot \vec{b}  = |\vec{a}|\cdot|\vec{b}|\cos{\theta}
$$

而n维向量$\vec{x}$和$\vec{y}$

$$
\vec{a} \cdot \vec{b} = a_1b_1 + a_2b_2 + \cdots + a_nb_n
$$

**向量积**结果是一个向量，和相乘的两个向量垂直，满足右手定则。设在三维坐标中，$\vec{a}=\{a_1,a_2,a_3\},\vec{b}=\{b_1,b_2,b_3\}$

$$
\vec{a} \times \vec{b} = \{a_2b_3-a_3b_2, a_3b_1-b_3a_1, a_1b_2-a_2b_1 \}
$$

且

$$
|\vec{a} \times \vec{b}| = |\vec{a}|\cdot|\vec{b}|\sin{\theta}
$$

### 1.8.2 混合积

混合积

$$
[\vec{a}, \vec{b}, \vec{c}] = (\vec{a} \times \vec{b}) \cdot \vec{c} = \begin{vmatrix} a_1 & a_2 & a_3 \\ b_1 & b_2 & b_3 \\ c_1 & c_2 & c_3 \end{vmatrix}
$$


### 1.8.3 模

向量模公式

$$
\begin{Vmatrix} \vec{x} \end{Vmatrix}=\sqrt{a_1^2+a_2^2+\cdots+a_n^2}
$$


### 1.9 矩阵和方程组

### 1.9.1 线性方程组和矩阵的联系

一个线性方程组的所有系数组成该方程组的**系数矩阵**，添加上方程组右侧系数列以后得到的矩阵称为**增广阵**，可以通过传统高斯消元法将方程转换为三角矩阵之后求解


### 1.9.2 矩阵的行最简等价标准型

行阶梯阵示例

$$
\begin{bmatrix}
2 & 2 & -1 \\
0 & 0 & 3 \\
0 & 0 & 0 \\
\end{bmatrix}
$$

$$
\begin{bmatrix}
2 & 2 & 0 & 3 \\
0 & 1 & 3 & 2 \\
0 & 0 & 1 & 4 \\
0 & 0 & 0 & 0 \\
\end{bmatrix}
$$

行最简阵示例，所有行第一个非0值都是1

$$
\begin{bmatrix}
1 & 3 & -1 & 0 \\
0 & 1 & 7 & 1 \\
0 & 0 & 0 & 1 \\
0 & 0 & 0 & 0\\
\end{bmatrix}
$$


### 1.9.3 矩阵的秩

**矩阵子式**

一个矩阵，去除某些行和某些列以后得到一个行列式，就称为子式。

**矩阵的秩**

矩阵的秩其实就代表了**一组方程中有效等式的数量**

如果一个矩阵存在一个$r$阶子式不为0，而所有的$(r+1)$阶子式都为0，则$r$就是矩阵的秩

初等变换不会改变矩阵的秩

若矩阵的秩为$r$，那么这个矩阵可以化为$r$阶单位阵和$r$行矩阵，加上若干全零行


### 1.9.4 线性方程组可解的判别

**基本判别**

> 1. 方程组增广阵和系数矩阵的秩相同
> 2. 如果秩$r$等于未知变量数量，那么方程有唯一一组解
> 3. 如果秩$r$小于未知变量数量，那么方程有无穷组解，而且自由未知数数量为$(n-r)$

**克拉默法则**

> 如果一个多元方程组的方程数量和未知数数量相同，并且其系数行列式$D=\lvert a_{ij} \rvert_n \neq 0$，那么这个方程组有唯一的一组解$x_n=\dfrac{D_n}{D}$

**齐次线性方程组**

一个多元方程组所有等式右侧都为0，那么这个方程组被称为**齐次线性方程组**。

**一个齐次线性方程组一定有一组全零解**。

**齐次线性方程组有非零解的充要条件为**：$r(A) < n$（$n$为未知数数量）

**齐次线性方程组仅有零解的充要条件为**：$r(A) = n$


### 1.10 向量组

如果存在一组不全为0的数$k_1,k_2,\cdots,kn$，使得$k_1\vec{\alpha_1}+k_2\vec{\alpha_2}+\cdots+k_n\vec{\alpha_n}=\vec{0}$，那么就称这组向量**线性相关**

**向量组和齐次线性方程组**

一个齐次线性方程组$Ax=0$有非零解，那么这个方程组一定有一个基础解系，并且有$n-r(A)$个线性无关的解向量

**线性方程组解的结构**

如果$X_1$和$X_2$是齐次线性方程组的两个解，那么它们的线性组合也是方程组的解。

### 1.11 方阵特征值和特征向量

如果一个$n$维方阵$A$，和一个$n$维向量$\vec{x}$，满足以下公式

$$
A\vec{x}=\lambda\vec{x}
$$

**那么称$\vec{x}$为$A$的特征向量，$\lambda$为$A$关于$\vec{x}$的特征值**

**特征值和特征向量在工科数学中有非常大的数学意义，本章划重点**

### 1.11.1 特征值和特征向量的理解

一般一个方阵的特征向量可能不止一个，**这些向量可以组成一个空间的基（因为线性无关）**

$$
\begin{cases}
A\vec{p_1}=\lambda_1 \vec{p_1} \\
A\vec{p_2}=\lambda_2 \vec{p_2} \\
\quad \vdots \\
A\vec{p_n}=\lambda_3 \vec{p_n} \\
\end{cases}
$$

设空间内一个向量$\vec{x}=k_1\vec{p_1}+k_2\vec{p_2}+\cdots+k_n\vec{p_n}$

那么

$$
A\vec{x}=k_1A\vec{p_1}+k_2A\vec{p_2}+\cdots+k_nA\vec{p_n} \\
=k_1\lambda_1\vec{p_1}+k_2\lambda_2\vec{p_2}+\cdots+k_n\lambda_n\vec{p_n}
$$

另外，**还可以通过此公式将A分解**

$$
A=P
\begin{bmatrix}
\lambda_1 \qquad \qquad \qquad \\
\qquad \lambda_2 \qquad \qquad \\
\qquad \qquad \ddots \qquad \\
\qquad \qquad \qquad \lambda_n\\
\end{bmatrix}
P^{-1}
$$

以上公式一般可以表示为

$$
A=P \Lambda P^{-1}
$$


### 1.11.2 特征向量的求解

**特征多项式**

$$
| \lambda E - A  |
$$

$ | \lambda E - A  |=0 $的解就是特征值

解析：

> 由于对于一个$\lambda$一定存在至少一个$\vec{x}$使得$A\vec{x}=\lambda \vec{x}$
>
> 所以$\vec{x}$可以看成$(\lambda E-A)\vec{x}=0$的非零解
>
> 所以一定有$ | \lambda E - A  |=0 $
>
> 特征向量只要最后把所有$\lambda$依次代入求解即可

**补充结论**

> 1. 如果$\lambda$是$A$的特征值，那么$\lambda^{-1}$是$A^{-1}$的特征值
> 2. $A$的特征向量线性无关
> 3. 一个$\lambda$可能对应多个特征向量。这些特征向量都线性无关


### 1.11.3 方阵的相似以及对角化

若存在可逆矩阵$P$使得$P^{-1}AP=B$，这种操作被称为相似变换，$B$为$A$的相似矩阵

> 1. 相似矩阵有相同的特征多项式，以及相同的特征值（即相似变换不影响特征值）
> 2. 若$A$相似于一个对角阵，那么$A$可以对角化
> 3. 如果一个$n$阶方阵有$n$个不同的特征值（$n$个线性无关的特征向量），那么$n$可以对角化


### 1.12 实对称阵和二次型

实际应用当中，经常可以碰到形如$x^TAx$的式子，其中$A$为对称阵，也即$a_{ij}=a_{ji}$。一般情况下，$x^TAx$的结果为

$$
x^TAx = a_{11}x_1^2 + 2a_{12}x_1x_2 + \cdots + 2a_{1n}x_1x_n \\
        + a_{22}x_2^2 + \cdots + a_{2n}x_2x_n \\
        \vdots \\
        + a_{nn}x_n^2
$$

称为$n$元二次型，$A$称为该二次型的矩阵

而如果$A$是一个对角阵，那么矩阵就会变得较容易处理

$$
x^TAx = \lambda_1 x_1^2 + \lambda_2 x_2^2 + \cdots + \lambda_n x_n^2
$$

所以对于一个普通的$A$，可以找到$Cy=x$，使得$x^TAx=(Cy)^TACy=y^T(C^TAC)y$，其中$C^TAC$为对角阵，转换以后的$d_1y_1^2+d_2y_2^2+\cdots+d_ny_n^2$称为$x^TAx$的一个**标准型**。一个二次型可能对应多个标准型，这些标准型正负系数数量不变（惯性）

**实对称阵对应不同特征值的特征向量互相正交**

**实对称阵可以正交对角化**：存在一个正交阵P，使得
$$
P^TAP=
\begin{bmatrix}
\lambda_1 \qquad \qquad \qquad \\
\qquad \lambda_2 \qquad \qquad \\
\qquad \qquad \ddots \qquad \\
\qquad \qquad \qquad \lambda_n\\
\end{bmatrix}
$$

其中$\lambda_i$都是A的特征值

**正定二次型**

如果对于任意非零$\vec{x}$，$x^TAx$大于零，那么A就为正定阵，并且$A$的特征值都大于零

$A$和$C^TAC$有相同的正定性