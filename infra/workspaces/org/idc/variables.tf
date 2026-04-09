variable "env" {
  description = "unique environment name"
  default     = "mgmt"
  type        = string
}

variable "users" {
  description = "Map of SSO users to create and their group memberships."
  type = map(object({
    given_name  = string
    family_name = string
    email       = string
    groups      = list(string)
  }))
  default = {}
}
