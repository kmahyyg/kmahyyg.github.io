---
title: "Recommend a NetBoost: KCPTUN"
date: 2016-07-17T08:43:51
description: "用于高延迟、不稳定网络的高速传输中间件 KCPTUN"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Background

Protocol: https://github.com/skywind3000/kcp
Software: https://github.com/xtaci/kcptun

加速效果极端明显，而且有基本利他性，与多倍发包无关！大力支持！拒绝 net-speeder！

# 初阶应用

## Install

以下以Debian8 x64,V20160922 为例

### 服务端

#### 下载解压 并以root登录

```bash
    cd ~
    wget https://github.com/xtaci/kcptun/releases/download/v20160922/kcptun-linux-amd64-20160922.tar.gz
    tar zxvf ./kcptun-linux-amd64-20160922.tar.gz
    rm -rf ./client_linux_amd64
    mkdir ./kcp-server
    mv ./server_linux_amd64 ./kcpserv
    chmod 700 ./kcpserv
```

#### config.json

服务器端： 

```json
    {
        "listen": ":服务器监听端口",
        "target": "127.0.0.1:转发端口",
        "key": "密码",
        "crypt": "加密方法",
        "mode": "模式",
        "mtu": 1350,
        "sndwnd": 自行调整,
        "rcvwnd": 自行调整,
        "datashard": 10,
        "parityshard": 3,
        "dscp": 46,
        "nocomp": true,
        "acknodelay": false,
        "nodelay": 0,
        "interval": 40,
        "resend": 0,
        "nc": 0,
        "sockbuf": 4194304,
        "keepalive": 10
    }
```

两端参数必须一致的有: datashard parityshard nocomp key crypt

内置模式：

响应速度: fast3 > [fast2] > fast > normal > default

有效载荷比: default > normal > fast > [fast2] > fast3

中间mode参数比较均衡，总之就是越快越浪费带宽，推荐模式 fast2

更高级的 手动档 需要理解KCP协议，并通过 隐藏参数 调整，例如:

```
    -mode manual -nodelay 1 -resend 2 -nc 1 -interval 20
```

高丢包率的网络建议采用 fast2, 低丢包率的网络，建议采用 normal。

客户端：

```json
    {
        "localaddr": ":本地监听端口",
        "remoteaddr": "服务器地址:监听端口",
        "key": "密码",
        "crypt": "加密",
        "mode": "模式",
        "conn": 1,
        "autoexpire": 60,
        "mtu": 1350,
        "sndwnd": 自行调整,
        "rcvwnd": 自行调整,
        "datashard": 10,
        "parityshard": 3,
        "dscp": 46,
        "nocomp": true,
        "acknodelay": false,
        "nodelay": 0,
        "interval": 40,
        "resend": 0,
        "nc": 0,
        "sockbuf": 4194304,
        "keepalive": 10
    }
```

#### 启动参数，写入 `/etc/rc.local`

此处以 100M 电信光纤为例 

**带$的均为变量，请根据自己的具体信息更改**

```bash
    nohup /root/kcpserv -c /root/config.json -log /root/kcplog.log >> /dev/null
```

## Usage

### 客户端

#### PC下：

创建一个 bat，写入：

```bash
    client_windows_386.exe -c ./config.json
``` 

将其置于与客户端同一文件夹，每次先启动 ss 再运行此 bat 即可。

后面的各项参数除 `--rcvwnd` `--sndwnd`外均必须与服务器保持一致！具体的参数配置请参见进阶应用部分。
    
#### SS本地设置

本地SS客户端设置：

> 主机： 127.0.0.1
> 端口： kcptun 的客户端监听的端口
> 其余的不变

# 进阶应用

## 自行调整的参数

第一步：同时在两端逐步增大 client `rcvwnd` 和 server `sndwnd`;
第二步：尝试下载，观察如果带宽利用率（服务器＋客户端两端都要观察）接近物理带宽则停止，否则跳转到第一步。

## 手动调整参数

> # 协议配置
>
>协议默认模式是一个标准的 ARQ，需要通过配置打开各项加速开关：
>1. 工作模式：
   ```cpp
   int ikcp_nodelay(ikcpcb *kcp, int nodelay, int interval, int resend, int nc)
   ```
>
   - nodelay ：是否启用 nodelay模式，0不启用；1启用。
   - interval ：协议内部工作的 interval，单位毫秒，比如 10ms或者 20ms
   - resend ：快速重传模式，默认0关闭，可以设置2（2次ACK跨越将会直接重传）
   - nc ：是否关闭流控，默认是0代表不关闭，1代表关闭。
   - 普通模式：`ikcp_nodelay(kcp, 0, 40, 0, 0);
   - 极速模式： ikcp_nodelay(kcp, 1, 10, 2, 1);

>2. 最大窗口：
   ```cpp
   int ikcp_wndsize(ikcpcb *kcp, int sndwnd, int rcvwnd);
   ```
   该调用将会设置协议的最大发送窗口和最大接收窗口大小，默认为32. 这个可以理解为 TCP的 SND_BUF 和 RCV_BUF，只不过单位不一样 SND/RCV_BUF 单位是字节，这个单位是包。

>3. 最大传输单元：
   纯算法协议并不负责探测 MTU，默认 mtu是1400字节，可以使用ikcp_setmtu来设置该值。该值将会影响数据包归并及分片时候的最大传输单元。

>4. 最小RTO：
   不管是 TCP还是 KCP计算 RTO时都有最小 RTO的限制，即便计算出来RTO为40ms，由于默认的 RTO是100ms，协议只有在100ms后才能检测到丢包，快速模式下为30ms，可以手动更改该值：
   ```cpp
   kcp->rx_minrto = 10;
   ```


> # 文档索引

> 协议的使用和配置都是很简单的，大部分情况看完上面的内容基本可以使用了。如果你需要进一步进行精细的控制，比如改变 KCP的内存分配器，或者你需要更有效的大规模调度 KCP链接（比如 3500个以上），或者如何更好的同 TCP结合，那么可以继续延伸阅读：

> - [Wiki Home](https://github.com/skywind3000/kcp/wiki)
> - [KCP 最佳实践](https://github.com/skywind3000/kcp/wiki/KCP-Best-Practice)
> - [同现有TCP服务器集成](https://github.com/skywind3000/kcp/wiki/Cooperate-With-Tcp-Server)
> - [传输数据加密](https://github.com/skywind3000/kcp/wiki/Network-Encryption)
> - [应用层流量控制](https://github.com/skywind3000/kcp/wiki/Flow-Control-for-Users)
> - [性能评测](https://github.com/skywind3000/kcp/wiki/KCP-Benchmark)

# Enjoy It!
