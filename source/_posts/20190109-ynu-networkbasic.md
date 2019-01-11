---
title: 计算机网络期末复习稿
date: 2019-01-09 00:06:43
tags:
  - School
---

# Computer Network - Chapter 1 - Basic Concepts

Host: End System.

Routers: Forward packets(chunks) of data through network.

Protocols: Control sending and receiving of messages. A protocol is a set of rules that govern data communication. It is an agreement between the communication entities. The elements of protocol are syntax, semantics, and timing.  

- Syntax: Data structure or format. 
- Semantics: the meaning of each section of bits. 
- Timing: When to send and how fast it should be.

C/S: Client/Server Model: Client host requests, receives service from server.

Peer2Peer model: Minimal (or no) use of dedicated server.

## Level 5/7 Layers (Important)

Level 5:

TCP/IP Layer:

| Application Layer | Message  |
| :---------------: | :------: |
|  Transport Layer  | Segment  |
|   Network Layer   | Datagram |
|    Link Layer     |  Frame   |

ISO/OSI Layer:

| Application Layer  |          应用软件接口          |
| :----------------: | :----------------------------: |
| Presentation Layer |         转换格式并封包         |
|   Session Layer    |          维护会话状态          |
|  Transport Layer   |       添加传输表头形成片       |
|   Network Layer    | 形成数据报，决定路径选择与转发 |
|  Data link Layer   |   网络寻址，错误纠正，形成帧   |
|   Physical Layer   |         与硬件直接互通         |

## Store and Forward (Important)

Circuit Switching: A dedicated circuit per call as telephone net.

- End to end resources served for "call"
- Link Bandwidth, Switch Capacity
- Dedicated Resouces
- Circuit-like (guaranteed) performance
- Call setup required

Example: TDM&FDM, Datagram network **is neither connection-oriented or connection-less**

Packet Switching: Data sent through net in discrete "chunks"

Pros:

- Divided data stream into packets
- Shared network resources
- each packet uses full link bandwidth
- resources used as needed

Cons:

- Aggregate resource demand can exceed amount available
- Congestion Control
- Node receives complete packet before forwarding, store and forward

### Delay (Important)

Transmission 传输 Delay: From the first sent bit to the last sent bit (Check header and calculate checksum)

Propagation 传播 Delay: From the first sent bit to the first received bit

Queuing Delay: From entering queue to send

Processing Delay: From Send process to queue entrance

Total delay: the sum of the four delays above.

## Communication

Full Duplex: Client&Server transfer in 2 directions at the same time.

Half Deplex: Only Client/Server can transfer at the same time but allow 2 directions.

Simplex: Only single directions can be used for transmission. (eg. Radio Station)

Connection Media: 

UnGuided media: 
- Wireless network
- Satellite radio

Guided media:
- Twisted-Pair Wire
- Coaxial cable
- Fiber optics

# Computer network - Chapter 2 - Application Layer

Due to the well-known, this part will be simplified.

## Process

Process: Progam running within a host, a instance.

Two processes communicate through IPC. Inter-process communicate by exchanging message.

## Application Service you may need to know

### HTTP

URL: Protocol + Hostname + Path name

Pipeline + Connection-alive(Persistent HTTP with single TCP conn) + Stateless

**RTT** : Round-Trip Time. 1 RTT = Send out and get back. Total RTT for HTTP: 2 RTT(1 for initiate conn, one for first request) + Transfer.

Request Packet Format:
```
[METHOD] [PATH NAME] [HTTP Version][\r\n]
[Headers][\r\n]
[Data body][\r\n]
```

Response Packet Format:
```
[HTTP Version] [Status code] [Status Phrase][\r\n]
[Headers][\r\n]
[Data: Entity body][\r\n]
```

Authentication:
![MDN HTTP 403](https://mdn.mozillademos.org/files/14689/HTTPAuth.png)

Conditional GET:
Related Header: `If-modified-since:` `304 Not Modified / 200 OK`

### FTP

Out of band communication: Port 20 for data transfer, Port 21 for command transfer

## Email

Major Components: User agents + Mail server + DNS + Protocol (SMTP/IMAP/POP3)

SMTP(25 / 465 SSL / 587 TLS): Push to server. (Send only for now)

IMAP(143/ 993 Encrypted) & POP3(110/ 995 Encrypted): Pull from client. (Receive at client, IMAP recommended)

Message in SMTP: 7-bit ASCII Code with Extended S/MIME via Base64 Encode

SMTP: 
```
-- Header lines --
To:   
From:  
Subject:   
-- Header lines --
DATA BODY  [\r\n][\r\n]
```

## DNS

Provide: 
- Distributed database based name resolver (Map from domain name to IP address)
- Host aliasing via CNAME
- Mail server aliasing via MX and PTR
- Load distribution

53/UDP with iterated query, 8 Global Root Server.

## Socket

Socket: The interface (sends to / receives from), middle-man in process and system TCP buffers.
Socket Pair: [IP Address:Port]

Server:
```python
import socket
import sys
import time

HOST = '0.0.0.0'
PORT = 23301


lsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)   # Define protocal stack as IPV4
lsock.bind((HOST, PORT))  # Bind IP and port
lsock.listen(65535)  # max connection number
conn, addr = lsock.accept()  # Accept Connection
data = conn.recv(1492)  # receive data with MTU 1492
conn.sendall(data)  # send data
conn.close()
```

Client:
```python
import socket
import sys
import time

HOST = '127.0.0.1'
PORT = 23301

recsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
recsock.connect_ex((HOST,PORT))   # Connect to server
recsock.sendall(b'HelloWorld!')
data=recsock.recv(1492)
recsock.close()
```

# Computer Network - Chapter 3 - Transport layer (Really matters)

Transport layer: logical communication between processes

Network layer: logical communication between hosts

## Multiplex and Demultiplex

Demultiplex: delivering received segments to correct socket.

Multiplex: Gather data from multi sockets and enveloping data with header.

IP Datagram format: `Header fields | 32 Bits SRC IP | 32 Bits DEST IP | DATA`

UDP socket: identified by `dest IP | dest port`
TCP socket: identified by `src IP | src port`

## Transport service 

An app needed:

- Data loss control
- Bandwidth
- Timing(Low delay)

### TCP Service (Important)

- Connection-oriented, full duplex data, pipeline
- Reliable Transport with point to point and in-order
- Flow control
- Congestion control with buffers

MSS: Max segment size, default 536 Bytes

Segment Structure:
```
| source port | dest port |
| sequence no | ack no    |
| head len  | 0 | UAPRSF  |
|Receive window | checksum|
|Urg data pointer| options|
|        body : data      |
```

#### Reliable data transfer

Sequence No. = 第一个字节号

Piggybacked & Cumulative ACKs: ACK No.: 下一个待传字节号

TCP 超时重传： Timeout events & Duplicate ACKs

MSL: Max segment lifetime

![TCP_CONN](https://yygc.zzjnyyz.cn/asset_files/tcp-handshake-conn.jpg)

SYN_SENT -> SYN_RCVD -> ESTABLISHED -> ESTABLISHED

![TCP_DISCONN](https://yygc.zzjnyyz.cn/asset_files/tcp-handshake-disconn.jpg)

FIN_WAIT_1 -> CLOSE_WAIT -> FIN_WAIT_2 -> LAST_ACK -> TIME_WAIT -> CLOSED

#### Checksum

IEEE 802.3 CRC32

### UDP Service (Important)

- Unreliable, unordered delivery (data may be lost)
- Connection-less (no handshake, each segment handled by app): Simple and smaller header
- No congestion control with best-effort

Used for:

- Loss tolerant, rate sensitive(streaming and multimedia)
- DNS & SNMP

Packet format:
```
        src port        |    dest port    |
length including header |    checksum     |
```

Checksum:

Divided data into 16-bit groups and add each one, wrap around if additional bit get.
checksum is sum get reversed.

# Computer network - Chapter 4 - Network Layer

## Network Layer Function

- Routing: determine which route should be taken
- Forwarding: process to next hop

BTW, Virtual circuit networking: router must maintain connection state information, contains path from src to desc, vc no, entries in fwd tables.

## IP: Internet protocol

### Data structure

```
version | head length | type of service |       length      |
identifier      |        flags      |   fragment offset     |
  TTL     |     Upper Layer         |   IP Checksum         |
                            SRC IP                          |
                            DEST IP                         |
                            Options                         |
                            DATA                            |
```

Identifier: Used for reassemale segment

Header len: Min 20 Bytes = 5, Max 60 Bytes = 15;

Flag: | Reserved 0 | Don't Fragment (1,DF) | Last Fragment (0,More_F)|

Type of service: Used for QOS,
| Precendence (0-2 bits) | Normal delay (0) | High throughput (1) | High Reliability(1) | Reserved (6-7 Bits) |

Fragment Offset:

**数据部分切割，不含报头长度** = (PacketLength - HeaderLength) / 8

### Addr

IPv4 Addr is 32 Bits.

In binary: 

Class A = 0 + Netid + Hostid
Class B = 10 + Netid + Hostid
Class C = 110 + Netid + Hostid

Class D = 1110 + xx (Multicast Addr)
Class E = 1111 + yy (Reserved Addr) 

CIDR: 192.168.200.0/24  24:Network mask, previous 24 bits of mask is 1.

Minimum IP is Subnet Addr, Last IP is multicast IP.

IP Address AND network mask is CIDR ADDR.

### Hierarchical Addressing: Route Aggregation

Autonomous System: An aggregation of routers that they run the same routing algorithm, and one or more of the routers ( is called gateway router) can routing packets to other networks. Use Intra-AS routing protocol for peering with another AS.

## Routing Algorithms

Global: Link state algorithm (Dijkstra)

Decentralized: Distance vector Algorithm (Bellman-Ford Equation)

### Dijkstra 

TALK IS CHEAP, SHOW ME THE CODE!

```python
#!/usr/bin/env python3
# -*- encoding:utf-8 -*-

import sys

class Graph():
    def __init__(self,vertices):
        self.V = vertices   # initiate 2D arrays with the number of vertexes
        self.graph = [[0 for column in range(vertices)] for row in range(vertices)]

    def printSolution(self,dist):
        print("  Vertex\tDistance from src")   # print the solution, loop all vertexes
        for node in range(self.V):
            print("\t",node,"\t\t\t",dist[node])

    def minDistance(self,dist,sptSet):
        min = sys.maxsize  # assume that all paths have the maximum length
        min_index = None   # initial var to avoid non-sense error
        for v in range(self.V):
            # find the vertex with minDist from not in sTree
            if dist[v] < min and sptSet[v] == False:
                min = dist[v]
                min_index = v
        if min_index == None:
            raise NotImplementedError
        return min_index

    def dijkstra(self,src):
        dist = [sys.maxsize] * self.V
        dist[src] = 0  # vertex to itself should be zero
        sptSet = [False] * self.V  # Shortest path tree set, initiate

        # choose a vertex
        for cout in range(self.V):
            # pick the minDist vertex from not accessed vertexes, first time == src
            u = self.minDistance(dist,sptSet)
            # the minDist vertex put into shortest path tree
            sptSet[u] = True
            # only when current vertex > new vertex, and the vertex not in sptset,
            # update the picked vertex's neighbor's distance (new distance with new node as a relay)
            for v in range(self.V):
                if self.graph[u][v] > 0 and sptSet[v] == False and dist[v] > dist[u] + self.graph[u][v]:
                    dist[v] = dist[u] + self.graph[u][v]
        self.printSolution(dist)

if __name__ == '__main__':
    g = Graph(6)
    g.graph = [
        [0,2,5,1,0,0], #A, and no-route should be zero.
        [2,0,3,2,0,0], #B
        [5,3,0,3,1,5], #C
        [1,2,3,0,1,0], #D
        [0,0,1,1,0,2], #E
        [0,0,5,0,2,0]  #F
    ]
    g.dijkstra(0) # source is A
```

### Distance vector Algorithm (Bellman-Ford Equation)

D (X to Y) = min {neiborhood V} -> cost(x,v) + cost(v,y)
重点：结点获得最短路径的下一跳, 该信息用于转发表中！

异步迭代:

- 引发每次局部迭代的因素
- 局部链路费用改变
- 来自邻居的DV更新

分布式:

- 每个结点只当DV变化时才通告给邻居
- 邻居在必要时（其DV更新后发生改变）再通告它们的邻居

# Computer Network - Chapter 5 - Link Layer

## Introduction

Nodes: Hosts and routers

Links: Communication channels that connect adjacent nodes along communication path.

Farme: Layer-2 Packet, PDF, encapsulates datagram. 

Responsible for : transfer datagram from one node to adjacent node over a link

## Error Detection and Correlation

### Parity Bit

奇校验 是 奇数个 1 得到的校验位为 0，偶校验 是 偶数个 1 得到的校验位 为 0

### CRC: Cyclic Redundancy Check

G:1001=x^3+x^0=x^3+1 D:101110

G 的最高位恒为 1, D 左移 (len(G)-1) 位后对 G 作 XOR 除法运算，最终得到余数即为 Checksum.

检验无误： D 左移 (len(G)-1) 位后加上 Checksum 对 G 作 XOR 除法，余数为 0 则正常。

## ARP

Address Resolution Protocol: IP/MAC address mapping for lan nodes

ARP Table builder:

- A Broadcast: B's IP Addr is blahblah，but I don't know B's MAC (Dest IP: 192.168.200.255, Dest MAC: FFFFFFFFFFFF)
- B Receive, then replies to A with B's MAC (unicast)
