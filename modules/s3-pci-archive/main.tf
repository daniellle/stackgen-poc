terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ---------------------------------------------------------------------------
# Customer-managed KMS key.
# Rationale: PCI DSS 3.6 requires key management under the cardholder-data
# entity's control. SSE-S3 (AES256) does not satisfy this because AWS holds
# the key material. Rotation is mandatory.
# ---------------------------------------------------------------------------
resource "aws_kms_key" "archive" {
  description             = "CMK for ${var.name} statement archive"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_kms_alias" "archive" {
  name          = "alias/${var.name}-archive"
  target_key_id = aws_kms_key.archive.key_id
}

resource "aws_s3_bucket" "this" {
  bucket = var.name
  tags   = local.tags
}

# Object Lock cannot be enabled after creation, so it is not toggled here.
# See README for the compliance-mode variant used in production.

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.archive.arn
      sse_algorithm     = "aws:kms"
    }
    # Cuts KMS API cost on high-volume archives by reusing the data key.
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------------------
# Deny any request not using TLS. PCI DSS 4.1 - encrypt cardholder data in
# transit over open networks. The public access block does not cover this.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "tls_only" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "tls_only" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.tls_only.json

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# ---------------------------------------------------------------------------
# Retention. Statement archives are financial records; the default here is
# seven years, which is the common retention floor for transaction records.
# Confirm against the customer's own regulator before reusing.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "archive-then-expire"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }

    expiration {
      days = var.retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

locals {
  tags = merge(
    var.tags,
    {
      "data-classification" = "confidential"
      "compliance-scope"    = "pci-dss"
      "managed-by"          = "platform-engineering"
    }
  )
}
