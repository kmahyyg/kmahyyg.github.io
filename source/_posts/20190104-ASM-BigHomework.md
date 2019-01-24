---
title: 2018 汇编大作业
date: 2019-01-04 20:12:43
tags:
  - School
  - Tech
---

## 整体思路

读取输入 -> 处理输入 -> 与密码比较 -> 装入 Decoder -> Decoder 装载 MBR

观察发现 MS-DOS 7.11 和 WinXP 的 磁盘，1～31 扇区均为空！（0 扇区为 MBR）

## Reference

https://stackoverflow.com/questions/1396909/ret-retn-retf-how-to-use-them

https://sourcegraph.com/github.com/sunnyden/MBRLock@master/

https://www.felixcloutier.com/x86/

https://asminst.kmahyyg.xyz/

https://blog.csdn.net/u013630349/article/details/50370227
