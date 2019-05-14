---
title: OpenVAS9 的 GSAD 频死或无法登陆 Bug
date: 2019-05-14T08:59:26+08:00
description: "OpenVAS 作为 Nessus 的完全社区化版本，可供用于大批量的自有大规模网络的漏洞扫描，是一款相对易于使用的软件"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# 前情提要

[Openvas 9 的安装实践](https://www.kmahyyg.xyz/installation-of-openvas/#prevent-suddenly-crash) 这篇文章中的最后一个部分记录了一些常见的遇到的 Scanner 卡死的问题。

# 问题表现

在上面修改之后，完成一个一次性 50+ 机器的扫描，然后直接关闭浏览器。浏览器设置正确的情况下，Cookie 可以写入，但是后端验证请求合法性过程中 Token 传丢，导致系统报错。

查看认证日志：可以发现有认证成功字样。更改日志级别为 Debug，进一步检查发现在获取前端资源的过程中 `openvas_validate` 传丢 Token。前端提示为： Cookie missing or bad, please try again.

另外：使用 `openvas-manage-cert -af` 生成的证书，在 Chrome 75+(Dev) 版本上提示 `ERR_SSL_INCOMPATITABLE_KEY_USAGE`， 在 Chrome 73(Stable)、74(Chromium) 无限跳转死循环在证书无法验证页面，在 FF 63 ESR 上工作正常，CURL 访问工作正常。如 CURL 访问出现 403 错误，请手动添加 `--allow-header-host <YOUR HOSTNAME>` 选项在 `openvas-gsad.service` 的 `ExecStart` 部分解决。

<del>已前往官方开启 Issue： https://github.com/greenbone/gsa/issues/1364</del> 上游确认问题，本地修改 UTC 时间可破。

在双系统下，请不要开启 `sudo timedatectl set-local-rtc 1` !!! 请使用 修改注册表 的方法。

# 当前的解决方案

自己写一个 Dockerfile，抛弃 OpenVAS 9，跟进上游新版 GVM 10。

上游新版 GVM 10 CE 对 OpenVAS Scanner、Manager 进行了更新，前端 GSA 使用 ReactJS 进行了完全重写，抛弃了 XSLT 生成的页面并修复了 Bug。

当前进度：[CI 编译完成](https://cloud.docker.com/repository/docker/kmahyyg/gvm10-docker-pgsql/builds)，已上线。

(END) 2019.5.5
