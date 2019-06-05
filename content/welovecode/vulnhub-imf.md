---
title: "Vulnhub - IMF Writeup"
date: 2019-06-05T19:24:33+08:00
description: ""
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# 紧急插播

https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md

# Download here

Target VM: https://download.vulnhub.com/imf/IMF.ova

Difficulty: Beginner/Moderate

IMF is a intelligence agency that you must hack to get all flags and ultimately root. The flags start off easy and get harder as you progress. Each flag contains a hint to the next flag. This IMF has 6 flags.

# Before Start

After you download it, just import to your VMWare workstation and change the network interface type as you pleased. Network is configured via DHCP.

Prepare your Kali and ensure they are in the same subnet.

Open VMware workstation - Edit - Virtual network editor to get the ip range.

## Check VM IP

`nmap -sn -n 172.16.51.0/24`, found: 172.16.51.134

# GOGOGO

## Before Attack

`nmap -A -Pn -p1-65535 -O -oN imf-nmap 172.16.51.134`

Only 80 port is opened, things might be tough.

## Start Attack

### Flag 1

Access to the site, `flag1{YWxsdGhlZmlsZXM=}` found at the `contact.php` source code.

Decode flag via Base64: allthefiles

### Flag 2

`contact.php` src:

```html
        <script src="js/ZmxhZzJ7YVcxbVl.js"></script>
        <script src="js/XUnRhVzVwYzNS.js"></script>
        <script src="js/eVlYUnZjZz09fQ==.min.js"></script>
```

Combine and decode via base64: `flag2{aW1mYWRtaW5pc3RyYXRvcg==}`

Decode again: imfadministrator

### Flag 3

`gobuster -u http://172.16.51.134 -w /media/kmahyyg/linuxdata/WorkData/HostedOnGithub/hackbox_tools/utils/outsidetools/dictionaries/DirBuster-Lists/directory-list-2.3-medium.txt -x php,html,txt,html -o imf.txt` to check if can find something:

```
/contact.php (Status: 200)
/images (Status: 301)
/index.php (Status: 200)
/projects.php (Status: 200)
/css (Status: 301)
/js (Status: 301)
/fonts (Status: 301)
/less (Status: 301)
/server-status (Status: 403)
```

Nothing useful... Try `/imfadministrator`, check webpage source code, found:

```
<!-- I couldn't get the SQL working, so I hard-coded the password. It's still mad secure through. - Roger -->
```

> Please note: OSCP doesn't allow bruteforce and SQLMap/Metasploit etc.

Try to get information from `contact.php`, found 3 usernames: estone, rmichaels, akeith

If you have a invalid username, it will tell you. So the only valid username is : `rmichaels`.

But how about password?

Firstly, `SQL`, SQL Injection? Due to the large amount data here, try SQLMap. NOT WORKING...

Secondly, `hard-coded` ? So, what to do next?

I just asked for help here, got the response:

> Update the name of the field `pass` to be `pass[]`. This means that PHP will interprete this field as **an array**, instead of **a string**. This can some times confuse validation or even string checks, as `strcmp` will return `NULL` if one of the inputs is an array.
> The script compares the user input from the `pass` field to the hardcoded password, using the `strcmp` function. It **then compares the result of this call to the value 0**. If you use `strcmp` to compare a `string` and an `array`, it will return `NULL`. `(NULL == 0) = TRUE`, as we're only using two equals signs. If the author had used three, then this bypass would not work, as `(NULL === 0) = FALSE`.

So just change the form code in HTML.

Got FLAG3: `flag3{Y29udGludWVUT2Ntcw==}` and a link to CMS which goes to `http://172.16.51.134/imfadministrator/cms.php?pagename=home`.

Decode again: continueTOcms

## FLAG 4


