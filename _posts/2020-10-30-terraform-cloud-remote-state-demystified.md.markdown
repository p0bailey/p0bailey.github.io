---
layout: post
title:  "Terraform cloud remote state demystified."
date:   2020-10-30 16:36:55 +0100
tags: [devops,automation,terraform]
---
A bit of history..... Since I started to use terraform back in 2015 (good old  days), the state management has been quite painful for individuals and teams. The biggest concerns  about state management were state corruption, state leak (usually trough a git public repo) and state deletion, unintentional or intentional. Then terraform remote state S3 backend came along, what I day.

With this little piece of configuration a new world was outside there. 😂

---

```
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
```

No more tfstate files around, then State Locking arrived and no more message on Slack "Please do not deploy!!!", yes I have been trough all this.

Today

HashiCorp evolve its software tools around the users need allowing to use and consume complex systems with a joyful user experience. From the state file sitting on laptop filesystem, to a remote S3 bucket, today we have Terraform Cloud.

About Terraform Cloud

_Terraform Cloud is an application that helps teams use Terraform together. It manages Terraform runs in a consistent and reliable environment, and includes easy access to shared state and secret data, access controls for approving changes to infrastructure, a private registry for sharing Terraform modules, detailed policy controls for governing the contents of Terraform configurations, and more._

Terraform Cloud is free  for small teams, and with paid plans with additional feature sets for medium-sized businesses.

So, let's tuck in and explore  how to use Terraform Cloud as a Remote State Backend.

Example files: https://github.com/p0bailey/blog-examples/tree/main/terraform-cloud-state

Login into https://app.terraform.io

1.Create an organisation.

<img src="/media/img/10-2020/tf1.png" width="800"/>

2.Create a workspace and choose a Workflow. This demo make use of **CLI-driven Run Workflow**

<img src="/media/img/10-2020/tf2.png" width="800"/>

3.Choose a name for your new workspace.

<img src="/media/img/10-2020/tf3.png" width="800"/>

4.Terraform backend configuration

<img src="/media/img/10-2020/tf4.png" width="800"/>



Create a provider.tf replacing organisation and workspace name with yours.

provider.tf
```
terraform {
  backend "remote" {
    organization = "fsociety"

    workspaces {
      name = "development"
    }
  }
}
```



5.Execution type.


Click on Setting > General

**Change from Remote to Local Execution Mode**

_Local
Your plans and applies occur on machines you control. Terraform Cloud is only used to store and synchronize state._


<img src="/media/img/10-2020/tf5.png" width="800"/>



6.Terraform cloud user token.

Go to https://app.terraform.io/app/settings/tokens

Create API token.


Copy the token string into a safe place and export it as an environment variable with:

This token is invalid ;)

```export TF_WEB_TOKEN="G5fdCGBmamr7rA.atlasv1.mysecret_token"```



Terraform in action.

7. Terraform web credentials and resource.

**!!! Be careful, this step will overwrite any previous credentials.tfrc.json stored into you HOME directory. Please do
take a backup of of before going ahead.**

```
#!/usr/bin/env bash

mkdir -p ~/.terraform.d

cat << EOF > ~/.terraform.d/credentials.tfrc.json
{
  "credentials": {
    "app.terraform.io": {
      "token": "$TF_WEB_TOKEN"
    }
  }
}
```

Create a resource.tf file.

```
resource "null_resource" "demo" {
 triggers  = {
   key = uuid()
 }

 provisioner "local-exec" {
   command = "echo 'This is a demo'"
 }
}
```

Terraform web credentials file generation.

`chmod +x credentials_helper.sh`

`./credentials_helper.sh`


8. Terraform init, plan and apply.

`terraform init --input=false`

```
Initializing the backend...

Successfully configured the backend "remote"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding latest version of hashicorp/null...
- Installing hashicorp/null v3.0.0...
- Installed hashicorp/null v3.0.0 (signed by HashiCorp)

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, we recommend adding version constraints in a required_providers block
in your configuration, with the constraint strings suggested below.

* hashicorp/null: version = "~> 3.0.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```
terraform plan --input=false

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.demo will be created
  + resource "null_resource" "demo" {
      + id       = (known after apply)
      + triggers = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

Releasing state lock. This may take a few moments...
```

`terraform apply --input=false --auto-approve`

```
null_resource.demo: Creating...
null_resource.demo: Provisioning with 'local-exec'...
null_resource.demo (local-exec): Executing: ["/bin/sh" "-c" "echo 'This is a demo'"]
null_resource.demo (local-exec): This is a demo
null_resource.demo: Creation complete after 0s [id=558383978950114382]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

`terraform apply --input=false --auto-approve`


```
null_resource.demo: Refreshing state... [id=558383978950114382]
null_resource.demo: Destroying... [id=558383978950114382]
null_resource.demo: Destruction complete after 0s
null_resource.demo: Creating...
null_resource.demo: Provisioning with 'local-exec'...
null_resource.demo (local-exec): Executing: ["/bin/sh" "-c" "echo 'This is a demo'"]
null_resource.demo (local-exec): This is a demo
null_resource.demo: Creation complete after 0s [id=4106345408931731158]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

As you can see we have successfully run our demo terraform using Terraform Cloud storage remote backend.


9.Terraform cloud state inspection.

Go to `https://app.terraform.io/app/{your_organization}/workspaces/{your_workspace}/states`

Terraform runs.
<img src="/media/img/10-2020/tf6.png" width="800"/>

Terraform latest state.
<img src="/media/img/10-2020/tf7.png" width="800"/>
<br>
<br>
<br>
I hope this post shed some light about state management with TF Cloud. I do have other Terraform posts on the line, stay tuned.
Cheers
