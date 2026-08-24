# Evidence — PoC tenant capability probe, 2026-08-24

Captured against `https://poc.cloud.stackgen.com`, project `danielle-poc`,
appStack `ledger-api` (`3da4a852-7ac5-405e-b57a-47848e88ccb2`), CLI v0.82.0.

## What the tenant allows

| Probe | Result |
|---|---|
| List appStacks | works |
| Add built-in resources (`aws_s3`, `aws_rds`) | works — 103 resource types available |
| Generate Terraform (`download-iac`) | works — output in `../generated/`, `terraform validate` clean |
| Create a custom module | **403** — see `test-c-403-permission-boundary.txt` |

The split is authoring vs consuming: consuming built-in resources is permitted,
authoring governed artifacts (custom resource templates at tenant level) is not.

## Do not misread a 413 as the guardrail

The first Test C attempt returned `413 Request Entity Too Large`, not a 403.
Cause: `--dir` bundles the *entire* directory, and `modules/s3-pci-archive/`
contained a 795 MB `.terraform/` from a local `terraform init`.

Upload from a clean copy containing only `.tf` files. The real 403 appears
only once the payload is small enough to reach the permission check.

## Drift detection is not a usable demo beat

`detect-drift` responds (so permissions are not the blocker) but cannot return
anything meaningful:

- `get_env_profiles` -> "No environment profiles found for the topology"
- drift compares desired config against *actually deployed* state

That needs provisioned AWS infrastructure and credentials. Neither exists.
An environment profile alone would not be enough.

## Note on the generated Terraform

`../generated/main.tf` contains `rds_master_password = "password"` — a default
from the built-in `aws_rds` module. Change it before showing this on screen.
