# 计算机视觉/3D重构

关键词： SLAM

## 参考

*An Introduction to 3D Computer Vision Techniques and Algorithms, Boguslaw lyganek, J. Paulsiebert, 2010*

计算机视觉之三维重建篇（精简版）北京邮电大学 鲁鹏 [Bilibili](https://www.bilibili.com/video/BV15f4y1v7pa)


## 0 图像的表示

一般平面二维图像有RGB，YUV两种基本表示格式，YCbCr只是YUV的一种（使用隔行扫描，而YPbPr使用逐行扫描）

### 0.1 RGB

RGB表示方式是最直接的表示方式，**分别代表红、绿、蓝三种颜色的亮度**，常见有RGB888，RGB565等，一般在显示器等硬件中应用较多


### 0.2 YUV

YUV表示方式中，**Y表示亮度（Luma），而U和V分别表示两种色度**。

RGB转YUV标准公式为

$$
Y = 0.299 R + 0.587 G + 0.114 B \\
U = -0.1687 R - 0.3313 G + 0.5 B + 128 \\
V = 0.5 R - 0.4187 G - 0.0813 B + 128 \\
$$

其中$UV$值都要加128，无加法时转换矩阵为（UV先减去128）

$$
\begin{bmatrix}
0.299 & 0.587 & 0.114 \\
-0.1687 & -0.3313 & 0.5 \\
0.5 & -0.4187 & -0.0813
\end{bmatrix}
$$

转换逆阵为

$$
\begin{bmatrix}
1 & 0 & 1.402 \\
1 & -0.34414 & -0.71414 \\
1 & 1.772 & 0
\end{bmatrix}
$$

YCbCr转RGB

$$
Y=0.299R+0.587G+0.114B \\
Cb=0.564(B-Y) \\
Cr=0.713(R-Y)
$$

RGB转YCbCr

$$
R=Y+1.402Cr \\
G=Y-0.344Cb-0.714Cr \\
B=Y+1.772Cb
$$


## 1 摄像机几何与内参数

### 1.1 针孔摄像机，透镜

针孔成像模型，就是将空间一个点通过小孔映射到胶片（一个平面）上面的过程

设想一个针孔成像的侧视图，小孔在胶片上方，发光点在小孔上方，在小孔处建立一个右手三维坐标系，$z$轴指向上方。针孔到胶片的距离为$f$（就是焦距，和$z$轴共线）。设空间一个发光点$A(x,y,z)$，那么胶片上该发光点的成像点$y$坐标为$f\dfrac{y}{z}$。同理可以得到$x$坐标为$f\dfrac{x}{z}$

由于针孔成像亮度和清晰度不可兼得，所以引入透镜

**透镜的焦距：平行光通过透镜到达焦点，到透镜中心的距离$f$**

以后只考虑透镜到胶片的距离$z_0$，这代表图像只有在特定的一段距离以内才可以清晰成像

**畸变：分为枕形畸变和桶形畸变**

这些形变其实都是相对中心坐标将原有坐标乘以一个常数

**枕形畸变：成像点远离中心**

**桶形畸变：成像点靠近中心**


### 1.2 摄像机几何基础

摄像机几何其实是**射影几何**的一个分支。**射影几何**可以用于研究**三维图形在二维平面的成像原理**

空间中一个点到胶卷平面的映射（针孔成像），有一个公式

$$
(x,y,z)\rightarrow(fk\dfrac{x}{z}+c_x,fl\dfrac{y}{z}+c_y)
$$

> 解析：像平面的坐标原点和成像的坐标原点不同。成像的原点对应成像胶片的中心点，而胶片的坐标习惯将左下角作为坐标原点，所以相对胶卷坐标平面需要添加一个offset$(c_x,c_y)$（单位pixel）
>
> 另外需要解决长度单位（m）到像素单位（pixel）的转换，这里添加$k$和$l$参数（单位都是pixel/m），方形像素中$k$和$l$的值相等
>
> 可以合并$fk$和$fl$分别为$\alpha$和$\beta$

$$
(x,y,z)\rightarrow(\alpha\dfrac{x}{z}+c_x,\beta\dfrac{y}{z}+c_y)
$$

**以上公式其实就是射影几何中基本公式的变形，基本原理就是将空间一个点的$(x,y)$的坐标除以距离，得到透视的效果**


### 1.2.1 齐次坐标

**正是以上的$z$坐标实现了投影之后的近大远小的透视效果**。但是$z$位于分母，这不便于使用矩阵进行线性变换，所以这里引入齐次坐标

**齐次坐标系便于坐标转换的线性计算，添加的一维齐次坐标便于透视问题的处理。也是射影几何的重要组成部分**

欧氏三维坐标转换为齐次坐标添加一个**齐次项**（二维坐标同理），如下

$$
p=(x,y,z)\rightarrow\begin{bmatrix} x \\ y \\ z \\ 1 \end{bmatrix}
$$

点的齐次坐标可以转换为欧氏坐标，不同的齐次坐标点可能对应相同的欧氏坐标点（举一个比较生动的例子，如果看到了两个形状大小相同的物体，它们可能距离不同，而且距离远的那个物体更大）

$$
\begin{bmatrix}
x \\ y \\ w
\end{bmatrix}
\rightarrow(x/w,y/w)
$$

**在一般的计算机图形学/视觉中，对于三维坐标一般添加一个1。而在经过投影变换以后得到具有3个元的二维坐标（投影面坐标），再将其转变为欧氏坐标就是其在投影平面的位置**


### 1.2.2 摄像机映射矩阵（内参数）

齐次坐标中的映射矩阵，**重点公式**

$$
P'=\begin{bmatrix}\alpha x + c_xz \\ \beta y + c_yz \\ z \end{bmatrix}=\begin{bmatrix}
\alpha & 0 & c_x & 0 \\
0 & \beta & c_y & 0 \\
0 & 0 & 1 & 0 \\ 
\end{bmatrix}
\begin{bmatrix}
x \\ y \\ z \\ 1 
\end{bmatrix}
=MP
$$

可能会碰到像素坐标系不垂直的情况（摄像机偏歪），这种情况下需要对$M$稍加改动

![非垂直](images/210320a001.png)

得到

$$
M=
\begin{bmatrix}
\alpha & -\alpha\cot\theta & c_x & 0 \\
0 & \dfrac{\beta}{\sin\theta} & c_y & 0 \\
0 & 0 & 1 & 0 \\
\end{bmatrix}
$$

取$M$的一部分$K$，称为**摄像机内参数矩阵**，因为只和摄像机参数有关

$$
K=
\begin{bmatrix}
\alpha & -\alpha\cot\theta & c_x \\
0 & \dfrac{\beta}{\sin\theta} & c_y \\
0 & 0 & 1 \\
\end{bmatrix}
$$

所以开头的公式也可以表示为

$$
P'=MP=K\begin{bmatrix} I & 0 \end{bmatrix}P
$$

**规范化相机**

规范化相机的矩阵$M=\begin{bmatrix} 1 & 0 & 0 & 0 \\ 0 & 1 & 0 & 0 \\ 0 & 0 & 1 & 0 \\ \end{bmatrix}$

可以看成使用方形像素，没有偏歪，针孔和摄像机中心同轴


## 2 摄像机外参数

### 2.1 齐次坐标常用变换矩阵

设坐标$P=\begin{bmatrix} x \\ y \\ z \\ 1 \end{bmatrix}$

$M$一般形式：

$$
M=\begin{bmatrix}
a_{11}x & a_{12}x & a_{13}x & \Delta x \\
a_{21}x & a_{22}x & a_{23}x & \Delta y \\
a_{31}x & a_{32}x & a_{33}x & \Delta z \\
0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

**平移（Translation）**

$$
\begin{bmatrix}
1 & 0 & 0 & \Delta x \\
0 & 1 & 0 & \Delta y \\
0 & 0 & 1 & \Delta z \\
0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

**尺度/缩放（Scale）**

$$
\begin{bmatrix}
Scalex & 0 & 0 & 0 \\
0 & Scaley & 0 & 0 \\
0 & 0 & Scalez & 0 \\
0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

**旋转（Rotation）**

$x$轴

$$
\begin{bmatrix}
1 & 0 & 0 & 0 \\
0 & \cos(\theta) & -\sin(\theta) & 0 \\
0 & \sin(\theta) & \cos(\theta) & 0 \\
0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

$y$轴

$$
\begin{bmatrix}
\cos(\theta) & 0 & \sin(\theta) & 0 \\
0 & 1 & 0 & 0 \\
-\sin(\theta) & 0 & \cos(\theta) & 0 \\
0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

$z$轴

$$
\begin{bmatrix}
\cos(\theta) & -\sin(\theta) & 0 & 0 \\
\sin(\theta) & \cos(\theta) & 0 & 0 \\
0 & 0 & 1 & 0 \\
0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

### 2.2 世界坐标系

世界坐标系用于设定一个绝对参考。如果使用相机坐标系，相机移动以后坐标也会变。将以上齐次坐标变换矩阵代入

世界坐标系到摄像机坐标系的转变，$R$为旋转部分，$T$为平移部分

设摄像机沿世界坐标系$z$轴负方向平移$z_0$距离，那么应该在$T$加上相应的距离（平移的逆过程，**摄像机相对世界坐标所有移动步骤的逆**）

$$
P=\begin{bmatrix}
R & T \\
0 & 1 \\
\end{bmatrix}P_w
$$

其中$P_w=\begin{bmatrix} x_w \\ y_w \\ z_w \\ 1 \end{bmatrix}$为世界坐标

可以和映射矩阵结合，得到世界坐标系到胶片平面的映射 **（重点公式）**

$$
P'=
K\begin{bmatrix}
I & 0
\end{bmatrix}
\begin{bmatrix}
R & T \\
0 & 1 \\
\end{bmatrix}P_w=
K\begin{bmatrix}
R & T
\end{bmatrix}P_w
$$

其中，$K$为摄像机的**内参数**矩阵，$R$和$T$为**外参数**（即摄像机相对世界坐标系的位移的逆）。这两个矩阵可以合并，设为$M$，那么$P'=MP_w$

**自由度**：自由度就是看一个矩阵中可以影响一个矩阵的因素数量。$K$有5个自由度，$R$有3个自由度（分别绕$xyz$轴旋转），$T$有3个自由度（分别沿$xyz$轴移动），所以$M$一共有11个自由度

设$M=\begin{bmatrix} m_1 \\ m_2 \\ m_3 \end{bmatrix}$那么最终$P'$的欧氏坐标形式为$(\dfrac{m_1P_w}{m_3P_w},\dfrac{m_2P_w}{m_3P_w})$


### 2.3 Faugeras定理

原理会在之后提到，这里先引入结论

> 1. 设$M=K\begin{bmatrix} R & T \end{bmatrix}=\begin{bmatrix} KR & KT \end{bmatrix}=\begin{bmatrix} A & b \end{bmatrix}$，$M$是一个透视投影矩阵的充要条件是$\det (A) \neq 0$
> 
> 2. 设$A=\begin{bmatrix} a_1 \\ a_2 \\ a_3 \end{bmatrix}$，那么$M$是零倾斜($\theta=90\degree$)透视投影矩阵的充要条件是$(a_1 \times a_3)\cdot(a_2 \times a_3)=0$
>
> 3. $M$宽高比为1（使用方形像素）的充要条件为
> $$
\begin{cases}
(a_1 \times a_3)\cdot(a_2 \times a_3) = 0 \\
(a_1 \times a_3)\cdot(a_1 \times a_3) = (a_2 \times a_3)\cdot(a_2 \times a_3)
\end{cases}
$$


### 2.4 弱透视和正交投影

弱透视（将距离相差不大的点看成在同一个平面），$m_3P_w=1$，$P'=(m_1P_w,m_2P_w)$，常用于图像识别

正交投影（无透视），$x'=x,y'=y$，常用于工业设计CAD


## 3 摄像机标定

### 3.1 特征值分解（EVD）和奇异值分解（SVD）

分解$A=P \Lambda P^{-1}$，这就是 **特征值分解（EVD）**

**特征值分解**的意义就是，计算$A\vec{x}$时可以将$\vec{x}$分解为向量组$P$的线性组合，之后可以将矩阵$A$替换为特征值矩阵计算

而在这里，如果A为**对称矩阵**，那么此时$P$成为**正交矩阵**，可以进行标准化转化为**标准正交矩阵**（中文音译幺正矩阵/酉矩阵，Unitary Matrix，所有向量模为1且正交），此时$P^T=P^{-1}$，可以得到

$$
A=P\Lambda P^T
$$

> ~~无关补充~~：向量组正交化可以使用**施密特正交化法**
> **施密特正交化公式**
> $$
\beta_1 = \alpha_1 \\
\beta_2 = \alpha_2 - \dfrac{[\beta_1,\alpha_2]}{[\beta_1,\beta_1]} \beta_1 \\
\quad \vdots \\
\beta_n = \alpha_n - \dfrac{[\beta_1,\alpha_n]}{[\beta_1,\beta_1]} \beta_1 - \dfrac{[\beta_2,\alpha_n]}{[\beta_2,\beta_2]} \beta_2 - \cdots - \dfrac{[\beta_{n-1},\alpha_n]}{[\beta_{n-1},\beta_{n-1}]} \beta_{n-1} \\
$$

而**奇异值分解（SVD）** ，可以理解为和**对称矩阵的特征值分解**类似，**区别是$A$和$\Lambda$不再是对称阵（主要用于非方阵的场合）。SVD可以用于最小二乘问题，求解一个齐次超定方程组的最优解**，形式如下

$$
A=U\Sigma V^T
$$

可以这样想：**无论$A^TA$还是$AA^T$都是对称矩阵（$(AA^T)^T=AA^T$，反之同理），所以可以使用上面特征值分解中的技巧**。这里，方阵$U$的阶数和$A$的行数相同，$V$的阶数和$A$的列数相同，并且直接得到的$U$和$V$**都是正交矩阵**。$U$可以通过求$AA^T$的特征值和特征向量得到，由特征向量组合而成；而$V$可以通过求$A^TA$的特征值和特征向量得到

接下来可以这样看：

$$
AA^T = U \Sigma V^T (U \Sigma V^T)^T
= U \Sigma V^T V \Sigma^T U^T
= U \Sigma \Sigma^T U^T
= U \Sigma_U U^T \\
A^TA = (U \Sigma V^T)^T U \Sigma V^T
= V \Sigma^T U^T U \Sigma V^T
= V \Sigma^T \Sigma V^T
= V \Sigma_V V^T
$$

> 这里再次引用一条结论（证明过程省略）：**$A^TA$和$AA^T$拥有相同的非零特征值，且这些特征值都不为负数**。

由以上可以明显看出，其实等式就是$A=P\Lambda P^T$的形式

综上，SVD基本步骤：

> 1. 分别求出$AA^T$和$A^TA$的特征值和特征向量，并将特征向量标准化（模为1），分别作为$U$和$V$
> 2. 方法1（较为繁琐）：由于$A = U \Sigma V^T \Rightarrow AV = U\Sigma \Rightarrow Av_i = \sigma_i u_i \Rightarrow \sigma_i = \dfrac{Av_i}{u_i}$
> 方法2（简明高效）：因为$\Sigma_U$和$\Sigma_V$拥有相同的$\lambda_1,\lambda_2,\cdots,\lambda_k$，所以$\sigma_1=\sqrt{\lambda_1},\sigma_2=\sqrt{\lambda_2},\cdots,\sigma_k=\sqrt{\lambda_k}$

**SVD可以用于图像压缩（舍去较小的奇异值和奇异向量），但是效果较差，容易损失细节。常用的图片压缩算法一般基于DCT或DWT**


### 3.2 摄像机标定过程

**摄像机标定就是对于摄像机内外参数的求解（投影矩阵M的求解）**

本章开始使用$p$替代$P'$，使用$P$替代$P_w$

$$
p=K\begin{bmatrix} R & T \end{bmatrix}P
$$

$p_i$的欧氏坐标为

$$
p_i = \begin{bmatrix} u_i \\ v_i \end{bmatrix} = \begin{bmatrix} \dfrac{m_1P_i}{m_3P_i} \\ \dfrac{m_2P_i}{m_3P_i} \end{bmatrix}
$$

关键就在于$m_1,m_2,m_3$（都是1行4列的矩阵）的求解，**一共11个未知量，分别是世界坐标相对摄像机坐标的3个平移量、3个旋转量，以及5个摄像机参数，分别为$\alpha,\beta,\theta,c_x,c_y$**

而一对$p_i$和$P_i$可以得到两个方程，所以至少需要$6 \times 2 = 12 \gt 11$共6对点数据（先求出$m_1,m_2,m_3$的12个数据），而实际**一般取多于6对点**

可以列出方程组如下

$$
\begin{cases}
-u_1(m_3P_1)+m_1P_1=0 \\
-v_1(m_3P_1)+m_2P_1=0 \\
\quad \vdots \\
-u_n(m_3P_n)+m_1P_n=0 \\
-v_n(m_3P_n)+m_2P_n=0 \\
\end{cases}
$$

可以$m_1,m_2,m_3$转置合并为一个12行1列的矩阵$m=\begin{bmatrix} m_1^T \\ m_2^T \\ m_3^T \end{bmatrix}$

而$P$如下，最后可以求解$Pm=0$

$$
P=
\begin{bmatrix}
P_1^T & 0 & -u_1P_1^T \\
0 & P_1^T & -v_1P_1^T \\
\quad \vdots \\
P_n^T & 0 & -u_nP_n^T \\
0 & P_n^T & -v_nP_n^T \\
\end{bmatrix}
$$

但是由于方程行数一定大于列数，所以方程只有零解。**这里求解超定方程需要用到奇异值分解和最小二乘，只能求得近似的最优解（使得方程组左侧最接近于0）**

这里限制$|| m || = 1$，设$P=UDV^T$进行奇异值分解，**那么$m$为最小奇异值的右奇异向量**，由此求出$m1,m2,m3$，$M=\begin{bmatrix} m1 \\ m2 \\ m3 \end{bmatrix}$

**接下来可以根据$M$提取摄像机内参数$K$和外参数$\begin{bmatrix} R & T \end{bmatrix}$**

由于$K = \begin{bmatrix} \alpha & -\alpha\cot\theta & c_x \\ 0 & \dfrac{\beta}{\sin\theta} & c_y \\ 0 & 0 & 1 \\ \end{bmatrix}$，$R = \begin{bmatrix} r_1^T \\ r_2^T \\ r_3^T \end{bmatrix}$，$T = \begin{bmatrix} \Delta x \\ \Delta y \\ \Delta z \end{bmatrix}$

如下，设$A = \begin{bmatrix} a_1^T \\ a_2^T \\ a_3^T \end{bmatrix}, b = \begin{bmatrix} b_1 \\ b_2 \\ b_3 \end{bmatrix}$可以算已知，实际中$\begin{bmatrix} A & b \end{bmatrix}$一般需要加上一个常数系数$\rho$，那么

$$
M = K\begin{bmatrix} R & T \end{bmatrix} = \rho\begin{bmatrix} A & b \end{bmatrix} = \begin{bmatrix} \alpha r_1^T - \alpha \cot{\theta} r_2^T + c_x r_3^T & \alpha \Delta x - \alpha \cot{\theta} \Delta y + c_x \Delta z \\
\dfrac{\beta}{\sin{\theta}} r_2^T + c_y r_3^T & \dfrac{\beta}{\sin{\theta}} \Delta y + c_y \Delta z \\
r_3^T & \Delta z
\end{bmatrix}
$$

**先从旋转矩阵入手，求解$c_x$和$c_y$**

$$
\rho A = \begin{bmatrix}
\alpha r_1^T - \alpha \cot{\theta} r_2^T + c_x r_3^T \\
\dfrac{\beta}{\sin{\theta}} r_2^T + c_y r_3^T \\
r_3^T \\
\end{bmatrix}
$$

由于$r_3^T$是一个旋转矩阵的一行，**所以为单位向量**，可以得到以下结论

$$
|| \rho a_3 || = || r_3^T || = 1 \Rightarrow \rho = \dfrac{\pm 1}{| a_3 |}
$$

将$\rho A$第一行和第三行点积，**由于$r_1^T,r_2^T,r_3^T$两两正交**，所以点积为0；**而两个单位向量$r_3^T$点积之后为1**，所以可以得到如下等式

$$
c_x = \rho^2(a_1\cdot a_3)
$$

同理

$$
c_y = \rho^2(a_2\cdot a_3)
$$

**接下来求解参数$\theta$**

> 这里再引入一条~~显而易见的~~定理：如果$\vec x \vec y \vec z$为单位向量，两两正交且成右手系，那么$\vec x \times \vec y = \vec z$

运用以上定理，可以对$\theta$的求解作以下分析：

对$\rho A$行之间作叉积，可以得到

$$
\begin{cases}
\rho^2 (a_1 \times a_3) = \alpha r_2 - \alpha \cot{\theta} r_1 \\
\rho^2 (a_2 \times a_3) = \dfrac{\beta}{\sin{\theta}} r_1
\end{cases}
$$

两边取模（推导过程较为复杂，略）

$$
\begin{cases}
\rho^2 |a_1 \times a_3| = \dfrac{|\alpha|}{sin{\theta}} \\
\rho^2 |a_2 \times a_3| = \dfrac{|\beta|}{sin{\theta}}
\end{cases}
$$

综合以上推导，可以由下求出$\theta$

$$
\dfrac{(a_1 \times a_3)\cdot(a_2 \times a_3)}{|a_1 \times a_3|\cdot|a_2 \times a_3|} = \dfrac{\dfrac{-\alpha \beta \cos{\theta}}{\sin^2{\theta}}}{\dfrac{\alpha \beta}{\sin^2{\theta}}} = -\cos{\theta}
$$

如果这个式子为0，那么$\theta=90\degree$，这里就得到了之前[1.2.5章](210320a_3drebuild.md#125-Faugeras定理)讲过的Faugeras定理，好理解

**既然已经求得$\theta$，那么最后内参数$\alpha$和$\beta$直接使用上式即可求得**

**求解旋转外参数**

$\vec r_1 \vec r_2 \vec r_3$都是正交单位向量

所以

$$
\begin{cases}
r_1 = \dfrac{(a_2 \times a_3)}{| a_2 \times a_3 |} \\
r_2 = r_3 \times r_1 \\
r_3 = \dfrac{\pm a_3}{| a_3 |} \\
\end{cases}
$$

**最后算出平移外参数**

$$
\rho b = KT \Rightarrow T = K^{-1}\rho b
$$


### 3.3 径向畸变的处理

径向畸变包括之前讲过的**桶形畸变**和**枕形畸变**

桶形畸变将平面理想位置坐标乘以一个小于1的正数

枕形畸变将平面理想位置坐标乘以一个大于1的正数

具体转换如下，其中$\lambda = 1 \pm \sum_{p=1}^3 K_p d^{2p} $

$$
p = 
\begin{bmatrix}
\dfrac{1}{\lambda} & 0 & 0 \\
0 & \dfrac{1}{\lambda} & 0 \\
0 & 0 & 1
\end{bmatrix}
MP
$$

设$Q = \begin{bmatrix} q_1 \\ q_2 \\ q_3 \end{bmatrix} = \begin{bmatrix} \dfrac{1}{\lambda} & 0 & 0 \\ 0 & \dfrac{1}{\lambda} & 0 \\ 0 & 0 & 1 \end{bmatrix} M$，那么$p_i = QP_i = \begin{bmatrix} \dfrac{q_1P_i}{q_3P_i} \\ \dfrac{q_2P_i}{q_3P_i} \end{bmatrix}$，**但是这不是线性方程组**

可以使用**列文伯格-马夸尔特（L-M）** 法求解最近似值，但是直接求解过程非常复杂

可以先将$\dfrac{1}{\lambda}$分开算

$$
p_i = \begin{bmatrix} u_i \\ v_i \end{bmatrix} = \begin{bmatrix} \dfrac{q_1P_i}{q_3P_i} \\ \dfrac{q_2P_i}{q_3P_i} \end{bmatrix} 
= \dfrac{1}{\lambda} \begin{bmatrix} \dfrac{m_1P_i}{m_3P_i} \\ \dfrac{m_2P_i}{m_3P_i} \end{bmatrix}
\Rightarrow
\dfrac{u_i}{v_i} = \dfrac{m_1P_i}{m_2P_i}
$$

先求出前两行$m_1,m_2$，再使用**L-M**求解$m_3$和$\lambda$


### 4 2D变换

### 4.1 等距变换（欧氏变换）

特性：描述平移和旋转，面积和形状不变，有个3自由度

$$
\begin{bmatrix} x' \\ y' \\ 1 \end{bmatrix} = \begin{bmatrix} R & T \\ 0 & 1 \end{bmatrix} \begin{bmatrix} x \\ y \\ 1 \end{bmatrix}
$$


### 4.2 相似变换

在等距变换基础上加一个缩放$S$

特性：形状不变，有4个自由度

$$
\begin{bmatrix} x' \\ y' \\ 1 \end{bmatrix} = \begin{bmatrix} SR & T \\ 0 & 1 \end{bmatrix} \begin{bmatrix} x \\ y \\ 1 \end{bmatrix}, S = \begin{bmatrix} s & 0 \\ 0 & s \end{bmatrix}
$$


### 4.3 仿射变换

$A$没有特殊要求

特性：平行线不变，有6个自由度

$$
\begin{bmatrix} x' \\ y' \\ 1 \end{bmatrix} = \begin{bmatrix} A & T \\ 0 & 1 \end{bmatrix} \begin{bmatrix} x \\ y \\ 1 \end{bmatrix}
$$


### 4.4 射影（透视）变换

特性：共线性不变，有8个自由度，相对于坐标轴做透视变换

$$
\begin{bmatrix} x' \\ y' \\ 1 \end{bmatrix} = \begin{bmatrix} A & T \\ v & 1 \end{bmatrix} \begin{bmatrix} x \\ y \\ 1 \end{bmatrix}
$$


### 5 影消点和影消线

### 5.1 平面直线以及透视坐标系中平行线的相交

平面上的一条直线可以使用$ax+by+c=0$的形式表示，可以设$l = \begin{bmatrix} a \\ b \\ c \end{bmatrix}$，设直线上有一个点$x = \begin{bmatrix} x_1 \\ x_2 \end{bmatrix}$，那么$\begin{bmatrix} x_1 \\ x_2 \\ 1 \end{bmatrix}^T \begin{bmatrix} a \\ b \\ c \end{bmatrix} = 0$

> 这里直接引入一条结论：平面两条直线的交点，就是这两条直线参数向量的叉乘，即$x = l \times l'$，原因如下
>
> 由于叉乘得到的结果向量一定垂直于原向量，所以$ (l \times l')\cdot l = 0 $
>
> 同理$ (l \times l')\cdot l' = 0 $
> 
> 而由于直线的定义，交点的坐标代入正好是0，所以得证

> 无穷远点：齐次坐标$\begin{bmatrix} x \\ y \\ 0 \end{bmatrix}$转换为欧氏坐标为$(\infty,\infty)$
>
> 无穷远点经过仿射变换之后依然是无穷远点，但是经过射影（透视）变换之后就不是无穷远点了
>
> $$ \begin{bmatrix} A & T \\ 0 & 1 \end{bmatrix} \begin{bmatrix} 1 \\ 1 \\ 0 \end{bmatrix} = \begin{bmatrix} p_x \\ p_y \\ 0 \end{bmatrix}$$
> $$ \begin{bmatrix} A & T \\ v & 1 \end{bmatrix} \begin{bmatrix} 1 \\ 1 \\ 0 \end{bmatrix} = \begin{bmatrix} p_x \\ p_y \\ p_z \end{bmatrix}$$

**平行线的相交**

设两条平行线

$$
ax + by + c = 0 \\
a'x + b'y + c' = 0
$$

其中$\dfrac{b}{a} = \dfrac{b'}{a'}$

那么$l \times l' \propto \begin{bmatrix} b \\ -a \\ 0 \end{bmatrix} = x_\infty$

验证，可以反过来将坐标代入可得

$$
\begin{bmatrix}
a & b & c
\end{bmatrix}
\begin{bmatrix}
b \\ -a \\ 0
\end{bmatrix}
= 0
$$

> 无穷远线：$l_\infty = \begin{bmatrix} 0 \\ 0 \\ 1 \end{bmatrix}$
>
> 可以将无穷远点代入：$\begin{bmatrix} b & -a & 0 \end{bmatrix} \begin{bmatrix} 0 \\ 0 \\ 1 \end{bmatrix} = 0$
> 
> 无穷远线的变换，可以设直线上一个点$x$，那么$l'^THx=0$，$H = \begin{bmatrix} A & T \\ 0 & 1 \end{bmatrix}$，而$l^Tx = 0 \Rightarrow l^T H^{-1}Hx = 0 \Rightarrow (H^{-1T}l)^T Hx = 0$，**所以$l' = H^{-1T}l$**
>
> 无穷远线的透视变换：$H^{-T} l_{\infty} = \begin{bmatrix} A & t \\ v & b \end{bmatrix}^{-T} \begin{bmatrix} 0 \\ 0 \\ 1 \end{bmatrix} = \begin{bmatrix} t_x \\ t_y \\ b \end{bmatrix}$
> 
> 可以发现，无穷远线经过透视变换之后得到的不再是无穷远线
>
> 同无穷远点的仿射变换，无穷远线仿射变换之后依然是无穷远线


### 5.2 三维空间中的点和面

空间中一个点的齐次坐标为

$$
x = 
\begin{bmatrix}
x_1 \\
x_2 \\
x_3 \\
1
\end{bmatrix}
$$

类似平面中直线的表示，空间中一个平面的表示如下

$$
\Pi=\begin{bmatrix}
a \\
b \\
c \\
d
\end{bmatrix}
$$

三维平面上一个点，可以表示为$x^T\Pi=0$

**三维空间中的直线具有4个自由度，一般使用两个平面相交的形式表示。一般会定义直线的方向$d = \begin{bmatrix} a & b & c \end{bmatrix}^T$**

> 三维空间中的无穷远点（空间中平行线的交点，平行线方向为$\begin{bmatrix} a & b & c \end{bmatrix}^T$）：表示形式为$x_\infty = \begin{bmatrix} a \\ b \\ c \\ 0 \end{bmatrix}$


### 5.3 影消点

**三维空间中的无穷远点在图像平面上的投影点，成为影消点，不再是无穷远点**

$$
p_\infty = \begin{bmatrix} p_1 \\ p_2 \\ p_3 \end{bmatrix}
= v = Kd = K \begin{bmatrix} a \\ b \\ c \end{bmatrix}
$$

$$
d = \dfrac{K^{-1}v}{||K^{-1}v||}  
$$

> 可以作如下推导（K为摄像机内参数矩阵）：
>
> $$ x_\infty = \begin{bmatrix} a \\ b \\ c \\ 0 \end{bmatrix} \Rightarrow v = Mx_\infty = K \begin{bmatrix} I & 0 \end{bmatrix} \begin{bmatrix} a \\ b \\ c \\ 0 \end{bmatrix} = K\begin{bmatrix} a \\ b \\ c \end{bmatrix}$$


### 5.4 影消线

**三维空间中的无穷远线在图像平面上的投影线，成为影消线**

$$
l_{horiz} = H_P^{-T}l_\infty
$$

两条平行线一定交于影消线

> 影消线和平面法向量的关系：
> $$ \vec n = K^T l_{horiz} $$
>
> 其中K为摄像机内参数矩阵（投影）
>
> 推导：设水平面参数为$\Pi$，数值和法向量相同，那么平面上$X^T\Pi = 0$，经过投影矩阵$P$之后可以得到$(PX)^T l_{horiz} = 0 \Rightarrow X^T(P^Tl_{horiz}) = 0$，所以$\Pi = P^Tl_{horiz}$，即$ \vec n = P^T l_{horiz} $

> 无穷远平面：平行平面在无穷远处交于**无穷远直线**，多条无穷远直线组成无穷远平面$\Pi$
>
> $$ \Pi_\infty = \begin{bmatrix} 0 \\ 0 \\ 0 \\ 1 \end{bmatrix} $$


### 5.5 两组平行线夹角和影消点的关系

由于空间一个无穷远点坐标可以通过影消点反向求得

$$
d = \dfrac{K^{-1}v}{||K^{-1}v||}
$$

空间两对平行线夹角可以如下求解

$$
\cos\theta = \dfrac{d_1 \cdot d_2}{|d_1||d_2|}
\dfrac{v_1^T \omega v_2}{\sqrt{v_1^T \omega v_1} \sqrt{v_2^T \omega v_2}}
$$

其中

$$
\omega = (KK^T)^{-1} = 
\begin{bmatrix}
\omega_1 & \omega_2 & \omega_4 \\
\omega_2 & \omega_3 & \omega_5 \\
\omega_4 & \omega_5 & \omega_6 \\
\end{bmatrix}
$$

是一个对称矩阵，若$\omega_2 = 0$那么零倾斜，若同时$\omega_1 = \omega_3$那么是方形像素，$\omega$只有5个自由度

并且

$$
\theta = 90\degree \rightarrow v_1^T \omega v_2 = 0
$$


### 6 单视图重构

> 单视图重构分两个步骤
>
> 1. 通过单视图标定摄像机内参数$K$
> 2. 通过参数还原空间中面的信息
>
> 单视图重构存在重大缺陷就是不能真实还原三维场景的尺寸以及实际比例，并且影消点和影消线需要手动选择，需要场景先验信息

在图片中取三组互相正交的平行线，由之前[5.5](210320a_3drebuild.md#55-两组平行线夹角和影消点的关系)可知此时$\theta = 0$，设影消点分别为$v_1,v_2,v_3$，那么有

$$
\begin{cases}
v_1^T\omega v_2 = 0 \\
v_1^T\omega v_3 = 0 \\
v_2^T\omega v_3 = 0
\end{cases}
$$

此时可以假设摄像机零倾斜（$\omega_2 = 0$）并且使用方形像素（$\omega_1 = \omega_3$），求出$\omega$即可求出$K$，完成摄像机的标定

标定完成之后就可以进行重构，求出这3个平面的法向量，就可以求出平面方程

$$
\vec n = K^Tl_{horiz}
$$


### 7 对极几何

使用双目视觉图片的重构方法（多视图几何）

### 7.1 对极几何基础

极几何描述同一场景或物体两个视点**图像**之间的几何关系，如下。对极几何有一个关键点就是**查找一个视图上面一个点在另一个视图上面的对应位置**

![对极成像系统](images/210320a002.png)

> 定义
> 1. **极平面**：过$O_lO_rP$的平面$\Pi_e$
> 2. **基线**：中心点$O_lO_r$的连线
> 3. **极点**：**基线**和相机成像平面的交点$e_l$和$e_r$
> 4. **极线**：**极平面**$\Pi_e$和两相机成像平面的交线$e_lp_l$和$e_rp_r$
>
> 性质
> 1. **极平面**相交于**基线**
> 2. 所有**极线**相交于**极点**
> 3. $p_l$的对应点在$e_rp_r$上
> 4. $p_r$的对应点在$e_lp_l$上
>
> 极几何约束：查找一个视图中一个点在另一个视图中的坐标，只需要**在极线上查找**即可

> 平行视图：考虑一种特殊情况，**如果两个摄像机成像平面平行，那么基线$O_lO_r$和摄像机成像平面平行，极点$e_le_r$位于无穷远处**。这是大部分双目视觉系统的构造

> 前向平移：两个摄像机平面依然平行，此时两**极点**$e_le_r$在两平面中坐标相同


### 7.2 本质矩阵

本质矩阵用于**代数化描述规范相机拍摄的图像之间的极几何关系（空间中同一个点$P$在坐标$O_l$和$O_r$中对应坐标的关系）**

设有两个规范化相机，那么每个规范化相机的投影矩阵就是

$$
p = MP = \begin{bmatrix} 1 & 0 & 0 & 0 \\ 0 & 1 & 0 & 0 \\ 0 & 0 & 1 & 0 \end{bmatrix} \begin{bmatrix} x \\ y \\ z \\ 1 \end{bmatrix} = \begin{bmatrix} x \\ y \\ z \end{bmatrix}
$$

三维坐标中一个点的投影坐标和三维坐标相同

设空间中一点$P$，两摄像机中心点分别为$O_lO_r$，空间同一点$P$在两坐标的对应点分别为$P_lP_r$。在$O_l$和$O_r$处建立坐标系。其中，摄像机$O_l$可以经过$R T$得到$O_r$（$R$为旋转矩阵，$T$为平移坐标，**旋转矩阵的逆阵就是它的转置**），那么可以类似之前世界坐标到摄像机坐标的转换原理，$P_r = R(P_l  - T)$**（注：这里的$P_lP_r$是同一个点$P$在$O_lO_r$的两个不同坐标）**

**接下来作如下推导**

> 已知$P_r = R(P_l  - T)$，并且由图可知$P_l$和$T$在$\Pi_e$内，那么$P_l - T$也在$\Pi_e$上，可得
>
> $$ (P_l - T) \cdot (T \times P_l) = 0 $$
>
> 接下来分析$T \times P_l$。由于向量叉乘可以化为矩阵和向量点乘的形式，如下
>
> $$ T \times P_l = [T_\times]P_l = \begin{bmatrix} 0 & -T_3 & T_2 \\ T_3 & 0 & -T_1 \\ T_2 & -T_1 & 0 \end{bmatrix} \begin{bmatrix} P_{l1} \\ P_{l2} \\ P_{l3} \end{bmatrix} = AP_l$$
>
> 那么最后代入得到
>
> $$ (R^TP_r)^TAP_l = P_r^TRAP_l = P_r^TEP_l = 0 $$

其中，$E = RA$就是**本质矩阵**，本质矩阵**体现了同一个坐标点在$O_l$和$O_r$中的坐标的关系**

由于$A$的秩为2，所以$E = RA$的**秩为2**


### 7.3 基础矩阵

基础矩阵更进一步，**用于描述两个投影之后的齐次坐标的关系**

有关基础矩阵，可以作如下推导

> 在规范化相机中，由于$p_l = MP_l$，$p_r = MP_r$**（$p_lp_r$分别为经过相机$O_lO_r$投影的坐标）**，所以
>
> $$ p_r^TEp_l = 0 $$
> 
> 设$p_r$所在极线为$u_r$，$p_l$所在极线为$u_l$，那么有
>
> $$ p_ru_r = 0 \\ p_lu_l = 0 $$
>
> 所以有
>
> $$ u_r = Ep_l \\ u_l = E^Tp_r $$
>
> 由实际情况中摄像机的内参数矩阵分别为$K_lK_r$，$\bar p_l = K_lp_l$，$\bar p_r = K_rp_r$**（其中$\bar p_l$和$\bar p_r$分别是$p_lp_r$经过投影之后的齐次坐标）**，那么
>
> $$ (K_r^{-1}\bar p_r)^TEK_l^{-1}\bar p_l = 0 \Rightarrow \bar p_r^TK_r^{-T}EK_l^{-1}\bar p_l = 0 $$
>
> 设$F = K_r^{-T}EK_l^{-1} = K_r^{-T}RAK_l^{-1}$，所以
>
> $$ \bar p_r^TF \bar p_l = 0 $$

其中，$F = K_r^{-T}EK_l^{-1}$就是**基础矩阵**，因为$E$的秩为2，所以$F$的**秩也为2**


### 7.4 基础矩阵估计

> 由以上$F$的组成分析，$F$有7个自由度（**由于$ \bar p_r^TF \bar p_l = 0 $右侧为0**，所以$F$具有**尺度等价性**，需要**减去1个自由度**。又因为$F$为3阶方阵并且秩为2，$\det(F) = 0$，所以只有7个自由度）。计算中可以取8对点建立线性方程组，而实际中**一般会使用9对点以增加鲁棒性**
> 
> 最终可以列出矩阵的一行如下（点坐标分别为$(u,v,1)(u',v',1)$，实际有9个点代入，所以有9行）

$$
\begin{bmatrix} uu' & vu' & u' & uv' & vv' & v' & u & v & 1 \end{bmatrix} \begin{bmatrix} F_{11} \\ F_{12} \\ F_{13} \\ F_{21} \\ F_{22} \\ F_{23} \\ F_{31} \\ F_{32} \\ F_{33} \\ \end{bmatrix} = 0
$$

> 表示形式为

$$
Wf = 0
$$

> 此时又到了求解超定方程组的**最小二乘问题**，同样对$W$进行**SVD**，求解其**最小奇异值对应右特征向量（$|| f || = 1$）**，最终求得结果记为$\hat F$
>
> **但是这里还存在一个问题：$\hat F$通常秩为3，而实际中$F$秩为2**。所以这里还要对$\hat F$做一次**SVD**使得$\hat F$相对于$F$最小化，**去除最小奇异值**（此时$\det(F) = 0$）

$$
\hat F = U \begin{bmatrix} S_1 & 0 & 0 \\ 0 & S_2 & 0 \\ 0 & 0 & S_3 \end{bmatrix} V^T \Rightarrow F = U \begin{bmatrix} S_1 & 0 & 0 \\ 0 & S_2 & 0 \\ 0 & 0 & 0 \end{bmatrix} V^T
$$

**但是8点法存在精度差的问题，因为$W$中有些变量是相乘得到的结果，所以数值差异可能很大**

所以改良这种算法得到了**归一化8点算法**，如下

> 对左右两张图分别施加平移和缩放（变换$T$和$T'$），使得图像原点为图像重心，且各像点到原点均方根距离为$\sqrt{2}$
>
> $$ q_i = Tp_i, q_i' = Tp_i' $$
>
> 之后计算$F_q$，然后进行逆归一化$F = T'^TF_qT$


### 8 双目立体视觉系统

### 8.1 平行视图




### 8.2 平行视图校正

### 8.3 平行视图对应点搜索

### 8.4 运动结构恢复

### 8.4.1 欧氏结构恢复

### 8.4.2 仿射结构恢复

### 8.4.3 透视结构恢复