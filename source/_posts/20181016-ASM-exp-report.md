---
title: YNU - 汇编语言程序设计实验报告
date: 2018-10-16 13:24:31
tags:
  - Tech
  - School
---

# Unrelated

## Preface

由于过去不努力和各种原因，导致没有选到汇编课程。旁听课程，保存下了逍爷的 PPT，积极参与实验和旁听课程。

这就是我现在能做的，感谢王逍老师的辛勤付出。感谢我亲爱的钰帮我做的一切，么么哒！

也感谢 RainbowTrash23333 一直以来对我的帮助，没有他们，就没有现在的我。

最后感谢 #rich 的刘老板提供的已备案域名用于本站所有图片和其他资源文件的 OSS 存储与 CDN 加速。

废话不多说，上实验报告。这里由于并不提交正式的实验报告，就只是简单记录下实验步骤和踩的坑了，

用于抄袭后交作业者请自觉绕道，发现必将严惩。

## License

本篇文章授权 采用 CC BY-NC-ND 3.0 Unported 协议，禁止转载。

## Experiment Environment

Windows? 不可能的，不到 Linux 下完全没有替代工具或者我完全没时间折腾的时候我是打死都不会用的。

> Linus Torvalds: Your PC is like air-conditioning — it becomes useless when you open Windows.

So: 实验虚拟机全部采用 KVM 搭建，目前有 MSDOS 7.11 和 Windows XP SP3.


```
                   -`                    kmahyyg@PatrickY 
                  .o+`                   ---------------- 
                 `ooo/                   OS: Arch Linux x86_64 
                `+oooo:                  Host: Lenovo XiaoXin CHAO 7000 
               `+oooooo:                 Kernel: 4.18.14-arch1-1-ARCH 
               -+oooooo+:                Uptime: 1 hour, 25 mins 
             `/:-:++oooo+:               Packages: 1626 (pacman) 
            `/++++/+++++++:              Shell: zsh 5.6.2 
           `/++++++++++++++:             Resolution: 1920x1080, 1920x1080 
          `/+++ooooooooooooo/`           DE: KDE 
         ./ooosssso++osssssso+`          WM: KWin 
        .oossssso-````/ossssss+`         WM Theme: Arc-OSX-Dark-Transparent 
       -osssssso.      :ssssssso.        Theme: Breeze [KDE], deepin [GTK2/3] 
      :osssssss/        osssso+++.       Icons: Macos-sierra-CT-0.8.1 [KDE], appmenu-gtk-module [GTK2], deepin [GTK3] 
     /ossssssss/        +ssssooo/-       Terminal: konsole 
   `/ossssso+/:-        -:/+osssso+-     Terminal Font: Hack [simp] 11 
  `+sso+:-`                 `.-/+oso:    CPU: Intel i5-7200U (4) @ 3.100GHz 
 `++:.                           `-/+/   GPU: NVIDIA GeForce 940MX 
 .`                                 `/   GPU: Intel HD Graphics 620 
                                         Memory: 2296MiB / 7905MiB 

```

# Experiment 1

## 实验用到的软件环境

gcc (GCC) 8.2.1 20180831

Kate - Advanced Text Editor Version 18.08.2

## 实验要求

C 语言编写： 


```c
int x=学号后三位;
int y=学号后去掉最后一位的后四位;
int z=x+y;
printf("%d %d %d",x,y,z);
return 0;
```

之后编译生成 ASM 文件，查看并尝试解释 ASM 与 C 源代码的关系。

## 实验代码

C语言:

```c
#include <stdio.h>

int main(void){
        int x=152;    // 数据已经经过变换处理以保护隐私
        int y=2011;
        int z=x+y;
        printf("%d %d %d",x,y,z);
        return 0;
}
```

编译： `gcc -O -fverbose-asm -S -fno-pic -fno-plt -fno-pie -nodefaultlibs -std=c99 exp1.c -o exp1.noplt.s`

得到的 ASM 文件：

```asm6502
        .file   "exp1.c"
# GNU C99 (GCC) version 8.2.1 20180831 (x86_64-pc-linux-gnu)
#       compiled by GNU C version 8.2.1 20180831, GMP version 6.1.2, MPFR version 4.0.1, MPC version 1.1.0, isl version isl-0.19-GMP

# Here is the default compiler options which was builtin while compiler compile itself. Just delete them to reduce the text size.

        .text
        .section        .rodata.str1.1,"aMS",@progbits,1
.LC0:
        .string "%d %d %d"
        .text
        .globl  main
        .type   main, @function
main:
.LFB3:
        .cfi_startproc
        subq    $8, %rsp        #,               ; 修改堆栈基址寄存器，进入过程。
        .cfi_def_cfa_offset 16
# exp1.c:7:     printf("%d %d %d",x,y,z);
        movl    $2163, %ecx     #,               ; 根据显示顺序，编译器预先完成加法计算后写入 ASM， 并将数据写入到对应寄存器
        movl    $2014, %edx     #,               ; 传递立即数到指定寄存器
        movl    $149, %esi      #,
        movl    $.LC0, %edi     #,               ; Read-Only Text data to be passed to the function
        movl    $0, %eax        #,               ; Pass the beginning address to the EAX register
        call    *printf@GOTPCREL(%rip)  #        ; 调用系统标准C语言库中预定义好的 printf 宏实现打印到屏幕，具体请参考 GLIBC 的 stdio 实现
# exp1.c:9: }
        movl    $0, %eax        #,               ; 0 传入 EAX，保存程序执行得到的返回值
        addq    $8, %rsp        #,               ; 自加8 传入 栈基址寄存器 RSP，设置堆栈指针。主要用于实现堆栈平衡，即 程序执行前后 ESP 不变。
        .cfi_def_cfa_offset 8
        ret                                      ; 使用栈中的数据修改 IP，实现近转移，最终返回父进程。
        .cfi_endproc
.LFE3:
        .size   main, .-main
        .ident  "GCC: (GNU) 8.2.1 20180831"
        .section        .note.GNU-stack,"",@progbits
```

## 实验分析

请参见上方的 ASM 中 `;` 开头的代码注释。

## 实验总结

体验 C 到 ASM 的转化，为之后的反编译和逆向打下基础。

# Experiment 2

## 实验用到的软件环境

gcc (GCC) 8.2.1 20180831

Bochs x86 Emulator 2.6.9

bximage 和 dd 工具

Kate - Advanced Text Editor Version 18.08.2

## 实验目的

练习使用 Bochs 的调试功能，为接下来的调试操作系统或者底层代码做准备。

## 实验要求

使用 NASM 编译给出的源代码，在计算机启动时打印你的学号。使用 BochsDBG 进行调试。

## 实验源代码

```asm6502
MOV AX,0xb810            ; move to the screen buffer
MOV DS,AX                ; move the base addr to the buffer

MOV BYTE[0x00], '2'      ; put the data into the buffer
MOV BYTE[0x02], 'A'
MOV BYTE[0x04], 'B'
MOV BYTE[0x06], 'C'
MOV BYTE[0x08], '1'
MOV BYTE[0x0A], 'W'      ; student id data hidden for privacy protection
MOV BYTE[0x0C], 'O'
MOV BYTE[0x0E], 'R'
MOV BYTE[0x10], '1'
MOV BYTE[0x12], 'L'
MOV BYTE[0x14], 'D'

JMP $                    ; loop the above code and done for fatal error

TIMES 510 - ($-$$) DB 0  ; pad remainder of boot sectors with 0
DB 0x55,0xAA             ; the standard PC boot signature
```

编译： `nasm ./exp2.asm -fbin -owx -lwx.lst`

产生的 wx 文件：`DOS/MBR boot sector`

## 实验操作：编译完成后的 BOCHS 导入

**请先查阅 Bochs 手册和对应工具的 manpage 以熟悉基础操作。**

### 1. 写 Bochs RC 虚拟机启动配置文件

范例文件请参考： `/etc/bochsrc-sample.txt`

```yaml
floppy_bootsig_check: disabled=1
boot: floppy, disk, cdrom
floppya: image="boot.img", status=inserted
ata0-master: type=disk, mode=flat, path="boot.img", cylinders=0
```
最后两行二选一，建立 1.44M 镜像。

### 2. 建立虚拟机磁盘镜像并写入对应的 Boot Sector

目的：建立 BOCHS 允许体积的镜像用于虚拟机启动，修改 0 扇区以实现 MBR 启动。

- bximage 创建镜像

type: fd, size: 1.44, name: boot.img, Done.

请根据 `bximage` 的输出修改你的 Bochs RC 文件。

- dd 写入镜像

```bash
$ dd if=wx.bin of=boot.img bs=512 count=1 conv=notrunc oflag=direct
```

### 3. 启动虚拟机

```bash
$ bochs -q -f new.bochsrc
```

### 备用：挂载修改镜像

```bash
$ sudo mount ./floppya.img /mnt/floppy/ -o loop
```

## 实验结果与分析总结

源代码相关总结请参见前文。

### Part 1: 启动成功

![STARTUP EXP02](https://yygc.zzjnyyz.cn/asset_files/2018-asmexp1.png)

踩了很多坑，主要是镜像建立和不截断写入数据。

### Part 2: 关于 Bochs 的使用

BIOS 执行完成后，会跳转到 0x7c00 位置，我们使用 `b 0x7c00` 在这里下断。

> BOCHS 简易指南
> 命令 c  运行程序，相当于windbg的g以及OD的F9
> 命令 s  即step，单步执行程序
> 命令 p  单步执行，步过函数
> 命令 q  退出bochs并关闭虚拟机
> 命令 b  下断点命令，如本例中：b 0x7c00
> 命令 blist  显示断点状态
> 命令 watch  显示当前所有读写断点
> 命令 r  显示寄存器的值
> 命令 u  反汇编代码，可设定起始和结束位置
> 命令 info 根据参数不同显示相关信息

接下来交替使用 s 和 p 交替执行，直到 BIOS 加载完成。因为现有知识不足以看清楚 BIOS 加载和启动过程，我们直接使用 c 执行 BIOS 程序直到断点。

![BOCHSDBG EXP02](https://yygc.zzjnyyz.cn/asset_files/2018-asmexp2.png)

到达断点处，可以看到我们编写的汇编程序源代码。最终会陷入死循环（看起来就是没动静），这时候，如果 Bochs 调试器不处于等待输入状态，则使用 Ctrl-C 跳回解释器，接下来使用 q 命令退出。

简单调试完成。对应截图中可能涉及隐私泄露的信息已经打码，很抱歉给各位带来的糟糕的体验。 

# 临时分割线

（暂时完结）

Updated on Tue Oct 16 21:52:16 CST 2018

Rev.3

# Reference

https://stackoverflow.com/questions/35762970/jmp-in-nasm-bootloader

https://stackoverflow.com/questions/137038/how-do-you-get-assembler-output-from-c-c-source-in-gcc

https://stackoverflow.com/questions/38335212/calling-printf-in-x86-64-using-gnu-assembler

https://stackoverflow.com/questions/37902940/disable-got-in-gcc

https://stackoverflow.com/questions/35762970/jmp-in-nasm-bootloader

https://www.nasm.us/doc/nasmdo12.html

https://www.cnblogs.com/chengxuyuancc/archive/2013/05/13/3076524.html
