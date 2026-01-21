terraform {
  backend "s3" {
    bucket                      = "ordisius-tf"
    key                         = "ordisius/infra/workspaces/app/blog/${var.env}.state"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    access_key                  = var.r2_access_key
    secret_key                  = var.r2_secret_key
    endpoints                   = { s3 = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com" }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
