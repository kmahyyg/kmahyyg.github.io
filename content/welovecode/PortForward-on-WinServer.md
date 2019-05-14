---
title: PortForward on WinServer
date: 2017-12-28T11:56:06
description: "Windows Server 端口转发设置"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

```
netsh interface portproxy add v4tov4 listenaddress=INTERFACEIP listenport=LOCALPORT connectaddress=REMOTEIP  connectport=REMOTEPORT
```
