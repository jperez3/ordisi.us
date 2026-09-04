variable "enable_vpc_endpoint_s3" {
  description = "enables/disables S3 VPC endpoint"
  type        = bool
  default     = true
}

locals {
  s3_endpoint_route_table_ids = values(aws_route_table.private)[*].id
}
