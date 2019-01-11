---
title: 使用 Backblaze + Cloudflare 搭建 10G 免费网盘
date: 2018-11-11 16:32:06
tags:
  - Tech
---

# Preface

 Backblaze 作为一家专业提供云存储服务的厂商为我们提供了一个 B2 Cloud Storage 服务。其免费额度包含 10GiB 存储空间 + 每天 1 GiB 下载流量 + 每天 2500 次的 API 调用量。近期，由于 Cloudflare CDN 到 B2 服务器的流量不再计费，我们可以利用这一特性打造不限下载流量，附带全球免费 CDN 加成的下载网盘。

# Deploy

## 注册和登陆

按照文字提示处理，B2 注册的时候不需要提供信用卡，请提供真实的账单地址以供验证。请注册完成之后创建 Bucket，然后任意上传一个文件，记录下该文件的 Friendly Download Address，以备后续使用。

## 接入 Cloudflare

请参考我之前的博文： [CAMAL 离线下载套件](/2018/CAMAL-OfflineDL/)

接入时的几点注意：

- 如果您使用 CNAME 方式接入，请注意检查是否已经由 Cloudflare 正确下发证书。
- B2 Cloud Storage 要求请求的 URL 必须为 HTTPS，请您注意您分发时的 URL.
- 使用 CNAME 方式接入时的回源地址应为你的 Friendly Download Address 中的域名，如果这个方式无法正确下发域名，请您将其临时更改为其他启用了 HTTPS 的大站的域名并重新禁用、启用一次 Cloudflare Universal SSL，等待下发证书成功后改回即可。
- 接入完成并确认证书正确下发后再根据 Reference 设置您的 Page Rules 用以屏蔽未授权的访问。
- 在您的 权威 DNS 端的 CNAME 设置也请参考我之前的博文，如果存在问题，请先改为由伙伴面板提供的 CNAME 再切换为您想定义的其他线路。

最终的文件访问 URL 格式应当为：  `https://<YOUR CUSTOM DOMAIN WITH CLOUDFLARE ACCLERATED>/file/<BUCKET NAME>/<FILE NAME>`

具体的 B2 云存储相关的安全设置请参考 Backblaze 官方文档，Cloudflare 安全性相关设置请参考 Cloudflare 官方文档并结合您的自身需求。

Recommended Page Rules:

![Recommended Page Rules](/asset_files/2018-b2cf-01.png)

# Reference

- https://help.backblaze.com/hc/en-us/articles/217666928-Using-Backblaze-B2-with-the-Cloudflare-CDN
- https://www.kmahyyg.xyz/2018/CAMAL-OfflineDL/
