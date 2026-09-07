import json
import os
from decimal import Decimal

import boto3


dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["FINDINGS_TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)


def decimal_to_native(value):
    if isinstance(value, Decimal):
        return int(value) if value % 1 == 0 else float(value)

    raise TypeError


def normalize_query_params(event):
    params = event.get("queryStringParameters") or {}

    return {
        key.lower(): value.strip()
        for key, value in params.items()
        if value is not None
    }


def finding_matches_filters(finding, filters):
    supported_filters = {
        "severity",
        "status",
        "category",
        "department",
        "control_id",
    }

    for key, value in filters.items():
        if key not in supported_filters:
            continue

        finding_value = str(
            finding.get(key, "")
        )

        if finding_value.lower() != value.lower():
            return False

    return True


def lambda_handler(event, context):
    print("Processing EduCloud Guard findings API request.")

    filters = normalize_query_params(event)

    print(
        f"Filters received: {filters}"
    )

    response = table.scan()
    findings = response.get("Items", [])

    filtered_findings = [
        finding
        for finding in findings
        if finding_matches_filters(
            finding,
            filters,
        )
    ]

    filtered_findings.sort(
        key=lambda item: item.get(
            "last_detected_at",
            ""
        ),
        reverse=True,
    )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(
            {
                "count": len(filtered_findings),
                "filters": filters,
                "findings": filtered_findings,
            },
            default=decimal_to_native,
        ),
    }
