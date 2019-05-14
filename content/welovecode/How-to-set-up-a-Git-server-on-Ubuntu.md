---
title: How to set up a Git server on Ubuntu
date: 2017-11-11T07:57:49
description: "多快好省，速度搭建一个纯 Git Server"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Prepartion

1. Set a proper APT source
2. Ubuntu Xenial
3. Network connected and root access
4. Configure your firewall properly

# Installation

## Install the dependencies

```bash
apt-get update -y
apt-get install git-core git-all -y
```

## Install a proper SSH key

```bash
ssh-copy-id
adduser git
mkdir /home/git/.ssh && chmod 700 /home/git/.ssh
touch /home/git/.ssh/authorized_keys && chmod 600 /home/git/.ssh/authorized_keys
touch /home/git/.ssh/authorized_keys && cat /root/.ssh/authorized_keys >> /home/git/.ssh/authorized_keys
```

# Set up the repo and git server

## Set up an empty repo

```bash
cd /var/lib/git
mkdir ./gitrepo
cd ./gitrepo
git init --bare
chown -R git:git gitrepo
```

## Set up Git user login shell

```bash
mkdir /home/git/git-shell-commands
chmod +x /home/git/git-shell-commands
cat >/home/git/git-shell-commands/no-interactive-login <<\EOF
#!/bin/bash
printf '%s\n' "Hi $USER! You've successfully authenticated, But We donnot provide the shell access."
exit 128
EOF
chmod +x /home/git/git-shell-commands/no-interactive-login 
chsh git -s /home/git/git-shell-commands/no-interactive-login
```

## Make sure Git daemon is running

```bash
ps aux
runsv /etc/service
```

# Set the local repo synced with remote branch

## Set up local repo

```bash
git remote add origin master ssh://git@[your hostname]:[your ssh port]/[absolute path of the git repo]/[reponame.git]
git fetch
git rebase master
git add .
git commit -m "sync with upstream"
git push origin master
```

# Troubleshooting

## Troubleshooting

### cannot create the lock file

just delete {[repo root]/refs/master/heads/master.lock}

### permission denied

use `chown -R git:git [folder path]`


