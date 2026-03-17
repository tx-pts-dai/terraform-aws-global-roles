mock_provider "aws" {}

variables {
  terraform_execution_role = {
    create = false
  }
}

run "does_not_create_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_role.cross_account) == 0
    error_message = "No roles should be created when cross_account_roles is empty"
  }
}

run "creates_single_role" {
  command = plan

  variables {
    cross_account_roles = {
      "my-crawler" = {
        trusted_role_arns = ["arn:aws:iam::123456789012:role/my-service"]
        policy_statements = [
          { actions = ["s3:GetObject"], resources = ["arn:aws:s3:::my-bucket/*"] }
        ]
      }
    }
  }

  override_data {
    target = data.aws_iam_policy_document.cross_account_assume["my-crawler"]
    values = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  override_data {
    target = data.aws_iam_policy_document.cross_account_policy["my-crawler"]
    values = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  assert {
    condition     = aws_iam_role.cross_account["my-crawler"].name == "my-crawler"
    error_message = "Role name should match map key"
  }

  assert {
    condition     = aws_iam_policy.cross_account["my-crawler"].name == "my-crawler"
    error_message = "Policy name should match map key"
  }
}

run "creates_multiple_roles" {
  command = plan

  variables {
    cross_account_roles = {
      "dai-lens-data-crawler" = {
        trusted_role_arns = ["arn:aws:iam::111111111111:role/dai-lens"]
        policy_statements = [
          { actions = ["rds:Describe*", "rds:List*"] },
          { actions = ["health:DescribeEvents", "health:DescribeEventDetails", "health:DescribeAffectedEntities"] },
        ]
      }
      "backup-monitor-crawler" = {
        trusted_role_arns = ["arn:aws:iam::222222222222:role/backup-monitor"]
        policy_statements = [
          { actions = ["rds:Describe*", "rds:List*", "rds:ListTagsForResource"] },
          { actions = ["backup:ListBackupJobs", "backup:ListCopyJobs"] },
          { actions = ["kms:DescribeKey"] },
        ]
      }
    }
  }

  override_data {
    target = data.aws_iam_policy_document.cross_account_assume["dai-lens-data-crawler"]
    values = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  override_data {
    target = data.aws_iam_policy_document.cross_account_policy["dai-lens-data-crawler"]
    values = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  override_data {
    target = data.aws_iam_policy_document.cross_account_assume["backup-monitor-crawler"]
    values = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  override_data {
    target = data.aws_iam_policy_document.cross_account_policy["backup-monitor-crawler"]
    values = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  assert {
    condition     = length(aws_iam_role.cross_account) == 2
    error_message = "Should create 2 roles"
  }

  assert {
    condition     = aws_iam_role.cross_account["dai-lens-data-crawler"].name == "dai-lens-data-crawler"
    error_message = "dai-lens-data-crawler role should exist"
  }

  assert {
    condition     = aws_iam_role.cross_account["backup-monitor-crawler"].name == "backup-monitor-crawler"
    error_message = "backup-monitor-crawler role should exist"
  }
}

run "outputs_all_roles" {
  command = plan

  variables {
    cross_account_roles = {
      "test-crawler" = {
        trusted_role_arns = ["arn:aws:iam::123456789012:role/test"]
        policy_statements = [
          { actions = ["s3:ListBucket"] }
        ]
      }
    }
  }

  override_data {
    target = data.aws_iam_policy_document.cross_account_assume["test-crawler"]
    values = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  override_data {
    target = data.aws_iam_policy_document.cross_account_policy["test-crawler"]
    values = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  assert {
    condition     = length(output.cross_account_roles) == 1
    error_message = "Output should contain 1 role"
  }

  assert {
    condition     = output.cross_account_roles["test-crawler"] != null
    error_message = "Output should contain the created role"
  }
}
