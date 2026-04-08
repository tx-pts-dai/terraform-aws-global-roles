output "terraform_execution_role" {
  description = "Terraform execution role details"
  value       = module.global_roles.terraform_execution
}

output "gotthard_role" {
  description = "Gotthard role details"
  value       = module.global_roles.gotthard
}

output "dai_data_crawler_role" {
  description = "DAI Lens data crawler role details"
  value       = module.global_roles.dai_data_crawler
}
