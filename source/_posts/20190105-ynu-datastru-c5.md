---
title: 数据结构与算法课程 - Chap 5 数组和广义表
date: 2019-01-05 01:15:56
tags:
  - School
  - Datastru
---

# 数据结构复习 - Chapter 5 数组和广义表

## 数组

高级语言中的数组一定是顺序结构，元素的值并非原子类型，可以再分解。 **广义的线性表包括线性表元素组成的线性表**

**这里的数组中的每一维度的元素长度是不相同的。**

### 数组的顺序保存结构的地址计算

1. 多维数组的元素存储反复故事： 行优先/列优先。
2. 数组寻址格式： 起始位置 + 数组 A 前面保存的元素 × 元素的长度。
3. 画图！画图啊！

### 广义的数组顺序表示

```c
#include <string.h>
#define MAX_ARRAY_DIM 8
typedef struct{
    ElemType *baseaddr;
    int dim;
    int *bounds;
    int *constants;
}Array;
```

Baseaddr: 存储数组的内存空间的基地址
Dim: 数组的最高维度
Bounds： 存储每一维数组长度的内存空间的基地址
Constants： 存放各数据的内存空间的基地址

### 应用举例

#### 可变长参数列表 stdarg.h

https://www.kmahyyg.xyz/2018/DS04-Maze-EXP/#stdarg-h-%E5%9C%A8-C-%E4%B8%AD%E7%9A%84%E5%BA%94%E7%94%A8

```cpp
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
int echoinfo(char *strNotice, ...);
int main(int argc, char *argv[]){
    char noti[50] = {0};
    strcpy(noti,"The printout is");
    echoinfo(noti, argv[1], argv[2], argv[3]);
    return 0;
}
int echoinfo(char *strNotice, ...){
    char *str0 = NULL;
    char *str1 = NULL;
    char *str2 = NULL;
    va_list stArgv;         // define a param list
    va_start(stArgv, strNotice);      // pass the fixed param to the function
    str0 = va_arg(stArgv, char*);
    str1 = va_arg(stArgv, char*);
    str2 = va_arg(stArgv, char*);
    printf("%s: %s %s %s", strNotice, str0, str1, str2);
    va_end(stArgv);
    return 0;
}
```

#### 矩阵的压缩存储

- 为多值相同的元素只分配一个存储空间
- 对 0 元素不分配存储空间
- 值相同或 0 元素在矩阵中的分布有一定规律，则称其为特殊矩阵，否则称之为稀疏矩阵。（也就是说正常的矩阵应当是稀疏的）
- 保存格式 <行，列，值>

## 特殊矩阵

### 三角矩阵

数组保存的下标：
  - 上三角：[列*(列-1)]/2+行
  - 下三角：[行*(行-1)]/2+列

#### 重点：矩阵的转置

快速转置算法： 

每一列第一个非零元素保存个数位置 = 上一列第一个非零元素保存位置 + 上一列非零元素。

num 数组 存储 M 中 第 col 列中非 0 元素个数
cpot 数组 存储 M 中 第 col 列的非 0 元素在 T.data 中的保存位置。

把转置后的位置放到 cpot 数组对应的位置，然后 cpot++;

#### 稀疏矩阵的乘法

矩阵乘法 = **M 矩阵该行所有元素对应与 N 矩阵该列所有元素分别相乘之和**

#### 十字链表

[所在行，所在列，非零元素，向右域，向下域]

## 广义表

表头 = 头元素，第一个元素
表尾 = **后面的所有元素，表尾必须是一个广义表**

广义表特点：有次序性、有长度、有深度、可以递归定义、可以共享。
广义表的长度：最外层括号的元素个数
广义表的深度：括号层数（有多少括号匹配）

数据保存时，需要添加 tag 标志域，区分表节点与数据 (Atom) 节点。

[tag=0,data=atom]
[tag=1,headptr=head,endptr=tail]

headptr 永远指向表或者表元素，也是唯一一个可以直接指向 atom 元素的指针。

广义表中的数据元素有数据的相对次序，一个直接前驱、一个直接后继。

广义表的 ADT 表示，借此复习 ADT 的表示方法：

```cpp
ADT Glist {
    数据对象：
    D＝{ei | i=1,2,..,n; n≥0; ei∈AtomSet或ei∈Glist}
    数据关系：
    LR＝{<ei-1, ei>| ei-1 ,ei ∈D,  2≤i≤n }
    基本操作：
    InitGList(&L);          //创建空的广义表L。
    DestroyGList(&L)        //销毁广义表L。
    CreateGList(&L, S)      //由串S创建广义表L。
    CopyGList(&T, L)        // 由广义表L复制得到广义表T。
    GListLength(L);  GListDepth(L);  GListEmpty(L);    // 判深、判空、判长
    GetHead(L);             //取表头 (可能是原子或列表);
    GetTail(L);             //取表尾 (一定是列表) 
    InsertFirst_GL(&L, e);  //插入元素e作为广义表L的第一元素。
    DeleteFirst_GL(&L, &e)  //删除广义表L的第一元素，并用e返回其值。
}ADT Glist
```
