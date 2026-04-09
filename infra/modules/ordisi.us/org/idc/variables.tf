variable "env" {
  description = "The environment for the AWS account (e.g., dev, prod)."
  type        = string
}

variable "users" {
  description = "Map of SSO users to create. Each user requires a first name, last name, email, and the list of group display names to add them to."
  type = map(object({
    given_name  = string
    family_name = string
    email       = string
    groups      = list(string)
  }))
  default = {}
}

locals {
  sso_instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  sso_identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]


  all_accounts = merge(
    { for acct in data.aws_organizations_organizational_unit_descendant_accounts.workloads_all.accounts : acct.id => acct },
    { for acct in data.aws_organizations_organizational_unit_descendant_accounts.infrastructure_all.accounts : acct.id => acct },
    { for acct in data.aws_organizations_organizational_unit_descendant_accounts.security_all.accounts : acct.id => acct },
  )

  non_prod_workloads_accounts = { for acct in data.aws_organizations_organizational_unit_descendant_accounts.workloads_non_prod.accounts : acct.id => acct }

  # Map of group display_name -> group_id for all managed groups
  groups_by_name = {
    "devops" = aws_identitystore_group.devops.group_id
    "devs"   = aws_identitystore_group.devs.group_id
  }

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


  common_tags = {
    Environment = var.env,
    ManagedBy   = "IaC",
    Module      = "org-idc"
  }
}
