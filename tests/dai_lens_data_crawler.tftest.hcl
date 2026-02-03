mock_provider "aws" {
  override_data {
    target = data.aws_iam_policy_document.dai_lens_data_crawler_assume_role_policy[0]
    values = {
      json = <<-JSON
        {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": { "Service": "ec2.amazonaws.com" },
            "Action": "sts:AssumeRole"
          }]
        }
      JSON
    }
  }

  override_data {
    target = data.aws_iam_policy_document.dai_data_crawler_policy[0]
    values = {
      json = <<-JSON
        {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Action": ["rds:Describe*", "rds:List*"],
            "Resource": "*"
          }]
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
    condition     = length(aws_iam_role.dai_data_crawler) == 0
    error_message = "Role should not be created by default"
  }
}

run "creates_role_when_enabled" {
  command = plan

  variables {
    dai_lens_data_crawler = {
      create = true
    }
  }

  assert {
    condition     = aws_iam_role.dai_data_crawler[0].name == "dai-lens-data-crawler"
    error_message = "Role name should be 'dai-lens-data-crawler'"
  }
}

run "creates_role_with_prefix" {
  command = plan

  variables {
    dai_lens_data_crawler = {
      create     = true
      nameprefix = "prod-"
    }
  }

  assert {
    condition     = aws_iam_role.dai_data_crawler[0].name == "prod-dai-lens-data-crawler"
    error_message = "Role name should include prefix"
  }
}

run "creates_policy_with_rds_and_health" {
  command = plan

  variables {
    dai_lens_data_crawler = {
      create = true
    }
  }

  assert {
    condition     = aws_iam_policy.dai_data_crawler_policy[0].name == "dai-lens-data-crawler"
    error_message = "Policy should be created"
  }
}

run "outputs_role_info" {
  command = plan

  variables {
    dai_lens_data_crawler = {
      create = true
    }
  }

  assert {
    condition     = output.dai_data_crawler != null
    error_message = "Output should not be null when role is created"
  }
}

run "outputs_null_when_disabled" {
  command = plan

  assert {
    condition     = output.dai_data_crawler == null
    error_message = "Output should be null when role is not created"
  }
}
