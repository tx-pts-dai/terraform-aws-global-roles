output "dai_data_crawler" {
  description = "values for the DAI Lens data crawler IAM role"
  value = {
    role_name = aws_iam_role.dai_data_crawler[0].name
    role_arn  = aws_iam_role.dai_data_crawler[0].arn
  }
}
