# v1 → v2 remediation

Apply these **after** the scan, on camera. Keep the diff small so the panel
can follow it; the point is that remediation is minutes, not a project.

Note: custom modules in StackGen change only through versioning — there is no
direct edit panel. So this becomes v2 in the catalog, and the version bump is
itself the audit record. Say that out loud.

## The three to fix live

Do these three. They map to the findings a fintech auditor cares about most,
and they're fast to type.

**1. Encrypt storage** — the headline fix.

```hcl
storage_encrypted = true
kms_key_id        = aws_kms_key.ledger.arn
```

Plus the key:

```hcl
resource "aws_kms_key" "ledger" {
  description             = "CMK for ${var.name} ledger database"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}
```

**2. Take it off the internet.**

```hcl
publicly_accessible = false
```

And narrow the security group:

```hcl
ingress {
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = var.allowed_cidr_blocks   # new variable, no default
}
```

**3. Turn on backups and guard rails.**

```hcl
backup_retention_period = 35
deletion_protection     = true
skip_final_snapshot     = false
final_snapshot_identifier = "${var.name}-final"
multi_az                = true
```

## The rest, if there's time

```hcl
# Password out of state entirely
manage_master_user_password = true
# and delete the master_password variable

enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
performance_insights_enabled    = true
performance_insights_kms_key_id = aws_kms_key.ledger.arn
auto_minor_version_upgrade      = true
```

## What to say while you type

Don't narrate the syntax. Narrate the counterfactual: this module was in a
Git repo, it looked fine in review, and it would have gone to production
unscanned — because nothing in their current toolchain scans a homegrown
module. That's the gap, not the missing `= true`.
