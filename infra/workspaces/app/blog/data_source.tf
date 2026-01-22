data "cloudflare_zone" "ordisi_us" {
  filter = {
    name = var.domain_name
  }
}
