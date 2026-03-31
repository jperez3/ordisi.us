---
title: "AWS Organizations"
author: "Joe"
authorAvatarPath: "images/avatar.jpg"
date: "2026-03-31"
summary: "Building an AWS Organization from scratch"
description: "Building an AWS Organization from scratch"
toc: false
readTime: true
autonumber: true
math: true
tags: ["iac", "terraform", "aws", "organizations", "greenfield"]
showTags: false
hideBackToTop: true
---
![shrimp](https://static.taccoform.com/header_ord_033126.jpg)




AWS Organizations was announced almost 10 years ago as a way to centralize the management of AWS accounts. At some point, people realized that creating environment boundaries within a single AWS account was difficult to accomplish and maintain. The proposed solution was to separate environments into AWS accounts. Production would have its own account, and so would each of the lower environments. Eventually, teams would request their own accounts. What starts as one AWS environment can balloon into tens or hundreds of accounts to maintain. Investing in AWS Organizations gives you faster AWS account provisioning, centralized governance, and centralized cost management.


### AWS Management Account

When starting a new AWS organization, AWS recommends creating a management account as a centralized place to manage accounts, users, and permissions. The management account should not be used for any other purpose. You can create a new management account [here](https://signin.aws.amazon.com/signup?request_type=register)

1. When prompted for an email address (and your email provider is Gmail), add a `+` and the account name, such as `mgmt`, e.g., `joe+mgmt@gmail.com`. The `+mgmt` acts as an alias that allows you to receive notifications about the account and identify it without having to memorize the account number.
2. Give the account name what you used in the alias to keep things consistent, which would be `mgmt`
3. AWS will send you an email to verify control over that email address. Click `verify`.
4. Select `free` account if you haven't set up an account with your information yet, otherwise select `paid` and enter your credit card information.
5. Select the `free` support plan



### MFA On Root Account

Multi-factor authentication is extremely important for the `root` account, which has the keys to the castle (AKA your AWS organization).

1. Log into the `mgmt` account for the first time
2. Click the account name in the upper-right corner and select "Security Credentials"
3. Click “assign MFA” or “assign MFA device”
4. Give the device a name and use the authenticator app of your choice




### Temporary IAM account for IaC

You'll eventually need to create temporary AWS CLI credentials to provision resources in a more automated and consistent way. Both AWS CLI and OpenTofu require AWS access keys to create resources. We don't have AWS Identity Center set up yet, so we will need to create the account via the IAM console.

1. Go to IAM in the AWS console
2. Create an IaC user, e.g., `iac-mgmt`
3. Attach Policy: `AdministratorAccess`
4. Go to the `iac-mgmt` user account
5. Create Access Keys
6. Select “Command Line Interface” use case
7. Save Access Keys to your password manager


### Set up Terminal

In order to start provisioning from your terminal, you will need to install and configure a couple of tools, mainly `awscli` and `opentofu`.

1. Install [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) for your system
2. Install [opentofu](https://opentofu.org/docs/intro/install/) for your system.
3. Configure `awscli` in your terminal by setting the access key environment variables:
```bash
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
export AWS_REGION="us-east-1"
```

### S3 Bucket for IaC State

You will need an `s3` bucket to store the infrastructure-as-code state files, but you will not be able to manage that bucket via `opentofu` because there is nowhere to store the state yet. You could create it with a local backend, but that is kind of a waste of time. You can just create this one resource via `awscli`.

1. Create an environment variable for your state file bucket name:
```bash
export BUCKET_NAME="something-something-mgmt"
```

2. Create state file bucket:
```bash
$ aws s3api create-bucket \
  --bucket ${BUCKET_NAME} \
  --region ${AWS_REGION} \
  --create-bucket-configuration
```
3. Block all public access to this bucket:
```bash
aws s3api put-public-access-block \
  --bucket ${BUCKET_NAME} \
  --public-access-block-configuration \
BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```
4. Enable versioning on the bucket, something you should do for every state bucket:
```bash
aws s3api put-bucket-versioning \
  --bucket ${BUCKET_NAME} \
  --versioning-configuration Status=Enabled
```


### AWS Organization IaC resources

You will now need to create a workspace to reference the `s3` bucket you just created so you can start provisioning AWS organization resources.

`provider.tf`
```bash
terraform {
  backend "s3" {
    bucket = "something-something-iac"
    key    = "ordisi.us/infra/workspaces/org/base/${var.env}.state"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Workspace = "ordisi.us/infra/workspaces/org/base/${var.env}"
    }
  }
}
```

#### Organization

You'll need to create two organization resources to get started: the organization itself and organization features. The organization resource defines the name, integration features, and enabled policy types. The organization features resource allows you to centrally manage the root account for each member account.

`org.tf`
```bash
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "iam.amazonaws.com",
    "access-analyzer.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
  ]
}

resource "aws_iam_organizations_features" "this" {
  enabled_features = [
    "RootCredentialsManagement",
    "RootSessions"
  ]

  depends_on = [aws_organizations_organization.this]
}

```
_Note: More organization integrations exist, but some are free and others are not. It is best to research each of these integrations before adding them._


#### Organizational Units (OUs)

Organizational Units are essentially folders under the organization root that allow you to place AWS accounts in those folders. Policies can be attached to individual folders to provide guardrails via Service Control Policies. These OU paths can also be used in IAM policies to grant granular access to resources.

Below is an example OU structure:

```bash
org-root
├── infrastructure  # OU for centralized services used by all accounts
│   ├── non-prod
│   └── prod
├── security        # OU for security tooling and centralized logging
│   ├── non-prod
│   └── prod
└── workloads       # OU for business related workloads
    ├── non-prod
    └── prod
```

If you are starting with a new organization, it is best to keep it as simple as possible. Each top-level folder contains a `prod` and `non-prod` subfolder. This allows you to test policy changes before promoting them to production. You may also want to restrict things like instance size via SCPs in lower environments for cost-control guardrails.

Here is an example of how to build out this structure:

`ou.tf`
```bash
######################
# Infrastructure OUs #
######################

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "infrastructure"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "infrastructure_prod" {
  name      = "prod"
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "infrastructure_non_prod" {
  name      = "non-prod"
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  tags = local.common_tags
}


################
# Security OUs #
################

resource "aws_organizations_organizational_unit" "security" {
  name      = "security"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "security_prod" {
  name      = "prod"
  parent_id = aws_organizations_organizational_unit.security.id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "security_non_prod" {
  name      = "non-prod"
  parent_id = aws_organizations_organizational_unit.security.id

  tags = local.common_tags
}


#################
# Workloads OUs #
#################

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "workloads"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "workloads_prod" {
  name      = "prod"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "workloads_non_prod" {
  name      = "non-prod"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = local.common_tags
}

```

#### AWS Accounts

As discussed earlier, we want to separate workload environments, but we also want to create centralized accounts for security and shared services.


```bash
org-root
├── infrastructure
│   ├── non-prod
│   └── prod
│       └── shared-services # Shared AWS services like Route53 and ECR
├── security
│   ├── non-prod
│   └── prod
│       └── security        # Used for centralized CloudTrail and logging
└── workloads
    ├── non-prod
    │   └── dev             # development environment workloads
    └── prod
        └── prod            # production environment workloads
```

An example of this in IaC would look like:

`accounts.tf`
```bash
locals {
  accounts = {
    prod = {
      name      = "prod"
        email     = "joe+prod@gmail.com"
      parent_id = aws_organizations_organizational_unit.workloads_prod.id
    }
    dev = {
      name      = "dev"
        email     = "joe+dev@gmail.com"
      parent_id = aws_organizations_organizational_unit.workloads_non_prod.id
    }
    networking = {
      name      = "networking"
        email     = "joe+networking@gmail.com"
      parent_id = aws_organizations_organizational_unit.infrastructure_prod.id
    }
    shared_services = {
      name      = "shared-services"
        email     = "joe+shared-services@gmail.com"
      parent_id = aws_organizations_organizational_unit.infrastructure_prod.id
    }
    security = {
      name      = "security"
        email     = "joe+security@gmail.com"
      parent_id = aws_organizations_organizational_unit.security_prod.id
    }
  }
}

resource "aws_organizations_account" "this" {
  for_each = local.accounts

  name      = each.value.name
  email     = each.value.email
  parent_id = each.value.parent_id

  tags = local.common_tags

  lifecycle {
    ignore_changes = [iam_user_access_to_billing]
  }
}
```


### Create Service Control Policies

Service Control Policies (SCPs) are guardrails that can be applied at the organization root, Organizational Units (OUs), or individual AWS accounts. Unless you have a very good reason to apply an SCP to an individual AWS account, it is generally best practice to apply them at the root or to specific OUs. You can create a baseline that applies to all of the AWS accounts in your organization by creating an SCP and attaching it to the organization root. This can be handy for avoiding common security problems like publicly exposed `s3` buckets.

An SCP baseline example would look like this:

`scp.tf`
```bash
resource "aws_organizations_policy" "baseline" {
  name        = "baseline-${var.env}"
  description = "Baseline guardrails applied to all accounts in the organization."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      },
      {
        Sid    = "DenyDisableCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors",
        ]
        Resource = "*"
      },
      {
        Sid      = "DenyIMDSv1"
        Effect   = "Deny"
        Action   = "ec2:RunInstances"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringNotEquals = {
            "ec2:MetadataHttpTokens" = "required"
          }
        }
      },
      {
        Sid      = "DenyModifyIMDSv1"
        Effect   = "Deny"
        Action   = "ec2:ModifyInstanceMetadataOptions"
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:Attribute/HttpTokens" = "optional"
          }
        }
      },
      {
        Sid    = "DenyS3PublicAccess"
        Effect = "Deny"
        Action = [
          "s3:PutAccountPublicAccessBlock",
          "s3:DeletePublicAccessBlock",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyCreateDefaultVpc"
        Effect = "Deny"
        Action = [
          "ec2:CreateDefaultVpc",
          "ec2:CreateDefaultSubnet",
        ]
        Resource = "*"
      },
    ]
  })

  tags = local.common_tags
}

resource "aws_organizations_policy_attachment" "root" {
  policy_id = aws_organizations_policy.baseline.id
  target_id = aws_organizations_organization.this.roots[0].id
}
```
_Note: Only 5 SCPs can be attached to the root OU. Consolidate SCPs into a single policy and choose wisely._



### Cleanup

Remember to remove the `iac-mgmt` access keys and account when you are done provisioning.


### Wrap up

You now have an AWS organization set up, which will allow you to quickly create new member accounts with basic guardrails, centralized billing for all accounts, and a path forward for scaling with business needs. Next, you will need to set up AWS IAM Identity Center for centralized user management and access to organization member accounts.
