---
title: "给 Charles Proxy 的 chls 文件添加 MIME 关联"
date: 2019-05-09T00:17:51+08:00
description: "给 Linux 添加 Charles Proxy 的文件关联的办法"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: false
dropCap: false
---

# 写在前面

Charles Proxy 的 Session 保存下来打开总是很麻烦，想直接打开默认是不行的，于是有了本文。将 `*.chls` 绑定到 `application/x-charles-savedsession` 这个 MIME Type 之后，再将这个 Type 绑定到应用。

# 操作

## 创建 MIME

 `/usr/share/mime/application/x-charles-savedsession.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info"> 
<mime-type type="application/x-charles-savedsession">
  <!--Created automatically by update-mime-database. DO NOT EDIT!-->
  <comment>Charles Proxy Saved Session</comment>
  <!-- Use the wireshark icon because I am lazy !-->
  <glob pattern="*.chls"/>
</mime-type>
</mime-info>
```

## 安装 MIME 到系统并绑定到应用

```bash
$ sudo xdg-mime install --mode system /usr/share/mime/application/x-charles-savedsession.xml
$ sudo xdg-mime default charles-proxy.desktop application/x-charles-savedsession
$ sudo update-mime-database /usr/share/mime
```

## 更新 KDE 缓存

```bash
$ kbuildsycoca5 
```

(完) 2019.5.9
