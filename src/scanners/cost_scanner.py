import boto3

ec2 = boto3.client("ec2")


def tags_to_dict(tags):
    if not tags:
        return {}

    return {
        tag["Key"]: tag["Value"]
        for tag in tags
    }


def scan_unattached_volumes():
    findings = []

    response = ec2.describe_volumes()

    for volume in response["Volumes"]:
        volume_id = volume["VolumeId"]
        state = volume["State"]

        tags = tags_to_dict(
            volume.get("Tags", [])
        )

        resource_name = tags.get(
            "Name",
            volume_id
        )

        # Only evaluate EduCloud Guard lab resources.
        if not resource_name.startswith("educloud-guard-"):
            continue

        attachments = volume.get(
            "Attachments",
            []
        )

        # COST-001 — Unattached EBS Volume
        if (
            state == "available"
            and len(attachments) == 0
        ):
            findings.append(
                {
                    "control_id": "COST-001",
                    "resource_id": volume_id,
                    "resource_name": resource_name,
                    "resource_type": "AWS::EC2::Volume",
                    "department": tags.get(
                        "Department",
                        "UNKNOWN"
                    ),
                    "category": "COST",
                    "severity": "MEDIUM",
                    "description": (
                        "EBS volume is unattached but "
                        "continues to incur storage charges."
                    ),
                    "recommendation": (
                        "Confirm whether the volume is still "
                        "required. Snapshot important data and "
                        "delete unused volumes when appropriate."
                    ),
                    "status": "OPEN",
                    "volume_size_gb": volume.get("Size"),
                    "volume_type": volume.get("VolumeType"),
                    "volume_state": state,
                }
            )

    return findings
