---
title: rem() 与 mod() 函数的区别
date: 2018-08-26T23:34:13
description: "Matlab 里一些函数的使用与区别 1"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_school.webp"
categories: ["school"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

> 转载自: http://blog.sina.com.cn/s/blog_633750d90100gs8p.html
> 国内各大博客关的关，停的停，干脆转过来存档
> 版权归原作者所有

取模（mod）与取余（rem）的区别 —— Matlab 学习笔记【09-11-15】

本帖来自:数学中国 作者: 木长春 日期: 2009-11-15 19:51

昨天在学习 Matlab 的数学函数时，教程中提到取模（mod）与取余（rem）是不同的，今天在网上具体查了一下：

通常取模运算也叫取余运算，它们返回结果都是余数. rem 和 mod 唯一的区别在于:

x 和 y 的正负号一样的时候，两个函数结果是等同的；当 x 和 y 的符号不同时，rem 函数结果的符号和x的一样，而 mod 和 y 一样。

这是由于这两个函数的生成机制不同，rem 函数采用 fix 函数，而 mod 函数采用了 floor 函数（这两个函数是用来取整的，fix 函数向 0 方向舍入，floor 函数向无穷小方向舍入）。
rem（x，y） 命令返回的是 x-n.*y ，如果 y 不等于0，其中的n = fix(x./y)，而 mod(x,y) 返回的是 x-n.*y，当 y 不等于 0 时，n = floor(x./y)


两个异号整数取模取值规律            （当是小数时也是这个运算规律，这一点好像与C语言的不太一样）

先将两个整数看作是正数，再作除法运算

①能整除时，其值为0

②不能整除时，其值=除数×(整商+1)-被除数


例：mod(36,-10)=-4

即：36除以10的整数商为3，加1后为4；其与除数之积为40；再与被数之差为（40-36=4）；取除数的符号。所以值为-4。

例：mod(9,1.2)=0.6

例：

>> mod(5,2)
ans =1                   %“除数”是正，“余数”就是正

>> mod(-5,2)
ans =1

>> mod(5,-2)
ans =-1                  %“除数”是负，“余数‘就是负

>> mod(-5,-2)
ans =-1                  %用rem时，不管“除数”是正是负，“余数”的符号与“被除数”的符号相同

>> rem(5,2)
ans =1                   %“被除数”是正，“余数”就是正

>> rem(5,-2)
ans =1

>> rem(-5,2)
ans =-1                 %“被除数”是负，“余数”就是负

>> rem(-5,-2)
ans =-1


