locals {
  accounts = {
    prod = {
      name      = "ordisi-prod"
      email     = "joe+ordisi-prod@ordisius.com"
      parent_id = aws_organizations_organizational_unit.workloads_prod.id
    }
    dev = {
      name      = "ordisi-dev"
      email     = "joe+ordisi-dev@ordisius.com"
      parent_id = aws_organizations_organizational_unit.workloads_non_prod.id
    }
    networking = {
      name      = "ordisi-networking"
      email     = "joe+ordisi-networking@ordisius.com"
      parent_id = aws_organizations_organizational_unit.infrastructure_prod.id
    }
    shared_services = {
      name      = "ordisi-shared-services"
      email     = "joe+ordisi-shared-services@ordisius.com"
      parent_id = aws_organizations_organizational_unit.infrastructure_prod.id
    }
    security = {
      name      = "ordisi-security"
      email     = "joe+ordisi-security@ordisius.com"
      parent_id = aws_organizations_organizational_unit.security_prod.id
    }
  }
}

resource "aws_organizations_account" "this" {
  for_each = local.accounts

  name      = each.value.name
  email     = each.value.email
  parent_id = each.value.parent_id

  tags = local.common_tags

  lifecycle {
    ignore_changes = [iam_user_access_to_billing]
  }
}
