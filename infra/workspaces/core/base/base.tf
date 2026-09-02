module "core_base" {
  source = "../../../modules/ordisi.us/core/base"

  name = "primary"
  env  = var.env

  enable_jumpbox_instance = true

}
