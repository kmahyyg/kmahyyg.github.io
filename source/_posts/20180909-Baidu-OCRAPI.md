---
title: Baidu OCR Restful API 的几个大坑
date: 2018-09-09 16:14:53
tags:
  - Tech
---

# Preview

见鬼的百度 OCR API，免费的中文识别率相对好一点的我只知道这个。希望大家多多推荐好用的。

这垃圾玩意浪费了我半个下午的时间，只因为官网的 Restful API 文档最关键的地方出错了！

# Code

需要的自取，实测可用。这是通用高精度 OCR 基础版 API 的处理，最终结果直接拼接字符串后保存。

```python
#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import requests
import base64
import json

def gettoken(apikey,secretkey):
    acstk = 'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=' + apikey + '&client_secret=' + secretkey
    getacs = requests.post(acstk,headers={'Content-Type':'application/json; charset=UTF-8'})
    whocare = getacs.json()
    return whocare['access_token']

def ocrnow(tokens,filename):
    baseurl = 'https://aip.baidubce.com/rest/2.0/ocr/v1/accurate_basic'
    query_url = baseurl + '?access_token=' + tokens
    with open(filename,'rb') as file:
        data2 = base64.b64encode(file.read()).decode()
    datatp = {'image':data2}
    r = requests.post(query_url,headers={'Content-Type':'multipart/form-data'},data=datatp)
    with open('result.json','w+') as fl1:
        fl1.write(r.text)
    return 0

def procresu(resultjson):
    fl1 = open(resultjson,'r').read()
    dat1 = json.loads(fl1)
    final = ''
    for i in dat1['words_result']:
        final = final + i['words']
    with open('result.txt','w+') as fp23:
        fp23.write(final)
    return 0
```

# Super Boom

1. 最终上传图片时的 header 应为 `headers={'Content-Type':'multipart/form-data'}`
2. 图片只需要 `base64.b64encode().decode()` ， 不需要 `urllib.parse.quote_from_bytes()`
