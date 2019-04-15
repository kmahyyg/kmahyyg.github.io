---
title: 数据结构与算法课程 - Chap 4 串
date: 2019-01-05T01:15:48
description: "数据结构与算法课程期末复习记录 Chapter 4"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_school.webp"
categories: ["school"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# 数据结构复习 - Chapter 4 串

## 本质区分 （C 语言）

字符串：  " " 中间，本质是 **字符数组** ，本质是线性表结构，结尾 '\0' 不计入长度
字符： ' ' 中间的元素

## 基本操作

```c
StrAssign(&T, chars);  // 给字符串赋值
StrCpy(&T, S);   // 复制 S 到 T
StrCmp(S,T);     // 比较二进制的字符串是否符合
StrConcat(&T, S1, S2);   // 链接 S1 S2 至 T
Strlen(&S);      // 字符串长度
SubStr(&Sub,S, Pos,Len);   // 返回 S 中 pos 位（含）起长度为 len 的子串至 Sub
StrDestroy(&S);   // 销毁串 S
StrIsEmpty(&S);   // 串 S 判空
StrIndex(S, T, pos);   // 返回 T 在 S 的 pos 位置之后第一次出现的位置
StrIns(&S, pos, T);   // 串 S 的第 pos 个字符之前插入串 T
StrReplace(&S,T,V);   // 用 V 替换 S 中 符合 T 的串
```

## 表示与实现

### 机内表示

- 定长顺序表示： 静态存储，地址连续的存储单元。
- 堆分配存储： 动态分配的一块地址连续的存储单元。
- 串的块链存储表示：链式存储，块链存储，以 **“串的整体”作为操作对象** 。

#### 块链结构

1. 每个节点存放多个字符合理，多个是几个？存储密度计算：串值存储位/实际分配存储位。

块链结构描述：

- 每个结点存放多个字符
- 结点中空位采用特殊符号填充
- 设置 tail 指针指向链表中的最后一个节点位置，方便进行串链接操作，需要注意处理串尾的第一个无效字符。

## 模式匹配算法

BruteForce & KMP:

https://www.kmahyyg.xyz/2018/KMP-BF-DataStru/
