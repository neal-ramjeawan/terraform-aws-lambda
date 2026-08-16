# Contributing

## Making a change

1. Branch, make the change, update `tests/lambda-function.tftest.hcl` if
   behavior changed.
2. Run `terraform fmt`, `terraform validate`, and `terraform test` locally
   — CI runs the same three checks and will block the PR otherwise. All
   fully offline: no AWS account or credentials needed.
3. Update `README.md` if variables, outputs, or behavior changed.
4. Update `CHANGELOG.md` in the same PR as the change, not as a follow-up.

## This module is a dependency of others

`terraform-aws-secrets-manager` composes this module via a pinned `ref` in
its own `main.tf`. A breaking change here doesn't affect that repo until
someone deliberately bumps the `ref` — but it's worth checking
`terraform-aws-secrets-manager`'s usage before changing this module's
public interface, so the version bump you tag actually reflects the
blast radius.

## Versioning

Plain semver tags: `v0.1.0`, `v0.2.0`, etc. Breaking variable/output
changes bump the major version, additive changes bump minor, fixes bump
patch.

## Pull requests

CI (`fmt`, `validate`, `test`, `tflint`, Trivy) must pass. `terraform-docs` regenerates the README automatically — no need to run it yourself before pushing. If the PR changes this module's
variables or outputs, say so explicitly in the description.
