resource "cloudflare_pages_project" "ordisi" {
  account_id = var.cloudflare_account_id
  build_config = {
    build_command   = "hugo"
    destination_dir = "public"
    root_dir        = "app/blog/"
  }
  deployment_configs = {
    preview = {
      always_use_latest_compatibility_date = false
      build_image_major_version            = 3
      compatibility_date                   = "2026-01-22"
      fail_open                            = true
    }
    production = {
      always_use_latest_compatibility_date = false
      build_image_major_version            = 3
      compatibility_date                   = "2026-01-22"
      fail_open                            = true
    }
  }
  name              = local.project_name
  production_branch = "main"
  source = {
    config = {
      owner                          = "jperez3"
      owner_id                       = "21203946"
      path_includes                  = ["*"]
      pr_comments_enabled            = true
      preview_branch_includes        = ["*"]
      preview_deployment_setting     = "all"
      production_branch              = "main"
      production_deployments_enabled = true
      repo_id                        = "1133108286"
      repo_name                      = var.domain_name
    }
    type = "github"
  }
}

resource "cloudflare_pages_domain" "ordisi_us" {
  account_id   = var.cloudflare_account_id
  name         = "www.${var.domain_name}"
  project_name = local.project_name
}

resource "cloudflare_dns_record" "ordisi_cname" {
  content = "${local.project_name}.pages.dev"
  name    = "www.${var.domain_name}"
  proxied = true
  settings = {
    flatten_cname = false
  }
  ttl     = 1
  type    = "CNAME"
  zone_id = data.cloudflare_zone.ordisi_us.zone_id
}
