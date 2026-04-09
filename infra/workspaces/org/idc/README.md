# base

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_org_idc"></a> [org\_idc](#module\_org\_idc) | ../../../modules/ordisi.us/org/idc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | unique environment name | `string` | `"mgmt"` | no |
| <a name="input_users"></a> [users](#input\_users) | Map of SSO users to create and their group memberships. | <pre>map(object({<br/>    given_name  = string<br/>    family_name = string<br/>    email       = string<br/>    groups      = list(string)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
