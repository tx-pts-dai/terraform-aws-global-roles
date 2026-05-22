variable "backup_monitor_crawler" {
  description = <<-EOT
    Configuration for the backup monitor crawler IAM role and permissions.

    - create            : Whether to create the IAM role and policies.
    - nameprefix        : Prefix for the IAM role name and policy.
    - trusted_role_arns : List of ARNs for roles that can assume this role (e.g. the backup monitor Lambda execution role).
  EOT

  type = object({
    create            = optional(bool, false)
    nameprefix        = optional(string, "")
    trusted_role_arns = optional(list(string), [])
  })
  default = {}
}

variable "dai_lens_data_crawler" {
  description = <<-EOT
    Configuration for the DAI Lens data crawler IAM role and permissions"

    - create                : Whether to create the IAM role and policies.
    - nameprefix            : Prefix for the IAM role name and policy.
    - disable_rds_access    : If true, disables access to RDS resources.
    - disable_health_access : If true, disables access to AWS Health resources.
    - trusted_role_arns     : List of ARNs for roles that can assume this role.
  EOT

  type = object({
    create                = optional(bool, false)
    nameprefix            = optional(string, "")
    disable_rds_access    = optional(bool, false)
    disable_health_access = optional(bool, false)
    trusted_role_arns     = optional(list(string), [])
  })
  default = {}
}

variable "gotthard" {
  description = <<-EOT
    Configuration for the Gotthard IAM role.
    This role grants broad read-only access for the Gotthard AI agent to detect issues
    within AWS accounts. Secret values cannot be read as ReadOnlyAccess excludes GetSecretValue.

    - create            : Whether to create the IAM role and policies.
    - nameprefix        : Prefix for the IAM role name and policy.
    - trusted_role_arns : List of role ARNs that can assume this role. Each ARN's account is
                          trusted at the root level with an aws:PrincipalArn condition scoped
                          to the exact ARN (e.g. the Gotthard AI agent role).
  EOT

  type = object({
    create            = optional(bool, false)
    nameprefix        = optional(string, "")
    trusted_role_arns = optional(list(string), [])
  })
  default = {}
}

variable "terraform_execution_role" {
  description = <<-EOT
    Configuration for the Terraform execution IAM role. This role is assumed by
    GitHub Actions OIDC roles to run Terraform, separating authentication from authorization.

    - create                        : Whether to create the IAM role (default: true).
    - github_actions_oidc_role_name : Name of the GitHub Actions OIDC role in the current account (default: "cicd-iac").
    - external_trusted_arns         : List of external role ARNs that can assume this role (cross-account access).
    - policy_arns                   : List of managed policy ARNs to attach.
    - permissions_boundary          : ARN of permissions boundary policy (optional).
  EOT

  type = object({
    create                        = optional(bool, true)
    github_actions_oidc_role_name = optional(string, "cicd-iac")
    external_trusted_arns         = optional(list(string), [])
    policy_arns                   = optional(list(string), ["arn:aws:iam::aws:policy/AdministratorAccess"])
    permissions_boundary          = optional(string, null)
  })
  default = {}
}

variable "grafana_athena_role" {
  description = <<-EOT
    Configuration for the Grafana Athena IAM role.

    - create                : Whether to create the IAM role and policies.
    - nameprefix            : Prefix for the IAM role name and policy.
    - trusted_role_arns     : List of ARNs for roles that can assume this role (e.g. the Grafana data source Lambda execution role).
    - athena_source_buckets : List of S3 bucket ARNs that the crawler can read from (for Athena queries). Remember to include both the bucket ARN and the bucket ARN with /* for objects.
    - athena_cache_buckets  : List of S3 bucket ARNs for Athena query results. Remember to include both the bucket ARN and the bucket ARN with /* for objects.
    - athena_resources      : List of ARNs for Athena resources (e.g. workgroups) that the role can access.
    - glue_resources        : List of ARNs for Glue resources (e.g. databases, tables) that the role can access.
  EOT

  type = object({
    create                = optional(bool, false)
    nameprefix            = optional(string, "")
    trusted_role_arns     = optional(list(string), [])
    athena_source_buckets = optional(list(string), [])
    athena_cache_buckets  = optional(list(string), [])
    athena_resources      = optional(list(string), ["*"])
    glue_resources        = optional(list(string), ["*"])
  })
  default = {}

  # if create is true, then resources and buckets must be provided and cannot be empty
  validation {
    condition = !(var.grafana_athena_role.create) || (
      (length(var.grafana_athena_role.athena_source_buckets) > 0) &&
      (length(var.grafana_athena_role.athena_cache_buckets) > 0)
    )
    error_message = "If grafana_athena_role.create is true, then athena_source_buckets and athena_cache_buckets must be provided and cannot be empty."
  }
}
