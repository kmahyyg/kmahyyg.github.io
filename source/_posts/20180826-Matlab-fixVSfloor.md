---
title: fix() 与 floor() 函数的区别
date: 2018-08-26 23:37:50
tags:
  - School
---

> 转载自: http://blog.sina.com.cn/s/blog_574d08530100p1bp.html
> 国内各大博客关的关，停的停，干脆转过来存档
> 版权归原作者所有

fix(x), floor(x) 和 ceil(x) 函数都是对 x 取整，只不过取整方向不同而已。

这里的方向是以x轴作为横坐标来看的，向右就是朝着正轴方向，向左就是朝着负轴方向。

fix(x)：向 0 取整（也可以理解为向中间取整）

floor(x)：向左取整

ceil(x)：向右取整

举例：

4个数：a=3.3、b=3.7、c=-3.3、d=-3.7

fix(a)=3

floor(a)=3

ceil(a)=4

------------------------

fix(b)=3

floor(b)=3

ceil(b)=4

----------------------

fix(c)=-3

floor(c)=-4

ceil(c)=-3

------------------------

fix(d)=-3

floor(d)=-4

ceil(d)=-3
