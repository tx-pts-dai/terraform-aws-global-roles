#
## Cross-Account Roles
data "aws_iam_policy_document" "cross_account_assume" {
  for_each = var.cross_account_roles

  dynamic "statement" {
    for_each = length(each.value.trusted_role_arns) > 0 ? [each.value.trusted_role_arns] : []

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = "AWS"
        identifiers = statement.value
      }
    }
  }
}

data "aws_iam_policy_document" "cross_account_policy" {
  for_each = var.cross_account_roles

  dynamic "statement" {
    for_each = each.value.policy_statements

    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_role" "cross_account" {
  for_each = var.cross_account_roles

  name               = each.key
  description        = each.value.description
  assume_role_policy = data.aws_iam_policy_document.cross_account_assume[each.key].json
}

resource "aws_iam_policy" "cross_account" {
  for_each = var.cross_account_roles

  name        = each.key
  description = each.value.description
  policy      = data.aws_iam_policy_document.cross_account_policy[each.key].json
}

resource "aws_iam_role_policy_attachment" "cross_account" {
  for_each = var.cross_account_roles

  role       = aws_iam_role.cross_account[each.key].name
  policy_arn = aws_iam_policy.cross_account[each.key].arn
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
