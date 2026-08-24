output "bucket_id" {
  description = "Name of the archive bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the archive bucket."
  value       = aws_s3_bucket.this.arn
}

output "kms_key_arn" {
  description = "ARN of the CMK encrypting the archive."
  value       = aws_kms_key.archive.arn
}
