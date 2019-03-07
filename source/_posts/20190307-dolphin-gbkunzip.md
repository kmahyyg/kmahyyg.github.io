---
title: Dolphin 添加右键菜单解压 Windows 打包的 Zip 文件
date: 2019-03-07 08:51:00
tags:
  - Tech
---

代码来源： https://github.com/farseerfc/dotfiles  （非常感谢教授~）

问题原因： Windows 打包的 Zip 文件默认采用 GBK 编码，与 Ark 默认的编码 UTF-8 冲突。

（PS. 如果您使用 Gnome 桌面环境搭配 Nautilus，请您查看代码来源下载对应的代码文件。）

解决办法： 使用 farseerfc 写的右键菜单快捷方式解码。

环境： KDE Plasma + Arch Linux

代码：

```bash
mkdir -p ~/.local/share/kservices5/ServiceMenus
```

将下列代码保存为 `unzip.desktop` 保存到上述文件夹内：

```yaml
[Desktop Entry]
Type=Service
ServiceTypes=KonqPopupMenu/Plugin
MimeType=application/zip;application/x-zip-compressed;application/octet-stream;
Actions=unzipsjis;unzipgbk;
X-KDE-Submenu=Unzip as

[Desktop Action unzipsjis]
Name=Unzip here shift-jis
Icon=application-zip
Exec="unzip" "-O" "sjis" "%U"

[Desktop Action unzipgbk]
Name=Unzip here GBK
Icon=application-zip
Exec="unzip" "-O" "gb18030" "%U"
```

```bash
$ chmod +x ~/.local/share/kservices5/ServiceMenus/unzip.deskstop
```

大功告成！

