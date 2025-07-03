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
