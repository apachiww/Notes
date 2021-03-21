# 计算机视觉/3D重构

关键词： SLAM

## 1 摄像机几何

### 1.1 针孔摄像机，透镜

针孔成像模型，就是将空间一个点通过小孔映射到胶片（一个平面）上面的过程

设想一个针孔成像的侧视图，小孔在胶片下方，发光点在小孔下方，在小孔处建立一个三维坐标系。针孔到胶片的距离为$f$（就是焦距，和$z$轴同向）。设空间一个发光点$A(x,y,z)$，那么胶片上该发光点的成像点$y$坐标为$f\dfrac{y}{z}$。同理可以得到$x$坐标为$f\dfrac{x}{z}$

由于针孔成像亮度和清晰度不可兼得，所以引入透镜

**透镜的焦距：平行光通过透镜到达焦点，到透镜中心的距离$f$**

以后只考虑透镜到胶片的距离$z_0$，这代表图像只有在特定的一段距离以内才可以清晰成像

**畸变：分为枕形畸变和桶形畸变**

**枕型畸变：成像点远离中心**

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

齐次坐标相对一般坐标（二次，三次）添加一个**齐次项**，如下

$$
p=(x,y,z)\rightarrow\begin{bmatrix}x \\ y \\ z \\ 1 \end{bmatrix}
$$

点的齐次坐标可以转换为欧氏坐标，不同的齐次坐标点可能对应相同的欧氏坐标点（举一个比较生动的例子，如果看到了两个形状大小相同的物体，它们可能距离不同，而且距离远的那个物体更大）

$$
\begin{bmatrix}
x \\ y \\ w
\end{bmatrix}
\rightarrow(x/w,y/w)
$$

**在一般的计算机图形学/视觉中，三维坐标一般添加一个1。而在经过投影变换以后得到具有3个元的二维坐标（投影面坐标），再将其转变为欧氏坐标就是其在投影平面的位置**


### 1.2.2 摄像机映射矩阵

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


### 1.2.3 齐次坐标常用变换矩阵

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

### 1.2.4 世界坐标系

世界坐标系用于设定一个绝对参考。如果使用相机坐标系，相机移动以后坐标也会变。将以上齐次坐标变换矩阵代入

世界坐标系到摄像机坐标系的转变，$R$为旋转部分，$T$为平移部分

$$
P=\begin{bmatrix}
R & T \\
0 & 1 \\
\end{bmatrix}P_w
$$

其中$P_w=\begin{bmatrix}x_w \\ y_w \\ z_w \\ 1 \end{bmatrix}$为世界坐标

