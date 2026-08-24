# Pre-demo checklist

## Before any `--dir` upload

`stackgen upload custom-modules --dir` bundles the *entire* directory. A local
`terraform init` leaves ~800 MB of provider binaries in `.terraform/`, which
returns `413 Request Entity Too Large` — an error that looks nothing like a
permissions problem and will be reached *before* any permission check.

```bash
find . -name .terraform -type d -exec rm -rf {} +
du -sh .    # sanity check before any --dir upload
```

Upload from a clean copy. The real `403` only appears once the payload is small
enough to reach the permission check. See `evidence/README.md`.

## Live flow: add S3

`bucket_name` has no default. Generation blocks with "1 action item to address"
until it is set. Fill it in as part of the flow.

## Live flow: add RDS

`rds_master_password` arrives pre-filled with the literal `"password"` and does
*not* block generation. Set it as a natural step in the flow — a default will
not survive a PCI review — and continue.

## Verify before presenting

```bash
cd generated && terraform init -backend=false && terraform validate
grep -n 'password' generated/main.tf     # must not be the default
```

## Known-good state

- appStack `ledger-api` — `3da4a852-7ac5-405e-b57a-47848e88ccb2`
- project `danielle-poc` — `4b4845e1-7d70-446f-8291-c841467272db`
- tenant `https://poc.cloud.stackgen.com`, CLI v0.82.0
- custom module creation returns 403 — this is expected, it is the guardrail beat
- drift detection is not usable: no environment profile, nothing deployed
