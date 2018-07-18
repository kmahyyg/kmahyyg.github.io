---
title: Develop a Simple Telegram Bot @lifehap4_yygbot
tags:
 - Tech
date: 2018-02-19 20:50:27
---

# Acknowledge

A huge thank to  [**@BennyThink**](https://www.bennythink.com)  . He helps me solved a lot of problems.

1. https://blog.nfz.moe/archives/how-to-write-beautiful-github-readme.html
2. https://github.com/BennyThink/ExpressBot
3. http://drakeet.me/create-telegram-bot-with-python/
4. [https://www.stackoverflow.com](https://www.stackoverflow.com/) Thanks for those experts.
5. [https://www.liaoxuefeng.com](https://www.liaoxuefeng.com/) Thanks for his tutorials. Very useful for green hands.
6. <https://github.com/eternnoir/pyTelegramBotAPI>  Thanks for dependencies.
7. <https://github.com/coderfox/Kuaidi100API> Thanks for dependencies.
8. <https://fast.v2ex.com/member/showfom> and his [https://ip.sb](https://ip.sb/) [https://sm.ms](https://sm.ms/) [https://u.nu](https://u.nu/)
9. https://core.telegram.org/bots/api

# Start up from Lifehacker

Originally, when I was young, I have a strong demand of using Gmail as my primary mail. However, because of some reasons we all know, Google Service was banned by China Communist Party's Government. As we all know, Google has a idiom that all IT man knew: Google is human's hugest hope. **We Need Google! We love Google! Google helps us make the world better!** Love Nexus&Pixel.

So that, I started to learn technologies to cross the firewall. Thanks to Lifehacker's creator @roamlog and maintainer @jannerchang, their blogs helps me a lot.(Now, we named our blog as CodeSucker and gathered so many people to share their experience about all things.)

But, with the censorship goes really strict, we changed our main IM from QQ to Telegram, a Peer-to-Peer-Encyption-supported & Non-censorship chat platform. Telegram has a very powerful dev-friendly Bot ReST API, you can use it to do a lot of things and improve your productivities.

First of all, the Telegram isn't a popularity in the past few years.  @chinanet has some powerful features. For example, Send a package emoji to check your express package status; Set a message trigger to make jokes on somebody(We called it as put a flag); Use search engine and check daily-life info very comfortably.  With the users group of Telegram grows so fast, This bot turns into internally use. We can't have any fun after that.

# Preparation

PS.  Cause I doesn't like to deploy a database which may cause private data leaking, So this bot didn't have any cache and push feature.

Telegram bot can use two methods to get update from server:

* Call  ```getUpdates```  API

* Set Webhook

According to personal preferrence and Github Stars, I chose ```python-telegram-bot``` as my base dependency. But it's difficult for me to understand its code structure and thinking. At last, I chose ```pyTelegramBotAPI``` .

-----------------------

To use ```getUpdates``` API , you have to define a bot instance first. 

```python
import telebot

bot = telebot.TeleBot("TOKEN")
```

Then use:

```python
bot.polling(none_stop=True,timeout=30)
```

to get the latest update from user.

------------------------------

To use Webhook, you must set up your own server to let Telegram Server post data to your server, so that you could do some response to TG's requests.

I chose Flask with Python 3.6 to finish this job.

However, This method will always bind one of those ports:[**443, 80, 88, 8443**]

But because of fucking CCP, I need to use some of above ports to set up a proxy.

So I finally didn't use the ```setWebhook``` method.

----------------

# Learning

http://flask-sqlalchemy.pocoo.org/

http://flask.pocoo.org/docs/0.12/

https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000

https://core.telegram.org/bots/api

https://github.com/eternnoir/pyTelegramBotAPI

Just follow the documents and demos.

# While Coding

Recommend: https://www.bennythink.com/tgbot1.html

https://www.bennythink.com/tgbot0.html

ReplyKeyboardMarkup should not and cannot use CallbackQuery to proceed data. Just use message ID to identify all messages and then proceed all datas.

Modulize all features you need, just use ```pyTelegramBotAPI``` as an extensible frontend framework. Then introduce all features and commands you need to deal with it.

# Finally

[My BOT Source Code](https://github.com/kmahyyg/life-tg-bot) Proudly Hosted on Github.

[My BOT(Limited to internal usage only)](https://t.me/lifehap4_yygbot) Now the hosting is dead, I'm waiting my service provider to fix it.

BTW, Finally, cooperate with Hermit, I can give up almost all Chinese-made malware APPs. (Only those Chinese-made app:Netease Music, QQ, Wechat, Alipay, Zhihu, Mobike left on my phone, and I almost never use them. Of course, they all downloaded from Google Play Store.)

**Use HTML5&Telegram BOT, NO APP!**

## TODO

Watchdog service and error handler need to be updated. Welcome PR.

