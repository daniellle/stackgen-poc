# ledger-api — StackGen PoC artifacts

Simulated assets of a mid-sized fintech: two Terraform modules the platform
team "owns", plus the governance policies that make developers use them.

```
modules/
  s3-pci-archive/          compliant — the override target
  rds-postgres-ledger/     v1 non-compliant on purpose — the scan demo
    V2-FIX.md              remediation to apply live
policies/
  override-s3-pci-archive.json
```
