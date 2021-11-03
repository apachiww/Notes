# 高数笔记

### 2.1 极限

### 2.1.1 区间和邻域

**区间定义**

$(a,b)$称为开区间，$[a,b]$称为闭区间，$(a,b]$称为半开区间，$(a,+\infty)$称为无限区间

**邻域定义**

$a$的邻域$U(a)$：以$a$为中心的**任何开区间**

$a$的$\delta$邻域$U(a,\delta)$：$U(a,\delta) = \{x | |x - a| \lt \delta \}$

$a$的$\delta$去心邻域$\mathring U(a,\delta)$：$\mathring U(a,\delta) = \{x | 0 \lt |x - a| \lt \delta \}$


### 2.1.2 确界

在一个实数集$E$中，如果存在一个$M$，使得对于任意一个$x\in E$有$x \le M$（或$x \ge M$），那么$M$称为$E$的上（下）确界

如果$E$有**上界和下界**，那么称$E$**有界**，反之$E$**无界**

**确界**

如果$E$有上界$\beta$，并且对于任意$\epsilon \gt 0$存在$x_0 \in E$使得$\beta - \epsilon \lt x_0$，那么$\beta$就是$E$的**上确界**


### 2.1.3 函数

**函数的单调性**

函数$y = f(x)$的定义域为$D$，区间$I \subset D$，在$I$上任取$x_1 \lt x_2$，有$f(x_1) \le f(x_2)$，那么称函数在$I$单调递增

**函数的有界性**

函数在定义域内区间$I$如果存在$K$使得任意$x \in I$有$f(x) \le K$，那么$K$称为$f(x)$在$I$的一个上界

如果函数在$I$**既有上界也有下界**，那么称$f(x)$在$I$有界

**函数的奇偶性**

如果一个函数$f(x)$定义域$D$关于原点对称，并且对于任意$x\in D$有$f(-x) = -f(x)$，那么函数在$D$为奇函数；如果$f(-x) = f(x)$，那么函数为偶函数

**函数的周期性**

对于一个定义域为$D$的函数$f(x)$，若存在正数$l$，使得对于$D$上任意$x$，有$f(x) = f(x\pm l)$，那么$f(x)$为周期函数，周期为$l$

**反函数**

函数$f: D \rightarrow f(D)$是单射，那么其逆映射$f^{-1}: f(D) = D$就是其反函数，$f(x) = y(x \in D) \Rightarrow f^{-1}(y) = x(y \in f(D))$

**复合函数**

设$y = f(u)$定义域为$D_f$，$u = g(x)$定义域为$D_g$，$R_g \subset D_f$，那么函数$y = f[g(x)], x\in D_g$称为复合函数

**基本初等函数**

| 名称 | 形式 |
| :-: | :-: |
| 幂函数 | $y = x^a$ |
| 指数函数 | $y = a^x(a\gt 0) \\ y = e^x$ |
| 对数函数 | $y = \log_a(x)(a\gt 0) $ |
| 三角函数 | $y = \sin(x) = \dfrac{1}{\csc(x)} \\ y = \cos(x) = \dfrac{1}{\sec(x)} \\ y = \tan(x) = \dfrac{1}{\cot(x)}$ |
| 反三角函数 | $y = \arcsin(x) \\ y = \arccos(x) \\ y = \arctan(x)$ |

其中三角函数：

$$\begin{aligned} \sin(a+b) &= \sin(a)\cos(b) + \cos(a)\sin(b) \\ \cos(a+b) &= \cos(a)\cos(b) - \sin(a)\sin(b) \\ \tan(a+b) &= \dfrac{\tan(a) + \tan(b)}{1 - \tan(a)\tan(b)} \end{aligned}$$

$$\begin{aligned} \sin(a)\cos(b) = \dfrac{1}{2}(\sin(a+b) + \sin(a-b))\end{aligned}$$

**初等函数**

| 名称 | 形式 |
| :-: | :-: |
| 取整函数 | $y = [x]$ |
| 双曲函数 | $\sh(x) = \dfrac{e^x - e^{-x}}{2} \\ \ch(x) = \dfrac{e^x + e^{-x}}{2} \\ \th(x) = \dfrac{e^x - e^{-x}}{e^x + e^{-x}}$ |

其中双曲函数：

$$\begin{aligned} \sh(a+b) &= \sh(a)\ch(b) + \ch(a)\sh(b) \\ \ch(a+b) &= \ch(a)\ch(b) - \sh(a)\sh(b) \end{aligned}$$

$$ arsh(x) = \ln(x + \sqrt{x^2 + 1}) $$

> 推导过程:
> 令$u = e^y$
> $$\begin{aligned} x &= \sh(y) = \dfrac{e^y - e^{-y}}{2} \\ &= \dfrac{u - \dfrac{1}{u}}{2} \\ 0 &= u^2 - 2ux - 1 \\ \Rightarrow u &= x + \sqrt{x^2 + 1} \\ \Rightarrow y &= \ln(x + \sqrt{x^2 + 1}) \end{aligned}$$


### 2.1.4 数列极限

设数组$\{x_n\}$，其中$x_n = f(n), n\in \mathbb{N}^*$

若对于任意$\epsilon \gt 0$，存在$N \in \mathbb{N}^*$使得$n \gt N$时$| x_n - a | \lt \epsilon$，那么$\{a_n\}$以$a$为极限

$$\lim_{x \rightarrow \infty}x_n = a$$

数列极限具有**唯一性**，收敛数列$\{x_n\}$一定**有界**，$\{x_n\}$的**子数列也收敛且极限相同**


### 2.1.5 函数极限

**自变量有限值时的函数极限**

对于任意$\epsilon \gt 0$，存在$\delta \gt 0$，使得$0 \lt |x - x_0| \lt \delta$（去心邻域）时$| f(x) - A | \lt \epsilon$（即$| f(x) - A |$可以无限小），那么$A$就是$x \rightarrow x_0$时$f(x)$的极限

$$ \lim_{x\rightarrow x_0}f(x) = A $$

**左右极限**

左右极限分别代表从$x_0$左侧和右侧接近$x_0$时的极限，分别用

$$\lim_{x \rightarrow x_0^-}f(x) \\ \lim_{x \rightarrow x_0^+}f(x)$$

表示

**自变量无穷大时的函数极限**

对于任意$\epsilon \gt 0$，存在$X \gt 0$，使得$|x| \gt X$时$| f(x) - A | \lt \epsilon$（即$| f(x) - A |$可以无限小），那么$A$就是$x \rightarrow \infty$时$f(x)$的极限

$$ \lim_{x\rightarrow \infty}f(x) = A $$

函数极限具有**唯一性**，**局部有界性**以及**局部保号性（局部符号一致）**


### 2.1.6 无穷小和无穷大

**无穷小**：如果一个函数$f(x)$在$x\rightarrow x_0$时极限为0，那么称$f(x)$为$x\rightarrow x_0$时的无穷小

$$ \lim_{x\rightarrow x_0}f(x) = 0 $$

$x\rightarrow \infty$同理

$$ \lim_{x\rightarrow \infty}f(x) = 0 $$

有限个无穷小的和依然是无穷小

有界函数和无穷小的乘积依然是无穷小

**无穷大**：如果一个函数$f(x)$在$x\rightarrow x_0$时，$| f(x) |$无限增大，就称$f(x)$为$x\rightarrow x_0$时的无穷大

$$ \lim_{x\rightarrow x_0}f(x) = \infty $$

$x\rightarrow \infty$同理

$$ \lim_{x\rightarrow \infty}f(x) = \infty $$

可以是正无穷或负无穷

$$ \lim_{x\rightarrow \infty}f(x) = -\infty \\ \lim_{x\rightarrow \infty}f(x) = +\infty $$

如果$f(x)$无穷小，那么$\dfrac{1}{f(x)}$无穷大


### 2.1.7 极限四则运算

极限四则运算和普通数字四则运算基本相同，这里不再赘述

复合函数极限：设$y = f(g(x))$，$f(g(x))$在$\mathring U(x_0)$内有定义，$\lim_{x\rightarrow x_0}g(x) = a$，$\lim_{u\rightarrow a}f(u) = A$，那么

$$ \lim_{x\rightarrow x_0}f(g(x)) = A $$


### 2.1.8 极限存在准则

**夹逼定理**

设$f(x),g(x),h(x)$为3个函数，如果

$$ x\in \mathring U(x_0), g(x) \le f(x) \le h(x) \\ \lim h(x) = \lim g(x) = A$$

那么

$$ \lim f(x) = A $$

**单调有界原理**

如果$\{x_n\}$为一数列，且存在$N_0 \in \mathbb{N}^*$使$n \gt N_0$时$x_n$单调，同时$| x_n | \le M$有界，那么$\{x_n\}$收敛

**柯西极限准则**

$\{x_n\}$收敛的充要条件是对于任意$\epsilon \gt 0$，总存在$N \in \mathbb{N}^*$使得$n \gt N, m \gt N$时有$| x_n - x_m | \lt \epsilon$（无限小）


### 2.1.9 无穷小比较

如果$\lim \dfrac{\beta}{\alpha} = 0$那么$\beta$为$\alpha$的**高阶无穷小**，$\lim \dfrac{\beta}{\alpha} = \infty$那么$\beta$为$\alpha$的**低阶无穷小**，$\lim \dfrac{\beta}{\alpha} = c$那么$\beta$为$\alpha$的**同阶无穷小**，若$c = 1$则为**等价无穷小**（$\beta$ ~ $\alpha$）

若$\alpha$ ~ $\alpha'$ ， $\beta$ ~ $\beta'$，那么$\lim \dfrac{\beta}{\alpha} = \lim \dfrac{\beta'}{\alpha'}$


### 2.1.10 函数连续性

若

$$ \lim_{\Delta x \rightarrow 0}\Delta y = \lim_{\Delta x \rightarrow 0} [f(x_0 + \Delta x) - f(x_0)] = 0 $$

或

$$ \lim_{x \rightarrow x_0} f(x) = f(x_0) $$

那么$f(x)$在$x_0$**连续**

反之若

$f(x)$在$x_0$无定义，或$\lim_{x \rightarrow x_0} f(x)$不存在，或$\lim_{x \rightarrow x_0} f(x) \neq f(x_0)$

那么$f(x)$在$x_0$**间断**

**可去间断点（一类间断点）**

函数$f(x)$在$x_0$处**左右极限存在**，$\lim_{x \rightarrow x_0^-}f(x) = \lim_{x \rightarrow x_0^+}f(x) \neq f(x_0)$

**跳跃间断点（一类间断点）**

函数$f(x)$在$x_0$处**左右极限存在**，$\lim_{x \rightarrow x_0^-}f(x) \neq \lim_{x \rightarrow x_0^+}f(x)$

**无穷间断点（二类间断点）**

函数$f(x)$在$x_0$处**左右极限不存在**，$\lim_{x \rightarrow x_0^-}f(x)$和$\lim_{x \rightarrow x_0^+}f(x)$都为$\infty$

**振荡间断点（二类间断点）**

函数$f(x)$在$x_0$处**左右极限不存在**，且$x\rightarrow x_0$时无限振荡

**一致连续函数**

如果$f(x)$在闭区间$[a,b]$连续，那么它在$[a,b]$一致连续

**最大最小值定理**

闭区间上连续函数一定有最大最小值

**有界性定理**

闭区间上连续函数必有界

**零点定理**

若$f(x)$在$[a,b]$连续且$f(a)f(b)\lt 0$，那么$f(x)$在$[a,b]$上必定存在零点

**介值定理**

若$f(x)$在$[a,b]$连续且$f(a) = A, f(b) = B$那么对于任意一个介于$AB$之间的$C$，$ab$之间至少有一点$\xi$使得$f(\xi) = C$


### 2.2 导数和微分

导数反映函数的瞬时变化速率，定义如下

$$ \lim_{\Delta x \rightarrow 0}\dfrac{\Delta y}{\Delta x} = \lim_{\Delta x \rightarrow 0} \dfrac{f(x_0 + \Delta x) - f(x_0)}{\Delta x} $$

可以表示如下形式之一

$$ \left. \dfrac{dy}{dx} \right|_{x = x_0}, \left. \dfrac{df}{dx} \right|_{x = x_0} $$

**可导一定连续，连续不一定可导**

### 2.2.1 基本初等函数求导

| 函数 | 导数 |
| :-: | :-: |
| $(C)'$ | $0$ |
| $(x^a)'$ | $ax^{a-1}$ |
| $(a^x)'$ | $a^x\ln(a)$ |
| $(e^x)'$ | $e^x$ |
| $(\log_a x)'$ | $\dfrac{1}{x\ln(a)}$ |
| $(\ln x)'$ | $\dfrac{1}{x}$ |
| $(\sin x)'$ | $\cos x$ |
| $(\cos x)'$ | $\sin x$ |
| $(\tan x)'$ | $\dfrac{1}{\cos^2x} = \sec^2x$ |
| $(\csc x)'$ | $-\csc x \cdot \cot x$ |
| $(\sec x)'$ | $\sec x \cdot \tan x$ |
| $(\cot x)'$ | $-\csc^2 x$ |
| $(\arcsin x)'$ | $\dfrac{1}{\sqrt{1 - x^2}}$ |
| $(\arccos x)'$ | $-\dfrac{1}{\sqrt{1 - x^2}}$ |
| $(\arctan x)'$ | $\dfrac{1}{1 + x^2}$ |
| $(arc\cot x)'$ | $-\dfrac{1}{1 + x^2}$ |
| $(\sh x)'$ | $\ch x$ |
| $(\ch x)'$ | $\sh x$ |
| $(ar\sh x)'$ | $\dfrac{1}{\sqrt{x^2 + 1}}$ |
| $(ar\ch x)'$ | $\dfrac{1}{\sqrt{x^2 - 1}}$ |


### 2.2.2 导数运算以及复合函数求导

$$ \begin{aligned} &[u(x) \pm v(x)]' = u'(x) \pm v'(x) \\\ &[u(x) \cdot v(x)]' = u'(x)v(x) + u(x)v'(x) \\\ &\left[\dfrac{u(x)}{v(x)}\right]' = \dfrac{u'(x)v(x) - u(x)v'(x)}{v^2(x)} \end{aligned} $$

复合求导

$$ \begin{aligned} \{f[g(x)]\}' &= f'(u)g'(x) \\ \dfrac{dy}{dx} &= \dfrac{dy}{du} \cdot \dfrac{du}{dx} \end{aligned} $$

**求导技巧举例**

> $$ y = f(x) = \sqrt{\dfrac{(x - 1)(x - 2)}{(x - 3)(x - 4)}} $$
>
> 可以对两边同时取对数，最后将$y$代入即可
>
> $$ \begin{aligned} \dfrac{y'}{y} &= \dfrac{1}{2} \left( \dfrac{1}{x - 1} + \dfrac{1}{x - 2} - \dfrac{1}{x - 3} - \dfrac{1}{x - 4} \right) \\ \Rightarrow y' &= \dfrac{1}{2} y \left( \dfrac{1}{x - 1} + \dfrac{1}{x - 2} - \dfrac{1}{x - 3} - \dfrac{1}{x - 4} \right) \end{aligned} $$


### 2.2.3 高阶导数

表示形式

$$ \left. \dfrac{d^2 y}{dx^2} \right|_{x = x_0}, \left. \dfrac{d^2f}{dx^2} \right|_{x = x_0}$$

$$ \dfrac{d^2 f}{dx^2} = \dfrac{d}{dx}(\dfrac{df}{dx}) $$

**莱布尼兹公式**

$$
\begin{aligned}
&(uv)' = u'v + uv' \\
&(uv)'' = u''v + 2u'v' + v''u \\
&(uv)''' = u'''v + 3u''v' + 3u'v'' + uv''' \\
&(uv)^n = \sum_{k = 0}^n C^k_n u^{n-k} v^{k}
\end{aligned}
$$


### 2.2.4 特殊求导法

**反函数**

设$y = f(x)$和$x = \varphi(y)$互为反函数

那么$\varphi'(y) = \dfrac{1}{f'(x)}$

由此可以推导

$$
x = \sin y, y = \arcsin x \\
y'_x = \arcsin'{x} = \dfrac{1}{x'_y} = \dfrac{1}{\cos y} = \dfrac{1}{\sqrt{1 - \sin^2y}} = \dfrac{1}{\sqrt{1 - x^2}}
$$

**隐函数**

隐函数$F(x,y) = 0$

隐函数求导的基本方法就是对等式**左右同时求导**

$$ \dfrac{x^2}{16} - \dfrac{y^2}{8} = 1 $$

设左右同时对$x$求导

$$ \dfrac{2x}{16} - \dfrac{2yy'}{8} = 0 $$

最终得到

$$ y' = \dfrac{x}{2y} $$

**参数方程**

参数方程$\begin{cases} x = \varphi(t) \\ y = \psi(t) \end{cases}$

那么$t = \varphi^{-1}(x)$

$y = \psi(\varphi^{-1}(x))$

所以最终可以得到

$$ \dfrac{dy}{dx} = \dfrac{dy}{dt}\cdot \dfrac{dt}{dx} = \dfrac{\psi'(t)}{\varphi'(t)} $$

$$ \dfrac{d^2y}{dx^2} = \dfrac{\psi''(t)\varphi'(t) - \psi'(t)\varphi''(t)}{\varphi'^3(t)} $$


### 2.2.5 微分

$f(x)$在$x_0$可微$\Leftrightarrow$$f(x)$在$x_0$可导

$y = f(x)$微分公式形式

$$
dy = f'(x)dx
$$

运算法则

$$
\begin{aligned}
&d(u \pm v) = du \pm dv \\
&d(u \cdot v) = udv + vdu \\
&d\left(\dfrac{u}{v} \right) = \dfrac{vdu - udv}{v^2}
\end{aligned}
$$


### 2.3 中值定理

### 2.4 不定积分

### 2.5 定积分

### 2.6 多元函数微分

### 2.7 重积分

### 2.8 曲线/曲面积分

### 2.9 无穷级数

### 2.10 微分方程