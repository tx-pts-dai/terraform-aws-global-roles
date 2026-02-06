# My Global Roles

This module provides some global IAM Roles and Policies to be used across single or multiple AWS Accounts.

## Usage

```tf
module "global_roles" {
  source  = "tx-pts-dai/global-roles/aws
  version = "1.0.0

  dai_lens_data_crawler = {
    create = true
    trusted_role_arns = [
      "arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>"
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
| [aws_iam_policy.dai_data_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.dai_data_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.terraform_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach_data_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraform_execution_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.dai_data_crawler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dai_lens_data_crawler_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.terraform_execution_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dai_lens_data_crawler"></a> [dai\_lens\_data\_crawler](#input\_dai\_lens\_data\_crawler) | Configuration for the DAI Lens data crawler IAM role and permissions"<br/><br/>- create                : Whether to create the IAM role and policies.<br/>- nameprefix            : Prefix for the IAM role name and policy.<br/>- disable\_rds\_access    : If true, disables access to RDS resources.<br/>- disable\_health\_access : If true, disables access to AWS Health resources.<br/>- trusted\_role\_arns     : List of ARNs for roles that can assume this role. | <pre>object({<br/>    create                = optional(bool, false)<br/>    nameprefix            = optional(string, "")<br/>    disable_rds_access    = optional(bool, false)<br/>    disable_health_access = optional(bool, false)<br/>    trusted_role_arns     = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_terraform_execution_role"></a> [terraform\_execution\_role](#input\_terraform\_execution\_role) | Configuration for the Terraform execution IAM role. This role is assumed by<br/>GitHub Actions OIDC roles to run Terraform, separating authentication from authorization.<br/><br/>- create                        : Whether to create the IAM role (default: true).<br/>- github\_actions\_oidc\_role\_name : Name of the GitHub Actions OIDC role in the current account (default: "cicd-iac").<br/>- external\_trusted\_arns         : List of external role ARNs that can assume this role (cross-account access).<br/>- policy\_arns                   : List of managed policy ARNs to attach.<br/>- permissions\_boundary          : ARN of permissions boundary policy (optional). | <pre>object({<br/>    create                        = optional(bool, true)<br/>    github_actions_oidc_role_name = optional(string, "cicd-iac")<br/>    external_trusted_arns         = optional(list(string), [])<br/>    policy_arns                   = optional(list(string), ["arn:aws:iam::aws:policy/AdministratorAccess"])<br/>    permissions_boundary          = optional(string, null)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dai_data_crawler"></a> [dai\_data\_crawler](#output\_dai\_data\_crawler) | values for the DAI Lens data crawler IAM role |
| <a name="output_terraform_execution"></a> [terraform\_execution](#output\_terraform\_execution) | Values for the Terraform execution IAM role |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Alfredo Gottardo](https://github.com/AlfGot), [David Beauvererd](https://github.com/Davidoutz), [Davide Cammarata](https://github.com/DCamma), [Francisco Ferreira](https://github.com/cferrera),  [Roland Bapst](https://github.com/rbapst-tamedia) and [Samuel Wibrow](https://github.com/swibrow)

## License

Apache 2 Licensed. See [LICENSE](< link to license file >) for full details.
