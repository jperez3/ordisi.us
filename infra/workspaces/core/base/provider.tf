terraform {
  backend "s3" {
    bucket = "ord-${var.env}-iac"
    key    = "ordisi.us/infra/workspaces/core/base/${var.env}.state"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      tf-workspace = "ordisi.us/infra/workspaces/core/base/${var.env}"
    }
  }
}
