terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Terraform  = "true"
      GithubRepo = "terraform-aws-global-roles"
      GithubOrg  = "tx-pts-dai"
      Example    = "complete"
    }
  }
}

module "global_roles" {
  source = "../../"

  # Terraform Execution Role (enabled by default)
  # This role is assumed by the GitHub Actions OIDC role to run Terraform
  terraform_execution_role = {
    # Trusts the cicd-iac OIDC role in the current account by default
    github_actions_oidc_role_name = "cicd-iac"

    # Allow cross-account access from other DAI managed accounts
    external_trusted_arns = [
      # "arn:aws:iam::111111111111:role/terraform-execution",
      # "arn:aws:iam::222222222222:role/terraform-execution",
    ]

    # Attach managed policies
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]

    # Optional: Set a permissions boundary
    # permissions_boundary = "arn:aws:iam::123456789012:policy/TerraformBoundary"
  }

  # DAI Lens Data Crawler Role (disabled by default)
  dai_lens_data_crawler = {
    create = true

    # Allow DAI Lens to assume this role
    trusted_role_arns = [
      # "arn:aws:iam::123456789012:role/dai-lens-crawler",
    ]

    # Optionally disable specific permissions
    # disable_rds_access    = true
    # disable_health_access = true
  }
}
