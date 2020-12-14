---
layout: post
title: Lean and strong SSH keys with ed25519 elliptic curve cryptography.
date: '2020-12-13 19:30:00 +0100'
tags:
  - devops
  - devsecops
  - ssh
  - crypto
---
In a [previous instalment](https://bailey.st/2020/11/29/Defense-in-Dept-keep-ssh-keys-safe-with-gopass.html) I wrote about protecting SSH keys at rest, probably someone
with a sharp eye has spotted that I'm using ed25519 signature scheme to generate my
SSH key-pair. In this post I'm going to delve the use os elliptic-curve signatures
and why they are a good fit for a modern and scalable operation.

<!-- toc -->

- [An overview on SSH encryption scheme](#an-overview-on-ssh-encryption-scheme)
- [RSA 2048](#rsa-2048)
- [RSA 4096](#rsa-4096)
- [ed25519](#ed25519)
- [Key length comparison.](#key-length-comparison)
- [Practical benefits of ed25519](#practical-benefits-of-ed25519)
- [Conclusion](#conclusion)

<!-- tocstop -->

## An overview on SSH encryption scheme

Whenever we need to generate a SSH key pair we usually type `ssh-keygen` and
on Debian 10 systems the default signature scheme is  RSA 2048 which is slightly
on the edge of a good key length for these  days and years to come. Below is a brief representation
of the key schemes available to `ssh-keygen`, DSA or RSA 1024, ECDSA should not be used at all as deemed
insecure by the wider crypto community, [Nist](https://www.nist.gov/) and [NSA](https://www.nsa.gov/) might have a different opinion on the latter.

| Scheme | Utilisation | References |
| - | :-: | :-: |
| DSA or RSA  1024 | Unsafe | [https://eprint.iacr.org/2009/389.pdf](https://eprint.iacr.org/2009/389.pdf) |
| ECDSA | Advisable to change to ed25519 | Potentially unsafe due being allegedly backdoored by[NSA](https://www.schneier.com/blog/archives/2007/11/the_strange_sto.html). |
| RSA2048 | Advisable to change to  RSA4096 or ed25519. | [Eventually secure till 2030.](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-131Ar2.pdf) |
| RSA4096 | Excellent strength but lengthy key size and performance degradation. | [NIST Recommendation](https://https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-57Pt3r1.pdf) |
| ed25519 | In short is not NIST nor NSA, the implementation of Ed25519 curves is publicly documented and audit-able. Public and private ed25519 are the shortest in length. | [https://ed25519.cr.yp.to](https://ed25519.cr.yp.to/) |


Now let's generate the three key pairs with theirs signature schemes (RSA 2048, RSA 496 and ed25519 )  and compare the keys length.

## RSA 2048

```
~$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/phillip/.ssh/id_rsa):
Created directory '/home/phillip/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/phillip/.ssh/id_rsa.
Your public key has been saved in /home/phillip/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:4So+EEqv4ehiZRLv/pd0CR2c5uVjL/J+47zJ5PLW7MA phillip@debian
The key's randomart image is:
+---[RSA 2048]----+
|        . .      |
|         = .     |
|        = +      |
| o.    o + +     |
|..+.    S o o    |
|.o.=   o + ...   |
|o B.. o o o .Eo  |
|o+ o.. o   o=+oo |
|+...oo.   ..*O+. |
+----[SHA256]-----+
```

**RSA 2048 schema check**

ssh-keygen -lf  ~/.ssh/id_rsa

`2048 SHA256:dLtetasPa+RO+/EqVSvZUV+Uay/qlsCpPNSoyrf+GTI phillip@debian (RSA)`

ssh-keygen -lf  ~/.ssh/id_rsa.pub

`2048 SHA256:dLtetasPa+RO+/EqVSvZUV+Uay/qlsCpPNSoyrf+GTI phillip@debian (RSA)`

**RSA 2048 key length**

RSA 2048 private key:

`~$ cat   ~/.ssh/id_rsa`

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAQEAvAhxo2u+Y9X5vRwbXeDC1LSD+WfffKDBH2KvW1bBoP2o5iTNyifg
E3YrDm9EH64DNfRrfNQuxkVmIvpbMroBeTA5Z/XSB8hS7zj+g2acD1hzc5iMAEmBBxDQ6+
tQlTYXelHQ+ZrgcoFLfvYpsI25/pG6xJtC8LCZCeu24z+ZAWvl1nFIgzBvrQGSx3fGjCCB
B0a/5saOmGoLYjRbt5Qs3GxXZmLYdIR0PZyR/nHyDIAJ8OF8B46ECzYG0DhvDMz88A5cAn
EKuY6GywpUAj5GktVRKtZmwVTR3xc7t3lrTEonN62CU6M/f90ON0Vzkv0DtRPIiAMQHpjH
5ChVpwaIeQAAA8hGYUQgRmFEIAAAAAdzc2gtcnNhAAABAQC8CHGja75j1fm9HBtd4MLUtI
P5Z998oMEfYq9bVsGg/ajmJM3KJ+ATdisOb0QfrgM19Gt81C7GRWYi+lsyugF5MDln9dIH
yFLvOP6DZpwPWHNzmIwASYEHENDr61CVNhd6UdD5muBygUt+9imwjbn+kbrEm0LwsJkJ67
bjP5kBa+XWcUiDMG+tAZLHd8aMIIEHRr/mxo6YagtiNFu3lCzcbFdmYth0hHQ9nJH+cfIM
gAnw4XwHjoQLNgbQOG8MzPzwDlwCcQq5jobLClQCPkaS1VEq1mbBVNHfFzu3eWtMSic3rY
JToz9/3Q43RXOS/QO1E8iIAxAemMfkKFWnBoh5AAAAAwEAAQAAAQB6xPCdiO2odb83sDBW
HThYdPxuTVnoH3W4rlBcTMrj+HrcuU78HQj66/600AUkwhMqmUnNGSTpI8rKL7h36Gap38
i7jg7yMeOkegwDc22Vv2SyJvnR/iwWlu4x+1SD9+tgXCcbsfm2CaFnZgZWVlMIWdIeKFmO
mV9y0Mp6mb2m5NISGXczTicJUTHqZsYyc1HTHpdOW8ZsG2JkdUYhQVDLBpCBAUORipoWOy
GpQ4IhwAQrKQKzMr/iABfvfwGHiqnJ3KIZiENrE5Xkw4azT8d7khM7+DSthnl4LUzT4dlF
Lz5pOUOF9dA3HOaUo3fmQJnz0fX+l1Gujt934LBtDtUBAAAAgE5uRHQhZtE497WTdMfb4q
GNb47OuhotPuZEL2cT2csH5iadQq5ZWVhqRQh7wJbOJfK66y/OhZ+FQTQ3Nz5gimD+2NFU
b/z5jYboigalDqsxfDf7INXq2PK3CHQTtJrMCYDAmVT8EyjFUkUBofdWmQbYKKy6EzPYZx
CmiOYyQC76AAAAgQDy4FV8ZAl8ijcRcs986hPuFCbCykqR4d7rOx9SXNCpz+oOdlz8LMAI
HovUHoTsfQnnive/G9e2v6B4MfPeMhg16HsvmF8UQ/eTIH/hu33jdXHsKqQeJGMDPKrdLW
dlOQc2SKbbXNx3dna9W5NoNGIBXGkv4H7yszk8G4TRWVlwcQAAAIEAxjF4xdXR6+ZmdHt1
AyMuyA/BdZv4JcdwlVS1Ulo0ZLDJMdvf4PpZm/1vb8YrV1kyitAuyoxRL2g6w5FQzOGrO6
pQXu5q3Czerbz7pHRNDDziRV0ryFVfXlXN3pL7CAHol72fbBAZadn2TCiVvjTOrLIGTOLV
LdASITD89+otHIkAAAAOcGhpbGxpcEBkZWJpYW4BAgMEBQ==
-----END OPENSSH PRIVATE KEY-----
```

RSA 2048 public key:

`~$ cat   ~/.ssh/id_rsa.pub`

```
ssh-rsa
AAAAB3NzaC1yc2EAAAADAQABAAABAQC8CHGja75j1fm9HBtd4MLUt
IP5Z998oMEfYq9bVsGgajmJM3KJ+ATdisOb0QfrgM19Gt81C7GRWY
i+lsyugF5MDln9dIHyFLvOP6DZpwPWHNzmIwASYEHENDr61CVNhd6
UdD5muBygUt+9imwjbn+kbrEm0LwsJkJ67bjP5kBa+XWcUiDMG+tA
ZLHd8aMIIEHRrmxo6YagtiNFu3lCzcbFdmYth0hHQ9nJH+cfIMgAn
w4XwHjoQLNgbQOG8MzPzwDlwCcQq5jobLClQCPkaS1VEq1mbBVNHf
Fzu3eWtMSic3rYJToz9/3Q43RXOS/QO1E8iIAxAemMfkKFWnBoh5
phillip@debian
```

## RSA 4096

```
~$ ssh-keygen -t rsa -b 4096  -f ~/.ssh/id_rsa_4096
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/phillip/.ssh/id_rsa_4096.
Your public key has been saved in /home/phillip/.ssh/id_rsa_4096.pub.
The key fingerprint is:
SHA256:vb03VJJ/nHvRUwnK0ct7Q/tuSuCy2xKpVKdma966KKY phillip@debian
The key's randomart image is:
+---[RSA 4096]----+
|            .    |
|           . o   |
|          . + o..|
|         ..o.oooo|
|        S..+. o==|
|        . *+ o.B=|
|       . +ooo.o B|
|      o ..+= oo.+|
|    Eo ..o*=+..=o|
+----[SHA256]-----+
```
**RSA 4096 schema check**

~$ ssh-keygen -lf  ~/.ssh/id_rsa_4096

`4096 SHA256:vb03VJJ/nHvRUwnK0ct7Q/tuSuCy2xKpVKdma966KKY phillip@debian (RSA)`

~$ ssh-keygen -lf  ~/.ssh/id_rsa_4096.pub

`4096 SHA256:vb03VJJ/nHvRUwnK0ct7Q/tuSuCy2xKpVKdma966KKY phillip@debian (RSA)`

**RSA 4096 key length**

RSA 4096 private key:

`~$ cat   ~/.ssh/id_rsa_4096`

```
~$ cat   ~/.ssh/id_rsa_4096
-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----
```

RSA 4096 public key:

`~$ cat   ~/.ssh/id_rsa_4096.pub`

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEfKSyZsf9ErxObyq0wTYSjwIZC1
HsQc1I7z7vxDKv6oh8SyQS7xj5JeK45l9aXXBaNT5Oacfqfj2JErmnmSqh4fi3ybAL
sMcwybqh7Drnqkk9yQfuW+o27lhNYGbYioGLHRX0A89KWD5ecR/Q/+mckxpxhxVmLS
h7MQ6KxNfHOu46iu6htXRkm4ewkkNMLoxFnSUjsMWjnBjJAoV7igu8swpapyGspYm3
npN6DRNiBdJocMCqyUnzJg2RfbyNWjAgmzJMYrq1X9DiZLZ8ZSSJTlXN0ykrhSjgol
ERVBPOwwMwpTUMswnq0W6cKzO23kW1zozrGfJrRyZoceoXJm3wOfzWUe8yKSo08V4W
VCPfLcWxtJQ/6lNqc1EtFbCxuzZek5z6WzcBbNff+i1iq3cVkOOh2kwNd2HOY5U+pj
yeO9qS8wMrc7ibQ9VIzvg+HUVSQGJpjz1yh0Bq7fM8N/33w/sGMh9UPWTLolKcpq3N
nErgdKq78bft6gK4aDjtlUqWW0WgU0kpfHvRbRp51uoHeXsFAh5BV3gfdzOl6SdRA1
gGb16aK+yw5B5rSG90bHIkw25eE0ml8StApA2Fm13WR+BlUuArQGOdq6jFWMFjkaXL
cqRzEonCyrbjIwzwB1eLGeKlpabA1McYoZmlZYbLHG15A9IMwDSyp88DGw==
phillip@debian
```

## ed25519


`~$ ssh-keygen -a 100  -t ed25519  -f ~/.ssh/ed25519`

```
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/phillip/.ssh/ed25519.
Your public key has been saved in /home/phillip/.ssh/ed25519.pub.
The key fingerprint is:
SHA256:ylS3RBQXU7aQ+Vlve2lfz3HS9pV3qSrntF0dAwraxjo phillip@debian
The key's randomart image is:
+--[ED25519 256]--+
|         .+.==o  |
|         . .o+ ..|
|        ..o  o.o.|
|       .+o... + o|
|      ..S+..   ==|
|     o .o     .B&|
|      oE   .  o=&|
|        ....o.. =|
|          ++..   |
+----[SHA256]-----+
```

**ed25519 schema check**

~$ ssh-keygen -lf  ~/.ssh/ed25519

`256 SHA256:ylS3RBQXU7aQ+Vlve2lfz3HS9pV3qSrntF0dAwraxjo phillip@debian (ED25519)`

~$ ssh-keygen -lf  ~/.ssh/ed25519.pub

`256 SHA256:ylS3RBQXU7aQ+Vlve2lfz3HS9pV3qSrntF0dAwraxjo phillip@debian (ED25519)`

**ed25519 key length**

ed25519 private key:

`~$ cat  ~/.ssh/ed25519`

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBVOwukTA7cefuxFx1846vcpLr5sGP/xvDhJFYNMnGvrwAAAJigJ6Z8oCem
fAAAAAtzc2gtZWQyNTUxOQAAACBVOwukTA7cefuxFx1846vcpLr5sGP/xvDhJFYNMnGvrw
AAAEBnEpUs1iDu4It9JP4T/pnJ4nMWglmq0IWk1S0McUCiH1U7C6RMDtx5+7EXHXzjq9yk
uvmwY//G8OEkVg0yca+vAAAADnBoaWxsaXBAZGViaWFuAQIDBAUGBw==
-----END OPENSSH PRIVATE KEY-----
```

ed25519 public key:

`~$ cat  ~/.ssh/ed25519.pub`

```
ssh-ed25519
AAAAC3NzaC1lZDI1NTE5AAAAIFU7C6RMDtx5+7EXHXzjq9ykuvmwY//G8OEkVg0yca+v
phillip@debian
```

## Key length comparison.

| Scheme | Public Key Length (bytes) | Private Key Length (bytes) |
| - | :-: | :-: |
| RSA 2048 | 2048 | 2048 |
| RSA 4096 | 4096 | 4096 |
| ed25519 | 256 | 256 |

## Practical benefits of ed25519

In the old days we use to have a handful of servers sitting into a datacenter and eventually
managed by scripts or eventually by a provisioning system. Usually the SSH keys were generated at the beginning of the setup and never changed or rotate until the server decommissioning, usually 2/3 years. Today, with cloud, containers, IOT technologies we deal
with scalable, distribute systems in the order of thousand or even million servers and containers. Let's assume we
have to generate, store and distribute SSH keys with such scale and speed, a 256 bytes key would be much more convenient and efficient than a 2048 or 4096 bytes.


## Conclusion

[Elliptic curve cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography) like many other cryptographic methods are threatened by the
raise of [quantum computing](https://en.wikipedia.org/wiki/Quantum_computing). However, even though quantum research is already underway with modest but encouraging breakthroughs, usable quantum computers are still yet to come and with regret I won't see them in my lifetime.
We could spend days and years in an infinite war arguing which is most secure encryption algorithm at the present time.
Throughout my modest research I have found ed25519 to be the best suited to fulfil the security requirements
along with the performances and convenience of shorter keys. There's nothing wrong to use encryption with longer
keys or different algorithms. However, if your cryptosystem is poorly designed or handled, doubling or tripling your key length may create a false sense of security.

A weak encryption can be worse than no encryption at all.
