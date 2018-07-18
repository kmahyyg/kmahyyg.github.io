---
title: 学堂在线 MOOC 视频观看系统分析
date: 2017-12-05 15:22:58
tags:
  - Tech
  - YNU
---

学堂在线 MOOC 视频观看系统分析

# 前言

> 基础地址： http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/courseware/a0c88e15f0724905bdae5001ae905a15/4a819651df914e8e944be7e00f248d35/

> 鸣谢： https://github.com/wangqr/proto_xuetangx

因为学校垃圾校园网闪断问题频发，加上学堂在线 MOOC 系统设计存在重大缺陷，导致经常性无法正常记录学生的观看记录。

人懒，遂操起工具，分析视频观看记录系统。

# 加载页面

加载页面常用 JS、CSS、HTML 完成，看到是自己写的成绩记录系统 + XHR动态刷新 + OpenEDX 魔改而成。

加载完成后 访问  http://ynu.xuetangx.com/event ，然后 POST 一个 CDN_PREF数据到此处获取视频ID并加载视频，这里并不重要

# 播放视频全过程

## 心跳包解构

### 基础：浏览器环境
浏览器 Request Header：
```
Accept:*/*
Accept-Encoding:gzip, deflate
Accept-Language:en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7
Cookie:UM_distinctid=1601d25d955992-041780ba866e8-102c1709-1fa400-1601d25d9561182; _spoc_lms_cms_sessionid=8a1bc8065611bd8d6d347b9ae538f14f; _log_user_id=15490f8b4640272d3085687db3630f8a
DNT:1
Host:log.xuetangx.com
Proxy-Connection:keep-alive
Referer:http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/courseware/a0c88e15f0724905bdae5001ae905a15/4a819651df914e8e944be7e00f248d35/
User-Agent:Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.62 Safari/537.36
```

Response Header :
```
Connection:keep-alive
Content-Length:7
Content-Type:application/octet-stream
Content-Type:application/json
Date:Tue, 05 Dec 2017 12:35:29 GMT
Server:nginx
Via:1.1 ubuntu (squid/3.3.8)
X-Cache:MISS from ubuntu
X-Cache-Lookup:MISS from ubuntu:3128
```

### Heartbeat


#### 　起始播放
Base URL: ```http://log.xuetangx.com/heartbeat```
方式： POST

```
i:5 						// 心跳间隔： 5s
et:play                                  // 操作类型：play/seeking/pause/videoend/heartbeat
p:web　　　　　　　　// 终端：web/android
cp:0                                       //发生此行为的视频地址
fp:0					//拖拽起始
tp:0					//拖拽终止
sp:1.5					//播放倍速
ts:1512477329562　　　// 当前用户系统时间
u:7717027                            //用户ID
c:course-v1:TsinghuaX+y10_010610183_2X+2017_T2          // 课程ID
v:6e9bf023d8cf4744b7add14a3ab932d8                                 //课程结构中的视频ID
cc:B304B0428B631CD59C33DC5901307461　　　　　　//CC上存储的视频ID
d:519.4　　　　　　　　　　　//视频时长
pg:6e9bf023d8cf4744b7add14a3ab932d8_16uiv     //页面编号
sq:1					// 操作序号：自增ID
callback:c　　　　　　  //无意义：回调值恒为ｃ
_:1512477329564		//猜测是服务器时间戳，与系统时间戳+1/0
```

需要注意一点：　　页面编号: 

```javascript
var salt = Math.floor((1 + Math.random()) * 0x100000).toString(36);
// salt = (下舍入((1+ 一个0~1间的小数随机数) * 1048576)).转换为36进制
var pg = v + salt
```
#### Event 1 : Play_video

Base URL : ```http://ynu.xuetangx.com/event```
方式：　GET

Request Header:
```
Accept:application/json, text/javascript, */*; q=0.01
Accept-Encoding:gzip, deflate
Accept-Language:en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7
Content-Length:318
Content-Type:application/x-www-form-urlencoded; charset=UTF-8
Cookie:UM_distinctid=1601d25d955992-041780ba866e8-102c1709-1fa400-1601d25d9561182; _spoc_lms_cms_sessionid=8a1bc8065611bd8d6d347b9ae538f14f; sessionid=8a1bc8065611bd8d6d347b9ae538f14f; CNZZDATA1261596198=1201952707-1512317271-%7C1512476093; csrftoken=RrcGA18IeDhImhGwG6eDhoZbPViPyle7; user_id=7717027; _log_user_id=15490f8b4640272d3085687db3630f8a
DNT:1
Host:ynu.xuetangx.com
Origin:http://ynu.xuetangx.com
Proxy-Connection:keep-alive
Referer:http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/courseware/a0c88e15f0724905bdae5001ae905a15/4a819651df914e8e944be7e00f248d35/
User-Agent:Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.62 Safari/537.36
X-CSRFToken:RrcGA18IeDhImhGwG6eDhoZbPViPyle7
X-Requested-With:XMLHttpRequest
```

POST Form:
```
event_type:play_video
page:http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/courseware/a0c88e15f0724905bdae5001ae905a15/4a819651df914e8e944be7e00f248d35/
event:{"id":"6e9bf023d8cf4744b7add14a3ab932d8","code":"html5","currentTime":0}
```

```
event_type:cdn_perf
page:http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/courseware/a0c88e15f0724905bdae5001ae905a15/4a819651df914e8e944be7e00f248d35/
event:{"event":"canplaythrough","id":"6e9bf023d8cf4744b7add14a3ab932d8_16uiv","expgroup":"spoc","value":111457,"page":"B304B0428B631CD59C33DC5901307461","count":2}
```

#### 心跳连续打点

```
et= heartbeat
cp= 当前视频时间（单位秒）    //两个cp间隔= i * sp
ts= 当前系统时间戳 (Unix Timestamp，单位ms)                      // 两个ts间隔 = 5s
sq= 自增id
_=时间戳                                     //同样=ts
```

## 播放完成

### 保存用户状态并暂停，同时发送event

#### save_user_state

```
POST http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/xblock/block-v1:TsinghuaX+y10_010610183_2X+2017_T2+type@video+block@6e9bf023d8cf4744b7add14a3ab932d8/handler/xmodule_handler/save_user_state HTTP/1.1

Content-Length: 33
Referer: http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/courseware/a0c88e15f0724905bdae5001ae905a15/4a819651df914e8e944be7e00f248d35/
```

FORM Data:
```
saved_video_position:00:08:39
saved_video_position=00%3A08%3A39
```
注意几点：   

1. Base URL: ```http://ynu.xuetangx.com/courses/``` +  c + ```/xblock/block-v1:``` + c + ```type@video+block@```+ v +```/handler/xmodule_handler/save_user_state```

#### ( Heartbeat + event ) * 2

##### Heartbeat ( GET ) 

```javascript
et : pause
ts : (+1.5s) 
_ : (+1.5s)
```


##### event (post)

```
event_type:pause_video
page:http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/courseware/a0c88e15f0724905bdae5001ae905a15/4a819651df914e8e944be7e00f248d35/
event:{"id":"6e9bf023d8cf4744b7add14a3ab932d8","code":"html5","currentTime":519.36}
```

id = v

##### Heartbeat ( GET )

```javascript
et : pause
ts : (+15ms) 
_ : (+15ms)
```

##### event (post)
```
event_type:stop_video
page:http://ynu.xuetangx.com/courses/course-v1:TsinghuaX+y10_010610183_2X+2017_T2/courseware/a0c88e15f0724905bdae5001ae905a15/4a819651df914e8e944be7e00f248d35/
event:{"id":"6e9bf023d8cf4744b7add14a3ab932d8","code":"html5","currentTime":519.36}
```
# 后续

拉起 Python 3，使用 Requests 库准备动手。后续详情请查看 https://github.com/kmahyyg/proto_xuetangx 的 ```MASTER``` 分支。
