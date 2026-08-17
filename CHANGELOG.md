# Changelog

All notable changes to this module are documented here. Format loosely
follows [Keep a Changelog](https://keepachangelog.com/), versions follow
[SemVer](https://semver.org/).

## [0.1.2] - 2026-08-16

### Added
- `attach_additional_inline_policy` variable — lets a caller state
  explicitly whether `aws_iam_role_policy.inline` should be created,
  instead of Terraform inferring it from whether
  `additional_inline_policy_json` is null. The inference breaks when a
  caller (like `terraform-aws-secrets-manager`) composes this module and
  passes a value whose presence isn't known until apply — a `count` can
  never depend on an unknown value. Defaults to `null` (infer, same
  behavior as before) so existing callers are unaffected.

## [0.1.1] - 2026-08-16

### Fixed
- `terraform test` failed in real CI: the test file referenced
  `path.module` inside the top-level `variables` block, which Terraform's
  test framework doesn't allow there — only run blocks and variables are
  referenceable. Switched to a plain relative path, resolved from the
  working directory `terraform test` is invoked from (the repo root).
- `aquasecurity/trivy-action@0.29.0` no longer resolved — Aqua Security
  migrated all tags to a `v` prefix as part of their response to a supply
  chain incident, invalidating the old bare-number tags. Bumped to
  `v0.36.0`.
- `terraform-linters/setup-tflint@v4` is deprecated upstream; bumped to
  `v6`, and added `GITHUB_TOKEN` to the plugin-init step to avoid
  unauthenticated GitHub API rate limits when tflint fetches the AWS
  ruleset.
- `softprops/action-gh-release@v2` bumped to `v3` (current major).
- `terraform test` also failed on the *first* run, separately from the
  `path.module` issue: `mock_provider` mocks the entire provider,
  including `aws_iam_policy_document`'s own computed `.json` output —
  not just resources that hit a real API. The faked JSON isn't valid,
  which broke `aws_iam_role.this.assume_role_policy`. Fixed with a
  `mock_data "aws_iam_policy_document"` default in the test file.

## [0.1.0] - 2026-08-16

### Added
- Initial release: execution role, CloudWatch log group with configurable
  retention, local-zip or S3 deployment, optional VPC config, and
  `allowed_triggers` for generating invoke permissions declaratively
- Mocked `terraform test` suite — no AWS account or credentials required
- GitHub Actions CI: fmt/validate/test, `tflint` (AWS ruleset), and Trivy
  IaC scanning (tfsec's successor — tfsec is deprecated)
- `terraform-docs` wired into CI — the Inputs/Outputs reference in this
  README regenerates automatically on every PR
- Tag-triggered GitHub Releases, with notes pulled from this file
- `SECURITY.md` and issue templates