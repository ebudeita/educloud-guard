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


def lambda_handler(event, context):
    print("Processing EduCloud Guard findings API request.")

    response = table.scan()
    findings = response.get("Items", [])

    findings.sort(
        key=lambda item: item.get("last_detected_at", ""),
        reverse=True,
    )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(
            {
                "count": len(findings),
                "findings": findings,
            },
            default=decimal_to_native,
        ),
    }
