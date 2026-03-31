######################
# Infrastructure OUs #
######################

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "infrastructure"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "infrastructure_prod" {
  name      = "prod"
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "infrastructure_non_prod" {
  name      = "non-prod"
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  tags = local.common_tags
}


################
# Security OUs #
################

resource "aws_organizations_organizational_unit" "security" {
  name      = "security"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "security_prod" {
  name      = "prod"
  parent_id = aws_organizations_organizational_unit.security.id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "security_non_prod" {
  name      = "non-prod"
  parent_id = aws_organizations_organizational_unit.security.id

  tags = local.common_tags
}


#################
# Workloads OUs #
#################

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "workloads"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "workloads_prod" {
  name      = "prod"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = local.common_tags
}

resource "aws_organizations_organizational_unit" "workloads_non_prod" {
  name      = "non-prod"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = local.common_tags
}
