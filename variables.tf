variable "cross_account_roles" {
  description = <<-EOT
    Map of cross-account IAM roles to create. Each entry creates a role
    that trusted principals can assume, with an inline policy built from
    the provided statements.

    - trusted_role_arns : List of IAM role ARNs allowed to assume this role.
    - description       : Human-readable description for the role and policy.
    - policy_statements : List of IAM policy statements to attach.
      - sid       : Optional statement ID.
      - effect    : "Allow" or "Deny" (default: "Allow").
      - actions   : List of IAM actions.
      - resources : List of resource ARNs (default: ["*"]).
  EOT

  type = map(object({
    trusted_role_arns = optional(list(string), [])
    description       = optional(string, "Cross-account IAM role")
    policy_statements = list(object({
      sid       = optional(string, null)
      effect    = optional(string, "Allow")
      actions   = list(string)
      resources = optional(list(string), ["*"])
    }))
  }))

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
