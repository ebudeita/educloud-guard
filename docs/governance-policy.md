# NorthStar University AWS Cloud Governance Policy

## 1. Purpose

This policy defines the cloud governance standards for AWS resources operated by NorthStar University.

The purpose of the policy is to improve:

- Resource ownership and accountability
- Cost visibility
- Cloud security
- Resource consistency
- Operational governance

EduCloud Guard will automatically evaluate selected AWS resources against these policies and report violations to the university's central IT team.

---

## 2. Scope

This policy applies to AWS resources owned or managed by the following NorthStar University departments:

- Computer Science
- Engineering
- Research
- Admissions
- Learning Technology

The initial version of EduCloud Guard will evaluate:

- Amazon EC2 instances
- Amazon EBS volumes
- Amazon EBS snapshots
- Amazon EC2 security groups
- Amazon S3 buckets

Additional AWS services may be incorporated in future versions.

---

# 3. Resource Tagging Policy

All supported AWS resources that support the university's required tagging model must contain the following tags:

| Tag | Purpose | Example |
|---|---|---|
| Department | Identifies responsible department | Research |
| Owner | Identifies resource owner | cloud-admin@northstar.edu |
| Environment | Identifies workload environment | Development |
| Project | Identifies associated project | AI-Research-Lab |
| CostCenter | Associates spending with a department | RES-3001 |

## GOV-001 — Required Tags

Resources missing one or more required tags will generate a governance finding.

Severity:

LOW

Example violation:

Resource:

i-0123456789

Existing tags:

Department = Research  
Environment = Development  
Project = AI-Research-Lab

Missing:

Owner  
CostCenter

Recommended remediation:

Add all required NorthStar University governance tags to the resource.

---

## GOV-002 — Approved Department Values

The Department tag must contain one of the following approved values:

- ComputerScience
- Engineering
- Research
- Admissions
- LearningTechnology

Example:

Department = Research

is valid.

Department = Science

is invalid.

Severity:

LOW

Recommended remediation:

Replace the invalid Department value with an approved NorthStar University department identifier.

---

# 4. Environment Classification Policy

The Environment tag must use one of the following values:

- Production
- Development
- Testing
- Research

This standard prevents inconsistent values such as:

dev

DEV

test-env

production-server

Future versions of EduCloud Guard may automatically validate Environment values.

---

# 5. Cost Governance Policy

NorthStar University departments are responsible for avoiding unnecessary AWS resource costs.

EduCloud Guard will identify selected resources that may represent unnecessary spending.

---

## COST-001 — Unattached EBS Volumes

Amazon EBS volumes that are not attached to an EC2 instance must be identified for review.

An unattached volume may continue generating storage charges even when it is not being used.

Severity:

MEDIUM

Recommended remediation:

Determine whether the volume contains required data.

If the data is no longer needed, create a snapshot if required by university retention policy and delete the unused volume.

---

## COST-002 — Stopped EC2 Instances

EC2 instances remaining in a stopped state must be identified for review.

Although stopped instances do not incur EC2 compute charges, related resources such as EBS volumes may continue generating charges.

Severity:

LOW

Recommended remediation:

Confirm whether the instance is still required.

If the workload has been retired, preserve required data and terminate unnecessary resources.

---

## COST-003 — Old EBS Snapshots

EBS snapshots older than the university-defined review threshold must be identified.

Initial review threshold:

90 days

Severity:

LOW

Recommended remediation:

Confirm whether the snapshot is required for backup, recovery, compliance, or retention purposes before deletion.

---

## COST-004 — Potentially Idle EC2 Instances

EC2 instances showing consistently low utilization may be identified as potential cost-optimization opportunities.

Initial evaluation may use Amazon CloudWatch utilization metrics.

Example:

Average CPU utilization below a defined threshold during the evaluation period.

Severity:

MEDIUM

IMPORTANT:

EduCloud Guard must not automatically terminate an instance based solely on low utilization.

The system will generate a recommendation for administrator review.

---

# 6. Network Security Policy

NorthStar University AWS resources must not expose administrative services to the entire internet unless explicitly approved.

---

## SEC-001 — Public SSH Access

Security groups must not allow inbound TCP port 22 from:

0.0.0.0/0

This configuration allows any IPv4 address on the internet to attempt an SSH connection.

Severity:

HIGH

Recommended remediation:

Restrict SSH access to approved administrative IP ranges or use a secure administrative access solution such as AWS Systems Manager Session Manager where appropriate.

---

## SEC-002 — Public RDP Access

Security groups must not allow inbound TCP port 3389 from:

0.0.0.0/0

Severity:

HIGH

Recommended remediation:

Restrict RDP access to approved administrative networks or use an approved secure access mechanism.

---

# 7. Amazon S3 Security Policy

Amazon S3 buckets must follow university data-protection requirements.

---

## SEC-003 — Public S3 Access

S3 buckets must not be intentionally configured for unrestricted public access unless an approved business requirement exists.

EduCloud Guard will identify potentially public bucket configurations for administrator review.

Severity:

CRITICAL

Recommended remediation:

Review the bucket's access configuration and remove unnecessary public access.

Where appropriate, enable S3 Block Public Access.

---

## SEC-004 — Approved S3 Encryption Standard

University-managed S3 buckets containing governed workloads must use the approved encryption configuration.

For the EduCloud Guard lab, the approved standard is:

- Server-side encryption using AWS KMS (SSE-KMS)

Amazon S3 automatically applies SSE-S3 as baseline encryption. EduCloud Guard therefore evaluates whether governed buckets meet NorthStar University's stronger SSE-KMS requirement rather than testing whether S3 encryption exists at all.

Severity:

HIGH

Recommended remediation:

Configure the bucket to use an approved AWS KMS key for default server-side encryption.

---

# 8. Finding Severity Standard

EduCloud Guard will classify findings using four severity levels.

## CRITICAL

A configuration presents a potentially serious security or data-exposure risk requiring immediate investigation.

Example:

Potentially public S3 bucket.

## HIGH

A significant security risk requiring prompt remediation.

Examples:

- SSH exposed to the internet
- RDP exposed to the internet
- S3 encryption requirement violation

## MEDIUM

A cost or governance issue that should be investigated but does not normally require immediate action.

Examples:

- Unattached EBS volume
- Potentially idle EC2 instance

## LOW

A lower-risk governance or optimization issue.

Examples:

- Missing required tags
- Invalid Department tag
- Old snapshot
- Stopped EC2 instance

---

# 9. Remediation Policy

EduCloud Guard Version 1 will operate primarily as a detection and notification system.

The system WILL:

- Detect policy violations
- Record findings
- Assign severity
- Recommend remediation
- Notify administrators of selected findings

The system WILL NOT automatically:

- Delete EBS volumes
- Delete snapshots
- Terminate EC2 instances
- Modify security groups
- Delete S3 buckets
- Change resource permissions

Remediation decisions remain under human administrator control.

This reduces the risk of automated governance actions disrupting legitimate university workloads.

---

# 10. Notification Policy

EduCloud Guard will automatically notify administrators when it detects:

- CRITICAL findings
- HIGH findings

MEDIUM and LOW findings will be stored for review but will not generate immediate notifications in Version 1.

This approach reduces unnecessary alerts while ensuring significant risks receive prompt attention.

---

# 11. Audit and Monitoring

All EduCloud Guard scanner executions must generate application logs.

Amazon CloudWatch will be used to record:

- Scanner start time
- Scanner completion
- Resources evaluated
- Findings detected
- Errors
- Failed AWS API calls

This information will support troubleshooting and operational auditing.

---

# 12. Policy Review

NorthStar University's cloud governance requirements may evolve as cloud usage increases.

The EduCloud Guard architecture should therefore allow:

- New governance controls
- Additional AWS resource types
- New departments
- Updated severity classifications
- Updated cost thresholds
- Additional security requirements

without requiring a complete redesign of the application.
