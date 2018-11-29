---
title: YNU - 汇编语言程序设计实验报告 4-5
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

# Experiment 5

## 实验目的

了解计算机屏幕显示的原理，编程实现显存映射与中断 `int 10H` 式。

## 实验内容

1. 使用控制显存显示内容。

> 略，之前的实现均使用的这种方式。MASM 与 NASM 的差异，在使用这种方式时差异不大，此处略去不表。

2. 使用 `int 10H` 方式显示数据。

看这里！这里有代码： 

MASM: https://gist.github.com/kmahyyg/4e8dc523f513ff78a53c18e4234460af

NASM: https://gist.github.com/kmahyyg/4e8dc523f513ff78a53c18e4234460af

## 思考题

1. 注释源程序

已经注释了，懒得多写废话，具体的详细文档自己看后面的 Reference。这里略微一提， BIOS 是一个最小型的系统，在硬件支持 int 13h 对应的显示模式的前提下，可以通过 BIOS 中断向量 int 10h 调用显示 API。

具体参考这里 https://protas.pypt.lt/informatika/assembler/writing_to_the_screen

2.显示字符的方式

就两种，实验目的里写的很清楚，具体的自己去查资料。

## END

本学期的汇编课程的随堂实验就到此告一段落，感谢 王逍老师的精心付出 
和 钰在各方面的帮助，爱你！

Updated on Thu Nov 29 23:41:30 CST 2018
Rev. 07

# Reference

https://thestarman.pcministry.com/asm/mbr/STDMBR.htm

https://thestarman.pcministry.com/asm/bios/index.html

https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-823-computer-system-architecture-fall-2005/index.htm

https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-828-operating-system-engineering-fall-2012/index.htm

https://stackoverflow.com/questions/41196376/int-10h-13h-bios-string-output-not-working

http://www.ablmcc.edu.hk/~scy/CIT/8086_bios_and_dos_interrupts.htm
