---
title: Systemd-nSpawn 容器初体验
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

# 写在最前

受这篇 [为实验室建立公用 GPU 服务器](https://abcdabcd987.com/setup-shared-gpu-server-for-labs/) 的启发，加之最近 Arch 群里开始掀起一股推广 `底裤d-nSpawn` 容器 的热潮，配合上我对 Ubuntu 16.04 （迫于应用环境，无法升级）的 Canonical 魔改的厌恶 <del>Ubuntu 你尽管用，内部不错算我输.jpg</del> ，和 [OpenVAS 9 老旧、各种玄学 Bug](https://www.kmahyyg.xyz/openvas-9-gsad-bug/) 的问题。我尝试在 Ubuntu 16.04 上开启 systemd-nspawn 容器启用 Arch Linux 进行错误查找。因而有了这篇文章。

# 环境说明

Systemd 229, Linux Kernel 4.4.0-146, Ubuntu 16.04.6 LTS, Xen 虚拟化架构的 Huawei Fusion-Compute-Based VM

# 预备

todo

## 安装依赖

todo

## 修改内核参数

todo

## 建立网卡

todo

# 部署

todo

## 下载工具

todo

## 开启容器

todo

## 对接网络配置

todo

## 进一步共享文件

todo

# 写在文末

todo

（END） 2019.5.5
