import boto3

ec2 = boto3.client("ec2")

REQUIRED_TAGS = {
    "Department",
    "Owner",
    "Environment",
    "Project",
    "CostCenter",
}

APPROVED_DEPARTMENTS = {
    "ComputerScience",
    "Engineering",
    "Research",
    "Admissions",
    "LearningTechnology",
}


def tags_to_dict(tags):
    if not tags:
        return {}

    return {
        tag["Key"]: tag["Value"]
        for tag in tags
    }


def scan_security_group_tags():
    findings = []

    response = ec2.describe_security_groups()

    for security_group in response["SecurityGroups"]:
        resource_id = security_group["GroupId"]
        resource_name = security_group.get(
            "GroupName",
            "unknown"
        )

        tags = tags_to_dict(
            security_group.get("Tags", [])
        )

        # Only evaluate NorthStar University lab security groups.
        if not resource_name.startswith("educloud-guard-"):
            continue

        # GOV-001 — Missing Required Tags
        missing_tags = sorted(
            REQUIRED_TAGS - set(tags.keys())
        )

        if missing_tags:
            findings.append(
                {
                    "control_id": "GOV-001",
                    "resource_id": resource_id,
                    "resource_name": resource_name,
                    "resource_type": "AWS::EC2::SecurityGroup",
                    "department": tags.get(
                        "Department",
                        "UNKNOWN"
                    ),
                    "category": "GOVERNANCE",
                    "severity": "LOW",
                    "description": (
                        "Security group is missing required tags: "
                        + ", ".join(missing_tags)
                    ),
                    "recommendation": (
                        "Add all required NorthStar University "
                        "governance tags."
                    ),
                    "status": "OPEN",
                    "missing_tags": missing_tags,
                }
            )

        # GOV-002 — Invalid Department
        department = tags.get("Department")

        if (
            department
            and department not in APPROVED_DEPARTMENTS
        ):
            findings.append(
                {
                    "control_id": "GOV-002",
                    "resource_id": resource_id,
                    "resource_name": resource_name,
                    "resource_type": "AWS::EC2::SecurityGroup",
                    "department": department,
                    "category": "GOVERNANCE",
                    "severity": "LOW",
                    "description": (
                        f"Security group has invalid Department "
                        f"tag value: {department}"
                    ),
                    "recommendation": (
                        "Replace the Department tag with an approved "
                        "NorthStar University department identifier."
                    ),
                    "status": "OPEN",
                }
            )

    return findings
