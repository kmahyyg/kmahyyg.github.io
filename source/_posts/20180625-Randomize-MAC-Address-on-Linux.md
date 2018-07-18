---
title: Randomize MAC Address on Linux
date: 2018-06-25 17:28:07
tags:
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