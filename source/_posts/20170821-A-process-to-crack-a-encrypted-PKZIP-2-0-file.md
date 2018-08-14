---
title: A process to crack a encrypted PKZIP 2.0 file
date: 2017-08-21 01:21:49
tags:
  - Code
---

# Preface

开学前看到班群里发了任务8：破解zip文件密码

# 任务内容

> 任务八：走进安全
>
> * 破解离散数学2015年加密期中文件的口令
> 参考资料1: [密码分析](https://zh.wikipedia.org/wiki/%E5%AF%86%E7%A0%81%E5%88%86%E6%9E%90)
------------------ *这个是我自己加的，原本任务内容没有* -----------------
> 参考资料2: [Pkzip官方文件头描述文档](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT)
> 参考资料3: [Pkzip文件架构分析](https://users.cs.jmu.edu/buchhofp/forensics/formats/pkzip.html)
> 参考资料4: [zip加密算法分析1](https://eprint.iacr.org/2004/078.pdf)
> 参考资料5: [zip加密算法分析2](https://courses.cs.ut.ee/MTAT.07.022/2015_fall/uploads/Main/dmitri-report-f15-16.pdf)
> 参考资料6: [pkzip传统加密算法的无密文破解分析](https://www.cs.auckland.ac.nz/~mike/zipattacks.pdf)
------------------ *这个是我自己加的，原本任务内容没有* -----------------
> 
> 可选：
> 1.破解离散数学2015年加密期末文件的口令
> 2.了解压缩文件使用的加密算法

# 文件分析

## 分析HEADER，明确加密算法

老样子，Total Commander，使用内置Lister以hex形式打开加密后的文件。
看到：

> 00000000   504b 0304 1400 0100 0800 6d51 6647 03ae

查看参考资料2，得知文件头的格式如下：

>    4.3.6 Overall .ZIP file format:
>
>      [local file header 1]
>      [encryption header 1]
>      [file data 1]
>      [data descriptor 1]
>      . 
>      .
>      .
>      [local file header n]
>      [encryption header n]
>      [file data n]
>      [data descriptor n]
>      [archive decryption header] 
>      [archive extra data record] 
>      [central directory header 1]
>      .
>      .
>      .
>      [central directory header n]
>      [zip64 end of central directory record]
>      [zip64 end of central directory locator] 
>      [end of central directory record]

分析：

![local-file-header.png](https://yygc.zzjnyyz.cn/asset_files/pkzip1.png)

0x04034b50 (Must read in little-endian)   定义为文件头标签，即让OS知道这是个zip文件     

>      文档4.3.7部分
>      local file header signature     4 bytes  (0x04034b50)
>      version needed to extract       2 bytes
>      general purpose bit flag        2 bytes

0x00010014

由参考资料2可知，0x0014为最低的解压软件版本(20)，即至少需要 PKzip 2.0可以解压。
0x0001表示这是一个加密过的压缩文件。

### 可选任务2 ，看到这也就顺手完成了。

> 参考资料2 4.4.3.2
>  1.0 - Default value
   1.1 - File is a volume label
   2.0 - File is a folder (directory)
   2.0 - File is compressed using Deflate compression
   2.0 - File is encrypted using traditional PKWARE encryption
   2.1 - File is compressed using Deflate64(tm)
   2.5 - File is compressed using PKWARE DCL Implode 
   2.7 - File is a patch data set 
   4.5 - File uses ZIP64 format extensions
   4.6 - File is compressed using BZIP2 compression*
   5.0 - File is encrypted using DES
   5.0 - File is encrypted using 3DES
   5.0 - File is encrypted using original RC2 encryption
   5.0 - File is encrypted using RC4 encryption
   5.1 - File is encrypted using AES encryption
   5.1 - File is encrypted using corrected RC2 encryption**
   5.2 - File is encrypted using corrected RC2-64 encryption**
   6.1 - File is encrypted using non-OAEP key wrapping***
   6.2 - Central directory encryption
   6.3 - File is compressed using LZMA
   6.3 - File is compressed using PPMd+
   6.3 - File is encrypted using Blowfish
   6.3 - File is encrypted using Twofish

## 回归正题

由上可知，这个文件最低的解压缩软件要求版本是2.0，也就是说它在1.0 1.1是无法解压的，那么也不可能是过高的版本，知道了它使用了传统的 PKWARE 加密方式。

鉴于C语言没学，具体的算法和思路代码自己参看参考资料4吧。
无奈了，大概能看懂一些东西，就是crc32 + uint8/16/32 + xor + 伪随机数据流的一个东西。

好吧，转到Github，看看有没有大神写了crack代码并开源。找到了，然后把它附到了我的站点上，需要的自取。

## bruteforce cracker

Upload some [brute-force cracker](https://yygc.zzjnyyz.cn/asset_files/zipcracker-bruteforce-real.rar) for pkzip.
Still Cracking using DO .

