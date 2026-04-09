module "org_idc" {
  source = "../../../modules/ordisi.us/org/idc"

  env = var.env

  users = {
    "joe.developer" = {
      given_name  = "Joe"
      family_name = "Developer"
      email       = "joe@ordisius.com"
      groups      = ["devs"]
    }
  }
}
