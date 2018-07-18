title: 'How to Use SWAP File to Boost Your Old Kindle[Tested on KPW2]'
tags:
  - Tech
categories: []
date: 2016-06-04 13:47:00
---
**Of course , your Kindle needed to be jailbreaked and install KUAL & KTerm first!**

-----

# Background

Recently ,I have no hardware to play.You know that studying in YUSS XingYao Campus is so boring,so that as a poor student,I bought a Kindle PaperWhite 2 in Taobao to read <<\Zhihu Daily\\>> every day.

I can connect with this fucking world in this way!

-----
## Bash Code

Here's the bash code , which should be just executed one by one in kterm.

	 free -t -m # 可用RAM 
	 df -h # 可用磁盘空间
	 cd /mnt/base-us #一定是这个目录 
	 dd if=/dev/null of=./swapfile bs=1M count=256 #按照 1~2 倍原则创建 swap 文件 
	 mkswap ./swapfile #格式化为 swap 格式 
	 swapon -a ./swapfile #挂载，每次启动时手动执行
	 free -t -m #查看是否挂载成功 

--------

Connect with me at Google+ , Searching for "Yang Yuguang" is okay.