variable "env" {
  description = "The environment for the AWS account (e.g., dev, prod)."
  type        = string
}

locals {

  common_tags = {
    Environment = var.env,
    ManagedBy   = "IaC",
    Module      = "org-base"
  }
}
