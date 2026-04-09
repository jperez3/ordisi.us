################
# DevOps Group #
################
resource "aws_identitystore_group" "devops" {
  identity_store_id = local.sso_identity_store_id
  display_name      = "devops"
  description       = "DevOps engineers with full administrative access to all accounts"
}


###################################
# DevOps All Admin Permission Set #
###################################

resource "aws_ssoadmin_permission_set" "devops_all_admin" {
  name             = "devops-all-admin"
  description      = "Full administrative access to all accounts"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H"

  tags = local.common_tags
}

resource "aws_ssoadmin_managed_policy_attachment" "devops_all_admin" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.devops_all_admin.arn
}


#######################
# Account Assignments #
#######################

resource "aws_ssoadmin_account_assignment" "devops_all_admin" {
  for_each = local.all_accounts

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devops_all_admin.arn

  principal_id   = aws_identitystore_group.devops.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}
