---
title: Systemd-nSpawn 容器初体验 - Arch Inside Ubuntu
date: 2019-05-05T10:56:22+08:00
description: "Docker 的无守护设计理念也实在是让人难受，Systemd-NSpawn 完全虚拟了文件系统架构并限制了对 sysfs 的写操作实现了一个轻量化的命名空间级别的容器"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Reference 

放在最前，权威参考毕竟更实在：

- https://wiki.archlinux.org/index.php/Systemd-nspawn
- https://blog.felixc.at/2019/04/nspawn-org-simple-container-for-systemd-distributions/
- https://gist.github.com/artizirk/0d800be97bcdb35fb7bfd9755208e0e8
- https://github.com/systemd/systemd/issues/1968
- 慎重使用: http://www.jinbuguo.com/systemd/systemd-nspawn.html

# 写在最前

受这篇 [为实验室建立公用 GPU 服务器](https://abcdabcd987.com/setup-shared-gpu-server-for-labs/) 的启发，加之最近 Arch 群里开始掀起一股推广 `底裤d-nSpawn` 容器(2017 年就开始开发了耶) 的热潮，配合上我对 Ubuntu 16.04 （迫于应用环境，无法升级）的 Canonical 魔改的厌恶 <del>Ubuntu 你尽管用，内部不错算我输.jpg</del> ，和 [OpenVAS 9 老旧、各种玄学 Bug](https://www.kmahyyg.xyz/openvas-9-gsad-bug/) 的问题。我尝试在 Ubuntu 16.04 上开启 systemd-nspawn 容器启用 Arch Linux 进行错误查找。因而有了这篇文章。

# 环境说明

Systemd 229, Linux Kernel 4.4.0-146, Ubuntu 16.04.6 LTS, Xen 虚拟化架构的 Huawei Fusion-Compute-Based VM

# 预备

```bash
$ cd /usr/local/bin
$ wget https://raw.githubusercontent.com/nspawn/nspawn/master/nspawn
$ chmod +x nspawn
```

下载第三方提供的快速配置工具，由 Arch Linux Trusted User 带来，稳稳的。主要是简化了配置和拉取镜像及附带了一些常见问题的“预防针”。不建议手动 `pacstrap`，因为需要手动安装很多组件。

## 安装依赖

```bash
$ sudo apt update -y 
$ sudo apt install systemd-container -y
```

## 修改内核参数

```bash
$ sudo sysctl -w net.ipv4.ip_forward=1
$ sudo sysctl -w net.ipv6.conf.all.forwarding=1
```

## 建立网卡

Systemd-nSpawn 的原理是把容器里的应用包装为 Systemd Service 在以独立的命名空间后台运行

Systemd-nSpawn 默认的联网方式是 veth，即默认在模板 `/lib/systemd/system/systemd-nspawn@.service` 中已经使用了参数 `-n`， 你也可以选择删除后根据 Arch Wiki 的提示直接使用 host 的网卡，个人不推荐这样做。

### HOST

使用 `systemd-networkd` 建立网桥：

 `/etc/systemd/network/br0.netdev`
 
```
 # Tell systemd-networkd to create a bridge device
 [NetDev]
 Name=br0
 Kind=bridge
```

配置网桥的 IP 地址：

 `/etc/systemd/network/br0.network`

```
 # Configure ip address for the bridge
 [Match]
 Name=br0
 
 [Network]
 Address=172.23.0.1/24
 LinkLocalAddressing=yes
 IPMasquerade=yes
 LLDP=yes
 EmitLLDP=customer-bridge
```

配置完成后调整防火墙，手动启用 NAT，在 Debian-Based 分发版上，`IPMasquerade` 参数因为 Bug 不会自动生效。这里的示例是 80 端口转发。

```
$ sudo iptables -t nat -A POSTROUTING -s 172.23.0.0/24 -j MASQUERADE 
$ sudo iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 -m addrtype --dst-type LOCAL -j DNAT --to-destination 172.23.0.2:80 
```

接下来启用 `systemd-networkd` 即可。

```bash
$ sudo systemctl enable --now systemd-networkd
$ sudo systemctl restart systemd-networkd
```

编辑 `systemd-nspawn@.service` 模板：

```yaml
 [Service]
 ExecStart=<current execstart line> --network-bridge=br0
```

# 部署

这里，我们以 Arch 容器为例，容器内部为私有 IP + 静态手动指定的方式。如果你想要 DHCP 方式，请自行部署 DNSMASQ.

## 运行工具

```bash
$ sudo nspawn init archlinux/archlinux/tar
$ sudo machinectl list-transfers
```

镜像列表参见： https://nspawn.org (由 Arch Linux Trusted User @shibumi 为你带来)
传输过程略慢，等待传输完成即可开启

## 开启容器

```bash
$ sudo machinectl start archlinux-archlinux-tar
$ sudo machinectl shell archlinux-archlinux-tar
```

至此，容器成功启动。容器文件保存在： `/var/lib/machines/archlinux-archlinux-tar/` 下。退出 Shell，请快速连续按 `Ctrl + ]` 三次。

关闭容器：`sudo machinectl poweroff archlinux-archlinux-tar`

销毁容器：`sudo machinectl terminate archlinux-archlinux-tar`

## 提升磁盘限制

```bash
$ sudo machinectl set-limit infinity   # if this not work, try next one
$ sudo machinectl set-limit 16G
```

检测是否提升成功： `sudo machinectl image-status`

## 对接网络配置

### Container

建立并写入：

 `/etc/systemd/network/20-wired.network`
 
```
[Match]
Name=host0

[Network]
Address=172.23.0.2/24
Gateway=172.23.0.1
DNS=119.29.29.29
```

请注意检查文件夹下有没有其他配置文件默认指定了网卡使用 DHCP 方式，若有，请手动删除或修改为 `no`.

供你参考：[Arch wiki - systemd-networkd](https://wiki.archlinux.org/index.php/Systemd-networkd)

网卡显示为： `host0@if6` 表示容器内网卡名为 `host0` ，连接到 host 的 第 6 个 slot，host 端执行 ip link 应当能看到多出一个 `ve-xxx` 的网卡。

接下来启动服务：

```bash
$ sudo systemctl enable --now systemd-networkd
$ sudo systemctl restart systemd-networkd
```

### DNS

自行编辑 `/etc/systemd/resolved.conf` 之后执行：

```bash
$ sudo systemctl enable systemd-resolved
$ sudo systemctl start systemd-resolved
```

供你参考： [Arch Wiki - Systemd-resolved](https://wiki.archlinux.org/index.php/Systemd-resolved)

配置工具是 `resolvectl`.

### 端口转发的自动化配置

注意：Debian-Based 系统的 Bug 导致你仍需要手动前往 iptables 指明 NAT 和端口转发:

 `/etc/systemd/nspawn/http.nspawn`
 
```
  [Network]
  Port=tcp:80:80
  Port=tcp:443:443
```

## 进一步共享文件

在下列文件中写入下列内容：

 `/etc/systemd/nspawn/my-container.nspawn`

```
[Files]
Bind=/var/cache/pacman/pkg
BindReadOnly=/var/cache/read-only-data
```

# 写在文末

这样一番操作之后你就可以开始体验 Arch 了，记得先装 `glibc` ......

一些进阶操作的话就烦请移步 [Manual page](https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html) ，快照和临时隔离什么的也是可以有的。

有了 `systemd-nspawn` 以后，容器里也有独立的 `systemd` ，就非常香了。由于这样的轻量级容器系统开销极小，因此个人估计在未来会作为主力的环境隔离器使用。

（END） 2019.5.5
