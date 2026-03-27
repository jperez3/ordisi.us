resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "iam.amazonaws.com",
    "access-analyzer.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
  ]
}

resource "aws_iam_organizations_features" "this" {
  enabled_features = [
    "RootCredentialsManagement",
    "RootSessions"
  ]

  depends_on = [aws_organizations_organization.this]
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "infrastructure"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.common_tags
}
resource "aws_organizations_organizational_unit" "security" {
  name      = "security"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.common_tags
}

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
