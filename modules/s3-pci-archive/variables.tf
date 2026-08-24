variable "name" {
  description = "Bucket name. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{2,62}$", var.name))
    error_message = "Bucket name must be lowercase, 3-63 chars, and start alphanumeric."
  }
}

variable "retention_days" {
  description = "Days to retain archived statements before expiry."
  type        = number
  default     = 2555 # ~7 years

  validation {
    condition     = var.retention_days >= 2555
    error_message = "Retention below 7 years (2555 days) is not permitted for statement archives."
  }
}

variable "tags" {
  description = "Additional tags merged over the module's mandatory tags."
  type        = map(string)
  default     = {}
}
