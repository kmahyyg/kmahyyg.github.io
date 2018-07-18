---
title: Git Advanced Usage
date: 2017-10-12 02:50:47
tags:
---

# Git PR Specific Single Commit

$ git fetch --all
$ git checkout -b my-single-change upstream/master
$ git cherry-pick b50b2e7
$ git push -u origin my-single-change

# Git Single Commit Patch

git checkout <DETACHED HEAD SHA1>
git format-patch -1 HEAD > ./<PATCH FILE>
patch -p1 < ./<PATCH FILE>

# Git Merge Conflict Solve

https://stackoverflow.com/questions/161813/how-to-resolve-merge-conflicts-in-git
http://www.cnblogs.com/sinojelly/archive/2011/08/07/2130172.html