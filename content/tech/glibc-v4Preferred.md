---
title: "对指定域名的解析 IPv4 结果优先"
date: 2019-06-05T00:32:14+08:00
description: "对 GLIBC getaddrinfo 函数进行配置，A 记录优先级高于 AAAA 记录"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_network.webp"
categories: ["network"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
--- 

# Preface

Application Environment:

1. You have a native dual-stack network.
2. The route to destination via IPv6 is broken or much more slower than IPv4.
3. The latency is 20x faster in IPv4 comparing to IPv6.

# Depend on your situation

You have those methods listed below:

- Block the route to destination via IPv6.
- Use `iptables-wrapper` -like tool to remove the AAAA response in the packet.
- Force IPv4 globally.
- Hack the `getaddrinfo()` in GLIBC.
- Disable IPv6 in specific software.

I strongly recommend you to achieve this in DNS layer or just disable IPv6, not in IP layer, due to the IP corresponding to the specific domain name may get changed someday.

## Force IPv4 globally

1. Open a terminal window.
2. Change to the root user.
3. Issue the command sysctl -w net.ipv6.conf.all.disable_ipv6=1
4. Issue the command sysctl -w net.ipv6.conf.default.disable_ipv6=1

## Disable IPv6 in specific software (eg. apt)

----------

echo `Acquire::ForceIPv4 "true";` > `/etc/apt/apt.conf.d/99force-ipv4`

----------

OR specify `AF_INET` in `AddressFamily` when you open a socket.

----------

## Use wrapper software with iptables

[DNS-dropper](https://alicdn.kmahyyg.xyz/asset_files/dns-dropper.tar.xz) by [@lilydjwg](https://blog.lilydjwg.me/) , Thanks a lot to him.

It works like a DNS proxy, filter the AAAA inside a DNS response packet and feedback to software.

If you are an Arch Linux User, just run the binary inside with a domain blacklist in this way:

```bash
$ echo "fuckyou.com" > domain.txt
$ sudo ./dns-dropper domain.txt
```

## Block the route

Issue a command with `sudo`: `sudo ip route add unr xxxx:xxxx::xxxx`

`unr` means `unreachable`.

## Hack the glibc getaddrinfo

CAUTION: THIS METHOD SHOULD BE USED AT LAST AND IN A VERY CAREFULLY WAY!
IT MAY BROKEN YOUR WHOLE INTERNET CONNECTION IF CONFIGURED IN AN IMPROPER WAY!

This way ONLY APPLIED to softwares which rely on `getaddrinfo()` system call in GLIBC.

You should read the RFC listed in Reference list to know what's behind to make sure you understand what you are going to do.

Step-By-Step Tutorial:

- Get the AAAA and A result for the host you need to block 
- Check its IP range and subnet mask using ipip.net
- Convert A Response to IPv4-mapped IPv6 address via [Convert tools](https://www.ipaddressguide.com/ipv4-to-ipv6)
- Calculate converted address subnet mask
- Read each line carefully and backup `/etc/gai.conf`
- Append `reload yes` to `/etc/gai.conf`, it will allow you to check the result immediately (OPTIONAL).
- Append `precedence <IPv4-Mapped Addr> <Larger precedence, like 100>` to `/etc/gai.conf`
- Append `precedence <IPv6 Addr in AAAA Response> <Smaller precedence, like 10>` to `/etc/gai.conf`
- Done!

# Reference

- https://tools.ietf.org/html/rfc6145
- https://tools.ietf.org/html/rfc4291
- https://tools.ietf.org/html/rfc6724
- https://tools.ietf.org/html/rfc7757
- https://tools.ietf.org/html/rfc6555
- https://tools.ietf.org/html/rfc3484
- http://man7.org/linux/man-pages/man5/gai.conf.5.html
