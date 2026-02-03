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

#
## Terraform Execution Role
data "aws_caller_identity" "current" {
  count = var.terraform_execution_role.create ? 1 : 0
}

locals {
  # Build the GitHub Actions OIDC role ARN from the current account
  github_actions_oidc_arn = var.terraform_execution_role.create ? "arn:aws:iam::${data.aws_caller_identity.current[0].account_id}:role/${var.terraform_execution_role.github_actions_oidc_role_name}" : ""

  # Combine GitHub Actions OIDC role with any external trusted ARNs
  all_trusted_arns = var.terraform_execution_role.create ? concat(
    [local.github_actions_oidc_arn],
    var.terraform_execution_role.external_trusted_arns
  ) : []
}

data "aws_iam_policy_document" "terraform_execution_assume_role_policy" {
  count = var.terraform_execution_role.create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = local.all_trusted_arns
    }
  }
}

resource "aws_iam_role" "terraform_execution" {
  count = var.terraform_execution_role.create ? 1 : 0

  name                 = "terraform-execution"
  description          = "Role for Terraform execution, assumed by GitHub Actions OIDC roles"
  assume_role_policy   = data.aws_iam_policy_document.terraform_execution_assume_role_policy[0].json
  permissions_boundary = var.terraform_execution_role.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "terraform_execution_policies" {
  count = var.terraform_execution_role.create ? length(var.terraform_execution_role.policy_arns) : 0

  role       = aws_iam_role.terraform_execution[0].name
  policy_arn = var.terraform_execution_role.policy_arns[count.index]
}
