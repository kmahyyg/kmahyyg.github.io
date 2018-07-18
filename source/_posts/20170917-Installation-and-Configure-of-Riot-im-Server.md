---
title: Installation and Configure of Riot.im Server
date: 2017-09-17 01:53:31
tags:
---

# Before Installation

Preparation: Ubuntu 16.04 LTS with High-speed network connected

Because of fucking Later Beta Server , I finally decided to use DOCKER image to help me simplify my work.

# Docker Set-Up

Firstly , REF: https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#prerequisites to install docker.

sudo apt-get remove docker docker-engine docker.io -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce -y
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://eeae51ae.m.daocloud.io
sudo docker run hello-world

# Docker Hub Inside the 

https://www.daocloud.io/mirror#

# Pull from official docker

## Riot.im Matrix-Synapse Server

 **Please run all commands under root permission.**
 
https://www.upcloud.com/support/install-matrix-synapse/
https://github.com/matrix-org/synapse

Check Here and Follow Github Readme to build it from source yourself, otherwise some commands must be wrong.

## Riot.im Web APP

docker pull silviof/matrix-riot-docker

> -p 8765
> -A 0.0.0.0
> -c 3500
> --ssl
> --cert /data/fullchain.pem
> --key /data/key.pem

echo "ALL THE CONFIG ABOVE SHOULD BE PUT HERE" > /dockerconf/riotweb/riot.im.conf

docker run -d -p 8765:8765 -v /tmp/data:/data silviof/matrix-riot-docker

## Riot.im Cross-Platform 
 
Find them at App Store for iOS , Play Store for Android , go to https://riot.im for PC or use the web app.

## Future optimization

1. Strongly suggest that you should not put the server and web client in the same server to prevent XSS attack.
2. Strongly suggest that you should use Let's Encrypt Trusted CA certificates to replace the self-signed one.
3. Please consider auto add port forward in docker run command , something in official dockerfile readme is missing.



# Enjoy it!