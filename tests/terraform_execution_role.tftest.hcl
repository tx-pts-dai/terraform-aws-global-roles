mock_provider "aws" {
  override_data {
    target = data.aws_caller_identity.current[0]
    values = {
      account_id = "123456789012"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.terraform_execution_assume_role_policy[0]
    values = {
      json = <<-JSON
        {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": { "AWS": "arn:aws:iam::123456789012:role/cicd-iac" },
            "Action": "sts:AssumeRole"
          }]
        }
      JSON
    }
  }
}

variables {
  terraform_execution_role = {
    create = true
  }
}

run "creates_role_with_defaults" {
  command = plan

  assert {
    condition     = aws_iam_role.terraform_execution[0].name == "terraform-execution"
    error_message = "Role name should be 'terraform-execution'"
  }

  assert {
    condition     = aws_iam_role.terraform_execution[0].description == "Role for Terraform execution, assumed by GitHub Actions OIDC roles"
    error_message = "Role description is incorrect"
  }
}

run "attaches_policies" {
  command = plan

  variables {
    terraform_execution_role = {
      create      = true
      policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess", "arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.terraform_execution_policies) == 2
    error_message = "Should attach 2 policies"
  }
}

run "does_not_create_when_disabled" {
  command = plan

  variables {
    terraform_execution_role = {
      create = false
    }
  }

  assert {
    condition     = length(aws_iam_role.terraform_execution) == 0
    error_message = "Role should not be created when create = false"
  }
}

run "sets_permissions_boundary" {
  command = plan

  variables {
    terraform_execution_role = {
      create               = true
      permissions_boundary = "arn:aws:iam::123456789012:policy/boundary"
    }
  }

  assert {
    condition     = aws_iam_role.terraform_execution[0].permissions_boundary == "arn:aws:iam::123456789012:policy/boundary"
    error_message = "Permissions boundary should be set"
  }
}

run "outputs_role_info" {
  command = plan

  assert {
    condition     = output.terraform_execution != null
    error_message = "Output should not be null when role is created"
  }
}

run "outputs_null_when_disabled" {
  command = plan

  variables {
    terraform_execution_role = {
      create = false
    }
  }

  assert {
    condition     = output.terraform_execution == null
    error_message = "Output should be null when role is not created"
  }
}
