---
title: Installation of OpenVAS
date: 2017-09-16T01:53:09
description: "OpenVAS 的一次安装实践"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Before Installation

### Change APT Repository

```bash
sudo apt-get update -y
sudo vi /etc/apt/sources.list
sudo echo "113.55.12.55 mirrors.ynuosa.org" >> /etc/hosts
:% s/cn.archive.ubuntu.com/mirrors.ynuosa.org
:wq
```

### Add Kali Repository and Install Software

```
sudo wget -qO- https://www.kali.org/archive-key.asc | sudo apt-key add -
sudo echo "deb http://mirrors.ynuosa.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list
sudo add-apt-repository ppa:mrazavi/openvas
sudo apt-get update -y
sudo su
apt-get update -y
apt-get install openvas libopenvas9 libopenvas9-dev greenbone-security-assistant sqlite3 -y
```

# After Installation

```
openvas-setup
openvas-check-setup
openvas-feed-update
openvasmd --user admin --new-password fuCkY0USh!t
openvas-stop
openvas-start
```

## Prevent suddenly crash


> >     most likely the known issue where redis is blocking any access by the
> >     scanner due to unknown reasons. This should do the trick:
> >
> >     1. Delete dump.rdb (somewhere in /var/run/redis or similar)
> >     2. Comment out/remove all "save xy z" (e.g. save 900 1) from your
> >     redis.conf
> >     3. restart redis
> >     4. restart scanner and try again
>
> --
>
> Christian Fischer | PGP Key: 0x54F3CE5B76C597AD
> Greenbone Networks GmbH | http://greenbone.net
> Neumarkt 12, 49074 Osnabrück, Germany | AG Osnabrück, HR B 202460
> Geschäftsführer: Lukas Grunwald, Dr. Jan-Oliver Wagner
