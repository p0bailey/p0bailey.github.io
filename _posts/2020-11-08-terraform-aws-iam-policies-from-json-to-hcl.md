---
layout: post
title:  "How to convert Terraform AWS iam policies from json to hcl"
date:   2020-11-08 19:30:00 +0100
tags: [devops,automation,terraform]
---
On AWS cloud platform, permissions management are defined by the IAM identities which consist of users, groups of users, or roles with attached scoped policies and most of these policies are defined as Json
documents. AWS IAM is a vast topic and requires lot of practices to understand all the actions for any AWS service and its principals. Hence, we are here to talk about terraform and not about AWS policies in the specific if you fancy to delve into the IAM topic I advise to start [from here](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html). By now you should be already aware of my personal crusade against using [Json](https://en.wikipedia.org/wiki/JSON) as a configuration language. Please don't get me wrong, Json is an exceptional data format when it comes to be generate and interpreted by machines but it becomes impractical by humans.

To me, the two points below are absolutely showstoppers in any configuration language.


* **Lack of comments, a feature that is paramount for any configuration language.**

* **Too noisy, too much punctuation that doesn’t help the human eye.**

The aim of this post is to show the use of [iam-policy-json-to-terraform](https://github.com/flosell/iam-policy-json-to-terraform) tool to covert IAM Json policies to [Terraform](https://www.terraform.io/) [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) to get from something like this:

**NOTE:** Be aware that any  IAM policies in this post are samples and should not be used in any live or
production environment.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1604857512278",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::/"
    }
  ]
}
```
to something like that,

```hcl
# Here you can have comments!!!
data "aws_iam_policy_document" "policy" {
  statement {
    sid       = "Stmt1604857512278"
    effect    = "Allow"
    resources = ["arn:aws:s3:::/"]
    # Here you can have comments as well!!!
    actions   = ["s3:ListBucket"]
  }
}
```

Setup:

[https://github.com/flosell/iam-policy-json-to-terraform](https://github.com/flosell/iam-policy-json-to-terraform)

OSX

`$ brew install iam-policy-json-to-terraform`

Other

Download the latest binary from the releases page and put it into your PATH under the name iam-policy-json-to-terraform


Files and configuration are stored here - [https://github.com/p0bailey/blog-examples/tree/main/terraform-iam-json-to-hcl](https://github.com/p0bailey/blog-examples/tree/main/terraform-iam-json-to-hcl)

**1) Method1, the ugly way, this is how we used to do it.**

[https://github.com/p0bailey/blog-examples/tree/main/terraform-iam-json-to-hcl/method1](https://github.com/p0bailey/blog-examples/tree/main/terraform-iam-json-to-hcl/method1)



This method uses Terraform [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) with Multiple Line Heredoc Syntax, quite error prone whether you have to write long policy documents and without possibility to validate the Json document alone as bundled together with Terraform code.

file: [s3-read-write-policy.tf](https://github.com/p0bailey/blog-examples/blob/main/terraform-iam-json-to-hcl/method1/s3-read-write-policy.tf)

```hcl
resource "aws_iam_policy" "policy" {
  name        = "s3-read-write-policy"
  path        = "/"
  description = "Ugly way to do it."

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action": "s3:ListAllMyBuckets",
         "Resource":"arn:aws:s3:::*"
      },
      {
         "Effect":"Allow",
         "Action":["s3:ListBucket","s3:GetBucketLocation"],
         "Resource":"arn:aws:s3:::awsexamplebucket1"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:DeleteObject"
         ],
         "Resource":"arn:aws:s3:::awsexamplebucket1/*"
      }
   ]
}
EOF
}
```

**2) Method2, a better way than the previous, most of us still do this.**

[https://github.com/p0bailey/blog-examples/tree/main/terraform-iam-json-to-hcl/method2](https://github.com/p0bailey/blog-examples/tree/main/terraform-iam-json-to-hcl/method2)

This method uses Terraform [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) with file() Interpolation Function to decouple the IAM policy JSON from the Terraform configuration. In this case at least Json document can be validate with an external tool.

file: [s3-read-write-policy.tf](https://github.com/p0bailey/blog-examples/blob/main/terraform-iam-json-to-hcl/method2/s3-read-write-policy.tf)

```hcl
resource "aws_iam_policy" "policy" {
  name        = "s3-read-write-policy"
  path        = "/"
  description = "Less ugly way to do it."

  policy      = file("read-write-s3-bucket.json")
}
```
file: [s3-read-write-policy-document.json](https://github.com/p0bailey/blog-examples/blob/main/terraform-iam-json-to-hcl/method2/s3-read-write-policy-document.json)

```json
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action": "s3:ListAllMyBuckets",
         "Resource":"arn:aws:s3:::*"
      },
      {
         "Effect":"Allow",
         "Action":["s3:ListBucket","s3:GetBucketLocation"],
         "Resource":"arn:aws:s3:::awsexamplebucket1"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:DeleteObject"
         ],
         "Resource":"arn:aws:s3:::awsexamplebucket1/*"
      }
   ]
}
```
**3) Method3, the  cool way.**

[https://github.com/p0bailey/blog-examples/tree/main/terraform-iam-json-to-hcl/method3](https://github.com/p0bailey/blog-examples/tree/main/terraform-iam-json-to-hcl/method3)

This method uses [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) which allow to use aws_iam_policy_document data source to structure the policy into a more human friendly format.

Let's use `iam-policy-json-to-terraform` to convert our Json policy to HCL.


`iam-policy-json-to-terraform < read-write-s3-bucket.json`

Or you could even output directly into a Terraform file such:

`iam-policy-json-to-terraform < read-write-s3-bucket.json > s3-read-write-policy-document.tf`

```bash
$ iam-policy-json-to-terraform < read-write-s3-bucket.json
data "aws_iam_policy_document" "policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::*"]
    actions   = ["s3:ListAllMyBuckets"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::awsexamplebucket1"]

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::awsexamplebucket1/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject",
    ]
  }
}
```




file: [s3-read-write-policy.tf](https://github.com/p0bailey/blog-examples/blob/main/terraform-iam-json-to-hcl/method3/s3-read-write-policy.tf)

```hcl
resource "aws_iam_policy" "policy" {
  name        = "s3-read-write-policy"
  path        = "/"
  description     = "The right way to do it."
  policy      = data.aws_iam_policy_document.policy.json

}
```

file: [s3-read-write-policy-document.tf](https://github.com/p0bailey/blog-examples/blob/main/terraform-iam-json-to-hcl/method3/s3-read-write-policy-document.tf)


```hcl
# Here you can have comments!!!
data "aws_iam_policy_document" "policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::*"]
    actions   = ["s3:ListAllMyBuckets"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    # Here you can have comments as well!!!
    resources = ["arn:aws:s3:::awsexamplebucket1"]

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::awsexamplebucket1/*"]
    # Here you can have comments as well!!!

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject",
    ]
  }
}
```

In this post I have barely scratched the surface about all permutations of [data source aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document), give it a go and let me know!

Stay tuned!