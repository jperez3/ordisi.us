resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = local.sso_identity_store_id

  user_name    = each.key
  display_name = "${each.value.given_name} ${each.value.family_name}"

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = each.value.email
    primary = true
  }
}

resource "aws_identitystore_group_membership" "this" {
  for_each = local.user_group_memberships

  identity_store_id = local.sso_identity_store_id
  group_id          = local.groups_by_name[each.value.group]
  member_id         = aws_identitystore_user.this[each.value.username].user_id
}
