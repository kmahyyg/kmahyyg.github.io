---
title: CAMAL 离线下载套件
date: 2018-10-18 13:26:19
tags:
  - Tech
---

# 前言

CAMAL 离线下载套件，顾名思义：Caddy + AriaNG + Mldonkey(ED2K) + Aria2(BT+PT+HTTP+FTP+MAGNET) + Linux 用于简单搭建一个离线下载系统。

上述提到的软件均将运行在 x86_64 架构的计算机上。请在部署时注意您和您所租用的离线下载服务器所在地的法律法规，本人不承担任何相关的法律责任。

如您需要 不接受 DMCA 争议的离岸服务器，请参考本人最后一个参考文献。

# 软件下载与基础部署

示例环境：Ubuntu 18.04.1 LTS Full Installation via LXC Virtualization

- Caddy Webserver with FileManager

```bash
# apt update -y
# apt install curl wget ca-certificates -y
# curl https://getcaddy.com | bash -s personal http.filemanager,http.forwardproxy,http.ipfilter,http.login,http.minify,http.nobots,http.upload,tls.dns.rfc2136
$ # 编辑配置文件 /etc/Caddyfile
```

启动：`nohup caddy -conf /etc/Caddyfile > /dev/null 2>&1 &`

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
$ sudo systemctl enable mldonkey-server
$ sudo systemctl start mldonkey-server
```

## 部分配置文件

以下仅展示可运行的最简配置文件，更多详情请参考软件的 Manual Page.

部分文件由于默认配置过长，仅展示修改过的部分。

### Caddy (Caddyfile)

由于一般情况下，对于一些特大文件的传输，在运营商不存在劫持或文件过于冷门，且不存在文件审查的情况下，就使用 HTTP 传输就可以了，没必要对这类文件使用 HTTPS。

`/aria` 为 AriaNG 入口。

```
https://你的回源二级域名 {
  root <保存下载路径的上级目录>
  redir /aria <AriaNG 的 index.html 相对 root 的路径> 302
  timeouts none
  gzip
  tls <证书> <私钥>
  header / {
    Strict-Transport-Security "max-age=31536000;"
    X-XSS-Protection "1; mode=block"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"
  }
  filemanager <网盘入口相对路径> {
    database <网盘数据库文件保存位置>/filemgr.db
  }
}


http://你的CDN加速域名 {
  root <保存下载路径的上级目录>
  redir /aria <AriaNG 的 index.html 相对路径> 302
  timeouts none
  gzip
  filemanager <网盘入口相对路径> {
    database <网盘数据库文件保存位置>/filemgr.db
  }
}
```

**请在下载目录下执行运行 Caddy 的命令，以避免一些问题。**

### Aria2 (aria2.conf)

```
## 文件保存相关 ##

# 文件的保存路径(可使用绝对路径或相对路径), 默认: 当前启动位置
dir=<保存下载路径>
# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
disk-cache=32M
# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
# 预分配所需时间: none < falloc ? trunc < prealloc
# falloc和trunc则需要文件系统和内核支持
# NTFS建议使用falloc, EXT3/4建议trunc, MAC 下需要注释此项
file-allocation=trunc
# 断点续传
continue=true

## 下载连接相关 ##

# 最大同时下载任务数, 运行时可修改, 默认:5
max-concurrent-downloads=5
# 同一服务器连接数, 添加时可指定, 默认:1
max-connection-per-server=16
# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
min-split-size=10M
# 单个任务最大线程数, 添加时可指定, 默认:5
split=20
# 整体下载速度限制, 运行时可修改, 默认:0
#max-overall-download-limit=0
# 单个任务下载速度限制, 默认:0
#max-download-limit=0
# 整体上传速度限制, 运行时可修改, 默认:0
#max-overall-upload-limit=1M
# 单个任务上传速度限制, 默认:0
#max-upload-limit=1000
# 禁用IPv6, 默认:false
disable-ipv6=false

## 进度保存相关 ##

# 从会话文件中读取下载任务
input-file=/root/.aria2/aria2.session
# 在Aria2退出时保存`错误/未完成`的下载任务到会话文件
save-session=/root/.aria2/aria2.session
# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
#save-session-interval=60

## RPC相关设置 ##

# 启用RPC, 默认:false
enable-rpc=true
# 允许所有来源, 默认:false
rpc-allow-origin-all=true
# 允许非外部访问, 默认:false
rpc-listen-all=true
# 事件轮询方式, 取值:[epoll, kqueue, port, poll, select], 不同系统默认值不同
#event-poll=select
# RPC监听端口, 端口被占用时可以修改, 默认:6800
rpc-listen-port=<修改为你要的端口>
# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
rpc-secret=<远程管理密码>
# 设置的RPC访问用户名, 此选项新版已废弃, 建议改用 --rpc-secret 选项
#rpc-user=<USER>
# 设置的RPC访问密码, 此选项新版已废弃, 建议改用 --rpc-secret 选项
#rpc-passwd=<PASSWD>
# 是否启用 RPC 服务的 SSL/TLS 加密,
# 启用加密后 RPC 服务需要使用 https 或者 wss 协议连接
rpc-secure=true
# 在 RPC 服务中启用 SSL/TLS 加密时的证书文件(.pem/.crt)
rpc-certificate=<CADDY 申请的 TLS 证书文件>
# 在 RPC 服务中启用 SSL/TLS 加密时的私钥文件(.key)
rpc-private-key=<CADDY 申请的 TLS 证书私钥文件>

## BT/PT下载相关 ##

# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
follow-torrent=true
# BT监听端口, 当端口被屏蔽时使用, 默认:6881-6999
listen-port=51413
# 单个种子最大连接数, 默认:55
bt-max-peers=500
# 打开DHT功能, PT需要禁用, 默认:true
enable-dht=true
# 打开IPv6 DHT功能, PT需要禁用
enable-dht6=true
# DHT网络监听端口, 默认:6881-6999
#dht-listen-port=6881-6999
# 本地节点查找, PT需要禁用, 默认:false
#bt-enable-lpd=true
# 种子交换, PT需要禁用, 默认:true
enable-peer-exchange=true
# 每个种子限速, 对少种的PT很有用, 默认:50K
#bt-request-peer-speed-limit=50K
# 客户端伪装, PT需要
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
# 当种子的分享率达到这个数时, 自动停止做种, 0为一直做种, 默认:1.0
seed-ratio=1.5
# 强制保存会话, 即使任务已经完成, 默认:false
# 较新的版本开启后会在任务完成后依然保留.aria2文件
#force-save=false
# BT校验相关, 默认:true
bt-hash-check-seed=true
# 继续之前的BT任务时, 无需再次校验, 默认:false
bt-seed-unverified=true
# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
#bt-save-metadata=true
bt-tracker=udp://tracker.coppersurfer.tk:6969/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker.internetwarriors.net:1337/announce,http://tracker.internetwarriors.net:1337/announce,udp://9.rarbg.to:2710/announce,udp://exodus.desync.com:6969/announce,udp://explodie.org:6969/announce,http://explodie.org:6969/announce,udp://tracker.vanitycore.co:6969/announce,udp://public.popcorn-tracker.org:6969/announce,http://tracker.vanitycore.co:6969/announce,udp://mgtracker.org:6969/announce,http://mgtracker.org:6969/announce,udp://tracker1.itzmx.com:8080/announce,udp://ipv4.tracker.harry.lu:80/announce,http://tracker3.itzmx.com:6961/announce,http://tracker1.itzmx.com:8080/announce,udp://tracker.torrent.eu.org:451/announce,udp://tracker.tiny-vps.com:6969/announce,udp://open.stealth.si:80/announce,udp://tracker.port443.xyz:6969/announce,udp://open.demonii.si:1337/announce,udp://denis.stalker.upeer.me:6969/announce,udp://bt.xxx-tracker.com:2710/announce,http://tracker.port443.xyz:6969/announce,http://open.acgnxtracker.com:80/announce,udp://retracker.lanta-net.ru:2710/announce,http://retracker.telecom.by:80/announce,udp://thetracker.org:80/announce,http://torrent.nwps.ws:80/announce,http://0d.kebhana.mx:443/announce,udp://tracker.uw0.xyz:6969/announce,udp://tracker.cypherpunks.ru:6969/announce,https://tracker.fastdownload.xyz:443/announce,https://opentracker.xyz:443/announce,http://tracker.cypherpunks.ru:6969/announce,http://opentracker.xyz:80/announce,http://open.trackerlist.xyz:80/announce,udp://zephir.monocul.us:6969/announce,udp://tracker.ds.is:6969/announce,wss://ltrackr.iamhansen.xyz:443/announce,udp://tracker2.itzmx.com:6961/announce,udp://tracker.tvunderground.org.ru:3218/announce,udp://tracker.toss.li:6969/announce,udp://tracker.swateam.org.uk:2710/announce,udp://tracker.kamigami.org:2710/announce,udp://tracker.iamhansen.xyz:2000/announce,https://2.track.ga:443/announce,http://wegkxfcivgx.chickenkiller.com:80/announce,http://tracker4.itzmx.com:2710/announce,http://tracker2.itzmx.com:6961/announce,http://tracker.tvunderground.org.ru:3218/announce,http://tracker.torrentyorg.pl:80/announce,http://tracker.city9x.com:2710/announce,http://t.nyaatracker.com:80/announce,http://retracker.mgts.by:80/announce,http://open.acgtracker.com:1096/announce,http://node.611.to:9000/announce,wss://tracker.fastcast.nz:443/announce,wss://tracker.btorrent.xyz:443/announce,udp://tracker.justseed.it:1337/announce,udp://packages.crunchbangplusplus.org:6969/announce,https://1337.abcvg.info:443/announce,http://share.camoe.cn:8080/announce,http://fxtt.ru:80/announce
```

将 Aria2NG 解压到网站根目录下，从浏览器访问，然后配置对应 Aria2 本地配置项：

- 使用协议
- 域名 地址 端口
- RPC 密钥

即可使用。

### Aria2 (trackers_all.txt)

来源：https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt

### MLdonkey (/var/lib/mldonkey/downloads.ini)

```
allowed_ips = ["0.0.0.0/0";]

 shared_directories = [
  {     dirname = shared
     strategy = all_files
     priority = 0
};
  {     dirname = "<下载文件保存目录>"
     strategy = incoming_files
     priority = 0
};
  {     dirname = "incoming/directories"
     strategy = incoming_directories
     priority = 0
};]
```
保存目录可以自由修改，需要注意文件夹权限问题。

### MLDonkey 的进一步配置

在完成上面的配置之后，我们来添加管理员账户并设置一个普通用户。

同时对 ED2K 服务器列表 server.met 进行一次更新。

```bash
$ telnet localhost 4000
> useradd admin <你的管理员密码>
> quit
$ sudo systemctl restart mldonkey-server
$ telnet localhost 4000
> auth admin <你的管理员密码>
> d http://ed2k.2x4u.de/v1s4vbaf/max/server.met
> useradd 普通用户名 普通用户密码
> quit
```

经过上述设置之后，你可以通过 `http://<你的IP>:4080` 来登陆 WebUI 进行下载了。

注意每次拷贝下载完成的文件之前要去 WebUI 右上角命令框里输入一次 `commit`.

#### MLDonkey 忘记管理员密码

`/var/lib/mldonkey/users.ini` 里：

将对应 `user_name = admin` 的 `user_pass` 清空后重启服务。

## 关于后台进程守护

建议参考 阮一峰老师的 Systemd 相关教程和 计算器启动 与 后台守护相关文章

- [Linux 后台守护](http://www.ruanyifeng.com/blog/2016/02/linux-daemon.html)

- [计算机是如何启动的](http://www.ruanyifeng.com/blog/2013/02/booting.html)

- [Linux 是如何启动的](http://www.ruanyifeng.com/blog/2013/08/linux_boot_process.html)

> Unix 哲学: Keep simple, keep stupid.

- [Systemd Commands](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)

- [Systemd Services](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)

- [Systemd Timer (You could also use crontab)](http://www.ruanyifeng.com/blog/2018/03/systemd-timer.html)

如果你想学习更多的内容，也欢迎你前往 [Arch Linux Wiki](https://wiki.archlinux.org/) 那里有最详细的人类友好型文档，Arch Wiki 中的大多数内容对基于 Systemd 的发行版均是适用的。

# CDN 中转加速

## 准备域名

如果你还没有域名，你需要注册一个域名，个人推荐 [NameSilo](https://www.namesilo.com/register.php?rid=bd46d72xg) ，便宜，附送 WHOIS 隐私保护，支持支付宝。

然后建议将域名托管到 https://dns.he.net ，分别添加一个指向 @ 和 www 的 A 记录。再添加一个 cf_www 和 回源二级域名 的 A 记录。

注册一个 Cloudflare 账户，注册完成后不做任何配置。

## CNAME 接入 Cloudflare 加速

1. 寻找一家 Cloudflare Partner，并确保您的域名 **没有** 在 Cloudflare 注册过或正在处于 Cloudflare 服务之下。
2. 按照提示添加域名，之后按照 Partner 提示设置 www 记录的回源地址为 cf_www 地址。
3. 添加一个 CDN 加速域名，此 CDN 加速域名的回源地址指向 回源二级域名 地址。
4. 前往您的域名托管商，本例中是 HE，添加一个 CNAME 记录，从 CDN 加速域名 指向 `cdn.cf-a.x-gslb.com` 或者 `cdn.cf-b.x-gslb.com` 。
5. 通过 CDN 加速域名下载文件即可。

# 完

还有问题？请使用评论框。

公告：本站评论 **不对** 使用中国大陆 IP 地址访问本站的用户开放。

## Hostsolutions 关于 FUSE 无法使用的问题

该站的老板不是专业的 IDC，是个 Oneman，工单回复时效基本按月计算。需要使用 FUSE 进行 rclone 等操作的用户请先工单请求开启 FUSE，然后在 `/etc/systemd/system/hostsolutions-enable-fuse.service ` 中插入下列内容后：

```systemd
[Unit]
Description=Hostsolutions' LXC VPS - Enable FUSE
After=basic.target
Wants=local-fs.target basic.target

[Service]
User=root
Group=root
ExecStart=/bin/mknod -m 666 /dev/fuse c 10 229
Type=oneshot

[Install]
WantedBy=multi-user.target
```

执行

```bash
# systemctl daemon-reload
# systemctl start hostsolutions-enable-fuse.service 
# systemctl enable hostsolutions-enable-fuse.service 
```

之后使用 `ls -alh /dev` 检查输出是否为 `crw-rw-rw-   1 root root      10,   229 Jan 29 21:13 fuse`

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
