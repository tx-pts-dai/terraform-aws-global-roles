# terraform-aws-global-roles

This module provisions IAM roles to be deployed across AWS accounts. It supports two patterns:

- **Cross-account roles** — roles that a trusted service (e.g. a Lambda or EKS pod in a hub account) can assume in spoke accounts to read data. Add one entry per tool; no module changes required.
- **Terraform execution role** — a role assumed by GitHub Actions via OIDC to run Terraform in the account.

## Usage

```hcl
module "global_roles" {
  source  = "tx-pts-dai/global-roles/aws"
  version = "~> 2.0"

  # Cross-account roles — one entry per tool that needs access to this account
  cross_account_roles = {
    "dai-lens-data-crawler" = {
      description       = "Grants DAI Lens read access to RDS and AWS Health"
      trusted_role_arns = ["arn:aws:iam::<HUB_ACCOUNT_ID>:role/dai-lens"]
      policy_statements = [
        { actions = ["rds:Describe*", "rds:List*"] },
        { actions = ["health:DescribeEvents", "health:DescribeEventDetails", "health:DescribeAffectedEntities"] },
      ]
    }
    "backup-monitor-crawler" = {
      description       = "Grants shared-backups-monitoring read access to RDS backup jobs"
      trusted_role_arns = ["arn:aws:iam::<HUB_ACCOUNT_ID>:role/backup-monitor"]
      policy_statements = [
        { actions = ["rds:Describe*", "rds:List*", "rds:ListTagsForResource"] },
        { actions = ["backup:ListBackupJobs", "backup:ListCopyJobs"] },
        { actions = ["kms:DescribeKey"] },
      ]
    }
  }

  # Terraform execution role (enabled by default, trusts cicd-iac OIDC role)
  terraform_execution_role = {
    policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }
}
```

## Migration from v1

The `dai_lens_data_crawler` variable has been removed. Migrate to `cross_account_roles`:

```hcl
# Before (v1)
dai_lens_data_crawler = {
  create            = true
  trusted_role_arns = ["arn:aws:iam::<ID>:role/dai-lens"]
}

# After (v2)
cross_account_roles = {
  "dai-lens-data-crawler" = {
    trusted_role_arns = ["arn:aws:iam::<ID>:role/dai-lens"]
    policy_statements = [
      { actions = ["rds:Describe*", "rds:List*"] },
      { actions = ["health:DescribeEvents", "health:DescribeEventDetails", "health:DescribeAffectedEntities"] },
    ]
  }
}
```

> **Note:** because the resource addresses changed, run `terraform state mv` to avoid destroying and recreating the existing role:
> ```
> terraform state mv 'aws_iam_role.dai_data_crawler[0]' 'aws_iam_role.cross_account["dai-lens-data-crawler"]'
> terraform state mv 'aws_iam_policy.dai_data_crawler_policy[0]' 'aws_iam_policy.cross_account["dai-lens-data-crawler"]'
> terraform state mv 'aws_iam_role_policy_attachment.attach_data_crawler_policy[0]' 'aws_iam_role_policy_attachment.cross_account["dai-lens-data-crawler"]'
> ```

## Examples

See [`examples/complete`](./examples/complete) for a full working example with both cross-account roles and the Terraform execution role.

## Contributing

< issues and contribution guidelines for public modules >

### Pre-Commit

Installation: [install pre-commit](https://pre-commit.com/) and execute `pre-commit install`. This will generate pre-commit hooks according to the config in `.pre-commit-config.yaml`

Before submitting a PR be sure to have used the pre-commit hooks or run: `pre-commit run -a`

The `pre-commit` command will run:

- Terraform fmt
- Terraform validate
- Terraform docs
- Terraform validate with tflint
- check for merge conflicts
- fix end of files

as described in the `.pre-commit-config.yaml` file

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.cross_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cross_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.terraform_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cross_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraform_execution_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cross_account_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.terraform_execution_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cross_account_roles"></a> [cross\_account\_roles](#input\_cross\_account\_roles) | Map of cross-account IAM roles to create. Each entry creates a role<br/>that trusted principals can assume, with an inline policy built from<br/>the provided statements.<br/><br/>- trusted\_role\_arns : List of IAM role ARNs allowed to assume this role.<br/>- description       : Human-readable description for the role and policy.<br/>- policy\_statements : List of IAM policy statements to attach.<br/>  - sid       : Optional statement ID.<br/>  - effect    : "Allow" or "Deny" (default: "Allow").<br/>  - actions   : List of IAM actions.<br/>  - resources : List of resource ARNs (default: ["*"]). | <pre>map(object({<br/>    trusted_role_arns = optional(list(string), [])<br/>    description       = optional(string, "Cross-account IAM role")<br/>    policy_statements = list(object({<br/>      sid       = optional(string, null)<br/>      effect    = optional(string, "Allow")<br/>      actions   = list(string)<br/>      resources = optional(list(string), ["*"])<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_terraform_execution_role"></a> [terraform\_execution\_role](#input\_terraform\_execution\_role) | Configuration for the Terraform execution IAM role. This role is assumed by<br/>GitHub Actions OIDC roles to run Terraform, separating authentication from authorization.<br/><br/>- create                        : Whether to create the IAM role (default: true).<br/>- github\_actions\_oidc\_role\_name : Name of the GitHub Actions OIDC role in the current account (default: "cicd-iac").<br/>- external\_trusted\_arns         : List of external role ARNs that can assume this role (cross-account access).<br/>- policy\_arns                   : List of managed policy ARNs to attach.<br/>- permissions\_boundary          : ARN of permissions boundary policy (optional). | <pre>object({<br/>    create                        = optional(bool, true)<br/>    github_actions_oidc_role_name = optional(string, "cicd-iac")<br/>    external_trusted_arns         = optional(list(string), [])<br/>    policy_arns                   = optional(list(string), ["arn:aws:iam::aws:policy/AdministratorAccess"])<br/>    permissions_boundary          = optional(string, null)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cross_account_roles"></a> [cross\_account\_roles](#output\_cross\_account\_roles) | Map of created cross-account IAM roles, keyed by role name |
| <a name="output_terraform_execution"></a> [terraform\_execution](#output\_terraform\_execution) | Values for the Terraform execution IAM role |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Alfredo Gottardo](https://github.com/AlfGot), [David Beauvererd](https://github.com/Davidoutz), [Davide Cammarata](https://github.com/DCamma), [Francisco Ferreira](https://github.com/cferrera),  [Roland Bapst](https://github.com/rbapst-tamedia) and [Samuel Wibrow](https://github.com/swibrow)

## License

Apache 2 Licensed. See [LICENSE](< link to license file >) for full details.
