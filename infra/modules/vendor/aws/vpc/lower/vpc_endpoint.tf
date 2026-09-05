resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoint_s3 ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.s3_endpoint_route_table_ids

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-endpoint-s3"
  })
}
