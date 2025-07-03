## Providers
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

#
## DAI Lens Data Crawler
resource "aws_iam_role" "dai_data_crawler" {
  count = var.dai_lens_data_crawler.create ? 1 : 0

  name        = "dai-lens-data-crawler"
  description = "Grants access to DAI Lens in RDS and AWS Health"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::730335665754:role/dai-lens" # DAI Prod AWS Account
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
## Policy for RDS read-only + AWS Health read
data "aws_iam_policy_document" "dai_data_crawler_policy" {
  count = var.dai_lens_data_crawler.create ? 1 : 0

  dynamic "statement" {
    for_each = var.dai_lens_data_crawler.block_rds_access ? [] : [""]

    content {
      effect = "Allow"
      actions = [
        "rds:Describe*",
        "rds:List*"
      ]
      resources = ["*"]
    }
  }
  dynamic "statement" {
    for_each = var.dai_lens_data_crawler.block_health_access ? [] : [""]

    content {
      effect = "Allow"
      actions = [
        "health:DescribeEvents",
        "health:DescribeEventDetails",
        "health:DescribeAffectedEntities"
      ]
      resources = ["*"]
    }
  }
}
resource "aws_iam_policy" "dai_data_crawler_policy" {
  count = var.dai_lens_data_crawler.create ? 1 : 0

  name        = "dai-data-crawler-policy"
  description = "Read-only access to RDS and AWS Health"

  policy = data.aws_iam_policy_document.dai_data_crawler_policy[0].json
}
resource "aws_iam_role_policy_attachment" "attach_data_crawler_policy" {
  count = var.dai_lens_data_crawler.create ? 1 : 0

  role       = aws_iam_role.dai_data_crawler[0].name
  policy_arn = aws_iam_policy.dai_data_crawler_policy[0].arn
}
