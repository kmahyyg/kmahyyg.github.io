---
title: YNU - 汇编语言程序设计实验报告 4-5
date: 2019-01-11T20:58:01
description: "学校汇编语言课程的实验报告 2"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code","school"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
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

![2018-asmexp3-02.png](https://alicdn.kmahyyg.xyz/asset_files/2018-asmexp3-02.webp)

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

# Experiment 6

## 实验目的

接受键盘输入，保存到磁盘；从磁盘读取，显示到屏幕。

## 实验实现

目前问题：

Can： 接受输入、保存到 FDD，从磁盘读取，读取到指定的具体的固定 RAM 地址并显示。

<del>Cannot： 读取到变量对应的地址并显示，读取 FDD 成功但写入 RAM 失败... 已修复： dx 和 bx 两个寄存器中传入的地址存在问题</del>

接受输入，写入 FDD 的代码：

```asm6502
dataarea segment
    buffer db 64   ; max 63 bytes string
           db ?
    string db 64 dup ('$')  ; preallocated with '$', int 21h/0ah output
dataarea ends

codesg segment

;START PROC
main proc far
    assume cs:codesg,ds:dataarea
    
start:

;SAVE THE CURRENT SITUATION FOR RET
    push ds
    sub ax,ax
    push ax
    
;POINT CORRESPONDING DATA REGISTER
    mov ax,dataarea
    mov ds,ax

;GET INPUT FROM KEYBOARD
    lea dx,buffer
    mov ah,0ah
    int 21h
    
;PREPARE ES:BX to where data to be wrote into
    mov ax,dataarea
    mov es,ax
    lea bx,string
    
;WRITE DATA TO FDD, 0 Cylinder: 0 Track: 4 Sector
;Each sector has 512 bytes
    mov ah,3  ; 3 for write
    mov al,1  ; how many sectors to write
    mov dh,0  ; cylinder
    mov ch,0  ; track
    mov cl,4  ; sector
    mov dl,0  ; drive no. 
    ;0:FDD-A, 1:FDD-B, 80H:HDD-C, 81H:HDD-D
    int 13h 
    
    ret
main endp
codesg ends
    end start 
```

从 FDD 中读取内容并显示在屏幕上：
```asm6502
datasg segment
    readout db 512 dup ('$')
datasg ends

codesg segment

start:
        mov ax,datasg
        mov ds,ax
        mov es,ax
        lea bx,readout   ;ready for read buffer
        
        mov ah,2
        mov al,1
        mov dh,0
        mov ch,0
        mov cl,4
        mov dl,0
        int 13h
        
        mov dx,offset readout
        mov ah,9
        int 21h
        
        mov ax,4c00h
        int 21h

codesg ends
end start
```

### Reference

接受输入之后回显打印：

```asm6502
;sudo mount -o loop,offset=$(python -c 'print(512*63)') /var/lib/libvirt/images/dosdata.img /mnt/nfs1

dataarea segment
    buffer db 64
           db ?
    string db 64 dup ('$')
    hint   db 10,13,'$'
dataarea ends

codesg segment
main proc far
    assume cs:codesg,ds:dataarea
start:
    push ds
    sub ax,ax
    push ax

    mov ax,dataarea
    mov ds,ax

    lea dx,buffer
    mov ah,0ah
    int 21h

    mov cx,2
    
newl:
    lea dx,hint
    mov ah,9h
    int 21h

    loop newl
    
    lea dx,string
    mov ah,9h
    int 21h
    
    ret
main endp
codesg ends
    end start 
```

**不要忘记打末尾的 `h`**

```
INT 13h / AH = 02h - read disk sectors into memory.
INT 13h / AH = 03h - write disk sectors.
    input:
AL = number of sectors to read/write (must be nonzero)
CH = cylinder number (0..79).
CL = sector number (1..18).
DH = head number (0..1).
DL = drive number (0..3 , for the emulator it depends on quantity of FLOPPY_ files).
ES:BX points to data buffer.
    return:
CF set on error.
CF clear if successful.
AH = status (0 - if successful).
AL = number of sectors transferred. 
Note: each sector has 512 bytes.
```

```
INT 21h / AH=9 - output of a string at DS:DX. String must be terminated by '$'. 
example:
        org 100h
        mov dx, offset msg
        mov ah, 9
        int 21h
        ret
        msg db "hello world $"
```

```
INT 21h / AH=0Ah - input of a string to DS:DX, fist byte is buffer size, second byte is number of chars actually read. this function does not add '$' in the end of string. to print using INT 21h / AH=9 you must set dollar character at the end of it and start printing from address DS:DX + 2. 
```

# END

本学期的汇编课程所有的的随堂实验就到此告一段落，感谢 王逍 老师的精心付出。
和 钰 在各方面的帮助，爱你！

Updated on 2019-01-11 20:58:01
Rev. 11

# Reference

https://thestarman.pcministry.com/asm/mbr/STDMBR.htm

https://thestarman.pcministry.com/asm/bios/index.html

https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-823-computer-system-architecture-fall-2005/index.htm

https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-828-operating-system-engineering-fall-2012/index.htm

https://stackoverflow.com/questions/41196376/int-10h-13h-bios-string-output-not-working

http://www.ablmcc.edu.hk/~scy/CIT/8086_bios_and_dos_interrupts.htm

https://wiki.osdev.org/ATA_PIO_Mode

https://stackoverflow.com/questions/8461363/access-harddrive-using-assembly
