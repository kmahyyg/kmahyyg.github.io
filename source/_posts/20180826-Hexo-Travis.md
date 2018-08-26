---
title: Hexo 与 Travis CI 的八字不合
date: 2018-08-26 18:40:58
tags:
  - Tech
---

# 前因

请查看 [见鬼的 Travis CI](/2018/Sucked-Travis-CI/)

# 第一次查错

最近的 Travis CI Status Page 显示所有 `sudo:required` 的 build 均统一出现异常，没有太过在意。
联系 Travis CI 客服之后客服让我把 `sudo:required` 去掉，以便重新把我的 build 引流到 container-based 的另一个基础设施上。
后面短时间内的几个 build 均正常，可过了一段时间之后又回到了前面提到的状况当中。

# 第二次查错

客服的反馈是可能是环境变量和 npm 包的安装问题，建议我自查之后尝试把安装 `hexo-cli` 的参数从 `-g --save` 变成 `--save` 或 空。
查询 Hexo 官网 之后得知不能去掉 `-g`，尝试去掉或按照客服建议均无法成功，提示 `bash: hexo not found.`
继续邮件反馈给客服，3 天后收到了回信。

# 第三次查错

这一次回复的客服从 Customer Service Specialist 变成了 Travis Builder。她尝试 Fork 了我对应的 Repo 并进行了一系列测试，最终反馈了如下的结果：

- The problem does only happen when the node modules are cached.
- When the cached modules are used, the errors seem to follow an interesting pattern: 1 out of 2 builds fail, consecutively. I think this explains the behavior you're seeing where restarting the build makes it work. (This: build history list)
- This pattern made me think that the error might be caused by the combination of how cached contents are downloaded in the VM (this is, when the cache is downloaded and set up, I assume the order in which files are included might vary) AND, maybe, the order in which NPM is detecting these cached modules.
- Something I noticed is that, in these builds, NPM install seems to be returning a different output in each of them, where the order of these hexo packages varies.
- I found that, when the packages are installed in the same order, the problem does not happen:

```yaml
install:
- npm install hexo-cli -g --save
- npm install hexo-helper-qrcode
- npm install hexo-generator-feed
- npm install hexo-deployer-git
- npm install hexo-prism-plugin
- npm install hexo-generator-search
- npm install hexo
- npm install hexo-generator-sitemap
```

客服也注意到有人遇到了同样的问题，在 Hexo 的 Issues 里报了 Bug.

> As a bit more information, the order in which NPM installs packages, in general, is not deterministic since this shouldn't be relevant. However, it seems this is causing some differences here and I wonder if this might be related to a Hexo bug, as it happened here: https://github.com/hexojs/hexo/issues/2076

并建议我按照上面的顺序重写我的 `.travis.yml` 然后再行尝试。

最后客服提到了关键的一点 `package.json` 和 `package-lock.json`:

> Something I also noticed is that your package.json doesn't seem to be up-to-date with these installed packages, see the updates after the npm installs.
>
> After deleting the package-lock.json file during the build, I could obtain several working builds in a row and the intermittent failures didn't appear: See builds. **This seems to reinforce the hypothesis that the way NPM is treating these dependencies, non-deterministically, might be causing these errors.**

然而 `bash: hexo not found.` 的问题解决了， `hexo g` 生成静态内容的问题又出现了。
我先按照建议把 `package.json` 和 `package-lock.json` 删除后提交触发 build，然而还是 useless.
这一次我把和客服沟通的邮件 po 到了我博客所使用的主题的支持群中，请求开发者帮助。

# 最终查错

在这里，先感谢 @ysc3839 的帮助。

他建议我先在一个全新的干净环境下本地安装一次依赖之后将 `package.json` 和 `package-lock.json` 添加到 Repo 中。

最后我新建了一个 Cloud9 WebIDE Workspace，新建文件夹并从零开始安装了所有依赖，并使用空内容博客尝试进行了一次 `hexo g` 操作。测试成功后将 `package.json` 和 `package-lock.json` 添加到 原有的 Repo 中覆盖。这一次问题解决了。

# 总结

我做了这几件事来解决这个问题：

- Start a new and clean environment at local

这一步使用了这些指令：

```bash
$ npm install hexo-cli -g --save
```

- Create a new folder and input `hexo init`
- Install all the npm dependencies I need (installation commands all
coms from `.travis.yml` )

这一步使用了这些指令：

```bash
$ npm install hexo hexo-deployer-git hexo-prism-plugin hexo-helper-qrcode hexo-generator-search hexo-generator-sitemap hexo-generator-feed --save 
```

- Copy the `package.json` and `package-lock.json` to the existing repo
and replace the old ones
- Change `install` stage commands.

最终的 `.travis.yml` 中的 install stage 是这样的：

```yaml
install:
  - npm install hexo-cli -g --save
  - npm install
```

问题顺利解决。
