---
title: CI of Hexo Blog
date: 2017-09-16 03:13:54
tags:
---

# Pre-configure

Set Personal Access Tokens for accessing your repo with write access and so that the push operation won't need you to use SSH keys.

# Deploy Settings in Hexo Global _config.yml


deploy:
  type: git
  repo: 
    github: git@github.com:kmahyyg/kmahyyg.github.io.git,master
    coding: git@git.coding.net:kmahyyg/kmahyyg.git,master
    
    
# Refs

https://blog.nfz.moe/archives/hexo-auto-deploy-with-travis-ci.html

http://docs.flow.ci/zh/

https://huangyijie.com/2017/06/22/blog-with-github-travis-ci-and-coding-net-3/

https://docs.travis-ci.com/user/encrypting-files/#Automated-Encryption

https://huangyijie.com/2016/09/20/blog-with-github-travis-ci-and-coding-net-1/

https://github.com/kmahyyg/kmahyyg.github.io/blob/raw/.travis.yml
