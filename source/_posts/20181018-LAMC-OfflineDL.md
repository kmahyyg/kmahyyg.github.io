---
title: CAMAL 离线下载套件
date: 2018-10-18 13:26:19
tags:
  - Tech
---

# 前言

CAMAL 离线下载套件，顾名思义：Linux + Caddy + Aria2 + Mldonkey + AriaNG 用于简单搭建一个离线下载系统。

上述提到的软件均将运行在 x86_64 架构的计算机上。请在部署时注意您和您所租用的离线下载服务器所在地的法律法规，本人不承担任何相关的法律责任。

如您需要 不接受 DMCA 争议的离岸服务器，请参考本人最后一个参考文献。

# 软件下载与基础部署

示例环境：Ubuntu 18.04.1 LTS Full Installation via LXC Virtualization

- Caddy Webserver with FileManager

```bash
# apt update -y
# apt install curl wget ca-certificates -y
# curl https://getcaddy.com | bash -s personal http.filemanager,http.forwardproxy,http.ipfilter,http.login,http.minify,http.nobots,http.upload,tls.dns.rfc2136
```

关于 CaddyServer 的 systmed 后台守护，请参见 [此处](https://github.com/mholt/caddy/tree/master/dist/init/linux-systemd)

- [AriaNG Web前端](https://github.com/mayswind/AriaNg/releases/download/0.5.0/AriaNg-0.5.0.zip)

- Aria2

推荐使用参考文献中对应的一键脚本直接部署，方便简洁快速。如果您熟悉相关配置，您也可以选择从软件仓库安装之后手动配置。

```bash
$ sudo apt update -y
$ sudo apt install aria2 -y
$ # 编辑配置文件
$ aria2c -D --conf-path <Config file path>
```

一键脚本链接：

```bash
# wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/aria2.sh && chmod +x aria2.sh && bash aria2.sh
```

- MlDonkey

从软件仓库安装并启动：

```bash
$ sudo apt update -y
$ sudo apt install mldonkey-server -y
$ # 编辑系统配置文件 /var/lib/mldonkey/downloads.ini
$ sudo systemd enable mldonkey-server
$ sudo systemd start mldonkey-server
```

## 部分配置文件

# CDN 中转加速

## 准备域名

## CNAME 接入 Cloudflare 加速

# 参考文献

- [Caddy Server Documentation](https://caddyserver.com/docs)
- [Doubi Location](https://doub.io/goflyway-jc3/)
- [Cloudflare $5000 Route](https://www.dcc.cat/cloudflare/)
- [HE.net DNS](https://dns.he.net/)
- [Caddy Filemanager](https://doub.io/jzzy-3/)
- [Aria 2 Onekey Script](https://doub.io/shell-jc4/)
- [AriaNG WebUI](https://github.com/mayswind/AriaNg)
- [MLDonkey Config](http://mldonkey.sourceforge.net/Allowed_ips)
- [Hostsolutions Anti-DMCA VPS](https://secure.hostsolutions.ro/aff.php?aff=513&pid=271)
