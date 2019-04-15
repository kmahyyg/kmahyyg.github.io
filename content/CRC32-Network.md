---
title: 关于 C 的 CRC32 实现
date: 2018-12-04T21:14:28
description: "CRC32 是数据包校验的一个重要算法，本文主要记录作者的一些思考。"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code","school"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Preface

最近讲了计算机网络课程，在上课过程中明白了 CRC32 的人工计算方法。个人猜测后面计算机网络实验会做，趁最近忙碌，一鼓作气，在刚刚学完的时候一起实现了吧。

## 关于 CRC32

具体的原理性的东西就不说了，大家自己搜索 IEEE 802.3 相关文档和维基百科吧。主要用途是传输过程中的错误检测，由于容错率高，简单易于实现，占用资源少，得到了广泛的应用。

### 关于 手动计算

就那点内容，其实我也很懵逼，就多查查资料吧。剩下的就是 `Talk is cheap, show me the code!` ，大家自己根据 Reversed CRC32 的 GZip 实现参考吧。

```cpp
// C Native implement, CRC32

// Reference: RFC1952 https://tools.ietf.org/html/rfc1952
// Reference: PEDIY https://bbs.pediy.com/thread-17195.htm
// Reference: CSDN https://blog.csdn.net/xiaogugood/article/details/8724745
// Reference: https://stackoverflow.com/questions/2587766/how-is-a-crc32-checksum-calculated
// Reference: http://stigge.org/martin/pub/SAR-PR-2006-05.pdf

// Written by Patrick Young
// Created on Tuesday, December 11, 2018 2:57 PM
// Updated on Wednesday, December 12, 2018 1:06 PM
// Rev.5

/*
 * The highest bit of the generator is always 1, so ignored in the polyabbr.
 *
 * Algorithm   Result   	Check      	     Poly        Init       RefIn 	RefOut 	XorOut      ReversedPoly
    CRC-32	 0xCBF43926	  0xCBF43926	0x04C11DB7	  0xFFFFFFFF	true	true	0xFFFFFFFF   0xEDB88320
 */

#include <stdio.h>
#include <inttypes.h>
#include <string.h>
#include <stdlib.h>

unsigned long crc_table[256];  // Table of CRCs of all 8-bit messages
int is_crc_table_computed = 0;

//计算本字节后的CRC码，等于上一字节余式CRC码的低8位左移8位，加上上一字节CRC右移8位和本字节之和后所求得的CRC码
void make_crc_table(void){
    unsigned long c;
    for (int n = 0; n < 256; ++n) {
        // all groups contains 8 bits * 4 * n, XOR can be passed without any external opeation
        // divide the msg into 8-bit-long group
        c = (unsigned long) n;
        for (int k = 0; k < 8; ++k) {
            if (c & 1){
                // Least-Significant-Bit first.
                // Same CRC property but reversed to fit old hardware(low memory address save lower bits of data.)
                c= 0xedb88320L ^ (c >> 1);  // 0 is non-sense.
            } else {
                c= c >> 1;
            }
        }
        crc_table[n] = c;
    }
    is_crc_table_computed = 1;
}

/*
 * Update a running crc with the bytes buf[0..len-1] and return
the updated crc. The crc should be initialized to zero. Pre- and
post-conditioning (one's complement) is performed within this
function so it shouldn't be done by the caller. Usage example:
 *
 *  unsigned long crc = 0L;
 *
 *  while (read_buffer(buffer, length) != EOF) {
 *      crc = update_crc(crc, buffer, length);
 *  }
 *   if (crc != original_crc) error();
 *
*/

unsigned long update_crc(unsigned long crc, unsigned char *buf, int len){
    unsigned long c = crc ^ 0xffffffffL;

    if (!is_crc_table_computed){
        make_crc_table();    // build the crc table first for fast lookup
    }
    /*
    （1）将上次计算出的CRC校验码右移一个字节；
    （2）将移出的这个字节与新的要校验的字节进行XOR运算；
    （3）用运算出的值在预先生成码表中进行索引，获取对应的值（称为余式）；
    （4）用获取的值与第（1）步右移后的值进行XOR运算；
    （5）如果要校验的数据已经处理完，则第（4）步的结果就是最终的CRC校验码。如果还有数据要进行处理，则再转到第（1）步运行。
     */
    for (int p = 0; p < len; ++p) {
        c = crc_table[(c ^ buf[p]) & 0xff] ^ (c >>8);
        // remove the non-sense zero and shifted bits
    }
    return c ^ 0xffffffffL;
    // avoid "add zero as you want, not affected" problem
}

unsigned long crc(unsigned char *buf, int len){
    // Math theory by hand: (quotient + remainder)/divisor = 0
    // appended 0s is used for be a placeholder of remainder
    return update_crc(0L,buf,len);      // recursive update crc checksum.
}

int check_crcsum(unsigned char *src, unsigned long sum){
    // why should I calculate the damn divide
    // (data+crc) / divisor = 000 ,correct
    unsigned long xr = crc(src,(int)strlen(src));
    // just calculate received data's CRC, check if corresponding is okay.
    printf("The source is %s, Checksum calculated is: 0x%lx\n", src, xr);
    if (xr == sum){
        printf("Data CRC check passed! \n\n");
        return 0;
    }
    else {
        printf("The offered checksum 0x%lx is different from offered one. \n",sum);
        printf("Data Corrupted! \n");
        return 1;
    }
}

void printUsage(char *argv[]){
    printf("Illegal input! \n");
    printf("Usage: %s <SOURCE STRING> 0x<CRC32SUM>\n",argv[0]);
    printf("Usage: If you want to calculate, just input source in ASCII mode. \n");
    printf("Usage: If you want to check, use the second param such as 1A3C5D78 as a HEX String.\n\n");
}

int main(int argc, char* argv[]){
    if (argc != 2 && argc !=3) {
        printUsage(argv);
        return -1;
    } else if (argc == 2){
        char *ipt = argv[1];
        unsigned long final = crc(ipt,(int)strlen(ipt));
        printf("The source is: %s\n",ipt);
        printf("The CRC32 checksum is: 0x%lx \n\n",final);
        return 0;
    } else if (argc == 3){
        char *ipt = argv[1];
        char *csum = argv[2];
        if (strlen(csum) != 8){
            printUsage(argv);
            return -1;
        }
        unsigned long hexcsum = strtoul(csum,NULL,16);
        int stats = check_crcsum(ipt,hexcsum);
        return stats;
    }
}

```

## 参考文献

https://www.xilinx.com/support/documentation/application_notes/xapp209.pdf
