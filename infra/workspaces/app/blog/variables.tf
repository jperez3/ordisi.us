variable "env" {
  description = "unique environment name"
  type        = string
}

variable "cloudflare_api_token" {
  description = "cloudflare API token for provisioning resources"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "cloudflare account ID"
  type        = string
}

variable "r2_access_key" {
  description = "cloudflare r2 access key"
  type        = string
}

variable "r2_secret_key" {
  description = "cloudflare r2 secret access key"
  type        = string
}

variable "domain_name" {
  description = "domain name given to reach site"
  default     = "ordisi.us"
}

locals {
  project_name = replace(var.domain_name, ".", "-")
}
