# Changelog

All notable changes to this module are documented here. Format loosely
follows [Keep a Changelog](https://keepachangelog.com/), versions follow
[SemVer](https://semver.org/).

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
