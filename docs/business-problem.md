# EduCloud Guard — Business Problem and Requirements

## 1. Organization Background

NorthStar University is a fictional higher-education institution that uses AWS to support multiple departments, including:

- Computer Science
- Engineering
- Research
- Admissions
- Learning Technology

Each department provisions and manages cloud resources for different projects, applications, research workloads, and educational services.

As cloud adoption has increased, the university's central IT team has found it increasingly difficult to maintain visibility into cloud spending, security risks, and resource ownership.

---

## 2. Business Problem

NorthStar University currently lacks a centralized way to identify AWS resources that may:

- Generate unnecessary cloud costs
- Violate security best practices
- Lack required ownership and cost-allocation tags
- Be incorrectly configured
- Remain unused after projects have ended

Without automated governance, the central IT team must manually review AWS resources across departments.

This process is time-consuming, inconsistent, and difficult to scale as cloud usage grows.

The university needs a solution that automatically evaluates its AWS environment and provides administrators with actionable findings.

---

## 3. Proposed Solution

EduCloud Guard is an automated AWS cloud governance and cost-monitoring solution designed for NorthStar University.

The system will periodically scan selected AWS resources and identify:

- Cost optimization opportunities
- Security configuration risks
- Missing or invalid resource tags
- Governance policy violations

Detected findings will be categorized by severity and stored centrally.

High-risk findings will automatically trigger notifications to the university's cloud administrators.

The solution will also provide an API and dashboard for reviewing findings by category, department, severity, and resource.

---

## 4. Primary Users

### Cloud Administrator

Responsible for maintaining the university AWS environment.

The Cloud Administrator needs to:

- Identify security risks
- Find unnecessary resources
- Review cloud governance violations
- Receive alerts about high-risk findings
- Track issues requiring remediation

### IT Manager

Responsible for overall cloud governance and operational oversight.

The IT Manager needs visibility into:

- Overall governance health
- Number of outstanding findings
- Department-level compliance
- Potential cost savings
- Major security risks

### Department Resource Owner

Responsible for AWS resources belonging to a particular university department.

Resource owners need to understand:

- Which resources belong to their department
- Which resources violate university policies
- What corrective action should be taken

---

## 5. Business Goals

EduCloud Guard should help NorthStar University:

1. Improve visibility into AWS resource ownership.
2. Reduce unnecessary cloud spending.
3. Detect common cloud security risks.
4. Enforce university resource-tagging standards.
5. Reduce the amount of manual cloud auditing performed by IT staff.
6. Prioritize risks according to severity.
7. Provide actionable remediation recommendations.

---

## 6. Functional Requirements

The system must:

### FR-01 — Resource Scanning

Automatically inspect selected AWS resources.

Initial supported resources will include:

- EC2 instances
- EBS volumes
- EBS snapshots
- Security groups
- S3 buckets

### FR-02 — Required Tag Validation

Check resources for the following mandatory tags:

- Department
- Owner
- Environment
- Project
- CostCenter

### FR-03 — Department Validation

Verify that the Department tag contains an approved NorthStar University department.

Approved values:

- ComputerScience
- Engineering
- Research
- Admissions
- LearningTechnology

### FR-04 — Cost Findings

Detect selected conditions that may generate unnecessary AWS costs, including:

- Unattached EBS volumes
- Stopped EC2 instances
- Old EBS snapshots
- Potentially idle EC2 instances

### FR-05 — Security Findings

Detect selected security risks, including:

- SSH exposed to 0.0.0.0/0
- RDP exposed to 0.0.0.0/0
- Publicly accessible S3 buckets
- S3 buckets without encryption

### FR-06 — Finding Classification

Each finding must contain:

- Finding ID
- Resource ID
- Resource type
- Department
- Category
- Severity
- Description
- Recommended remediation
- Detection timestamp
- Status

### FR-07 — Severity

Findings must be categorized as:

- CRITICAL
- HIGH
- MEDIUM
- LOW

### FR-08 — Findings Storage

Detected findings must be stored in DynamoDB.

### FR-09 — Automated Scanning

The governance scan must run automatically on a scheduled basis using Amazon EventBridge.

### FR-10 — Notifications

HIGH and CRITICAL findings must generate an administrator notification using Amazon SNS.

### FR-11 — Logging

Application activity and errors must be recorded in Amazon CloudWatch Logs.

### FR-12 — API Access

Administrators must eventually be able to retrieve findings using a REST API.

Example queries:

- All findings
- Findings by severity
- Findings by department
- Findings by category

---

## 7. Non-Functional Requirements

### Security

The solution must follow least-privilege IAM principles.

The governance Lambda function should receive only the permissions required to inspect resources and write findings.

### Infrastructure as Code

AWS infrastructure must be deployed using Terraform.

### Cost

The portfolio environment should remain inexpensive and use a minimal number of resources.

### Maintainability

Scanner logic should be modular so that additional AWS services and governance checks can be added later.

### Observability

Application executions and failures should be visible through CloudWatch.

### Scalability

The architecture should allow additional departments, AWS resource types, and governance checks to be introduced without redesigning the complete system.

---

## 8. Initial Governance Controls

### Cost

COST-001 — Detect unattached EBS volumes.

COST-002 — Detect stopped EC2 instances.

COST-003 — Detect EBS snapshots older than the defined threshold.

COST-004 — Detect potentially idle EC2 instances.

### Security

SEC-001 — Detect security groups exposing SSH to the internet.

SEC-002 — Detect security groups exposing RDP to the internet.

SEC-003 — Detect publicly accessible S3 buckets.

SEC-004 — Detect S3 buckets without encryption.

### Governance

GOV-001 — Detect resources missing required tags.

GOV-002 — Detect invalid Department tag values.

---

## 9. Expected Outcome

EduCloud Guard will provide NorthStar University's IT team with an automated method for identifying cloud cost, security, and governance issues.

Instead of manually reviewing individual AWS resources, administrators will receive centralized findings containing:

- What resource has a problem
- Which department owns it
- Why the issue matters
- How serious the issue is
- What action should be taken

The project will demonstrate the use of AWS automation, serverless architecture, cloud security, governance, cost optimization, monitoring, APIs, and Infrastructure as Code.
