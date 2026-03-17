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
    ]

    # Attach managed policies
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]

    # Optional: Set a permissions boundary
    # permissions_boundary = "arn:aws:iam::123456789012:policy/TerraformBoundary"
  }

  # Cross-account roles — add one entry per tool that needs to crawl this account
  cross_account_roles = {
    # DAI Lens data crawler: reads RDS metadata and AWS Health events
    "dai-lens-data-crawler" = {
      description       = "Grants DAI Lens read access to RDS and AWS Health"
      trusted_role_arns = ["arn:aws:iam::730335665754:role/dai-lens"]
      policy_statements = [
        {
          sid     = "RDSReadOnly"
          actions = ["rds:Describe*", "rds:List*"]
        },
        {
          sid     = "HealthReadOnly"
          actions = ["health:DescribeEvents", "health:DescribeEventDetails", "health:DescribeAffectedEntities"]
        },
      ]
    }

    # Backup monitor crawler: reads RDS backup and copy job status
    "backup-monitor-crawler" = {
      description       = "Grants shared-backups-monitoring read access to RDS backup jobs"
      trusted_role_arns = ["arn:aws:iam::730335665754:role/backup-monitor"]
      policy_statements = [
        {
          sid     = "RDSReadOnly"
          actions = ["rds:Describe*", "rds:List*", "rds:ListTagsForResource"]
        },
        {
          sid     = "BackupReadOnly"
          actions = ["backup:ListBackupJobs", "backup:ListCopyJobs"]
        },
        {
          sid     = "KMSDescribe"
          actions = ["kms:DescribeKey"]
        },
      ]
    }
  }
}
