# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:` or `BREAKING CHANGE:` footer → major).

## [1.0.1](https://github.com/devotica-labs/terraform-aws-eks-cluster/compare/v1.0.0...v1.0.1) (2026-07-11)


### Bug Fixes

* remove comma from DevoticaWaiver tag value ([5cb6111](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/5cb6111c660fb805fe4079a651c9a23fc9cf14d8))
* remove comma from DevoticaWaiver tag value ([e7fadbd](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/e7fadbd7967a119cc27cdb79295a0bf0801d891f))
* remove invalid characters from DevoticaWaiver IAM tag value ([81af125](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/81af1255c87bec95a6f48710861cdc92fe7fc1e1))
* remove invalid characters from DevoticaWaiver IAM tag value ([573e72a](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/573e72a53db521369467017d78d8dd2ea888d4e8))

## [1.0.0](https://github.com/devotica-labs/terraform-aws-eks-cluster/compare/v0.1.0...v1.0.0) (2026-06-22)


### ⚠ BREAKING CHANGES

* the advanced label inputs (label_order, regex_replace_chars, id_length_limit, label_key_case, label_value_case, descriptor_formats, additional_tag_map, labels_as_tags, attributes, context) are removed. The commonly-used inputs (namespace, environment, stage, name, delimiter, tags, enabled) are preserved with identical behaviour.

### Features

* native, self-contained naming/tagging (no external naming module) ([bee032d](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/bee032df3a7b493758ada84fc194486c942e5ce6))


### Bug Fixes

* tflint — drop unused local.id_base, rename non-snake_case local ([4bb8837](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/4bb8837c38d7601ba7edb793f320b86b2544d3e7))

## 0.1.0 (2026-06-22)


### Features

* initial EKS control-plane module (fintech-hardened) ([482cc92](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/482cc92272fe30ac8af67c99873424804020a1b5))


### Bug Fixes

* satisfy Devotica OPA policies (mandatory tags + IAM wildcard waiver) ([2816403](https://github.com/devotica-labs/terraform-aws-eks-cluster/commit/28164030bec154fd6080b012f826c904c2b6191f))
