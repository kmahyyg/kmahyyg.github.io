---
title: Set up Google 2FA for Debian-based OS SSH Authentication
date: 2017-12-07T10:34:25
description: "在 Debian 8 上给 SSH 远程连接的身份认证添加两步认证机制"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Preparation

1. Debian-based system
2. Two conneced SSH sessions at the same machine to prevent from failure
           ** This machine should have a configured publickey auth method. **
3. A Phone with 2FA app installed (recommend Authy)
4. A safe place to save recovery code

# Usage

## Installation

```sh
sudo apt-get update -y
sudo apt-get install libpam-google-authenticator -y
google-authenticator
```

## Configuration of Authenticator

Follow the screen notification to input and save your recovery key.

Normally it should be: "Y" -> Save your Recovery key -> "Y" -> "N" -> "Y"

This config is highly-recommended.

## Configuration of PAM and SSH

Edit `/etc/pam.d/sshd` to enable the Google 2FA in PAM.

```
(At the top of the file)
# Standard Un*x authentication.
#@include common-auth       // Comment this line

......

(At the bottom of the file)
# Standard Un*x password updating.
@include common-password
auth required pam_google_authenticator.so nullok   //Add this Line here
```


Then edit the ```/etc/ssh/sshd_config``` to enable the force 2FA.

```
......

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication yes    // Change from no to yes

......

UsePAM yes      // Ensure Here is "yes"
AuthenticationMethods publickey,keyboard-interactive   // Add this line here

......

```

# Done!

Congratulaions! You've already configured it!

Try reconnect using another session!

If there's anything wrong, Search Google or leave a message here. Then use the connected session to change the config back.


