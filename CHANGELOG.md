# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:` or `BREAKING CHANGE:` footer → major).

## 0.1.0 (2026-06-22)


### Features

* initial EKS control-plane module (fintech-hardened) ([482cc92](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/482cc92272fe30ac8af67c99873424804020a1b5))


### Bug Fixes

* satisfy Devotica OPA policies (mandatory tags + IAM wildcard waiver) ([2816403](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/28164030bec154fd6080b012f826c904c2b6191f))
