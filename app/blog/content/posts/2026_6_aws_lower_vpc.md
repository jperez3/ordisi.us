---
title: "Low cost lower AWS Environemnts"
author: "Joe"
authorAvatarPath: "images/avatar.jpg"
date: "2026-09-09"
summary: "Replacing NAT Gateway with fck-nat"
description: "Replacing NAT Gateway with fck-nat"
toc: false
readTime: true
autonumber: true
math: true
tags: ["iac", "terraform", "aws", "vpc", "greenfield"]
showTags: false
hideBackToTop: true
---
![Thai fish](https://static.taccoform.com/header_ord_090926.jpg)


# Background

Once I started working through AWS Organizations and Identity Center, the next challenge was VPC networking. An AWS VPC is the foundation for nearly everything you build in the cloud, and one of the biggest costs in a private networking setup is NAT. If your workloads need outbound access to the internet, you usually need at least one NAT Gateway per VPC. A single NAT Gateway is roughly $32.85/month before data processing charges. If you want to do it “the right way,” you typically place a NAT Gateway in each Availability Zone to avoid cross-AZ data transfer fees. That can get expensive quickly.

A cheaper alternative is to use NAT instances instead. I would not recommend this for production, but for lower environments it can be a pragmatic option when cost matters more than operational polish.



# Evaluating fck-nat

I had previously built my own NAT instance setup and wrote about it in [A cost effective alternative to Managed NAT Gateways.](https://www.taccoform.com/posts/tfm_p5/) It worked well for a while, but the single NAT instance eventually failed, and the failure was disruptive. It was not built for production workloads, but it still created real problems in lower environments. I identified four main issues:

* No visibility into what was failing
* No automatic recovery when the NAT instance went down
* A single NAT instance outage meant all internet traffic was disrupted
* Cross-AZ traffic costs could increase when internet-bound traffic was routed poorly

On its own, fck-nat does not solve all of those problems, but it gives you a stronger starting point when paired with Auto Scaling Groups and CloudWatch alarms. Creating a NAT instance per AZ improves redundancy and reduces cross-AZ traffic, while Auto Scaling groups help replace unhealthy instances automatically. CloudWatch and SNS add the visibility layer that was missing before.



# Forking and refactoring fck-nat Terraform Module

Rather than start from scratch, I decided to [fork](https://github.com/jperez3/terraform-aws-fck-nat) the recommended [fck-nat Terraform module](https://github.com/RaJiska/terraform-aws-fck-nat). The module was a solid starting point, and the part I cared most about was the Auto Scaling configuration. The original module also leaned on inputs like the routing table, which made it flexible but not especially friendly for someone getting started with VPCs.

I wanted something more opinionated and easier to use as a first-class part of the environment, so I refactored it to include the rest of the VPC pieces, including subnets, routes, and related defaults, so the module felt more “batteries included.” I was able to test a lot of it locally with [floci](https://floci.io/), though I ran into issues creating ENIs in that tool.

I also leaned on pair programming with GitHub Copilot (Claude Sonnet 4) as a coding agent. The experience was useful, but not perfect. On the plus side, it caught an ENI attachment misconfiguration that would have broken the NAT instance setup. On the negative side, it also introduced a local variable that simply referenced another local variable:

```bash
locals {
  # AZs actually used by this module (single source of truth defined in vpc_variables.tf)
  asg_azs = local.azs
}
```

The GitHub Copilot review also caught unnecessary `region` parameters that had been added to resources. That was helpful, but I wish those issues had been surfaced during development instead of in review.

I eventually moved the forked module into the same GitHub repo as the workspace because Copilot was struggling to diagnose issues in a module that lived in a different repository. At the time, it seemed like a reasonable tradeoff, but versioned Terraform modules have a bit of a chicken-and-egg problem. If you update the workspace and the module simultaneously, the git module tag is not ready yet for your CI tests.



# Autoscaling Groups

Each Availability Zone (eg. `us-east-1a`, `us-east-1b`, `us-east-1c`) gets its own Auto Scaling Group with a minimum and maximum count of 1. You cannot have more than one NAT instance at a time because the ENI providing the static public IP can only be attached to a single instance. The launch template uses a t4g.micro Graviton-based instance, and to reduce costs further, we rely on Spot instances.

Spot instances are noticeably cheaper than on-demand pricing, but AWS can reclaim them at any time. Sometimes capacity is not available, and if you do not specify alternative instance types in the ASG, your NAT instances may not come back until Spot capacity becomes available again. The capacity rebalance option is useful here because it proactively replaces a Spot instance before AWS reclaims it.



# NAT Validation

Because this is a brand-new VPC, there are not any application workloads yet to validate the routing. You could use [Network Access Analyzer](https://docs.aws.amazon.com/vpc/latest/network-access-analyzer/what-is-network-access-analyzer.html), but I prefer validating the configuration by proving that internet access actually works from a freshly provisioned instance.

I also included an option in the fck-nat VPC module to provision a jumpbox with AWS Session Manager enabled. This gives me a way to connect to the instance without exposing it to the public internet. Once connected with the SSM helper tool [aws-connect](https://github.com/rewind-community/aws-connect), I can test internet access directly. Old habits die hard, so I usually start by checking my public IP with `curl icanhazip.com`. The returned IP should match the public IP of the NAT instance in the same AZ as the jumpbox. I can then move the jumpbox to another AZ and confirm the other NAT instances behave the same way. When I am done, I turn the jumpbox off to avoid unnecessary cost.



# Monitoring

By far, the most time-consuming part of this process was monitoring. The setup itself is simple: an SNS topic, an SNS subscription, and a CloudWatch alarm. That was made more difficult by the AWS outages that happened last week. Initially, the CloudWatch alarm was checking every minute and evaluating over 3 minutes, which created a flood of emails. Do not be me.

After several rounds of trial and error, I settled on checking every 5 minutes and evaluating over 20 minutes. I also set datapoints_to_alarm to 4, which means 4 out of 5 data points need to be breaching before an alert is sent. Once that was in place, the inbox returned to a much more normal rhythm of marketing emails vying for my attention.



# Cost

I ended up creating a reusable [fck-nat VPC module](https://github.com/jperez3/ordisi.us/tree/main/infra/modules/vendor/aws/vpc/lower) and referenced it from a Core Base module that I deployed in a new `dev` AWS account and environment. To get a better sense of the costs, I signed up for [Infracost](https://www.infracost.io/) and ran a report on the infrastructure:

```bash
The Core Base project is estimated at $9.23/month in us-east-1, or about $110.74/year.
Breakdown:
* 3 NAT Auto Scaling Groups: $8.93/month
* 3 CloudWatch alarms: $0.30/month
* VPC, subnets, flow logs, S3, and SNS: $0/month in the estimate
```

This was the kind of result I was hoping for. The design stayed inexpensive while still giving me a working NAT setup with redundancy and some visibility into failures.



# Wrap up

I started this project with a simple goal: build a low-cost VPC for lower environments. Along the way, I ended up learning far more about EC2 Auto Scaling groups and NAT instances than I expected. I also got a chance to try out a few different tools, and each one helped me move faster and understand the problem more clearly.

In the end, I built a reusable VPC pattern that was cheap, practical, and much easier to reason about than a managed NAT Gateway. That felt like the right tradeoff for lower environments, and it gave me a solid foundation to keep iterating from.



# Resources

* [fck-nat VPC deployed in Core Base module](https://github.com/jperez3/ordisi.us/blob/main/infra/modules/ordisi.us/core/base/vpc.tf)
* [Core Base module deployed in dev environment workspace](https://github.com/jperez3/ordisi.us/blob/main/infra/workspaces/core/base/base.tf)
* [fck-nat](https://fck-nat.dev/)
* [fck-nat official Terraform Module](https://github.com/RaJiska/terraform-aws-fck-nat)
* [fck-nat VPC module](https://github.com/jperez3/ordisi.us/tree/main/infra/modules/vendor/aws/vpc/lower)
* [infracost](https://www.infracost.io/)
* [floci](https://floci.io/)
* [aws-connect](https://github.com/rewind-community/aws-connect)
