module "vpc_lower" {
  source = "git::git@github.com:jperez3/ordisi.us.git//infra/modules/vendor/aws/vpc/lower?depth=1&ref=aws-vpc-lower-v1.0.1"
  #   source = "../../../vendor/aws/vpc/lower"

  count = var.env != "prod" ? 1 : 0

  name = "primary"
  env  = var.env

  alarm_email_addresses   = ["joe+ordisi-${var.env}@ordisius.com"]
  enable_jumpbox_instance = var.enable_jumpbox_instance

}
