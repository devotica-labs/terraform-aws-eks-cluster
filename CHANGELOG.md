# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:` or `BREAKING CHANGE:` footer → major).

## [Unreleased]

### Added
- Initial module, derived from [`cloudposse/terraform-aws-eks-cluster`](https://github.com/cloudposse/terraform-aws-eks-cluster)
  (Apache-2.0) — see [`NOTICE`](NOTICE) for full attribution.
- EKS control plane with IAM service role (create or bring-your-own),
  `null-label` naming, and Cloud Posse's access-entry / access-policy
  surface, EKS add-ons, EKS capabilities (Argo CD / ACK / KRO), and EKS
  Auto Mode passthrough.
- OIDC identity provider for IRSA (default **on**).
- Secrets envelope encryption via a module-managed KMS key (rotation on,
  30-day deletion window) or a bring-your-own key.
- Control-plane logging to CloudWatch — all five log types at 365-day
  retention by default.

### Changed (Devotica fintech-hardened defaults vs. upstream)
- `endpoint_private_access` → `true`, `endpoint_public_access` → `false`
  (private-only Kubernetes API by default).
- `oidc_provider_enabled` → `true`.
- `enabled_cluster_log_types` → all five; `cluster_log_retention_period` → `365`.
- `deletion_protection_enabled` → `true`.
- `kubernetes_version` default → `1.31` (upstream ships the EOL `1.21`).
- Encryption-config KMS key deletion window → 30 days.
- Added a `check "public_endpoint_restricted"` guardrail flagging an open
  public endpoint left at `0.0.0.0/0`.

### Replaced (governance)
- Upstream Cloud Posse CI/CD, Atmos config, issue templates, and Go
  (terratest) suite replaced with the Devotica shape: central reusable CI,
  conftest policies, release-please + cosign + CycloneDX SBOM,
  terraform-docs auto-update, Dependabot auto-merge, Python
  architecture-diagram renderer, and native `terraform test` suites.

### Deferred to later versions
- Managed node groups / Karpenter wiring (separate module).
- A `sample-infra/eks` consumer service.
