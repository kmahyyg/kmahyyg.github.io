---
title: "HackTheBox - WriteUp 1"
date: 2019-04-27T19:18:00+08:00
description: "HackTheBox 第一次练手"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
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
- https://jhalon.github.io/OSCP-Review/

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

# NetMon

## 第一关：扫扫扫

Nmap 来一下，发现开放了一些端口。可以有匿名目录列举和文件下载。轻易拿到 User 权限。

## 第二关：NetMon

正如其名，开了个 NetMon，这个 NetMon 的问题很多。首先版本号带了好几个 CVE，然后有明文的密钥存储，再然后有权限控制不严导致的 Remote Code Execution。

## 第三关：手写 Payload

既然有 RCE，那就要手写 Payload，相关的漏洞也有 CVE，搜索一下软件名，然后通过文件下载服务拿到那个文件，分析源代码直接构造一个 Payload 就行。

（完） 2019.4.28

# Lightweight

Think Simple, Try Harder. --OffSEC

{{<aplayer title="Try Harder" author="Offensive Security" musicurl="https://www.offensive-security.com/wp-content/uploads/2015/01/Try_Harder_2.0.mp3">}}

## 第一关：First FootHold

Nmap 扫描常见端口，CentOS 7, 有 80 、22、 LDAP。 80 访问之后有个网站，仔细阅读每个页面，获得最低登陆凭据。

## 第二关：Normal User Privilege

查看登陆用户，发现普通权限，没有 sudoer，SELinux 处于 Enforcing 状态。搜索可读目录，发现 `/tmp/b****p.7z`。下载，带密码。找个字典，跑 john，密码得到，是个单词 `de***e`。

解压文件，拿到普通用户 `ld******1`。（ 127.0.0.1 那个账户是没用的，LDAP 服务器的作用是拿普通用户权限，不要想太多）。最骚的操作就在这里，找了半天没发现 `user.txt`，一问才知道，在另外一个普通用户里。

继续返回 80 浏览整个网站，发现有这样一段话：

> This server is protected against some kinds of threats, for instance, bruteforcing. If you try to bruteforce some of the exposed services you may be banned up to 5 minutes.
> We strongly suggest you to change your password as soon as you get in the box.

然后访问论坛查找提示，发现有这样一个提示：

> The quieter you become, the more you are able to hear. (some peneration test may be needed.)

接下来你需要上传一个 `tcpdump` ，并监听在 `lo` 接口，然后尝试访问所有 80 端口的页面，可能需要多访问几次。这样，你就会抓到 `ld*******2` 这个用户的登录凭据， `su` 切换，获得 `user.txt`。

## 第三关：Root User Privilege

观察 `ld******1` 的家目录，发现有些奇怪的一个 binary，叫做 `o*******l` ，`ls -Zlha` 发现没有可疑点， SELinux Context 正常， `getcap` 进一步检查发现具有 `ep` 权限位。使用对应命令监听可得到 root 权限的 reverse shell，使用对应命令可以直接读取 `/root/root.txt` 拿到 root 用户的 flag。至此，渗透完成。

## Reference

- Use `id` to get selinux contents for user
- Use `getcap` to get the linux capabilities for a file: https://www.insecure.ws/linux/getcap_setcap.html
- Linux manual about capabilities: http://man7.org/linux/man-pages/man7/capabilities.7.html
- Check here for more details about linux command utils: https://gtfobins.github.io/
- Useless rabbit hole: https://www.exploit-db.com/exploits/38835
- Local Linux Enumeration & Privilege Escalation Script: http://www.rebootuser.com
- 提权那一步，很多人连 DirtyCow 都用上了，真是让人震惊。其实 LDAP 在这里并没有什么卵用。

(完) 2019.4.29 

# LaCasaDePapel

## Step 1: 信息收集

Nmap 走起，80/443/21/22 常见端口开启。（其实这里漏了一个）

## Step 2: 获取普通用户

检测到 21 使用的是有后门的 VSFtpd，启动 MSF，自动化渗透。发现渗透无法建立 Session，进一步检查发现后门端口被其他程序占用，也就是我上面说漏了的那一个。连接后门，发现是一个 PHP REPL，查询各类环境变量和信息，读取到一个相关的函数。一时间没想到能拿来干嘛，访问 443, 发现问题。

读取函数内容之后使用 PHP 函数获取到对应密钥，本地生成需要的验证凭据。生成后的凭据需要转换成对应格式才能被对应应用程序识别。

凭据生成完成，访问 443, 正确登陆。是个目录列表，观察发现下载地址的特征，是 `/files/xxxxxx` ，其中 `xxxxx` 是一个常见的编码后的字符串。进一步观察并检测，发现存在任意目录枚举。至此拿到普通用户。

## Step 3：获取 Root 用户

两句 Hints：

> The quieter you become, the more you are able to hear.
> The folder you have write permission, you can rename any files in it.

拿到普通用户后，继续利用枚举漏洞，发现一个 SSH 登陆凭据，通过 REPL 枚举当前系统用户，至此拿到普通用户 Interactive Shell，运行 LinEnum.sh 一无所获。利用 Hint 2, 重写某个配置文件，该配置文件被一个守护进程重复以 Root 权限运行，可能需要用到 pspy，至此完成提权。（你要拿 Flag 或者建立 Shell 那就随你咯）

> 吐槽：这个机器的 443 端口存在不正确编码导致 Web 服务器崩溃的问题，很不稳定。另外，Rabbit Hole 剧多，小心啊。

（完） 2019.5.3

# Bastion

## Step 1: 信息收集

Nmap 扫描，开放了一堆端口，还有一些连续的，然而都没什么卵用。

检测到 SMB 打开，允许 Guest 访问，访问查看，有备份的 VHD，使用 `smbclient` / `mount -t cifs` 挂载到本地之后，使用 `guestmount` / `qemu-nbd -c /dev/nbd0` 进一步挂载，检查发现 SAM 文件。

## Step 2: 普通用户

挂载点下查找 SYSTEM+SAM 文件，在对应目录下直接执行 `samdump2 SYSTEM SAM`，无需单独 dump syskey，直接得到 NTLM Hash，格式是： `Status Username:Salt:Password Hash`

使用 `john pwdhash.txt -format=NT -users=L*****e --wordlist 227mword.lst` 破解得到普通用户密码。个人推荐这个： https://hashkiller.co.uk/Cracker/NTLM

拿到之后根据之前扫描到的 22,连接 SSH，得到 CMD interactive shell on Windows.

## Step 3: 超管

### 常规方法

在 `%appdata` 下找到备份，拉回本地，在 VM 中安装相同版本软件，导入后以明文导出凭据，密码到手。

### HardCore 程序员

审阅源代码： https://github.com/mRemoteNG/mRemoteNG/tree/release/v1.76

相关密钥生成与加解密的代码：

https://github.com/mRemoteNG/mRemoteNG/tree/release/v1.76/mRemoteV1/Security/KeyDerivation

https://github.com/mRemoteNG/mRemoteNG/tree/release/v1.76/mRemoteV1/Security/SymmetricEncryption

审阅代码后自行实现的解密软件：

我写好的解密代码： https://github.com/kmahyyg/mremoteng-decrypt

## Step 4: End

拿到密码之后同样 SSH 上去拿到 Shell，读取 root.txt ，渗透完成。

(END) 2019.5.11
