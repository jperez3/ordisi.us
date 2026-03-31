# blog

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.ordisi_cname](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_pages_domain.ordisi_us](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/pages_domain) | resource |
| [cloudflare_pages_project.ordisi](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/pages_project) | resource |
| [cloudflare_zone.ordisi_us](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudflare_account_id"></a> [cloudflare\_account\_id](#input\_cloudflare\_account\_id) | cloudflare account ID | `string` | n/a | yes |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | cloudflare API token for provisioning resources | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | domain name given to reach site | `string` | `"ordisi.us"` | no |
| <a name="input_env"></a> [env](#input\_env) | unique environment name | `string` | n/a | yes |
| <a name="input_r2_access_key"></a> [r2\_access\_key](#input\_r2\_access\_key) | cloudflare r2 access key | `string` | n/a | yes |
| <a name="input_r2_secret_key"></a> [r2\_secret\_key](#input\_r2\_secret\_key) | cloudflare r2 secret access key | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
