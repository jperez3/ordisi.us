data "aws_ssoadmin_instances" "this" {}
data "aws_organizations_organization" "this" {}


#########################
# Workloads OU Accounts #
#########################

data "aws_organizations_organizational_unit" "workloads_non_prod" {
  parent_id = data.aws_organizations_organizational_unit.workloads.id
  name      = "non-prod"
}

data "aws_organizations_organizational_unit_descendant_accounts" "workloads_non_prod" {
  parent_id = data.aws_organizations_organizational_unit.workloads_non_prod.id
}


data "aws_organizations_organizational_unit" "workloads" {
  parent_id = data.aws_organizations_organization.this.roots[0].id
  name      = "workloads"
}

data "aws_organizations_organizational_unit_descendant_accounts" "workloads_all" {
  parent_id = data.aws_organizations_organizational_unit.workloads.id
}


##############################
# Infrastructure OU Accounts #
##############################

data "aws_organizations_organizational_unit" "infrastructure" {
  parent_id = data.aws_organizations_organization.this.roots[0].id
  name      = "infrastructure"
}

data "aws_organizations_organizational_unit_descendant_accounts" "infrastructure_all" {
  parent_id = data.aws_organizations_organizational_unit.infrastructure.id
}


########################
# Security OU Accounts #
########################

data "aws_organizations_organizational_unit" "security" {
  parent_id = data.aws_organizations_organization.this.roots[0].id
  name      = "security"
}

data "aws_organizations_organizational_unit_descendant_accounts" "security_all" {
  parent_id = data.aws_organizations_organizational_unit.security.id
}
