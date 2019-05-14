---
title: "Net-Speeder Shell Script[弃用]"
description: "不建议使用: 使用 netspeeder 通过多倍发包加速网络"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_network.webp"
categories: ["network"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
date: 2016-06-18T13:41:00
---

# Net-Speeder 启动相关规则

net-speeder 的使用方法为 `./net_speeder 网卡名 加速规则`

其中加速规则采用 bpf 规则，一般常用下面规则来启动 

```
./net_speeder venet0 "ip" 
./net_speeder venet0 "tcp" 
```

有 V 友讨论过，这样可能存在安全隐患，这个帖子里用 iptables 来处理，但总觉得未从根源来解决 


其实可以用 bpf 规则使之只复制发出的包，下面 3 条规则供参考 
复制本机发出的 tcp 包： `./net_speeder venet0 "tcp and src host 本机 IP 地址"`
复制本机某个端口发出的 tcp 包： `./net_speeder venet0 "tcp src port 端口号 and src host 本机 IP 地址"`
复制本机多个端口发出的 tcp 包： `./net_speeder venet0 "(tcp src port 端口号 1 or 端口号 2 or 端口号 3) and src host 本机 IP 地址"`
（本机 IP 地址不要用 `127.0.0.1` ，可用 `ifconfig | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " " | grep -v '127\.0\.0\.'` 来获取）
复制本机发出的 tcp 和 udp 包： `./net_speeder venet0 "(tcp or udp) and src host 本机 IP 地址"` 

语法参考 

http://biot.com/capstats/bpf.html 
http://blog.csdn.net/jk110333/article/details/8675547
https://www.v2ex.com/t/248273 
