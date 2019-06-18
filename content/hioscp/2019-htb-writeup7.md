---
title: "HackTheBox - WriteUp 7"
date: 2019-06-18T18:55:47+08:00
description: "HackTheBox 练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# OneTwoSeven

## Before we start

All the same, nmap scan, gobuster enum.

22 & 80 Opened. But you're unable to gobuster it due to fail2ban.

## User

Access the site, go to `signup.php` page to find credentials designed for you. Then trying to SSH, get noticed that it only allows sftp connection.

You will find that the SFTP connection is in chroot directory, but since the signup page let you know where the page you uploaded is. You may access it via web. Since the Apache Web Server doesn't take the same environment as SFTP, so you can access some file via symlink.

First issue the command of SFTP `symlink` from `/etc/passwd` to `public_html/test1` and access `test1` via Web, Then `symlink` `/var/www` to find the webroot, here, you will get a SHA256 Hash in `/var/www/html_admin/admin.php.swp`, and you'll be able to see the requirements for you to login into the web admin panel. The admin panel must be access with 60080 and 127.0.0.1.

Then use `ssh -N -T -L 127.0.0.1:60080:127.0.0.1:60080 YOUR-USERNAME@10.10.10.133 sftp` to build a tunnel to admin panel. Like the name suggest, you need to build a tunnel like this and access it using `127.0.0.1` instead of `localhost`:

Localhost(Client):60080 -> SSH 10.10.10.133:22 -> Localhost(Server):60080

Manual page of ssh told us that:

> -N      Do not execute a remote command.  This is useful for just forwarding ports
> -L [bind_address:]port:host:hostport
    Specifies that connections to the given TCP port or Unix socket on the local (client) host are to be forwarded to the given host and port, or Unix socket, on the remote side.  This works by allocating a socket to listen to either a TCP port on the local side, optionally bound to the specified bind_address, or to a Unix socket.  Whenever a connection is made to the local port or socket, the connection is forwarded over the secure channel, and a connection is made to either host port hostport, or the Unix socket remote_socket, from the remote machine. Port forwardings can also be specified in the configuration file.  Only the superuser can forward privileged ports.  IPv6 addresses can be specified by enclosing the address in square brackets. By default, the local port is bound in accordance with the GatewayPorts setting.  However, an explicit bind_address may be used to bind the connection to a specific address.  The bind_address of “localhost” indicates that the listening port be bound for local use only, while an empty address or ‘*’ indicates that the port should be available from all interfaces.
> -T      Disable pseudo-terminal allocation.

So after you see the notice that you were only allowed to use SFTP, the tunnel has already established.

From the `swp` file you get, and using HashKiller, you will get username as `ots-admin` and password `Homesweethome1`.

After you logged in, you will get a user you may get from `/etc/passwd`, `ots-yODc2NGQ:f528764d`, then just download the user.txt from its home and `chmod 777`, you'll get the user flag.

## Root

Root this machine is really time-consuming. After you get the flag, use the `[DL]` link to download all the plugins you can get from the panel. The do some code review, check the notice from the plugin manager. Sinch the `addon-upload.php` is 404, you need to do the following things to build a PHP script contains shellcode and the items the system want:

In frontend:

- Modify the POST destination to `addon-download.php?/addon-upload.php`, check the source code of `ots-man-addon.php`, it will tell you how to bypass.
- Modify the submit button to remove the disable attribute.

In script:

- Make sure including the hashtag sign the system wants, the first three lines must be the same with other plugins.
- I strongly suggest you use Python in `shell_exec` to build a reverse shell. I don't know why `sh` reverse shell get killed immediately after connection established.
- The filename should always be `ots-****.php`

I just grabbed one from pentestmonkey reverse shell cheatsheet.

Then after you get a reverse shell, run `sudo -l`, you can see that all users may run `sudo` without password but only two commands with `env_keep = ftp_proxy http_proxy https_proxy no_proxy`:

- apt-get update
- apt-get upgrade

I also run a LinEnum but found nothing useful here.

So it's a APT MitM attack, check `/etc/apt/sources.list` and `/etc/apt/sources.list.d`, you will see a special repo designed for this purpose and all repo are in HTTP protocol instead of HTTPS. Don't forget to spawn a tty using Python before you use `sudo`.

Check the following referrence before continue:

- https://packages.roundr.devuan.org/devuan_mirror_walkthrough.txt
- https://blog.heckel.xyz/2015/10/18/how-to-create-debian-package-and-debian-repository/#Demo-package-netutils
- https://versprite.com/blog/apt-mitm-package-injection/

This box is running a Devuan, a more "free" distribution in Linux. However, since its `ascii` version is based on `stretch (debian 9)`, It uses a lot of packages coming from Debian directly.

Next, I believe that you have some knowledge about debian repository and packaging system. So make sure you've modify every place that may going with MD5 or SHA256 file checksum. And enable the `mitmproxy` with `wireshark` and http server log, this will help you build the correct directory tree to meet the APT need.

Here, I choose to modify `wget`, which was directly taken from Debian repo. So, download the package index from Devuan, download the package from deb.debian.org, unpack, modify, add postinst script to the package to do anything you want, repack, hash, modify the repo index, pack again. modify checksum, try harder. Then after you get the software you modified upgraded, you've taken the root. 

Repo will look like this:

```
.
├── devuan
│   ├── dists
│   │   └── ascii
│   │       ├── main
│   │       │   └── binary-amd64
│   │       │       ├── Packages
│   │       │       ├── Packages.xz
│   │       │       └── Release
│   │       └── Release
│   └── pool
│       └── main
│           └── w
│               └── wget_1.55-5+deb9u3_amd64.deb
```

(FINISHED)

I just add a `postinst` script in `DEBIAN` folder after unpack, copy the root flag to /tmp, and `chmod 777`. That's all.
