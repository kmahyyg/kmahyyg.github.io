---
title: Java 语言笔记 - 控制流程
date: 2019-03-30T15:20:58
description: "Java 语言关于控制流程的课程笔记"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["school","code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Java 语言笔记 - 控制流程

Last Edited: Mar 30, 2019 3:20 PM

1. 关于变量的生命周期与重定义问题

每一 Block 之内的变量只能定义一次，只在当前 Block 及其子 Block 内有效，且不能重复定义。

2. 关于判断与循环

```java
    while(condition) statement;
    
    do{} while();
    
    if(){}else if(){} else{};
    
    for(int i=1; i≤10; i++){}  // Please Note: DON'T DETECT FLOATING VALUE.
    
    switch(choice){case 1: break; default: break;}
```

请不要在 for 循环中检测终止使用浮点数，因为可能因为二进制浮点数在计算机中的保存问题造成死循环。

3. 带标签的 break 语句

```java
    label:  {
    
    ...
    
    if (condition) break label;
    
    if (condition) continue;   // jump back to the first line of the block
    
    ...
    
     }  // jump here when the break statements executes
```
