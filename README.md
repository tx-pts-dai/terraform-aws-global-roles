# My Global Roles

This module provides some global IAM Roles and Policies to be used across single or multiple AWS Accounts.

## Usage

```tf
module "global_roles" {
  source  = "tx-pts-dai/global-roles/aws"
  version = "~> 1.0"

  # Terraform Execution Role (enabled by default)
  terraform_execution_role = {
    github_actions_oidc_role_name = "cicd-iac"
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
  }

  # Backup Monitor Crawler Role (disabled by default)
  backup_monitor_crawler = {
    create = true
    trusted_role_arns = [
      "arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>",
    ]
  }

  # DAI Lens Data Crawler Role (disabled by default)
  dai_lens_data_crawler = {
    create = true
    trusted_role_arns = [
      "arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>",
    ]
  }
}
```

## Explanation and description of interesting use-cases

< create a h2 chapter for each section explaining special module concepts >

## Examples

< if the folder `examples/` exists, put here the link to the examples subfolders with their descriptions >

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.backup_monitor_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dai_data_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.backup_monitor_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.dai_data_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.gotthard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.terraform_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach_backup_monitor_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_data_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.gotthard_readonly_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraform_execution_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.backup_monitor_crawler_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.backup_monitor_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dai_data_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dai_lens_data_crawler_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gotthard_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.terraform_execution_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_backup_monitor_crawler"></a> [backup\_monitor\_crawler](#input\_backup\_monitor\_crawler) | Configuration for the backup monitor crawler IAM role and permissions.<br/><br/>- create            : Whether to create the IAM role and policies.<br/>- nameprefix        : Prefix for the IAM role name and policy.<br/>- trusted\_role\_arns : List of ARNs for roles that can assume this role (e.g. the backup monitor Lambda execution role). | <pre>object({<br/>    create            = optional(bool, false)<br/>    nameprefix        = optional(string, "")<br/>    trusted_role_arns = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_dai_lens_data_crawler"></a> [dai\_lens\_data\_crawler](#input\_dai\_lens\_data\_crawler) | Configuration for the DAI Lens data crawler IAM role and permissions"<br/><br/>- create                : Whether to create the IAM role and policies.<br/>- nameprefix            : Prefix for the IAM role name and policy.<br/>- disable\_rds\_access    : If true, disables access to RDS resources.<br/>- disable\_health\_access : If true, disables access to AWS Health resources.<br/>- trusted\_role\_arns     : List of ARNs for roles that can assume this role. | <pre>object({<br/>    create                = optional(bool, false)<br/>    nameprefix            = optional(string, "")<br/>    disable_rds_access    = optional(bool, false)<br/>    disable_health_access = optional(bool, false)<br/>    trusted_role_arns     = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_gotthard"></a> [gotthard](#input\_gotthard) | Configuration for the Gotthard IAM role.<br/>This role grants broad read-only access for the Gotthard AI agent to detect issues<br/>within AWS accounts. Secret values cannot be read as ReadOnlyAccess excludes GetSecretValue.<br/><br/>- create            : Whether to create the IAM role and policies.<br/>- nameprefix        : Prefix for the IAM role name and policy.<br/>- trusted\_role\_arns : List of role ARNs that can assume this role. Each ARN's account is<br/>                      trusted at the root level with an aws:PrincipalArn condition scoped<br/>                      to the exact ARN (e.g. the Gotthard AI agent role). | <pre>object({<br/>    create            = optional(bool, false)<br/>    nameprefix        = optional(string, "")<br/>    trusted_role_arns = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_terraform_execution_role"></a> [terraform\_execution\_role](#input\_terraform\_execution\_role) | Configuration for the Terraform execution IAM role. This role is assumed by<br/>GitHub Actions OIDC roles to run Terraform, separating authentication from authorization.<br/><br/>- create                        : Whether to create the IAM role (default: true).<br/>- github\_actions\_oidc\_role\_name : Name of the GitHub Actions OIDC role in the current account (default: "cicd-iac").<br/>- external\_trusted\_arns         : List of external role ARNs that can assume this role (cross-account access).<br/>- policy\_arns                   : List of managed policy ARNs to attach.<br/>- permissions\_boundary          : ARN of permissions boundary policy (optional). | <pre>object({<br/>    create                        = optional(bool, true)<br/>    github_actions_oidc_role_name = optional(string, "cicd-iac")<br/>    external_trusted_arns         = optional(list(string), [])<br/>    policy_arns                   = optional(list(string), ["arn:aws:iam::aws:policy/AdministratorAccess"])<br/>    permissions_boundary          = optional(string, null)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backup_monitor_crawler"></a> [backup\_monitor\_crawler](#output\_backup\_monitor\_crawler) | Values for the backup monitor crawler IAM role |
| <a name="output_dai_data_crawler"></a> [dai\_data\_crawler](#output\_dai\_data\_crawler) | values for the DAI Lens data crawler IAM role |
| <a name="output_gotthard"></a> [gotthard](#output\_gotthard) | Values for the Gotthard IAM role |
| <a name="output_terraform_execution"></a> [terraform\_execution](#output\_terraform\_execution) | Values for the Terraform execution IAM role |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Alfredo Gottardo](https://github.com/AlfGot), [David Beauvererd](https://github.com/Davidoutz), [Davide Cammarata](https://github.com/DCamma), [Francisco Ferreira](https://github.com/cferrera),  [Roland Bapst](https://github.com/rbapst-tamedia), [Samuel Wibrow](https://github.com/swibrow) and [Christian Jürges](https://github.com/chrisamti)

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.
