variable "name" {
  description = "Identifier for the ledger database."
  type        = string
}

variable "vpc_id" {
  description = "VPC the database lives in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.medium"
}

variable "master_username" {
  description = "Master username."
  type        = string
  default     = "ledger_admin"
}

# [FINDING 2] Removed in v2 in favour of manage_master_user_password.
variable "master_password" {
  description = "Master password. Do not use in production."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
