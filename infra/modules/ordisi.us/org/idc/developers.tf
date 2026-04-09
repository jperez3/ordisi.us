####################
# Developers Group #
####################

resource "aws_identitystore_group" "devs" {
  identity_store_id = local.sso_identity_store_id
  display_name      = "devs"
  description       = "devs group for accociation with permission sets and account assignments"
}

################################################
# Developers Workloads Non-Prod Permission Set #
################################################

resource "aws_ssoadmin_permission_set" "devs_workloads_non_prod_rw" {
  name             = "devs-workloads-non-prod"
  description      = "Least-privilege developer access to common application services in non-prod workloads accounts."
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"

  tags = local.common_tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "devs_workloads_non_prod_rw" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devs_workloads_non_prod_rw.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ── Compute ──────────────────────────────────────────────────────────

      {
        Sid    = "ECSReadWrite"
        Effect = "Allow"
        Action = [
          "ecs:Describe*",
          "ecs:List*",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:StartTask",
          "ecs:UpdateService",
          "ecs:CreateService",
          "ecs:DeleteService",
          "ecs:TagResource",
          "ecs:UntagResource",
        ]
        Resource = "*"
      },
      {
        Sid    = "LambdaReadWrite"
        Effect = "Allow"
        Action = [
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:GetPolicy",
          "lambda:ListFunctions",
          "lambda:ListVersionsByFunction",
          "lambda:ListAliases",
          "lambda:ListEventSourceMappings",
          "lambda:ListTags",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:PublishVersion",
          "lambda:CreateAlias",
          "lambda:UpdateAlias",
          "lambda:DeleteAlias",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:CreateEventSourceMapping",
          "lambda:UpdateEventSourceMapping",
          "lambda:DeleteEventSourceMapping",
          "lambda:InvokeFunction",
          "lambda:TagResource",
          "lambda:UntagResource",
        ]
        Resource = "*"
      },

      # ── Storage ───────────────────────────────────────────────────────────

      {
        Sid    = "S3ReadWrite"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectTagging",
          "s3:GetObjectVersionTagging",
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetBucketTagging",
          "s3:GetBucketNotification",
          "s3:GetLifecycleConfiguration",
          "s3:GetBucketCORS",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketTagging",
          "s3:PutBucketVersioning",
          "s3:PutBucketNotification",
          "s3:PutLifecycleConfiguration",
          "s3:PutBucketCORS",
        ]
        Resource = "*"
      },

      # ── Database ──────────────────────────────────────────────────────────

      {
        Sid    = "DynamoDBReadWrite"
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:CreateTable",
          "dynamodb:DeleteItem",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:GetItem",
          "dynamodb:ListTables",
          "dynamodb:ListTagsOfResource",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:UpdateContinuousBackups",
          "dynamodb:UpdateItem",
          "dynamodb:UpdateTable",
          "dynamodb:UpdateTimeToLive",
        ]
        Resource = "*"
      },
      {
        Sid    = "RDSReadWrite"
        Effect = "Allow"
        Action = [
          "rds:AddTagsToResource",
          "rds:CreateDBCluster",
          "rds:CreateDBClusterSnapshot",
          "rds:CreateDBInstance",
          "rds:CreateDBSnapshot",
          "rds:DeleteDBCluster",
          "rds:DeleteDBClusterSnapshot",
          "rds:DeleteDBInstance",
          "rds:DeleteDBSnapshot",
          "rds:Describe*",
          "rds:DownloadDBLogFilePortion",
          "rds:ListTagsForResource",
          "rds:ModifyDBCluster",
          "rds:ModifyDBInstance",
          "rds:RebootDBCluster",
          "rds:RebootDBInstance",
          "rds:RemoveTagsFromResource",
          "rds:RestoreDBClusterFromSnapshot",
          "rds:RestoreDBInstanceFromDBSnapshot",
          "rds:StartDBCluster",
          "rds:StartDBInstance",
          "rds:StopDBCluster",
          "rds:StopDBInstance",
        ]
        Resource = "*"
      },

      # ── Messaging & Eventing ─────────────────────────────────────────────

      {
        Sid    = "SQSReadWrite"
        Effect = "Allow"
        Action = [
          "sqs:CreateQueue",
          "sqs:DeleteMessage",
          "sqs:DeleteQueue",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ListQueues",
          "sqs:ListQueueTags",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:SetQueueAttributes",
          "sqs:TagQueue",
          "sqs:UntagQueue",
        ]
        Resource = "*"
      },
      {
        Sid    = "SNSReadWrite"
        Effect = "Allow"
        Action = [
          "sns:CreateTopic",
          "sns:DeleteTopic",
          "sns:GetTopicAttributes",
          "sns:ListSubscriptions",
          "sns:ListSubscriptionsByTopic",
          "sns:ListTopics",
          "sns:Publish",
          "sns:SetTopicAttributes",
          "sns:Subscribe",
          "sns:TagResource",
          "sns:Unsubscribe",
          "sns:UntagResource",
        ]
        Resource = "*"
      },

      # ── Observability ────────────────────────────────────────────────────

      {
        Sid    = "CloudWatchReadWrite"
        Effect = "Allow"
        Action = [
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:PutMetricData",
          "cloudwatch:TagResource",
          "cloudwatch:UntagResource",
        ]
        Resource = "*"
      },
      {
        Sid    = "LogsReadWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:FilterLogEvents",
          "logs:GetLogEvents",
          "logs:ListTagsForResource",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy",
          "logs:TagResource",
          "logs:UntagResource",
        ]
        Resource = "*"
      },

      # ── Secrets & Config ─────────────────────────────────────────────────

      {
        Sid    = "SecretsManagerReadWrite"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:PutSecretValue",
          "secretsmanager:RestoreSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:UpdateSecret",
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMParameterReadWrite"
        Effect = "Allow"
        Action = [
          "ssm:AddTagsToResource",
          "ssm:DeleteParameter",
          "ssm:DeleteParameters",
          "ssm:DescribeParameters",
          "ssm:GetParameter",
          "ssm:GetParameterHistory",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:LabelParameterVersion",
          "ssm:ListTagsForResource",
          "ssm:PutParameter",
          "ssm:RemoveTagsFromResource",
        ]
        Resource = "*"
      },

      # ── Networking (read-only) ────────────────────────────────────────────

      {
        Sid    = "VPCReadOnly"
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeTags",
        ]
        Resource = "*"
      },

      # ── IAM (pass-role only) ─────────────────────────────────────────────

      {
        Sid    = "IAMPassRoleToServices"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListRoles",
          "iam:PassRole",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = [
              "ecs-tasks.amazonaws.com",
              "lambda.amazonaws.com",
              "rds.amazonaws.com",
            ]
          }
        }
      },

      # ── Explicit Denies ───────────────────────────────────────────────────

      {
        Sid    = "DenyIAMWrite"
        Effect = "Deny"
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:UpdateRole",
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:CreateAccessKey",
          "iam:UpdateAccountPasswordPolicy",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyOrganizationsWrite"
        Effect = "Deny"
        Action = [
          "organizations:*",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyBillingWrite"
        Effect = "Deny"
        Action = [
          "aws-portal:Modify*",
          "billing:Modify*",
        ]
        Resource = "*"
      },
    ]
  })
}



####################################################
# Developers Workloads Non-Prod Account Assignment #
####################################################

resource "aws_ssoadmin_account_assignment" "devs_workloads_non_prod_rw" {
  for_each = local.non_prod_workloads_accounts

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devs_workloads_non_prod_rw.arn

  principal_id   = aws_identitystore_group.devs.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}
