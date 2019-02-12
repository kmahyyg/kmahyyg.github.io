---
title: 2018 汇编大作业
date: 2019-02-08 09:24:00
tags:
  - School
  - Tech
---

## 整体思路

![workflow chart](https://alicdn.kmahyyg.xyz/asset_files/2019-asmbighw-flow.webp)

Storage:
-  Test

Encrypt:
-  Test

Decrypt:
-  Test

MBR PlaceHolder:


## Source code 

Check [Github Repository](https://github.com/kmahyyg/MBRLock) , Please.

All source codes are well-commented. If you have any questions, please open a Issue in GitHub.

## Reference

观察发现 MS-DOS 7.11 和 WinXP 的 磁盘，1～31 扇区均为空！（0 扇区为 MBR）

- https://stackoverflow.com/questions/21463908/x86-instructions-to-power-off-computer-in-real-mode
- https://wiki.osdev.org/APM
- https://stackoverflow.com/questions/1396909/ret-retn-retf-how-to-use-them
- https://stackoverflow.com/questions/39474332/assembly-difference-between-var-and-var/39474660
- https://sourcegraph.com/github.com/sunnyden/MBRLock@master/
- https://www.felixcloutier.com/x86/
- https://asminst.kmahyyg.xyz/
- https://blog.csdn.net/u013630349/article/details/50370227
- https://docs.microsoft.com/en-us/cpp/cpp/argument-passing-and-naming-conventions?view=vs-2017
