---
title: 见鬼的 Travis CI
date: 2018-08-18T07:39:24+08:00
description: "Travis CI 自动化 Hexo 博客部署实践的又一次踩坑"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

## 情况

最近一个月内 Travis CI 出现了 5 次基础设施不可用的情况，参见 https://www.traviscistatus.com/history

所有 `sudo: required` Build 均会直接 Timeout 或者 Build 失败。

## 努力

与客服邮件沟通 3 次，无果。

## 更改

改动：

```git
From: kmahyyg <16604643+kmahyyg@users.noreply.github.com>
Date: Sat, 18 Aug 2018 07:32:49 +0800
Subject: [PATCH] reroute ci build to container to avoid sucked travis ci

---
 .travis.yml | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/.travis.yml b/.travis.yml
index 6554487..925bfd9 100644
--- a/.travis.yml
+++ b/.travis.yml
@@ -1,5 +1,5 @@
-dist: xenial
-sudo: required
+dist: trusty
+sudo: false
 
 language: node_js
 node_js:
-- 
2.18.0
```

## 结果

当尝试把 Build Reroute 到 Travis 的 Container-Based build infrastructure 之后，依然失败。同一个 Build, 人工重启后成功。问题仍然存在。

继续联系客服，等待回复，表达愤怒。
