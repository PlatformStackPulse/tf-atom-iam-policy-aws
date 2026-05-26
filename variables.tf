# -----------------------------------------------------------------------------
# Module-Specific Variables
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the IAM policy. Defaults to module ID if not provided."
  type        = string
  default     = null
}

variable "path" {
  description = "Path for the IAM policy (e.g., /, /service-role/)"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/", var.path))
    error_message = "path must start with /."
  }
}

variable "policy" {
  description = "JSON-encoded IAM policy document"
  type        = string

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "policy must be valid JSON."
  }
}
