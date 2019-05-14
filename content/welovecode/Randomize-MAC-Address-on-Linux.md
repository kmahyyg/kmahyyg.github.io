---
title: Randomize MAC Address on Linux
date: 2018-06-25T17:28:07
description: "隐私防护的议题逐渐提上日程，MAC 随机化也是很重要的一部分。"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Background

Fuck dormmate! They watch the FIFA via speakers the whole night.
Disconnect their network should work. Or else, I have to buy a network channel filler.

# Method

## Method 1: Use the Bash Script

```bash
#!/bin/bash
randmac=$(echo 03:6a:2f:`openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//'`)
sudo ifconfig eth0 down
sudo ifconfig eth0 hw ether $randmac
sudo ifconfig eth0 up
exit 0
```

## Method 2: Randomize everytime when you connect

/etc/NetworkManager/conf.d/randmac.conf
```
[device-mac-randomization]
# "yes" is already the default for scanning
wifi.scan-rand-mac-address=yes

[connection-mac-randomization]
# Randomize MAC for every ethernet connection
ethernet.cloned-mac-address=random
# Generate a random MAC for each WiFi and associate the two permanently.
wifi.cloned-mac-address=random
```
