<!-- BEGIN_TF_DOCS -->
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

## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_vpc_lower"></a> [vpc\_lower](#module\_vpc\_lower) | git::git@github.com:jperez3/ordisi.us.git//infra/modules/vendor/aws/vpc/lower?depth=1&ref=aws-vpc-lower-v1.0.0 | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_jumpbox_instance"></a> [enable\_jumpbox\_instance](#input\_enable\_jumpbox\_instance) | indicates if a jumpbox instance should be enabled | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | unique environment name | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | name of the resource | `string` | `"primary"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
