output "cross_account_roles" {
  description = "Map of created cross-account IAM roles, keyed by role name"
  value = {
    for k, role in aws_iam_role.cross_account : k => {
      role_name = role.name
      role_arn  = role.arn
    }
  }
}

output "terraform_execution" {
  description = "Values for the Terraform execution IAM role"
  value = var.terraform_execution_role.create ? {
    role_name = aws_iam_role.terraform_execution[0].name
    role_arn  = aws_iam_role.terraform_execution[0].arn
  } : null
}
