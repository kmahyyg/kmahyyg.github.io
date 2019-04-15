---
title: Arch Linux
draft: false
displayInMenu: true
displayInList: false
dropCap: false
---

## libvirt 4.6.0-2

请使用 Arch Linux 的用户注意，不要更新 libvirt 4.6.0-2 ，更新此版本后出现了无法链接  qemu:///system 和  qemu:///sessions 的情况。官方确认是由于引入的 Jansson 无法解析 QEMU's quirky JSON 目前已经 Revert back 回 yajl 。

请已更新的用户尽快升级至 4.6.0-3，该版本已经修复这个问题。

## mesa 18.0.4-1

#Arch_Linux  FS#58933 (https://bugs.archlinux.org/task/58933) 已经在 mesa 18.1.6-1  修复，使用 NVIDIA 显卡配合 primusrun 和最新 X.org Server 运行的用户可以尝试从 mesa 18.0.4-1 升级后无需任何手工操作即可体验。

相关： Github: SegmentFault with primusrun+mesa+xorg-server (https://github.com/amonakov/primus/issues/201)

## systemd 241.93

Failed to start Network Time Synchronization

上游链接： https://github.com/systemd/systemd/issues/12131#issuecomment-477617212

手动修复方案：

```bash
$ sudo rm /var/lib/systemd/timesync
$ sudo systemctl restart systemd-timesyncd
```

预计修复版本：systemd v243
