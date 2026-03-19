---
title: "Scaling Infrastructure as Code: 5 to 1,000+ workspaces"
author: "Joe"
authorAvatarPath: "images/avatar.jpg"
date: "2026-03-19"
summary: "Lessons learned from scaling IaC"
description: "Lessons learned from scaling IaC"
toc: false
readTime: true
autonumber: true
math: true
tags: ["iac", "terraform"]
showTags: false
hideBackToTop: true
---



When a company starts their infrastructure-as-code journey in AWS (or other cloud providers), they usually draw a line between each environment. This often starts with the creation of a VPC, then compute and storage for a new product or service. As the business grows, more resources are created and environments diverge (intentionally and not). Before long, the infrastructure becomes a mess to maintain and the tool gets blamed as inadequate. The reality is that a lack of proper planning and execution contributed to the problems.




### Hierarchy of Resources

In providers like AWS, there's a hierarchy of resources that need to be created in a specific order to succeed (aka dependencies). For example, you need to create a public DNS zone prior to adding DNS records to the zone. This is a bit of a read-between-the-lines thing in AWS as you familiarize yourself with the cloud provider.

Some resources can only be created once in an AWS account (e.g., public DNS zones, IAM users). I refer to these as global resources. Other resources are region-specific, meaning they can exist with the same name across regions without worrying about naming collisions. An easy way to test whether a resource is global or regional is to create it via the console in a new account, then change the region. If the resource is still visible, it's a global resource.

With that in mind, you'll want to put the global resources you want in every account into a `global-base` (or whatever makes sense to you) module. Once that module is created, you need somewhere to call it.




### Directory Structure

Keeping hierarchy in mind, you want to have the global resources closer to the root, regional resources next, then your applications/products/services closer to the leaf.

An example of this would look like:

```bash
❯ tree -d .
.
└── global
    ├── base                # default resources for every account
    └── region
        ├── base            # shared resources for a given region
        └── services
            ├── base        # shared resources by all services
            └── burrito
                └── base
```

_Note: Another way to look at this: things closer to the root change less often and things closer to the leaf change more frequently._




### One Workspace, One Module

Sticking with the `global-base` module example, it's important to map each complete module with its own workspace. When I say workspace, I don't mean the `terraform workspace` command. I'm referring to where the module is called. Most of the time, people just call the module inside a `main.tf` file:

`main.tf`
```hcl
module "global_base" {
  source = "../../../modules/global/base"

  env = var.env

}
```
_Note: Create a good module README and limit the number of inputs. More inputs means more differences._





### Managing Multiple Environments

Previously, you needed to create a directory structure for each AWS account you maintain. This limitation was brought on by the backend configuration: Terraform variables are not allowed inside backend values. You can use the `-backend-config` flag, but it needs to be included every time the `terraform` command runs, which can be error-prone even with a wrapper.

A newer solution to this problem involves moving to [OpenTofu](https://opentofu.org/), which allows variables inside the backend block, e.g.:

```hcl
terraform {
  backend "s3" {
    bucket    = "ordisius-tf"
    key       = "ordisius/infra/workspaces/app/blog/${var.env}.state"
    region    = "auto"
    ...
    ...
    ...
    endpoints = { s3 = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com" }
  }
}
```
_Note: You still need to use a flag each time you run the `tofu` (Terraform) command (e.g., `tofu plan -var-file=prod.tfvars`), but it's much less error-prone._

Collapsing the directories doesn't buy you fewer workspaces, but it does enforce consistency between them. No more forgetting to update all deployments in each environment's directory tree.





### Drift Detection

Eventually, more engineers will work on the infrastructure, and this will cause drift from the desired IaC state. Most of the time this is unintentional: someone starts working on an update and gets pulled away before they can finish. Catching these differences is important because they can block an emergency update during an incident. Drift detection should be a priority, and you'll need tooling to identify when it happens and contact the owner.





### Updates

Updates fall into three major buckets:
1. Terraform/OpenTofu binary updates - Binary updates used to be a bigger problem. Updates over the last several years have been smooth, but you should still read the release notes for breaking changes.
2. Provider updates - Provider updates are dictated by whoever owns the provider. Sometimes this is HashiCorp; other times it's the cloud provider who owns the Terraform provider.
3. Module tag updates - Whether you're using a hosted registry or GitHub tags, you will need to update submodules from time to time. Without version pinning, you're likely to run into surprises.





### Random Observations

* Most teams start with one state per environment because it's easy and they don't know how to reference resources created in other workspaces. If you're still stuck here, look into `data sources` and [tagging](https://www.taccoform.com/posts/tfg_p2/).
* Consumable submodules (e.g., EC2, RDS) should be updated to the most recent version any time the module/workspace is touched by an engineer. Failing to do so creates drift and more work later for someone else.
* Tools like [Renovate](https://github.com/renovatebot/renovate) exist to automate the IaC update process, but I haven't used it yet, so I can't give an informed opinion on how well it performs.
