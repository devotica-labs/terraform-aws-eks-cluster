#!/usr/bin/env python3
"""Render an EKS cluster architecture diagram from a Terraform plan JSON.

Centres the EKS control plane and draws edges to the pieces this module
provisions around it:
  - the IAM cluster service role
  - the secrets-encryption KMS key
  - the control-plane CloudWatch log group
  - the OIDC provider (IRSA)
  - any EKS add-ons

Usage:
    python scripts/render-architecture.py <plan.json> <output-path-no-ext>
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EKS
from diagrams.aws.management import Cloudwatch
from diagrams.aws.network import VPC
from diagrams.aws.security import IAMRole, KMS


def load_resources(plan_path: Path) -> list[dict]:
    plan = json.loads(plan_path.read_text())
    root = plan.get("planned_values", {}).get("root_module", {})
    collected: list[dict] = []

    def walk(mod: dict) -> None:
        for r in mod.get("resources", []):
            collected.append(r)
        for child in mod.get("child_modules", []):
            walk(child)

    walk(root)
    return collected


def values(r: dict) -> dict:
    return r.get("values", {}) or {}


def render(plan_path: Path, out_no_ext: Path) -> None:
    resources = load_resources(plan_path)
    by_type: dict[str, list[dict]] = {}
    for r in resources:
        by_type.setdefault(r["type"], []).append(r)

    clusters = by_type.get("aws_eks_cluster", [])
    if not clusters:
        raise SystemExit("No aws_eks_cluster found in plan — nothing to render.")

    c_v = values(clusters[0])
    name = c_v.get("name") or "eks"
    version = c_v.get("version") or "?"
    log_types = c_v.get("enabled_cluster_log_types") or []
    deletion_protection = bool(c_v.get("deletion_protection"))

    # vpc_config is a list with one block in the plan
    vpc_cfg = (c_v.get("vpc_config") or [{}])[0] if c_v.get("vpc_config") else {}
    private_access = bool(vpc_cfg.get("endpoint_private_access"))
    public_access = bool(vpc_cfg.get("endpoint_public_access"))

    has_kms = bool(by_type.get("aws_kms_key"))
    has_log = bool(by_type.get("aws_cloudwatch_log_group"))
    has_oidc = bool(by_type.get("aws_iam_openid_connect_provider"))
    service_roles = [
        r for r in by_type.get("aws_iam_role", []) if r["address"].endswith(".default")
    ]
    addons = by_type.get("aws_eks_addon", [])

    endpoint = (
        "private+public" if (private_access and public_access)
        else "private-only" if private_access
        else "public-only" if public_access
        else "no endpoint"
    )

    badges = [f"k8s {version}", f"endpoint: {endpoint}"]
    if log_types:
        badges.append(f"logs: {len(log_types)}/5")
    if deletion_protection:
        badges.append("deletion-protected")

    graph_attr = {
        "fontsize": "20",
        "splines": "ortho",
        "ranksep": "1.0",
        "nodesep": "0.6",
        "pad": "0.5",
    }

    out_no_ext.parent.mkdir(parents=True, exist_ok=True)
    with Diagram(
        f"terraform-aws-eks-cluster — {name} · {' · '.join(badges)}",
        filename=str(out_no_ext),
        show=False,
        direction="LR",
        outformat="png",
        graph_attr=graph_attr,
    ):
        vpc = VPC("VPC\nprivate subnets")

        with Cluster(f"EKS control plane — {name}"):
            cluster_node = EKS(f"cluster\nk8s {version}")
            vpc >> Edge(label="runs in") >> cluster_node

            if service_roles:
                IAMRole("cluster service role") >> Edge(style="dashed", label="assumes") >> cluster_node

            if has_kms:
                KMS("KMS key") >> Edge(style="dashed", label="encrypts secrets") >> cluster_node

            if has_oidc:
                cluster_node >> Edge(style="dashed", label="IRSA / OIDC") >> IAMRole("OIDC provider")

            if has_log:
                log_node = Cloudwatch(f"control-plane logs\n{len(log_types)}/5 types")
                cluster_node >> Edge(label="audit/api/…") >> log_node

            if addons:
                with Cluster("add-ons"):
                    for a in addons:
                        EKS(values(a).get("addon_name", "addon"))


def main() -> None:
    if len(sys.argv) < 3:
        sys.stderr.write("Usage: render-architecture.py <plan.json> <output-path-without-ext>\n")
        sys.exit(2)
    render(Path(sys.argv[1]), Path(sys.argv[2]))


if __name__ == "__main__":
    main()
