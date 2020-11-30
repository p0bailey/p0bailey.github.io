---
layout: post
title:  "Defense in Depth: Keep your ssh keys safe with Gopass"
date:   2020-11-29 17:30:00 +0100
tags: [devops,devsecops]
---

![]()

<img src="/media/img/11-2020/richard-payette-TeXzIGmohkA-unsplash.jpg" width="800"/>

<span>Photo by <a href="https://unsplash.com/@thisusuallyworks?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Richard Payette</a> on <a href="https://unsplash.com/s/photos/keys?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>

**Houston we have a problem. Where Are My SSH Keys?**

Unencrypted private SSH keys can be compromised,leaked or lost in may circumstances
. Accidental commits into [SCMs (git)](https://www.ndss-symposium.org/wp-content/uploads/2019/02/ndss2019_04B-3_Meli_paper.pdf), unencrypted hard drives, backups and decommissioned hardware among the most common
ways to scatter these sensitive credentials all over the places. In this blog post we would walk trough  how to use [GoPass](https://www.gopass.pw/) to protect SSH keys sitting on ~/.ssh developers and engineers computers.


Today, [SSH or Secure Shell](https://www.openssh.com/) protocol is widely used to perform system administration task, application tunneling and Source Code Management (i.e. GitHub or GitLab) authentication. SSH rely on public key encryption with the use of battle tested, well-researched, secure, and trustworthy asymmetric cryptographic  algorithms such [RSA](https://simple.wikipedia.org/wiki/RSA_algorithm), [DSA](https://en.wikipedia.org/wiki/Digital_Signature_Algorithm) and [ed25519](https://ed25519.cr.yp.to/). 
Like any other asymmetric cryptographic implementation, SSH make use of two distinctive keys. 

* Public and Private Key Pair

	* Public key/s are copied to the SSH server(s) into the user authorized_keys file. Anyone who holds the public key can perform data encryption operation and the the content can be read only by the person or entity who holds the matching private key.



	* Private key/s stay with the users or on the system  from where the autuentication is initialised. The private key is the ultimate proof of the user or system identity, possession of private key that match a public key on the remote system will grant the ability to authenticate successfully. Due to the sensitive capabilities, private keys must be stored and  handled with rigorous care.


**SSH Private keys leakage: risks and mitigation**

Although it is common wisdom to protect SSH private keys with a passphrase. This
Measure would make quite impractical to use any automation workflow i.e. CI/CD
or password-less login.

Private keys are usually stored into the user's home directory  `~/.ssh/id_rsa` 

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAA
(( REDACTED ))
NBAtypDgzSyz6AsAAAAPcGhpbGxpcEBwaGlsbGlwAQIDBA==
-----END OPENSSH PRIVATE KEY-----
```

Without going into any sophisticated attack, let's assume these three real life scenarios.

**1)** Accidental commit into a corporate SCM or even worse into a public one, GitHub, GitLab, BitBucket, you name it.

**2)** Your laptop without full hard drive encryption gets nicked from your car, home or in a pub.

**3)** Your computer gets backed up to a remote server.
Therefore, along with your favourite holiday  pictures your unencrypted SSH private keys will be stored in the backup files. Anyone having access to the backup server can retrieve and use/abuse your keys with dire consequences. There are many tools and application to store securely SSH private keys and my favourite one is  [Gopass](https://www.gopass.pw/), a neat CLI password manager with advanced capabilities such YAML support, password leak checker,  multi-line secrets.    

Requirements:

GoPass installation and setup is not in scope of this post.

* [GoPass](https://www.gopass.pw/) installed and [configured](https://github.com/gopasspw/gopass/blob/master/docs/setup.md).

	* GoPass configuration: [https://github.com/gopasspw/gopass/blob/master/docs/setup.md](https://github.com/gopasspw/gopass/blob/master/docs/setup.md)


1) Generate a SSH keypair.

`ssh-keygen -o -a 100 -t ed25519    -C "phillip@bailey.st"`

```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/phillip/.ssh/id_ed25519):
Created directory '/home/phillip/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/phillip/.ssh/id_ed25519.
Your public key has been saved in /home/phillip/.ssh/id_ed25519.pub.
The key fingerprint is:
SHA256:MzAtMS2Yv/zCM+zJ++62uikihqF8FjSh+hidQvRlmHk phillip@bailey.st
The key's randomart image is:
+--[ED25519 256]--+
|    +oo.         |
| . =oE.+.        |
|. o =.+..        |
| o +  .+         |
|o..... .S        |
|= o.  o  o       |
|+*  .o .         |
|=ooo..*oo        |
|..o. oO%=.       |
+----[SHA256]-----+
```
2) Import SSH private key into GoPass


`gopass insert -m misc/ssh.privkey`

Paste the key located at ~/.ssh/id_ed25519 

3) Show the SSH key from GoPass storage.

`$ gopass show misc/ssh.privkey`

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACA7w+snfHTWo0Bo65aP0VLABRb97nfs2ug7u9QLlD+vCwAAAJju02Wa7tNl
don'tevenbothertousethiskey:)fs2ug7u9QLlD+vCwAAAJju02Wa7tNl
AAAEAk2oymC3vjlvLgNioP40DzLEi4ygFBWrk6Ozna//XsxTvD6yd8dNajQGjrlo/RUsAF
Fv3ud+za6Du71AuUP68LAAAAEXBoaWxsaXBAYmFpbGV5LnN0AQIDBA==
-----END OPENSSH PRIVATE KEY-----
```


4) Copy SSH public key into a remote server.



ssh-copy-id -i ~/.ssh/id_ed25519.pub   user1@server.org

```
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/user1/.ssh/id_ed25519.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
user1@server.org's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'user1@server.org'"
and check to make sure that only the key(s) you wanted were added.
```

5) SSH login via helper script or shell aliases.

GoPass integrates perfectly with almost any shell.

* Script helper.
 
Create a bash SSH helper script ssh_login.sh 

```
#!/usr/bin/env bash

PRIVATE_KEY=$(gopass show misc/ssh.privkey)
ssh-add - <<< "$PRIVATE_KEY"
ssh user1@server.org
```

chmod +x ssh_login.sh

`./ssh_login.sh`

```
user1@server.org:~$ hostname
server.org
```

* Shell aliases

Create a convenient alias for your shell environment i.e. ~/.bash_aliases 

```
alias ssh.server.org='
PRIVATE_KEY=$(gopass show misc/ssh.privkey) 
ssh-add - <<< "$PRIVATE_KEY" 
ssh user1@server.org'
```

Ssh login via shell alias.


`$ ssh.server.org`

```
user1@server.org:~$ hostname
server.org
```

6) SSH private key file removal.

Whether you are able to login into the remote systems using the SSH private key stored into GoPass, you can now proceed to remove the SSH private key file stored on 
your computer and continue to login with the shell alias or other login wrapper that you fancy.

 
`rm ~/.ssh/id_ed25519`

```
ls ~/.ssh/
authorized_keys  id_ed25519.pub  known_hosts
```

Finally, no more id_ed25519 private key file(s)!!!

**Final remarks.**

Secret management is a difficult task and different tools exist to assist engineers and developers to keep them safe. Depending on your very particular requirements, SSH keys can be stored into [HashiCorp Vault](https://www.vaultproject.io/), [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html), [Sops](https://github.com/mozilla/sops), [GoPass](https://www.gopass.pw/) and may others, from the most sophisticated
to the very convenient, these secrets management tools are publicly available and fairly easy to implement to use and consume. 

Protect your secrets and don't be the next in the news.

