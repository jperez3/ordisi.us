# Module: org/idc

Manages IAM Identity Center (IDC) resources for the `ordisi.us` AWS Organization: groups, users, permission sets, and account assignments.

## Architecture

```
IAM Identity Center instance (via data source)
├── Groups
│   ├── devops                      — full admin access to all accounts
│   └── devs                        — least-privilege builder access to non-prod workloads accounts
├── Users (var.users)               — created and assigned to groups
└── Permission Sets
    ├── devops-all-admin            — AdministratorAccess, all accounts, 4h session
    └── devs-workloads-non-prod     — inline least-privilege policy, non-prod workloads accounts only, 8h session
```

Account scope is resolved dynamically from Organizations data sources for the `workloads`, `infrastructure`, and `security` top-level OUs. No account IDs are hardcoded.

## Usage

```hcl
module "org_idc" {
  source = "../../../modules/ordisi.us/org/idc"

  env = "mgmt"

  users = {
    "alice.smith" = {
      given_name  = "Alice"
      family_name = "Smith"
      email       = "alice@example.com"
      groups      = ["devops"]
    }
    "bob.jones" = {
      given_name  = "Bob"
      family_name = "Jones"
      email       = "bob@example.com"
      groups      = ["devs"]
    }
  }
}
```

### Group name keys

The `groups` list in each user entry must use the internal lowercase key names, **not** display names:

| Key       | Display name | Access level                              |
|-----------|--------------|-------------------------------------------|
| `devops`  | devops       | AdministratorAccess — all accounts        |
| `devs`    | devs         | Least-privilege builder — non-prod only   |

## Limitations

**MFA enforcement is not managed by this module.** The AWS `sso-admin` public API does not expose IAM Identity Center authentication/MFA policy settings (e.g. "require MFA on every sign-in"). These settings must be configured manually in the IAM Identity Center console. See the [AWS IAM Identity Center MFA documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/enable-mfa.html) for guidance.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_identitystore_group.devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) | resource |
| [aws_identitystore_group.devs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) | resource |
| [aws_identitystore_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource |
| [aws_identitystore_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user) | resource |
| [aws_ssoadmin_account_assignment.devops_all_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_account_assignment.devs_workloads_non_prod_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_managed_policy_attachment.devops_all_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.devops_all_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set.devs_workloads_non_prod_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.devs_workloads_non_prod_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_organizations_organizational_unit.infrastructure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit) | data source |
| [aws_organizations_organizational_unit.security](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit) | data source |
| [aws_organizations_organizational_unit.workloads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit) | data source |
| [aws_organizations_organizational_unit.workloads_non_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit) | data source |
| [aws_organizations_organizational_unit_descendant_accounts.infrastructure_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit_descendant_accounts) | data source |
| [aws_organizations_organizational_unit_descendant_accounts.security_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit_descendant_accounts) | data source |
| [aws_organizations_organizational_unit_descendant_accounts.workloads_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit_descendant_accounts) | data source |
| [aws_organizations_organizational_unit_descendant_accounts.workloads_non_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit_descendant_accounts) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | The environment for the AWS account (e.g., dev, prod). | `string` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | Map of SSO users to create. Each user requires a first name, last name, email, and the list of group display names to add them to. | <pre>map(object({<br/>    given_name  = string<br/>    family_name = string<br/>    email       = string<br/>    groups      = list(string)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
