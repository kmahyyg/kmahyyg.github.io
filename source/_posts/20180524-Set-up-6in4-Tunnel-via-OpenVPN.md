---
title: Set up 6in4 Tunnel via OpenVPN
date: 2018-05-24 11:24:20
tags:
  - Tech
---

# Linux - iproute2 method

https://github.com/kmahyyg/6in4/

More details: https://www.kmahyyg.xyz/2018/6in4-Tunnel/

# *nix/Win - OpenVPN method


## Prerequisite

* A Server with IPv4 and native IPv6
* A Client with at least a connection to server via IPv4
* OpenVPN and its hosting OS with TUN support

## Deployment  

Test Environment: Ubuntu 18.04 LTS (Server) & DSM 5.2 also with a Arch Linux PC (Client)

### Server: Easy and simple

#### Install OpenVPN

```bash
root@testsrv: apt update -y && sudo apt install dist-upgrade -y
root@testsrv: apt install openvpn easy-rsa -y
root@testsrv: apt install dnsmasq -y  # Optional
```

#### Generate a server&client key pair

```bash
root@testsrv: mkdir /etc/openvpn/easy-rsa  # new directory to save keys
root@testsrv: cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa # copy sample configs
root@testsrv: vim /etc/openvpn/easy-rsa/vars
```

Edit the file opened to give your certs and keys' properties:

```
vim /etc/openvpn/easy-rsa/vars
```

```
>export KEY_COUNTRY="GR"       # International country code
>export KEY_PROVINCE="Central Macedonia"    # Province
>export KEY_CITY="Thessaloniki"     # City
>export KEY_ORG="Parabing Creations"     # Organization
>export KEY_EMAIL="nobody@parabing.com"    # Email
>export KEY_CN="VPNsRUS"      # Common name, recommend use your server hostname
>export KEY_NAME="VPNsRUS"    # as you want
>export KEY_OU="Parabing"     # Organization unit name
>export KEY_ALTNAMES="VPNsRUS"    # as you want, keep it default if you don't know much about it
```

Generator start:

```bash
root@testsrv: cp /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf    # openssl config, keep it unmodified
root@testsrv: cd /etc/openvpn/easy-rsa
root@testsrv: source vars
root@testsrv: ./clean-all
root@testsrv: ./build-ca
root@testsrv: ./build-key-server delta   # delta should be the server name you like
root@testsrv: ./build-dh
root@testsrv: openvpn --genkey --secret /etc/openvpn/easy-rsa/keys/ta.key
```

Copy the ```ca.crt ca.key delta.crt delta.key dh2048.pem ta.key``` from ```/etc/openvpn/easy-rsa/keys``` to ```/etc/openvpn/easy-rsa/```

#### OpenVPN server config and start

Config file: (save to ```/etc/openvpn/server.conf```)
```
server 10.0.8.0 255.255.255.0         # VPN Client IPv4 subnet
topology subnet
server-ipv6 fc00:aaff:ffac::13:0/64   # VPN Client IPv6 subnet
port 10666
proto udp   
dev tun
auth SHA1
# Ensure IPv4 is open for connection
push "redirect-gateway autolocal def1 bypass-dhcp"
push "topology subnet"
push "dhcp-option DNS 223.5.5.5"
push "dhcp-option DNS 119.29.29.29"
# IPv6 DNS
push "dhcp-option DNS 2001:da8::666"
push "dhcp-option DNS 2001:4860:4860::8888"
push "ping 5"
push "ping-restart 30"
keepalive 30 120
duplicate-cn
client-to-client
persist-key
persist-tun
group nogroup
user nobody
tls-auth ta.key 0
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
cipher AES-256-GCM
comp-lzo
verb 3
fast-io
explicit-exit-notify 1
```

Start Service:

```bash
root@testsrv: ip6tables -t nat -A POSTROUTING -j SNAT --to-source <SERVER EXACT IPv6 ADDRESS>
root@testsrv: systemctl start openvpn@server
root@testsrv: systemctl enable openvpn@server
```

### Client: Simply Copy&Paste

#### Generate client key pair@server

Generator start:

```bash
root@testsrv: ./build-key laptop
```

Copy the ```ca.crt laptop.crt laptop.key dh2048.pem ta.key``` from ```/etc/openvpn/easy-rsa/keys``` to your client machine.

#### OpenVPN client config

Client config file: (save to current working directory named ```v4Tv6.ovpn```)
```
client
proto udp
dev tun
verb 3
remote x.x.x.x 10666 udp
keepalive 30 120
route 0.0.0.0 0.0.0.0 net_gateway  # route IPv4 traffic to server
route-ipv6 ::/0 net_gateway     # route IPv6 traffic to server
script-security 2
ca ca.crt
cert client.crt
key client.key
tls-auth ta.key 1
cipher AES-256-GCM
nobind
auth SHA1
comp-lzo
auth-nocache
fast-io
verb 3
```

#### Start OpenVPN and enjoy

```bash
user@tstclient: sudo openvpn ./v4Tv6.ovpn
```

# Acknowledgement: (Successive Rankings)

- http://www.strrl.com/2018/05/24/%E4%BD%BF%E7%94%A8OpenVPN%E7%9A%84tun%E6%A8%A1%E5%BC%8F%E5%BB%BA%E7%AB%8B4to6%E9%9A%A7%E9%81%93/
- https://fangdingjun.blogspot.com/2015/11/openvpnipv6.html
- https://unix.stackexchange.com/questions/136211/routing-public-ipv6-traffic-through-openvpn-tunnel
- https://freeaqingme.tweakblogs.net/blog/9237/openvpn-ipv6-with-ula-and-nat.html
- https://serverfault.com/questions/237851/how-can-i-setup-openvpn-with-ipv4-and-ipv6-using-a-tap-device
- https://techblog.synagila.com/2016/02/24/build-a-openvpn-server-on-ubuntu-to-provide-a-ipv6-tunnel-over-ipv4/
- https://wiki.archlinux.org/index.php/Easy-RSA
- https://linux.cn/article-3706-1.html