---
title: "HackTheBox - IRKed"
date: 2019-04-27T19:18:00+08:00
description: "HackTheBox 第一次练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: false
dropCap: false
---

# HackTheBox

下半年准备进入 Pentesting with Kali 课程，打算开始学习 OSCP 的相关内容。今天下午复习的很累，看了一下官方 FAQ 和一些注意事项和国外的一些经验总结。

发现很多人提到这个站，于是注册了一个，开始折腾 <del>（复习咕咕咕）</del> ，准备为接下来 PwK 打下基础。具体链接不放了，自行 Google. 根据网站的 ToS 我不能泄露网站的题目内容，只能给出一些简单的 Hints，所以这里也就只会做一些简单的记录了。

# Reference

参考文献先放上来，每一个都是好东西。

- https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/
- https://www.hackingarticles.in/linux-privilege-escalation-using-suid-binaries/
- https://www.rapid7.com/db/modules/exploit/unix/irc/unreal_ircd_3281_backdoor
- https://futureboy.us/stegano/decinput.html

# 注册

网站的注册就体现了网站的名字，Hack First。很简单的一个邀请码小测试，F12，根据关键词慢慢找，最后用 Postman 发两个 POST，完成。这里考察了 R**13 加密(每次出现的加密方式不一样，不要照搬)。

# IRKed

注册完成，下载 Credential Pack，连接 OpenVPN，进入测试网络。需要注意：免费用户只能 reset 一次，只能使用 active 的机器，限制之外的机器需要加钱。推荐使用美国区域的实验网络并自行魔改 OVPN 文件使用上游代理为自己的 SS.

## 第一关: UnRealIRCD 3.2.8.1

> OSCP 测试中禁止使用自动化测试工具，但可以使用 nmap 这类扫描工具。

老样子，nmap 先上。第一次没发现有用的信息，只扫到了 80、22、111。第二次全端口扫描，发现开放了 IRC 的几个端口，尝试连接，出现版本号，搜索发现存在漏洞。使用 MSF 执行拿到普通 Shell。

## 第二关：Reverse Shell -> Interactive Shell

检查痕迹，发现存在一个 `.b**********y` 文件，读取，检测到里面有个 `.b****p` 文件。但是不在当前目录，检测权限，可读，读取，拿到一串代码和一个 `s*********** elite st**** ** b*****p` 的提示。
联想到之前开放的端口中存在一个看似古怪的文件，测试读取，成功，拿到普通用户权限。登陆 SSH，拿到 Proof。

## 第三关： Privilege escalation

这关就是不能想太多，我都折腾了差点把 exim4 提权搞上去了，最后发现简单的一批。

关键词：SUID 提权。 一通检查之后发现一个奇怪的 Shell Script，提示是用来检测用户权限并测试的，还处于开发待完善状态。尝试运行，提示缺失文件，手动建立并写入内容，再次尝试执行，拿到 Root Shell，提权完成。

（完） 2019.4.27
