---
layout: post
title:  "How to easily switch terraform version with tfswitch"
date:   2020-11-07 18:30:00 +0100
tags: [devops,automation,terraform]
---

Today [Terraform](https://www.terraform.io/) can be considered the de facto infrastructure as code software tool. Whilst the first releases were quite smooth to transition from a version to another. On May 2019 we have got Terraform 0.12 and all the sudden many of us discovered that our modules and code were no longer working with the new version. Lot of us found themselves into the situation of having two version of terraform installed on our laptops or servers with sometimes ad hoc terraform version named as terraform11 and terraform 12 or cumbersome shell scripts to download and switch version. Fortunately the open source community is excellent to pick on these very peculiar needs and therefore we got [Tfswitch](https://tfswitch.warrensbox.com/).

*The tfswitch command line tool lets you switch between different versions of terraform. If you do not have a particular version of terraform installed, tfswitch lets you download the version you desire. The installation is minimal and easy. Once installed, simply select the version you require from the dropdown and start using terraform.*

## Installation

**OSX-Homebrew**

`brew install warrensbox/tap/tfswitch`

**Debian Gnu Linux with Snapcraft**

`sudo snap install tfswitch`

**Linux**

Installation for any Linux operating system.

`curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash`

## Usage

First time you run tfswitch.

```bash

 
$ tfswitch
2020/11/07 18:14:25 Creating directory for terraform: /Users/user/.terraform.versions/
Use the arrow keys to navigate: ↓ ↑ → ←
? Select Terraform version:
  ▸ 0.13.5
    0.13.4
    0.13.3
    0.13.2
↓   0.13.1
```

Downloading Terraform 0.13.5

```bash
✔ 0.13.5
Downloading https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_darwin_amd64.zip to terraform_0.13.5_darwin_amd64.zip
Downloading ...
35665893 bytes downloaded.
Switched terraform to version "0.13.5"
```
Test Terraform version 0.13.5

```bash
$ terraform version
Terraform v0.13.5
```

Switch to  Terraform latest 0.12 version (0.12.29).

```bash
$ tfswitch
Use the arrow keys to navigate: ↓ ↑ → ←
? Select Terraform version:
↑   0.13.1
    0.13.0
  ▸ 0.12.29
    0.12.28
↓   0.12.27
```

Downloading Terraform 0.12.29

```bash
$ tfswitch
✔ 0.12.29
Downloading https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_darwin_amd64.zip to terraform_0.12.29_darwin_amd64.zip
Downloading ...
29167077 bytes downloaded.
Switched terraform to version "0.12.29"
```

Test Terraform version 0.12.29

```bash
$ terraform version
Terraform v0.12.29
```

Switch back to 0.13.5

```bash
$ tfswitch
Use the arrow keys to navigate: ↓ ↑ → ←
? Select Terraform version:
    0.12.29 *recent
  ▸ 0.13.5 *recent
    0.13.4
    0.13.3
↓   0.13.2
```

Test Terraform 0.13.5

```bash
$ tfswitch
✔ 0.13.5 *recent
Switched terraform to version "0.13.5"
```
Terraform 0.13.5 version

```bash
$ terraform  version
Terraform v0.13.5
```
Tfswitch is absolutely a time saver, a big  shout-out to the contributors at  [https://github.com/warrensbox/terraform-switcher/graphs/contributors](https://github.com/warrensbox/terraform-switcher/graphs/contributors)

Source code repository: [https://github.com/warrensbox/terraform-switcher](https://github.com/warrensbox/terraform-switcher)

Issues: [https://github.com/warrensbox/terraform-switcher/issues](https://github.com/warrensbox/terraform-switcher/issues)

Happy terraforming!!!