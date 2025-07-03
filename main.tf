#
## DAI Lens Data Crawler
data "aws_iam_policy_document" "dai_lens_data_crawler_assume_role_policy" {
  count = var.dai_lens_data_crawler.create ? 1 : 0

  dynamic "statement" {
    for_each = [""]

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.dai_lens_data_crawler.trusted_role_arns

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = "AWS"
        identifiers = [statement.value]
      }
    }
  }
}
resource "aws_iam_role" "dai_data_crawler" {
  count = var.dai_lens_data_crawler.create ? 1 : 0

  name        = "${var.dai_lens_data_crawler.nameprefix}dai-lens-data-crawler"
  description = "Grants access to DAI Lens in RDS and AWS Health"

  assume_role_policy = data.aws_iam_policy_document.dai_lens_data_crawler_assume_role_policy[0].json
}
## Policy for RDS read-only + AWS Health read
data "aws_iam_policy_document" "dai_data_crawler_policy" {
  count = var.dai_lens_data_crawler.create ? 1 : 0

  dynamic "statement" {
    for_each = var.dai_lens_data_crawler.disable_rds_access ? [] : [""]

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
    for_each = var.dai_lens_data_crawler.disable_health_access ? [] : [""]

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

  name        = "${var.dai_lens_data_crawler.nameprefix}dai-lens-data-crawler"
  description = "Read-only access to RDS and AWS Health"

  policy = data.aws_iam_policy_document.dai_data_crawler_policy[0].json
}
resource "aws_iam_role_policy_attachment" "attach_data_crawler_policy" {
  count = var.dai_lens_data_crawler.create ? 1 : 0

  role       = aws_iam_role.dai_data_crawler[0].name
  policy_arn = aws_iam_policy.dai_data_crawler_policy[0].arn
}
