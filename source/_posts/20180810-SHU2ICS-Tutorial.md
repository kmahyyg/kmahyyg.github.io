---
title: 爬取课表并转换为 ICS 文件
date: 2018-08-10 08:06:18
tags:
  - School
---

# Windows 用户请直接看这里

请您直接根据您所在的学校前往下列页面下载预编译好的 exe 文件，然后跳转到接下来的 `教程 Part 3` 部分，继续您的操作。

 云南大学：https://github.com/kmahyyg/YNU2GCalendar/releases
 
 上海大学：https://github.com/kmahyyg/shu2ics/releases


# 其他用户建议编译安装

--------------------------------
以下为编译安装步骤。
--------------------------------

# 注意

如果您发现运行过程中出现错误，请在对应项目页面重新下载代码并重新安装 **项目依赖** ，若仍然无法使用，请您提交 Issue, 我会检查并向您及时反馈。

# 教程

本文的主要目的是向使用以下项目的用户提供使用教程：

 - [YNU2Gcalendar](https://github.com/kmahyyg/ynu2gcalendar)
 
 - [SHU2ICS](https://github.com/kmahyyg/shu2ics)

请您根据您使用的项目点击目录侧对应的标题查看具体教程。

本次演示基于 Arch Linux, Mac OS应当可以正常使用。

<del> 不保证 Windows 系统不会出现兼容性问题（咕咕咕），但是应该能正常运行。 </del>

## 系统环境依赖

Linux 用户请直接安装 `python3` 和 `python-pip` 包。

Windows 用户请安装 Python 并勾选 `Add to Path` 和 `Install PIP` 选项。

Mac OS 用户请直接使用此教程安装 https://pythonguidecn.readthedocs.io/zh/latest/starting/install3/osx.html 

下载 适用于 Windows 的 Python： https://www.python.org/downloads/release/python-370/

安装完成后，请您打开终端输入 `python3 --version && pip3 --version` 查看是否正确安装完成。

正确回显：

![pyversion](https://alicdn.kmahyyg.xyz/asset_files/shu2ics_pyv.webp)

## 教程 Part 1： 下载代码并安装所需的项目依赖

请您打开您的项目对应的网址：

 上海大学用户请点击 [这里](https://github.com/kmahyyg/shu2ics)
 
 云南大学用户请点击 [这里](https://github.com/kmahyyg/ynu2gcalendar)
 
点击页面的 "Clone or Download" 按钮，然后选择 “Download zip”
 
![drepo](https://alicdn.kmahyyg.xyz/asset_files/2ics_dcode.webp)
 
将下载好的代码解压后，打开解压得到的文件夹，并在文件夹中打开终端，输入：
 
| 平台 | 代码 |
|:----: | :----: |
| Windows | python -m pip install -r requirements.txt|
| Linux | sudo pip3 install -r requirements.txt |
| Mac OS | sudo pip3 install -r requirements.txt |
 
安装依赖并耐心等待安装完成。

## 教程 Part 2： 创建日历文件

如果出现任何报错，请您检查以上的环境安装是否正常完成。

### SHU2ICS

第一步：打开终端，执行 `python3 ./main.py`

第二步：按照界面提示，根据格式输入一个学期开始的时间。接下来选择学期数，并输入您的教务系统帐号和密码。 **输入密码时不会有任何回显，您无需担心，请直接往下输入，输入完成按下回车键即可！**

![login](https://alicdn.kmahyyg.xyz/asset_files/shu2ics_op.webp)

第三步： 见到 `Validate Image` 开头的提示后，软件会自动弹出验证码，请您将验证码输入到对应位置。 **验证码不区分大小写**

![captcha notice](https://alicdn.kmahyyg.xyz/asset_files/shu2ics_capt1.webp)

![captcha img](https://alicdn.kmahyyg.xyz/asset_files/shu2ics_capt2.webp)

第四步： 请您耐心等待，直到导出完成，这时候，在您的当前工作文件夹内会产生一个大小不为 0 的文件 `Course Schedule.ics` 文件。导出成功！

![ics file](https://alicdn.kmahyyg.xyz/asset_files/shu2ics_suc.webp)

### YNU2Gcalendar

第一步： 复制 `apikey.py.example` 并改名为 `apikey.py`

第二步： 打开 `apikey.py` ，修改

|需要修改的地方|在等号后面的**引号内**填入|
|:---------:|:-----------------:|
| ynu_ehall_name | 您的学号 |
| ynu_ehall_password | 您的教务系统密码 |
| mailacc | MAILTO:您的邮箱 |

并保存，关闭文本编辑器。

![modify user login crediential](https://alicdn.kmahyyg.xyz/asset_files/ynu2ics_modify.webp)

**如果您的统一身份认证开启了两次确认验证或者单点登陆，本程序已经预置了处理代码，但不保证有效，请您暂时关闭。**

**如果您多次使用错误密码登陆触发了验证码，也请您根据界面提示输入验证码。 Linux 用户安装 Tesseract 库后可以选择使用自动识别验证码功能，其他系统用户无解，自动识别验证码功能的准确度大约在 85% 左右，如果自动识别不准确，还烦请您根据提示手动输入验证码。**

第三步：运行 `python3 ./client.py` 启动程序，按照提示接受免责声明并确认您已完成前面几步，接下来按任意键继续。程序模拟登陆完成后，请您输入当前学期共几周，一般为 18 ~ 20 周。只能输入整数！

![run photo](https://alicdn.kmahyyg.xyz/asset_files/ynu2ics_op.webp)

第四步：运行完成，当前文件夹内会产生一个大小不为 0 的文件 `ynucal.ics`，导出成功！

![success](https://alicdn.kmahyyg.xyz/asset_files/ynu2ics_suc1.webp)

![success2](https://alicdn.kmahyyg.xyz/asset_files/ynu2ics_suc2.webp)

## 教程 Part 3： 使用日历文件

您可以将导出的 ics 结尾的文件导出到几乎所有移动设备，并在移动设备打开，即可添加到您的手机系统自带日历！

上海大学用户默认课前 25 分钟提醒上课，云南大学用户默认课前 30 分钟提醒上课。

如果您使用 Mac，可以直接打开 ics 文件，您将会在您的日历应用中看到这个课表。

## 致谢

1. [JeromeTan1997](https://github.com/JeromeTan1997)
2. 我的好基友 - Cindy  （滑稽

## 运行出现问题

1. 请您检查上述步骤是否完整成功完成。
2. 欢迎您在对应项目页面点击 Issue,创建一个新的 Issue 向我反馈。

## 开源协议

我的所有代码均在 GNU Affero Public License V3.0 之下授权。
