output "backup_monitor_crawler" {
  description = "Values for the backup monitor crawler IAM role"
  value = var.backup_monitor_crawler.create ? {
    role_name = aws_iam_role.backup_monitor_crawler[0].name
    role_arn  = aws_iam_role.backup_monitor_crawler[0].arn
  } : null
}

output "dai_data_crawler" {
  description = "values for the DAI Lens data crawler IAM role"
  value = var.dai_lens_data_crawler.create ? {
    role_name = aws_iam_role.dai_data_crawler[0].name
    role_arn  = aws_iam_role.dai_data_crawler[0].arn
  } : null
}

output "terraform_execution" {
  description = "Values for the Terraform execution IAM role"
  value = var.terraform_execution_role.create ? {
    role_name = aws_iam_role.terraform_execution[0].name
    role_arn  = aws_iam_role.terraform_execution[0].arn
  } : null
}
