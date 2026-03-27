terraform {
  backend "s3" {
    bucket = "ord-mgmt-iac"
    key    = "ordisi.us/infra/workspaces/org/base/${var.env}.state"
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
      Workspace = "ordisi.us/infra/workspaces/org/base/${var.env}"
    }
  }
}
