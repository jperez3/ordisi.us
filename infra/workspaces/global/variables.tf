variable "env" {
  description = "unique environment name"
  type        = string
}

variable "cloudflare_api_token" {
  description = "cloudflare API token for provisioning resources"
  type        = string
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
