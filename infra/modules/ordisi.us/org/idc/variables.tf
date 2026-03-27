variable "env" {
  description = "The environment for the AWS account (e.g., dev, prod)."
  type        = string
}

locals {
  sso_instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  sso_identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  common_tags = {
    Environment = var.env,
    ManagedBy   = "IaC",
    Module      = "org-base"
  }
}
