variable "env" {
  description = "unique environment name"
  type        = string
}

variable "name" {
  description = "name of the resource"
  type        = string
  default     = "primary"
}

variable "enable_jumpbox_instance" {
  description = "indicates if a jumpbox instance should be enabled"
  type        = bool
  default     = false
}
