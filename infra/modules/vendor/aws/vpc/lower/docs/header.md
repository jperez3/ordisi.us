# Terraform VPC for lower environments

## Introduction

A Terraform module for deploying NAT Instances in a VPC using [fck-nat](https://github.com/AndrewGuenther/fck-nat). The (f)easible (c)ost (k)onfigurable NAT!
The following is a list of features available with this module:
- High-availability mode achieved by deploying EC2 on an ASG
- Consistent static IP via EIP re-attachment to the internet facing ENI
- Cloudwatch metrics reported similar to those available with the managed NAT Gateway
- Use of spot instances instead of on-demand for reduced costs

## Example

```hcl
module "vpc_lower" {
  source = "git::https://github.com/jperez3/terraform-aws-fck-nat.git"

  env  = "dev"
  name = "primary"

  # use_cloudwatch_agent = true                 # Enables Cloudwatch agent and have metrics reported
}
```
