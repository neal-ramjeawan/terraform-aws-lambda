# Changelog

All notable changes to this module are documented here. Format loosely
follows [Keep a Changelog](https://keepachangelog.com/), versions follow
[SemVer](https://semver.org/).

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
