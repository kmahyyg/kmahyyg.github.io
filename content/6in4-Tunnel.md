---
title: 6in4 Tunnel
date: 2018-05-21T17:01:53
description: "在 IPv4 Only 网络中尝试构建 6in4 隧道"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_network.webp"
categories: ["network"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# 背景

原本学校有 IPv6 双栈无线网络，然而网关最近坏了，恰逢各大高校 v6 PT 站 5.20 开放注册。
所以目前只有借用机房一台小跳板机器来实现。

# 尝试 OPENVPN

参考了很多教程，V6 路由一直不正常，Traceroute 第一跳都是 NULL，遂放弃。

# 尝试 iproute2

缺点：貌似只能在 Linux 系统下用

重点：开 NDP Proxy 和跨网卡 NAT 实现数据转发

代码： https://github.com/kmahyyg/6in4/

用法：懒得改某些机密信息了，随意吧。

服务器端运行 `sudo ./add_srv.sh`
客户端运行   `sudo ./add_cli.sh`

# PT站点支持情况

六维空间禁止隧道，南洋PT看起来正常且官方提供NAT端口转发教程。
