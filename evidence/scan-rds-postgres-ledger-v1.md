# Scan evidence — appStack `rds-postgres-ledger-v1`

Captured 2026-08-24 against `poc.cloud.stackgen.com`, project `danielle-poc`.
appStack `e212f9e8-b1f2-4316-b682-3687c5eb1a6c`, version 1.
`runType: static_analysis`, all `status: failed`.

Filtered by benchmark **PCI-DSSv4.0** — six violations, five HIGH, one MEDIUM.

| Rule | Policy | Sev | Attribute | v1 finding |
|---|---|---|---|---|
| STACKGEN_AWS_SG_028 | Unrestricted Postgres TCP 5432 | HIGH | `ingress` | FINDING 1 |
| STACKGEN_AWS_DB_INSTANCE_COMPOSITE_001 | Enable encryption for the RDS database | HIGH | `storage_encrypted` | FINDING 3 |
| STACKGEN_AWS_DB_INSTANCE_COMPOSITE_003 | Restrict public accessibility | HIGH | `publicly_accessible` | FINDING 4 |
| STACKGEN_AWS_DB_INSTANCE_COMPOSITE_002 | Ensure deletion protection is enabled | HIGH | `deletion_protection` | FINDING 6 |
| STACKGEN_AWS_DB_INSTANCE_COMPOSITE_005 | Enable CloudWatch log exports | MEDIUM | `enabled_cloudwatch_logs_exports` | FINDING 7 |
| STACKGEN_AWS_DB_INSTANCE_COMPOSITE_004 | Enable multi-AZ deployment | HIGH | `multi_az` | (module sets `multi_az = false`) |

`COMPOSITE_001` is the only one tagged with base `PCI-DSS` as well as
`PCI-DSSv3.2.1` and `PCI-DSSv4.0` — it is the strongest single slide.

## Not covered by any policy

- **FINDING 2** — plaintext master password. No policy checks it on any
  resource type. Argue it from the code, not the scan.
- **FINDING 5** — `backup_retention_period = 0`. A backup-retention policy
  exists (`STACKGEN_AWS_RDS_002`) but only for `aws_rds`, not for
  `aws_db_instance_composite`. Set to 0 here and nothing fires.

## Resource type matters more than expected

`aws_rds` and `aws_db_instance_composite` are both built-in and both look like
"an RDS database", but they carry completely different policy coverage:

| | `aws_rds` (Aurora cluster) | `aws_db_instance_composite` |
|---|---|---|
| Policies | 3 | 5 |
| PCI-tagged | **0** | **5** |

Building this stack on `aws_rds` produces two violations, neither tagged PCI —
so filtering the scan by PCI-DSS shows an empty result on a deliberately
non-compliant database. `aws_db_instance_composite` matches the v1 module
(`aws_db_instance`) and carries the PCI coverage. Use it.
