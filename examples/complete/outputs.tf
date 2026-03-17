output "terraform_execution_role" {
  description = "Terraform execution role details"
  value       = module.global_roles.terraform_execution
}

output "cross_account_roles" {
  description = "All created cross-account IAM roles"
  value       = module.global_roles.cross_account_roles
}
