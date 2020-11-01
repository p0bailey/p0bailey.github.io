---
layout: post
title:  "Packer Virtualbox builder, from json to hcl"
date:   2020-11-01 08:30:00 +0100
tags: [devops,automation,packer]
---
[Packer](https://www.packer.io/) is a free and open source tool to create golden machine images for various
platforms and operating systems using single source configuration. I have been using
packer to solve quite few interesting problems, from hardening Linux servers, create
AWS EC2 ami's with encrypted boot volume in order to achieve full disk encryption,
Virtuabox machines for local development to Docker images.However, something I have
always struggled was its json file configuration. Yes, Json is a powerful data format
but doesn't really make the cut for configuration, no support for long string and
comments are for me showstoppers. Luckily, Packer >1.5.0 supports
[HCL2 (HashiCorp Configuration Language)](https://github.com/hashicorp/hcl). HCL is
a configuration language built by HashiCorp. The goal of HCL is to build a structured
configuration language that is both human and machine friendly for use with command-line
tools, but specifically targeted towards DevOps tools, servers, etc.

Scripts and files to follow along this post are at: [https://github.com/p0bailey/blog-examples/tree/main/packer-virtualbox-builder-hcl](https://github.com/p0bailey/blog-examples/tree/main/packer-virtualbox-builder-hcl)

Yes, HCL makes the whole packer configuration humanly readable. A quick example from Packer website, https://www.packer.io/guides/hcl/from-json-v1

This file....
```json
{
  "builders": [
    {
      "ami_name": "packer-test",
      "region": "us-east-1",
      "instance_type": "t2.micro",

      "source_ami_filter": {
        "filters": {
          "virtualization-type": "hvm",
          "name": "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*",
          "root-device-type": "ebs"
        },
        "owners": ["amazon"],
        "most_recent": true
      },

      "ssh_username": "ubuntu",
      "type": "amazon-ebs"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": ["sleep 5"]
    }
  ]
}
```
Becomes this...
```hcl
# the source block is what was defined in the builders section and represents a
# reusable way to start a machine. You build your images from that source. All
# sources have a 1:1 correspondance to what currently is a builder. The
# argument name (ie: ami_name) must be unquoted and can be set using the equal
# sign operator (=).
source "amazon-ebs" "example" {
    ami_name = "packer-test"
    region = "us-east-1"
    instance_type = "t2.micro"

    source_ami_filter {
        filters = {
          virtualization-type = "hvm"
          name =  "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
          root-device-type = "ebs"
        }
        owners = ["amazon"]
        most_recent = true
    }

    communicator = "ssh"
    ssh_username = "ubuntu"
}

# A build starts sources and runs provisioning steps on those sources.
build {
  sources = [
    # there can be multiple sources per build
    "source.amazon-ebs.example"
  ]

  # All provisioners and post-processors have a 1:1 correspondence to their
  # current layout. The argument name (ie: inline) must to be unquoted
  # and can be set using the equal sign operator (=).
  provisioner "shell" {
    inline = ["sleep 5"]
  }

  # post-processors work too, example: `post-processor "shell-local" {}`.
}
```
Quite a difference and you can have comments as well, hooray!!!


My packer Virtualbox setup.


File: template.json
```json
{
"builders": [
{
  "type": "virtualbox-iso",
"boot_command": [
  "<esc><wait>",
  "install <wait>",
  " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
  "debian-installer=en_US.UTF-8 <wait>",
  "auto <wait>",
  "locale=en_US.UTF-8 <wait>",
  "kbd-chooser/method=us <wait>",
  "keyboard-configuration/xkb-keymap=us <wait>",
  "netcfg/get_hostname={{ .Name }} <wait>",
  "netcfg/get_domain=vagrantup.com <wait>",
  "fb=false <wait>",
  "debconf/frontend=noninteractive <wait>",
  "console-setup/ask_detect=false <wait>",
  "console-keymaps-at/keymap=us <wait>",
  "grub-installer/bootdev=/dev/sda <wait>",
  "<enter><wait>"
],
"boot_wait": "10s",
"disk_size": 20000,
"guest_os_type": "Debian_64",
"guest_additions_path": "VBoxGuestAdditions_{{.Version}}.iso",
"http_directory": "http",
"iso_checksum": "sha512:cb74dcb7f3816da4967c727839bdaa5efb2f912cab224279f4a31f0c9e35f79621b32afe390195d5e142d66cedc03d42f48874eba76eae23d1fac22d618cb669",
"iso_url": "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.6.0-amd64-netinst.iso",
"ssh_username": "vagrant",
"ssh_password": "vagrant",
"ssh_port": 22,
"ssh_wait_timeout": "10000s",
"shutdown_command": "echo vagrant|sudo -S /sbin/shutdown -hP now",
"vboxmanage": [
  [ "modifyvm", "{{.Name}}", "--memory", "1024" ],
  [ "modifyvm", "{{.Name}}", "--cpus", "2" ]
]
}],
"provisioners": [
      {
        "type": "shell",
        "execute_command": "echo vagrant|sudo -S sh {{.Path}}",
        "override": {
          "virtualbox-iso": {
            "scripts": [
              "scripts/base.sh",
              "scripts/vagrant.sh",
              "scripts/virtualbox.sh",
              "scripts/provision.sh",
              "scripts/cleanup.sh",
              "scripts/zerodisk.sh"
            ]
          }
        }
      }
      ],
"post-processors": [
    {
      "type": "vagrant",
      "override": {
        "virtualbox": {
          "output": "debian-10-x64-virtualbox.box"
        }
      }
    }
  ]
}
```
For long time I wanted to Switch from Json to HCL and as of v1.6.4, Packer provides a tool to help you convert legacy JSON files to HCL2 files.

`$ packer hcl2_upgrade template.json`

```
Successfully created template.json.pkr.hcl
```
At this point we should be good to build our Debian Virtualbox machine with `$ packer build .`

**Not quite there yet!**

```bash
packer build .
Error: Failed preparing provisioner-block "shell" ""

  on template.json.pkr.hcl line 48:
  (source code not available)

1 error(s) occurred:

* Either a script file or inline script must be specified.

Error: 1 error(s) occurred:

* One of iso_url or iso_urls must be specified

  on template.ok.json.pkr.hcl line 23:
  (source code not available)



==> Wait completed after 4 microseconds

==> Builds finished but no artifacts were created.
```

File: template.json.pkr.hcl
```hcl
# This file was autogenerated by the BETA 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.
# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
#could not parse template for following block: "template: generated:3:317: executing \"generated\" at <.Name>: can't evaluate field Name in type struct { HTTPIP string; HTTPPort string }"

source "virtualbox-iso" "autogenerated_1" {
  boot_command         = ["<esc><wait>", "install <wait>", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>", "debian-installer=en_US.UTF-8 <wait>", "auto <wait>", "locale=en_US.UTF-8 <wait>", "kbd-chooser/method=us <wait>", "keyboard-configuration/xkb-keymap=us <wait>", "netcfg/get_hostname={{ .Name }} <wait>", "netcfg/get_domain=vagrantup.com <wait>", "fb=false <wait>", "debconf/frontend=noninteractive <wait>", "console-setup/ask_detect=false <wait>", "console-keymaps-at/keymap=us <wait>", "grub-installer/bootdev=/dev/sda <wait>", "<enter><wait>"]
  boot_wait            = "10s"
  disk_size            = 20000
  guest_additions_path = "VBoxGuestAdditions_{{.Version}}.iso"
  guest_os_type        = "Debian_64"
  http_directory       = "http"
  iso_checksum         = "sha512:cb74dcb7f3816da4967c727839bdaa5efb2f912cab224279f4a31f0c9e35f79621b32afe390195d5e142d66cedc03d42f48874eba76eae23d1fac22d618cb669"
  iso_url              = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.6.0-amd64-netinst.iso"
  shutdown_command     = "echo vagrant|sudo -S /sbin/shutdown -hP now"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_username         = "vagrant"
  ssh_wait_timeout     = "10000s"
  vboxmanage           = [["modifyvm", "{{.Name}}", "--memory", "1024"], ["modifyvm", "{{.Name}}", "--cpus", "2"]]
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.virtualbox-iso.autogenerated_1"]


  #could not parse template for following block: "template: generated:2:47: executing \"generated\" at <.Path>: can't evaluate field Path in type struct { HTTPIP string; HTTPPort string }"
  provisioner "shell" {
    execute_command = "echo vagrant|sudo -S sh {{.Path}}"
  }
  post-processor "vagrant" {
    override {
      virtualbox = {
        output = "debian-10-x64-virtualbox.box"
      }
    }
  }
}
```
Original build section.
```hcl
build {
  sources = ["source.virtualbox-iso.autogenerated_1"]


  #could not parse template for following block: "template: generated:2:47: executing \"generated\" a
  t <.Path>: can't evaluate field Path in type struct { HTTPIP string; HTTPPort string }"
  provisioner "shell" {
    execute_command = "echo vagrant|sudo -S sh {{.Path}}"
  }
```
**FIX:**

The converter is still a bit buggy, in this case has almost skipped
the provisioner section which should have included the bash script to
setup and provision the machine.

Refactored build section.
```hcl
build {
  sources = ["source.virtualbox-iso.autogenerated-1"]
  provisioner "shell" {
  execute_command   = "echo 'vagrant' | {{.Vars}} sudo -S  sh {{.Path}}"
  scripts = [
    "scripts/base.sh",
    "scripts/vagrant.sh",
    "scripts/virtualbox.sh",
    "scripts/provision.sh",
    "scripts/cleanup.sh",
    "scripts/zerodisk.sh"
  ]
}
```

I do have refactored a little bit the template.json.pkr.hcl into template.refactored.pkr.hcl
adding a few variables into my-variables.pkrvars.hcl file.

File: my-variables.pkrvars.hcl
```hcl
memory       = "2048"
cpus = "4"
iso_checksum      = "sha512:cb74dcb7f3816da4967c727839bdaa5efb2f912cab224279f4a31f0c9e35f79621b32afe390195d5e142d66cedc03d42f48874eba76eae23d1fac22d618cb669"
iso_url           = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.6.0-amd64-netinst.iso"
```

Now  it's time to build our Debian10 Virtuabox image.

`packer build  -var-file=my-variables.pkrvars.hcl  template.refactored.pkr.hcl`


**Vagrant test.**


`$ vagrant up`

`$ vagrant ssh`

Here we go, now we can enjoy the full power of building Virtuabox machine images
with Packer and HCL. No more Json ;) !!!
