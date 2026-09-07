import os
from collections import Counter

import boto3
import requests
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest


REGION = "us-east-1"


def signed_get(url):
    session = boto3.Session()
    credentials = session.get_credentials().get_frozen_credentials()

    request = AWSRequest(
        method="GET",
        url=url,
    )

    SigV4Auth(
        credentials,
        "execute-api",
        REGION,
    ).add_auth(request)

    prepared = request.prepare()

    response = requests.get(
        url,
        headers=dict(prepared.headers),
        timeout=30,
    )

    response.raise_for_status()

    return response.json()


def print_summary(findings):
    severity_counts = Counter(
        finding.get("severity", "UNKNOWN")
        for finding in findings
    )

    category_counts = Counter(
        finding.get("category", "UNKNOWN")
        for finding in findings
    )

    status_counts = Counter(
        finding.get("status", "UNKNOWN")
        for finding in findings
    )

    print()
    print("=" * 64)
    print("                 EDUCloud Guard Dashboard")
    print("=" * 64)

    print()
    print(f"Total Findings : {len(findings)}")
    print(f"Open Findings  : {status_counts.get('OPEN', 0)}")
    print(f"Resolved       : {status_counts.get('RESOLVED', 0)}")

    print()
    print("Severity")
    print("-" * 30)
    print(f"HIGH   : {severity_counts.get('HIGH', 0)}")
    print(f"MEDIUM : {severity_counts.get('MEDIUM', 0)}")
    print(f"LOW    : {severity_counts.get('LOW', 0)}")

    print()
    print("Category")
    print("-" * 30)
    print(f"SECURITY   : {category_counts.get('SECURITY', 0)}")
    print(f"GOVERNANCE : {category_counts.get('GOVERNANCE', 0)}")
    print(f"COST       : {category_counts.get('COST', 0)}")


def print_findings_table(findings):
    print()
    print("=" * 110)
    print("Current Findings")
    print("=" * 110)

    header = (
        f"{'CONTROL':<10}"
        f"{'SEVERITY':<10}"
        f"{'STATUS':<10}"
        f"{'DEPARTMENT':<20}"
        f"{'RESOURCE':<45}"
    )

    print(header)
    print("-" * 110)

    for finding in findings:
        print(
            f"{finding.get('control_id', ''):<10}"
            f"{finding.get('severity', ''):<10}"
            f"{finding.get('status', ''):<10}"
            f"{finding.get('department', ''):<20}"
            f"{finding.get('resource_name', ''):<45}"
        )


def main():
    api_url = os.environ.get("FINDINGS_API_URL")

    if not api_url:
        raise RuntimeError(
            "FINDINGS_API_URL environment variable is not set."
        )

    data = signed_get(
        f"{api_url}?status=OPEN"
    )

    findings = data.get("findings", [])

    print_summary(findings)
    print_findings_table(findings)


if __name__ == "__main__":
    main()
