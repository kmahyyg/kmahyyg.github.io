---
title: OpenVAS9 的 GSAD 频死或无法登陆 Bug
date: 2019-05-05T11:35:19+08:00
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

查看认证日志：可以发现有认证成功字样。更改日志级别为 Debug，进一步检查发现在获取前端资源的过程中 `openvas_validate` 传丢 Token。

已前往官方开启 Issue： https://github.com/greenbone/gsa/issues/1364

等待修复。

# 当前的解决方案

自己写一个 Dockerfile，抛弃 OpenVAS 9，跟进上游新版 GVM 10。

当前进度：正在进行 CI 编译，等待上线测试。

(END) 2019.5.5
