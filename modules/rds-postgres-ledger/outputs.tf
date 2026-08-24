output "endpoint" {
  description = "Connection endpoint for the ledger database."
  value       = aws_db_instance.this.endpoint
}

output "security_group_id" {
  description = "Security group guarding the database."
  value       = aws_security_group.this.id
}
