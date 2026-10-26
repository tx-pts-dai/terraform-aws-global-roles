mock_provider "aws" {
  override_data {
    target = data.aws_iam_policy_document.devops_agent_assume_role_policy[0]
    values = {
      json = <<-JSON
        {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": { "Service": "aidevops.amazonaws.com" },
            "Action": "sts:AssumeRole"
          }]
        }
      JSON
    }
  }

  override_data {
    target = data.aws_iam_policy_document.devops_agent_policy[0]
    values = {
      json = <<-JSON
        {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
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
    condition     = length(aws_iam_role.devops_agent) == 0
    error_message = "Role should not be created by default"
  }
}

run "creates_role_when_enabled" {
  command = plan

  variables {
    devops_agent = {
      create = true
    }
  }

  assert {
    condition     = aws_iam_role.devops_agent[0].name == "devops-agent"
    error_message = "Role name should be 'devops-agent'"
  }
}

run "creates_role_with_prefix" {
  command = plan

  variables {
    devops_agent = {
      create     = true
      nameprefix = "prod-"
    }
  }

  assert {
    condition     = aws_iam_role.devops_agent[0].name == "prod-devops-agent"
    error_message = "Role name should include prefix"
  }
}

run "trusts_ai_platform_and_dai_accounts_by_default" {
  command = plan

  variables {
    devops_agent = {
      create = true
    }
  }

  assert {
    condition     = toset(var.devops_agent.trusted_account_ids) == toset(["017421875774", "464176558764", "851725213542", "730335665754"])
    error_message = "The AI Platform and DAI central accounts should be trusted by default"
  }
}

run "attaches_devops_agent_access_policy" {
  command = plan

  variables {
    devops_agent = {
      create = true
    }
  }

  assert {
    condition     = aws_iam_role_policy_attachment.devops_agent_access[0].policy_arn == "arn:aws:iam::aws:policy/AIDevOpsAgentAccessPolicy"
    error_message = "AIDevOpsAgentAccessPolicy managed policy should be attached"
  }
}

run "outputs_role_info" {
  command = plan

  variables {
    devops_agent = {
      create = true
    }
  }

  assert {
    condition     = output.devops_agent != null
    error_message = "Output should not be null when role is created"
  }
}

run "outputs_null_when_disabled" {
  command = plan

  assert {
    condition     = output.devops_agent == null
    error_message = "Output should be null when role is not created"
  }
}
