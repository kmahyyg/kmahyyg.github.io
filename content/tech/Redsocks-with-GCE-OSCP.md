---
title: "OSCP Prepare - Fuck GFW"
date: 2019-06-18T08:31:57+08:00
description: "使用 GCP 构建一个 Kali 工作平台并配置本地快速访问"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_network.webp"
categories: ["network"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Preface

Due to the fucking GFW, I cannot access to the OSCP lab very smoothly without some software. So I'd like to build my working environment in Google Cloud. This article is going to introduce you how to deploy latest Kali Linux and accelarate remote desktop access in your own laptop.

DO NOT UPLOAD A HUGE IMAGE FILE (whether in raw or vmdk) SINCE THE POOR NETWORK IN CHINA MAINLAND.

## Prerequisite

- A Network Accarlarator: ShadowsocksR with your own well-deployed server

Here, I assume your client listening at 127.0.0.1:1084 on your laptop.

- A Google Cloud Platform Account
- A laptop installed with Linux OS (here, I use Arch Linux :)

# GCP - install Kali with netboot

## Prepare custom image

Firstly, create a storage bucket in your console and open a cloud shell window.
Your storage bucket should give access to your service account inside your GCP project and also YOU NEED TO manually give full access to your own gmail account.

Next, download the tar.gz file from [here](https://boot.netboot.xyz/ipxe/netboot.xyz-gce.tar.gz), and rename it to `kali-gce.tar.gz` (Lowercase letters with numeric chars and hyphen are allowed). Upload it to your bucket.

In your cloud shell, Run:

```bash
$ gcloud compute images create kali-gce --source-uri gs://<YOUR BUCKET NAME>/kali-gce.tar.gz
```

## Create instance

Then you have a custom image, then create an instance with 40GiB persistent disk with the image we just created. After you created, halt this instance and enable the console access, Restart your machine and access its console via cloudshell.

## Install OS

Choose "Security related" Menu, and select Kali. Follow the stey-by-step wizard.
You have some points you must notice here:

- The network must be configured manually, for network configuration in detail, check the VPC network tab in your web console. The Netmask is 255.255.240.0, The IP should be your internal IP.
- The debian archive address must be input manually, using "http://http.kali.org", the archive root folder is "/".
- The partition step, I suggest you divide 25 GiB to /, and 15GiB to individual /home.
- The component part, make sure you choose "Web Server" and "SSH Server". I suggest you use XFCE (lightweight enough)or don't install any DE.

We'll use XFCE as an example here.

## After-Installation configure

Firstly, set a root password and copy your SSH public key to your instance.

Secondly, do the necessary secure enhancement.

> I tried to use VNC, since it's very slow and in a low-quality, also it's difficult to configure.

You just have the base installation.

Run the following commands to get all the packages we need.

```bash
$ sudo apt update -y
$ sudo apt install kali-linux-full kali-linux-web kali-linux-forensic kali-linux-pwtools -y
$ sudo apt install x2goserver x2goserver-extensions tmux -y
$ sudo systemctl enable ssh
$ sudo systemctl start ssh
$ sudo x2godbadmin --createdb
$ rm -rf /usr/share/applications/applications # IF FOUND DUPLICATE ENTRIES IN YOUR START MENU
$ sudo systemctl start x2goserver
$ sudo systemctl enable x2goserver
```

Please update the following settings in your `/etc/ssh/sshd_config`:

```
AllowAgentForwarding no
AllowTcpForwarding yes
GatewayPorts yes
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost yes
PermitTTY yes
PrintMotd no
TCPKeepAlive yes
Compression delayed
UseDNS no
PermitTunnel yes
```

That's all, enjoy it.

# Laptop - redsocks transparent proxy

## Prerequisite

- iptables enabled
- Enable packet forward in kernel parameter

Write the following contents to your `/etc/sysctl.d/99-forward_allow.conf` :

```
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

Then `sysctl -p /etc/sysctl.d/99-forward_allow.conf`

- `pacman -S redsocks x2goclient`
- Configured SSH Agent

## Local x2go configure

Create a session with your config since the data of x2go is transferred via SSH. Set the screen resolutions and DPI. Set connection speed to WAN, enable Try auto login via SSH Agent and make sure your session type is corresponding to your DE.

## Local redsocks configure

You should configure all of the below in root permission.

I assume that you would like to put your config in `/etc/redsocks/`.

Copy the following content to `/etc/redsocks/redsocks.service`:

```systemd
[Unit]
Description=Transparent redirector of any TCP connection to proxy using your firewall

[Service]
Type=forking
PIDFile=/run/redsocks.pid
EnvironmentFile=/etc/conf.d/redsocks
User=root
ExecStartPre=/usr/bin/redsocks -t -c $REDSOCKS_CONF
ExecStartPre=/etc/redsocks/iptables_conf.sh a
ExecStart=/usr/bin/redsocks -c $REDSOCKS_CONF \
  -p /run/redsocks.pid
ExecStopPost=/bin/rm /run/redsocks.pid
ExecStopPost=/etc/redsocks/iptables_conf.sh d
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

Set the correct environment for service, `/etc/conf.d/redsocks`:

```bash
REDSOCKS_CONF="/etc/redsocks/redsocks.conf"
```

Create a script to help you persistent your iptables config and `chmod +x iptables_conf.sh`, `/etc/redsocks/iptables_conf.sh`:

```bash
#!/bin/sh
case $1 in
        'a')
                # Create chains
                iptables -t nat -N REDSOCKS
                # Ignore the private network IP
                iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
                iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
                iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
                iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
                iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
                iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
                iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN
                # Only redirect Google Cloud IP
                iptables -t nat -A REDSOCKS -d 34.92.0.0/14 -p tcp -j REDIRECT --to-ports 11088
                # The 11088 is the configured port in your redsocks config, 34.92.0.0/14 is your Google Cloud machine IP address range
                # For all connectiont towards 22, redirect to redsocks chain.
                iptables -t nat -A OUTPUT -p tcp --dport 22 -j REDSOCKS
        ;;
        'd')
                # Clean up after service stop
                iptables -t nat -F REDSOCKS
                iptables -t nat -X REDSOCKS
        ;;
esac
```

Redsocks config, for just redirecting all TCP (Not UDP, write your own config if you need, UDP proxy only support for SOCKS5), `/etc/redsocks/redsocks.conf`:

```yaml
base {
        // debug: connection progress
        log_debug = off;
        // info: start and end of client session
        log_info = on;
        log = "syslog:daemon";
        daemon = yes;
        redirector = iptables;
}

redsocks {
        /* `local_ip' defaults to 127.0.0.1 for security reasons,
         * use 0.0.0.0 if you want to listen on every interface.
         * `local_*' are used as port to redirect to.
         */
        local_ip = 127.0.0.1;
        local_port = 11088;

        // Enable or disable faster data pump based on splice(2) syscall.
        // Default value depends on your kernel version, true for 2.6.27.13+
        // splice = false;
        
        // `ip' and `port' are IP and tcp-port of proxy-server
        // You can also use hostname instead of IP, only one (random)
        // address of multihomed host will be used.
        ip = 127.0.0.1;
        port = 1084;
        // known types: socks4, socks5, http-connect, http-relay
        type = socks5;
        disclose_src = false;
        on_proxy_fail = close;
}
```

That's all, enjoy it. If you need to redirect UDP packets, check the default config example in `/usr/share/redsocks/redsocks.conf.example`, the docs is in `/usr/share/doc/redsocks/README.md`, and the example service is `/usr/share/redsocks/redsocks.service`.

(FINISHED!)

# Referrence

1. https://wiki.archlinux.org/index.php/TigerVNC   VNC IS REALLY GARBAGE!
2. https://netboot.xyz/providers/gce/
3. https://wiki.archlinux.org/index.php/iptables
4. https://linuxaria.com/article/redirect-all-tcp-traffic-through-transparent-socks5-proxy-in-linux#targetText=Redirect%20all%20(TCP)%20traffic%20through%20transparent%20socks5%20proxy%20in%20Linux&targetText=SOCKet%20Secure%20(SOCKS)%20is%20an,users%20may%20access%20a%20server.
5. https://wiki.archlinux.org/index.php/X2Go
