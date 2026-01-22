locals {
  domains = {
    ordisi_us = {
      name = "ordisi.us"
      type = "full"
    }
  }

}

resource "cloudflare_zone" "global" {
  for_each = local.domains
  account = {
    id = var.cloudflare_account_id
  }
  name = each.value["name"]
  type = each.value["type"]
}
