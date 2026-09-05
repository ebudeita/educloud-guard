import boto3

ec2 = boto3.client("ec2")


def tags_to_dict(tags):
    if not tags:
        return {}

    return {
        tag["Key"]: tag["Value"]
        for tag in tags
    }


def rule_includes_port(permission, target_port):
    protocol = permission.get("IpProtocol")
    from_port = permission.get("FromPort")
    to_port = permission.get("ToPort")

    return (
        protocol in ("tcp", "-1")
        and from_port is not None
        and to_port is not None
        and from_port <= target_port <= to_port
    )


def rule_is_public_ipv4(permission):
    return any(
        ip_range.get("CidrIp") == "0.0.0.0/0"
        for ip_range in permission.get(
            "IpRanges",
            []
        )
    )


def scan_security_group_exposure():
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

        if not resource_name.startswith("educloud-guard-"):
            continue

        department = tags.get(
            "Department",
            "UNKNOWN"
        )

        for permission in security_group.get(
            "IpPermissions",
            []
        ):

            if not rule_is_public_ipv4(permission):
                continue

            # SEC-001 — Public SSH
            if rule_includes_port(permission, 22):
                findings.append(
                    {
                        "control_id": "SEC-001",
                        "resource_id": resource_id,
                        "resource_name": resource_name,
                        "resource_type": "AWS::EC2::SecurityGroup",
                        "department": department,
                        "category": "SECURITY",
                        "severity": "HIGH",
                        "description": (
                            "Security group allows SSH access "
                            "from 0.0.0.0/0."
                        ),
                        "recommendation": (
                            "Restrict SSH access to approved "
                            "administrative IP ranges or use "
                            "AWS Systems Manager Session Manager."
                        ),
                        "status": "OPEN",
                        "port": 22,
                        "source": "0.0.0.0/0",
                    }
                )

            # SEC-002 — Public RDP
            if rule_includes_port(permission, 3389):
                findings.append(
                    {
                        "control_id": "SEC-002",
                        "resource_id": resource_id,
                        "resource_name": resource_name,
                        "resource_type": "AWS::EC2::SecurityGroup",
                        "department": department,
                        "category": "SECURITY",
                        "severity": "HIGH",
                        "description": (
                            "Security group allows RDP access "
                            "from 0.0.0.0/0."
                        ),
                        "recommendation": (
                            "Restrict RDP access to approved "
                            "administrative networks or use "
                            "an approved secure access method."
                        ),
                        "status": "OPEN",
                        "port": 3389,
                        "source": "0.0.0.0/0",
                    }
                )

    return findings
