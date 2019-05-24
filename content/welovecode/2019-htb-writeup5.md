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
