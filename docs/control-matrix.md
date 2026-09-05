# EduCloud Guard Control Matrix

| Control ID | Category | AWS Resource | Condition | Severity | Automated Alert |
|---|---|---|---|---|---|
| GOV-001 | Governance | Supported Resources | Required tag missing | LOW | No |
| GOV-002 | Governance | Supported Resources | Invalid Department value | LOW | No |
| COST-001 | Cost | EBS | Volume is unattached | MEDIUM | No |
| COST-002 | Cost | EC2 | Instance is stopped | LOW | No |
| COST-003 | Cost | EBS Snapshot | Snapshot exceeds 90-day review threshold | LOW | No |
| COST-004 | Cost | EC2 | Potentially idle based on utilization | MEDIUM | No |
| SEC-001 | Security | Security Group | TCP/22 accessible from 0.0.0.0/0 | HIGH | Yes |
| SEC-002 | Security | Security Group | TCP/3389 accessible from 0.0.0.0/0 | HIGH | Yes |
| SEC-003 | Security | S3 | Potential public access detected | CRITICAL | Yes |
| SEC-004 | Security | S3 | Approved SSE-KMS encryption not configured | HIGH | Yes |
