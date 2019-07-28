---
title: "HackTheBox - Challenges 1"
date: 2019-04-27T19:18:00+08:00
description: "HackTheBox 练手 - Forensics Challenges"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Solutions

MarketDump:  Wireshark extract SQL, found strange string, do the magic using cyberchef (Exactly Base58)

Took The Byte: XOR encrypted using password "ff", then unzip.

Blue Shadow:

1. Use https://www.vicinitas.io/free-tools/download-user-tweets to download all tweets of `@blue_shad0w_` 
2. Download tweets, and convert xlsx to csv
3. Use `python` to process csv, grab all binary digits.
4. `dd` a new bin , its length is 4050
5. `hexedit` to input all binary digits in hex form
6. execute the elf
7. you'll get notice: get antidote on the blue shadow virus
8. google it, you will find the virus born in Star War, and reeksa is the antidote
9. Run `./virus.bin reeksa`, get flag.

# Referrence

- https://gchq.github.io/CyberChef/
