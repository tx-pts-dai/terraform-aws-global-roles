mock_provider "aws" {
  override_data {
    target = data.aws_iam_policy_document.backup_monitor_crawler_assume_role_policy[0]
    values = {
      json = <<-JSON
        {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": { "AWS": "arn:aws:iam::123456789012:role/backup-monitor-lambda-role" },
            "Action": "sts:AssumeRole"
          }]
        }
      JSON
    }
  }

  override_data {
    target = data.aws_iam_policy_document.backup_monitor_crawler_policy[0]
    values = {
      json = <<-JSON
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": ["rds:DescribeDBInstances", "rds:DescribeDBClusters"],
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Action": ["tag:GetResources"],
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Action": ["backup:ListBackupJobs", "backup:ListCopyJobs"],
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Action": ["kms:DescribeKey"],
              "Resource": "*"
            }
          ]
        }
      JSON
    }
  }
}

variables {
  terraform_execution_role = {
    create = false
  }
}

run "does_not_create_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_role.backup_monitor_crawler) == 0
    error_message = "Role should not be created by default"
  }
}

run "creates_role_when_enabled" {
  command = plan

  variables {
    backup_monitor_crawler = {
      create = true
    }
  }

  assert {
    condition     = aws_iam_role.backup_monitor_crawler[0].name == "backup-monitor-crawler"
    error_message = "Role name should be 'backup-monitor-crawler'"
  }
}

run "creates_role_with_prefix" {
  command = plan

  variables {
    backup_monitor_crawler = {
      create     = true
      nameprefix = "prod-"
    }
  }

  assert {
    condition     = aws_iam_role.backup_monitor_crawler[0].name == "prod-backup-monitor-crawler"
    error_message = "Role name should include prefix"
  }
}

run "creates_policy" {
  command = plan

  variables {
    backup_monitor_crawler = {
      create = true
    }
  }

  assert {
    condition     = aws_iam_policy.backup_monitor_crawler_policy[0].name == "backup-monitor-crawler"
    error_message = "Policy should be created"
  }
}

run "outputs_role_info" {
  command = plan

  variables {
    backup_monitor_crawler = {
      create = true
    }
  }

  assert {
    condition     = output.backup_monitor_crawler != null
    error_message = "Output should not be null when role is created"
  }
}

run "outputs_null_when_disabled" {
  command = plan

  assert {
    condition     = output.backup_monitor_crawler == null
    error_message = "Output should be null when role is not created"
  }
}
