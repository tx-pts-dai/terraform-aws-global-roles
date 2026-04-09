mock_provider "aws" {
  override_data {
    target = data.aws_iam_policy_document.gotthard_assume_role_policy[0]
    values = {
      json = <<-JSON
        {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": { "AWS": "arn:aws:iam::123456789012:root" },
            "Action": "sts:AssumeRole",
            "Condition": {
              "ArnLike": { "aws:PrincipalArn": "arn:aws:iam::123456789012:role/gotthard-ai-agent" }
            }
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
    condition     = length(aws_iam_role.gotthard) == 0
    error_message = "Role should not be created by default"
  }
}

run "creates_role_when_enabled" {
  command = plan

  variables {
    gotthard = {
      create = true
    }
  }

  assert {
    condition     = aws_iam_role.gotthard[0].name == "gotthard"
    error_message = "Role name should be 'gotthard'"
  }
}

run "creates_role_with_prefix" {
  command = plan

  variables {
    gotthard = {
      create     = true
      nameprefix = "prod-"
    }
  }

  assert {
    condition     = aws_iam_role.gotthard[0].name == "prod-gotthard"
    error_message = "Role name should include prefix"
  }
}

run "attaches_readonly_access_policy" {
  command = plan

  variables {
    gotthard = {
      create = true
    }
  }

  assert {
    condition     = aws_iam_role_policy_attachment.gotthard_readonly_access[0].policy_arn == "arn:aws:iam::aws:policy/ReadOnlyAccess"
    error_message = "ReadOnlyAccess managed policy should be attached"
  }
}

run "outputs_role_info" {
  command = plan

  variables {
    gotthard = {
      create = true
    }
  }

  assert {
    condition     = output.gotthard != null
    error_message = "Output should not be null when role is created"
  }
}

run "outputs_null_when_disabled" {
  command = plan

  assert {
    condition     = output.gotthard == null
    error_message = "Output should be null when role is not created"
  }
}
