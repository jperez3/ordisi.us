# Core Base Module

## Introduction

Description: a core module which deploys a VPC and supporting infrastructure


## Example

```hcl
module "core_base" {
  source = "../../../modules/ordisi.us/core/base"

  name = "primary"
  env  = var.env

  enable_jumpbox_instance = true

}
```
