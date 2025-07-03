variable "dai_lens_data_crawler" {
  description = <<-EOT
    Configuration for the DAI Lens data crawler IAM role and permissions"

    - create              : Whether to create the IAM role and policies.
    - block_rds_access    : If true, blocks access to RDS resources.
    - block_health_access : If true, blocks access to AWS Health resources.
    - trusted_role_arns   : List of ARNs for roles that can assume this role.
  EOT

  type = object({
    create              = optional(bool, false)
    block_rds_access    = optional(bool, true)
    block_health_access = optional(bool, true)
    trusted_role_arns   = optional(list(string), [])
  })
  default = {
    create              = false
    block_rds_access    = true
    block_health_access = true
    trusted_role_arns   = []
  }
}
