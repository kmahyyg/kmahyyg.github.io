#!/bin/sh

ssh-keyscan git.coding.net >> ~/.ssh/known_hosts
mkdir /tmp/tmp4coding
git clone https://kmahyyg:${CODING_PERTKN}@git.coding.net/kmahyyg/kmahyyg.git /tmp/tmp4coding
rm -rf /tmp/tmp4coding/*
cp -a ./public/* /tmp/tmp4coding
cd /tmp/tmp4coding
git config --global user.name "kmahyyg" && echo "Username set."
git config --global user.email "16604643+kmahyyg@users.noreply.github.com" && echo "UserEmail Set."
git add .
git commit -am "update from ci"
git push origin master
exit