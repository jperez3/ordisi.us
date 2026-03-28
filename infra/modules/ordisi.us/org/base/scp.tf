resource "aws_organizations_policy" "baseline" {
  name        = "baseline-${var.env}"
  description = "Baseline guardrails applied to all accounts in the organization."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      },
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
      },
      {
        Sid    = "DenyS3PublicAccess"
        Effect = "Deny"
        Action = [
          "s3:PutAccountPublicAccessBlock",
          "s3:DeletePublicAccessBlock",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyCreateDefaultVpc"
        Effect = "Deny"
        Action = [
          "ec2:CreateDefaultVpc",
          "ec2:CreateDefaultSubnet",
        ]
        Resource = "*"
      },
    ]
  })

  tags = local.common_tags
}

resource "aws_organizations_policy_attachment" "root" {
  policy_id = aws_organizations_policy.baseline.id
  target_id = aws_organizations_organization.this.roots[0].id
}
