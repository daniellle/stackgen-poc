terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ===========================================================================
# VERSION 1 - DELIBERATELY NON-COMPLIANT.
#
# This is the "we wrote this in 2021 and nobody scanned it" module. It is
# the artifact for the compliance-scan beat of the demo. Do NOT fix these
# before the scan; the whole point is that StackGen finds them.
#
# Planted findings are marked [FINDING n]. See V2-FIX.md for remediation.
# ===========================================================================

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnets"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "this" {
  name        = "${var.name}-db"
  description = "Ledger database access"
  vpc_id      = var.vpc_id

  # [FINDING 1] Ingress open to the world on the Postgres port.
  # Expected: CIS AWS 5.2 / PCI DSS 1.2.1 - restrict inbound to known CIDRs.
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier     = var.name
  engine         = "postgres"
  engine_version = "15.5"
  instance_class = var.instance_class

  allocated_storage = 100
  storage_type      = "gp3"

  db_name  = "ledger"
  username = var.master_username

  # [FINDING 2] Password supplied as a plain Terraform variable. It lands in
  # state in cleartext. Expected: manage_master_user_password + Secrets Manager.
  password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  # [FINDING 3] Storage encryption disabled. This is the headline violation -
  # an unencrypted ledger is an instant PCI DSS 3.4 audit failure.
  storage_encrypted = false

  # [FINDING 4] Publicly reachable from the internet.
  publicly_accessible = true

  # [FINDING 5] No automated backups. Zero means disabled, not "default".
  backup_retention_period = 0

  # [FINDING 6] Nothing stops a terraform destroy from taking the ledger.
  deletion_protection = false
  skip_final_snapshot = true

  # [FINDING 7] No audit trail exported. PCI DSS 10.2 requires logging of
  # access to cardholder data.
  enabled_cloudwatch_logs_exports = []

  multi_az = false

  tags = var.tags
}
