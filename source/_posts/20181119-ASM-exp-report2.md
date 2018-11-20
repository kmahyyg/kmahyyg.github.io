---
title: YNU - 汇编语言程序设计实验报告 4
date: 2018-11-19 13:09:43
tags:
  - Tech
  - School
---

## License

如未署名，所有 *.kmahyyg.xyz 的域名下的版权均为本人所有，遵循对应站点下的授权协议。

本篇文章授权 采用 CC BY-NC-ND 3.0 Unported 协议，禁止转载。

# Experiment 4

## 实验目的

使用虚拟机 Qemu-KVM 和调试器 Bochs，执行，调试 MBR 扇区代码，了解计算机启动的原理和 MBR 扇区代码的功能。

## 实验内容

1. 阅读参考源程序并增加注释；
2. 在参考源程序中增加指令(不要改变原程序的功能)，为程序增加功能：输出你的学号和姓名拼音；

SRC:     https://gist.github.com/kmahyyg/ce0d0e3079363f7be5d91f7ace0d9c0d

3. 使用 NASM 工具将修改后的实验源程序编译为 .bin 文件；
4. 将 .bin 文件用 dd 写入虚拟机硬盘 MBR 扇区；
5. 使用 Qemu-KVM 虚拟机观察写入 .bin 文件的执行结果；

Tutorial:    https://blog.kmahyyg.xyz/2018/ASM-exp-report/#%E5%AE%9E%E9%AA%8C%E6%93%8D%E4%BD%9C%EF%BC%9A%E7%BC%96%E8%AF%91%E5%AE%8C%E6%88%90%E5%90%8E%E7%9A%84-BOCHS-%E5%AF%BC%E5%85%A5

6. 关闭 Qemu-KVM，使用 BochsDBG 虚拟机调试写入在虚拟硬盘 MBR 扇区中的程序；

![2018-asmexp3-02.png](https://yygc.zzjnyyz.cn/asset_files/2018-asmexp3-02.png)

## 思考题

1. 计算机如何在屏幕上显示字符？

https://asm.kmahyyg.xyz/exps/exp7-transfer.html#quiz-2%EF%BC%9A-%E6%A0%B9%E6%8D%AE%E6%9D%90%E6%96%99%E7%BC%96%E7%A8%8B

2. 如何输入输出 10 进制数据？如何输入数字、字符串？

https://computer.howstuffworks.com/bios1.htm

https://blog.csdn.net/qq_28598203/article/details/51081368

结合中断向量表实现。

3. MBR 扇区有什么特点？MBR 扇区中的代码实现什么功能？

https://wiki.osdev.org/MBR_(x86)

4. 简述计算机复位后的启动过程。

https://wiki.osdev.org/Boot_Sequence

# COMING SOON

TODO

Updated on Tue Nov 20 21:22:34 CST 2018
Rev. 01

# Reference

https://thestarman.pcministry.com/asm/mbr/STDMBR.htm

https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-823-computer-system-architecture-fall-2005/index.htm

https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-828-operating-system-engineering-fall-2012/index.htm
