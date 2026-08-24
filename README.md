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

## Order of operations

1. Push this repo to GitHub (private is fine — you'll authenticate anyway).
2. Import both modules: **Add New Resource → Custom Module → Source from Git
   Repository**. You'll need repo URL, branch/tag, a secret token from the
   Secret Store, and the subdirectory, since neither module sits at root.
3. Scan `rds-postgres-ledger` from **Catalog → Actions → Scan**. Screenshot
   the findings — this is your evidence slide.
4. Remediate to v2 per `V2-FIX.md`.
5. Grab the **TemplateID (UUID)** of the imported `s3-pci-archive` module,
   paste it into the override policy, upload it.
6. Bundle both into a Resource Pack: "PCI Golden Path".

## Two things to verify, not trust

**The override upload subcommand.** The docs confirm the *policy schema*
(`Name` / `OverrideResourceTypeDetails` / `OverrideType` / `TemplateID`, with
`Locked` documented as ignorable) and confirm upload happens via
`stackgen upload` from the policy directory. They don't spell out the
subcommand for this policy type. Sibling commands look like:

```
stackgen upload security-rules -p ./file.json
stackgen upload resource-pack-policy -p ./file.json
stackgen upload resource-iam-restriction-policy -p ./file.json
```

So run `stackgen upload --help` first and use whatever it lists. Don't
improvise in front of the panel.

**The `aws_s3` vs `aws_s3_bucket` asymmetry.** In the documented example the
map *key* is `aws_s3` while `OverrideType` is `aws_s3_bucket`. The key looks
like StackGen's internal resource type and `OverrideType` like the Terraform
type, but that's inference, not documentation. Test the swap actually fires
before building the demo around it.

**The restriction policy is not in this repo.** I have the override schema
from docs; I do not have a verified schema for the allowed-templates
restriction policy, and inventing one would waste your gate hours debugging
my guess. Pull the real shape from `stackgen upload --help` or the
Governance Configurations UI, then write it.

Also worth knowing before someone asks: restriction reportedly behaves
differently across tfstate import versus Cloud-to-Code, and differently again
when no mapping policy exists. Test that edge yourself.

## Terraform hygiene

`terraform init` then `terraform validate` both modules locally before
importing. A syntax error surfacing inside StackGen's importer is a much
worse debugging experience than catching it in your own terminal.

For plan-only demos, use a throwaway AWS account with a read-only IAM user —
`plan` still needs credentials to resolve the provider, and dummy keys will
error.
