---
title: "AWS Identity Center"
author: "Joe"
authorAvatarPath: "images/avatar.jpg"
date: "2026-04-09"
summary: "Setting up AWS Identity Center"
description: "Setting up AWS Identity Center"
toc: false
readTime: true
autonumber: true
math: true
tags: ["iac", "terraform", "opentofu", "aws", "identity-center", "greenfield"]
showTags: false
hideBackToTop: true
---
![lemon](https://static.taccoform.com/header_ord_040926.jpg)



After configuring an AWS Organization, the next logical step would be to set up AWS Identity Center. Businesses used to manage user accounts for their employees via individual AWS accounts. Administrators would have to designate a central account with users, groups, roles, and trusts to authenticate to member accounts. Or worse, they would create users, groups, and roles in each AWS account. This becomes a problem when onboarding/offboarding employees. _"Did we disable that user and remove their access keys?"_ Something you can't confidently confirm when you have tens or hundreds of accounts. AWS Identity Center allows you to centralize user access management and role distribution to member accounts. It also enables SSO (Single Sign-On) which means no more static access keys on employee computers. Today we'll go through the initial setup of Identity Center and its various components.



# Enable IAM Identity Center

You will need to enable IAM Identity Center in the AWS console to get started with the buildout. As far as I can tell, you cannot enable Identity Center via API/IaC.

1. Log into your management AWS account
2. Search for and click on  “IAM Identity Center”
3. Press the orange “Enable” button
4. Verify your desired region, then press the “Enable” button

Some other Identity Center settings aren't configurable via API, so let's knock that out real quick. When you initialize Identity Center, AWS will assign you a unique ID which is not too friendly for users to remember.

1. In IAM Identity Center, on the left pane, click "Settings"
2. In the `Identity Source` tab, click "Actions" and select "Customize AWS access portal URL"
3. Enter a new subdomain to use to sign in, confirm and press "save"

Now let's update the authentication settings by starting with user onboarding. You will need to enable the setting for an email to be sent to the user with a one-time password.

1. In the IAM Identity Center Settings, Click on the "Authentication" tab
2. Under `Standard Authentication`, press the "Configure" button
3. Check the "Send email OTP" box, then press "Save"
_Note: This feature seems to be working for some, but not [others](https://repost.aws/questions/QUsjuJC6sYSzipCPluWnAGZA/identity-center-not-sending-otp-emails-to-users-created-using-the-createuser-api)_

And finally, let's update the multi-factor authentication to make sure that MFA is forced each time a user logs into AWS.

1. In the IAM Identity Center `Settings`, Click on the "Authentication" tab
2. Under `Multi-factor Authentication`, press the "Configure" button
3. Where it says "Prompt users for MFA", select "Every time they sign in (always-on)" then press "Save changes"


# Temporary IAM account for IaC

You'll eventually need to create temporary AWS CLI credentials to provision resources in a more automated and consistent way. Both AWS CLI and OpenTofu require AWS access keys to create resources. We don't have AWS Identity Center set up yet, so we will need to create the account via the IAM console.

1. Go to IAM in the AWS console
2. Create an IaC user, e.g., `iac-mgmt`
3. Attach Policy: `AdministratorAccess`
4. Go to the `iac-mgmt` user account
5. Create Access Keys
6. Select “Command Line Interface” use case
7. Save Access Keys to your password manager



# Groups


An Identity Center Group functions like other groups in that you can assign policies to the group and any user in the group inherits those policies. Without groups, managing individual users with common access becomes a chore.

An example of a group would look like:

`developers.tf`
```bash
resource "aws_identitystore_group" "devs" {
  identity_store_id = local.sso_identity_store_id
  display_name      = "devs"
  description       = "Developer Identity Center Group"
}
```

# Permission Sets

Permission Sets are basically IAM roles with policies. Prior to Identity Center, you would need to create a role in each member account and assume into that role from another account. The problem this fixes is centralized management of the role. A permission set name should clearly identify who has access, what they have access to, and the access type. In the example below, it includes the group `devs`, the OU `non-prod` under the parent OU `workloads`, and `rw` (or read-write) for the access type. This format makes it easy to understand and audit the purpose of the `devs-workloads-non-prod` permission set.

_Example OU tree structure_
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


Here is an example of the resources required to create a permission set with a customer managed policy:


`developers.tf`
```bash
resource "aws_ssoadmin_permission_set" "devs_workloads_non_prod_rw" {
  name             = "devs-workloads-non-prod"
  description      = "Least-privilege developer access to common application services in non-prod workloads accounts."
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"

  tags = local.common_tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "devs_workloads_non_prod_rw" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devs_workloads_non_prod_rw.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ── Compute ──────────────────────────────────────────────────────────

      {
        Sid    = "ECSReadWrite"
        Effect = "Allow"
        Action = [
          "ecs:Describe*",
          "ecs:List*",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:StartTask",
          "ecs:UpdateService",
          "ecs:CreateService",
          "ecs:DeleteService",
          "ecs:TagResource",
          "ecs:UntagResource",
        ]
        Resource = "*"
      },
# ...
# ...
# ...
      # ── Explicit Denies ───────────────────────────────────────────────────

      {
        Sid    = "DenyIAMWrite"
        Effect = "Deny"
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:UpdateRole",
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:CreateAccessKey",
          "iam:UpdateAccountPasswordPolicy",
        ]
        Resource = "*"
      },
    ]
  })
}
```



# Account Assignment

Account Assignment is where everything comes together. The group, permission set, and AWS accounts bond and all three are required to make a successful connection by a user into a member account. The permission set and group must be attached and so does the account and permission set. When a permission set is connected to an account, it distributes an IAM role to the member account with the policy defined in the permission set. You can identify a permission set role by the name because it is prefixed with "AWSReservedSSO"

Here is an example of IaC attaching the `devs-workloads-non-prod` permission set to the `devs` group and non-production `workloads` accounts:

`data_source.tf`
```bash
data "aws_organizations_organizational_unit" "workloads_non_prod" {
  parent_id = data.aws_organizations_organizational_unit.workloads.id
  name      = "non-prod"
}

data "aws_organizations_organizational_unit_descendant_accounts" "workloads_non_prod" {
  parent_id = data.aws_organizations_organizational_unit.workloads_non_prod.id
}
```

`developers.tf`
```bash
resource "aws_ssoadmin_account_assignment" "devs_workloads_non_prod_rw" {
  for_each = { for acct in data.aws_organizations_organizational_unit_descendant_accounts.workloads_non_prod.accounts : acct.id => acct }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devs_workloads_non_prod_rw.arn

  principal_id   = aws_identitystore_group.devs.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}

```

# Users

Users are the employees in your organization which need access to your AWS environment. Users can be associated with multiple groups which allows a user to have different permissions. For example, an engineering manager might be associated with a `manager` group and `dev` group if they still write code.



`variables.tf`
```bash
variable "users" {
  description = "Map of SSO users to create. Each user requires a first name, last name, email, and the list of group display names to add them to"
  type = map(object({
    given_name  = string
    family_name = string
    email       = string
    groups      = list(string)
  }))
  default = {}
}

locals {

  # Flatten users x groups into a map keyed by "username/groupname" for for_each
  user_group_memberships = {
    for pair in flatten([
      for username, user in var.users : [
        for group in user.groups : {
          key      = "${username}/${group}"
          username = username
          group    = group
        }
      ]
    ]) : pair.key => pair
  }
}
```

`users.tf`
```bash
resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = local.sso_identity_store_id

  user_name    = each.key
  display_name = "${each.value.given_name} ${each.value.family_name}"

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = each.value.email
    primary = true
  }
}

resource "aws_identitystore_group_membership" "this" {
  for_each = local.user_group_memberships

  identity_store_id = local.sso_identity_store_id
  group_id          = local.groups_by_name[each.value.group]
  member_id         = aws_identitystore_user.this[each.value.username].user_id
}
```




# Cleanup

Remember to remove the `iac-mgmt` access keys and account when you are done provisioning.


# Wrap up


This is just the start of an Identity Center build out. You may be faced with existing permission sets, groups, and accounts. From a search on the Internet, you'll find many different ways to structure your Identity Center and AWS organization. The most important things to consider are: "Does it help meet our security and velocity goals?" and "Is it easy to work on and audit?" If the answer to either question is no, then you have surveys to complete and work to do.


Full code can be found [here](https://github.com/jperez3/ordisi.us/tree/main/infra/modules/ordisi.us/org/idc)
