---
title: 将 CUPS 共享的打印机转为 Airprint 适用
date: 2018-10-24 10:31:57
tags:
  - Tech
---

# Convert CUPS Printer to Airprint-available

## Preface

由于人民日益增长的打印需要与打印店日益下降的打印质量和开门时间存在的巨大矛盾，已经穷得吃土的我买了一个打印机。<del>然而，迫于钱没加够，又有自动双面打印的需要（手动双面打印总是把纸放反......）所以舍弃了网络打印，买了个自动双面打印功能的 USB 打印机。</del>

## Prepare

1. 一台已经连接到打印机的服务器
2. 一台安装了对应 Linux 发行版及对应打印机驱动并连接到对应局域网的 Linux 主机
3. 可以正常运作的 CUPS 和 Avahi Daemon

## Configuration

请先确保您的打印机此时已经可以正常工作并能通过物理连接正常打印。

### CUPSD 添加打印机

添加一个打印机，做好默认设置，务必把打印机的默认打印设置配置好之后设为共享打印机，并对 CUPSD 打印服务器整体的打印共享功能打开。

### CUPSD 配置文件修改

> /etc/cups/cupsd.conf 

在 `Listen /run/cups/cups.sock` 后面添加这个。

```
Listen /run/cups/cups.sock
Listen 0.0.0.0:631
PreserveJobHistory
FileDevice Yes
ServerAlias *
```

在这里添加对应的缺失的几行，并在 Web 管理控制端勾起 `Share printers connected to this system` 。

```
<Location />
  # Allow shared printing...
  Order allow,deny
  Allow @LOCAL
</Location>
<Location /admin>
  Order allow,deny
  allow @LOCAL
</Location>
<Location /admin/conf>
  AuthType Default
  Require user @SYSTEM
</Location>
<Location /admin/log>
  AuthType Default
  Require user @SYSTEM
  Order allow,deny
  allow @LOCAL
</Location>
```

### 创建 MIME 应用类型配置

```bash
# echo "image/urf urf string(0,UNIRAST<00>)" > \
    /usr/share/cups/mime/airprint.types
# echo "image/urf application/pdf 100 pdftoraster" > \
    /usr/share/cups/mime/airprint.convs
```

### Avahi Daemon 配置文件修改

> /etc/avahi/avahi-daemon.conf 

```
domain-name=local
```

将这一行的注释符号去除。

### Avahi Daemon 及 打印机支持添加

下载 参考文献 2 中的对应的 Python 脚本，并安装对应支持库。

请注意，该脚本只支持 Python 2, 安装依赖：

```bash
$ sudo apt-get update -y && sudo apt-get install libxml2-dev
$ sudo pip2 install pycups
$ sudo pip2 install lxml
```

接下来使用对应的参数将会对所有已经在 CUPSD 中配置好的打印机生成对应的 Avahi 服务并保存到对应目录：

```bash
$ sudo python2 ./airprint-generate.py -P <CUPS 服务器端口号> -u root -d /etc/avahi/services -p c2a
```

重启服务，完成配置

```bash
$ sudo systemctl restart avahi-daemon.service
$ sudo systemctl restart org.cups.cupsd.service
```

## Enjoy

打开连接到同一局域网的苹果设备，尝试打印，你就能看到对应 PC 连接的打印机了。

## Acknowledgement

- [AskUbuntu](https://askubuntu.com/questions/26130/how-can-share-my-printer-so-that-i-can-use-it-with-airprint)
- [Airprint Service Generator](https://github.com/tjfontaine/airprint-generate)
- [EzUnix Tutorial](https://ezunix.org/index.php?title=Enable_iOS_AirPrint_with_any_printer_supported_by_CUPS)
