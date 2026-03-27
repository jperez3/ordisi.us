resource "aws_organizations_policy" "deny_leave_org" {
  name        = "deny-leaving-organization"
  description = "Prevent member accounts from leaving the organization."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_organizations_policy" "deny_disable_security_services" {
  name        = "deny-disable-security-services"
  description = "Prevent disabling or modifying CloudTrail, GuardDuty, Security Hub, and AWS Config in member accounts."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyDisableCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDisableGuardDuty"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DisassociateMembers",
          "guardduty:StopMonitoringMembers",
          "guardduty:UpdateDetector",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDisableSecurityHub"
        Effect = "Deny"
        Action = [
          "securityhub:BatchDisableStandards",
          "securityhub:DeleteHub",
          "securityhub:DisableImportFindingsForProduct",
          "securityhub:DisableSecurityHub",
          "securityhub:DisassociateFromMasterAccount",
          "securityhub:DisassociateMembers",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDisableConfig"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigRule",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder",
        ]
        Resource = "*"
      },
    ]
  })

  tags = local.common_tags
}

resource "aws_organizations_policy" "require_imdsv2" {
  name        = "require-imdsv2"
  description = "Require IMDSv2 on EC2 instances; deny requests that use IMDSv1."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyIMDSv1"
        Effect   = "Deny"
        Action   = "ec2:RunInstances"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringNotEquals = {
            "ec2:MetadataHttpTokens" = "required"
          }
        }
      },
      {
        Sid      = "DenyModifyIMDSv1"
        Effect   = "Deny"
        Action   = "ec2:ModifyInstanceMetadataOptions"
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:Attribute/HttpTokens" = "optional"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_organizations_policy" "deny_s3_public_access" {
  name        = "deny-s3-public-access"
  description = "Prevent disabling S3 Block Public Access settings at the account level."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyS3PublicAccess"
        Effect = "Deny"
        Action = [
          "s3:PutAccountPublicAccessBlock",
          "s3:DeletePublicAccessBlock",
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

locals {
  scp_root_attachments = {
    deny_leave_org                 = aws_organizations_policy.deny_leave_org.id
    deny_disable_security_services = aws_organizations_policy.deny_disable_security_services.id
    require_imdsv2                 = aws_organizations_policy.require_imdsv2.id
    deny_s3_public_access          = aws_organizations_policy.deny_s3_public_access.id
  }
}

resource "aws_organizations_policy_attachment" "root" {
  for_each  = local.scp_root_attachments
  policy_id = each.value
  target_id = aws_organizations_organization.this.roots[0].id
}
