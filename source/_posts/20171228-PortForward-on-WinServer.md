---
title: PortForward on WinServer
date: 2017-12-28 11:56:06
tags:
  - Tech
---

```
netsh interface portproxy add v4tov4 listenaddress=INTERFACEIP listenport=LOCALPORT connectaddress=REMOTEIP  connectport=REMOTEPORT
```
