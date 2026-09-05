# EduCloud Guard — MVP Architecture Design

## 1. Architecture Goal

The goal of the MVP is to automatically evaluate a small NorthStar University AWS environment for cost, security, and governance issues, store findings, and alert administrators about high-severity problems.

The MVP will prioritize:

- Simplicity
- Low cost
- Clear separation of responsibilities
- Easy testing
- Infrastructure as Code
- Future extensibility

---

## 2. Monitored University Resources

The NorthStar University test environment will contain deliberately compliant and non-compliant AWS resources.

Initial monitored resource types:

- EC2 instances
- EBS volumes
- EBS snapshots
- Security groups
- S3 buckets

These resources simulate workloads owned by different university departments.

---

## 3. EduCloud Guard Components

### Amazon EventBridge

Purpose:

Trigger the governance scan automatically on a schedule.

Initial schedule:

Once every 24 hours.

Why:

Governance checks should not depend on an administrator manually starting the scanner.

---

### AWS Lambda

Purpose:

Run the EduCloud Guard governance scanner.

The Lambda function will:

1. Query selected AWS resources.
2. Evaluate resources against university governance controls.
3. Create findings.
4. Store findings in DynamoDB.
5. Send HIGH and CRITICAL findings to SNS.

The scanner logic will be modular so each resource type can have a separate scanner.

---

### Amazon DynamoDB

Purpose:

Store governance findings.

Each finding will include information such as:

- Finding ID
- Control ID
- Resource ID
- Resource type
- Department
- Category
- Severity
- Description
- Recommendation
- Detection timestamp
- Status

This allows findings to be reviewed historically rather than existing only in logs.

---

### Amazon SNS

Purpose:

Notify cloud administrators about HIGH and CRITICAL findings.

Examples:

- Public SSH exposure
- Public RDP exposure
- Potential public S3 access
- S3 encryption violation

LOW and MEDIUM findings will be stored but will not generate immediate notifications.

---

### Amazon CloudWatch

Purpose:

Provide logging and operational visibility for EduCloud Guard.

CloudWatch Logs will record:

- Scan start
- Scan completion
- Number of resources scanned
- Number of findings
- Errors
- AWS API failures

---

### AWS IAM

Purpose:

Control access between EduCloud Guard and AWS resources.

The Lambda execution role will follow least-privilege principles.

The role will require:

- Read-only permissions for resources being evaluated
- Permission to write findings to DynamoDB
- Permission to publish alerts to SNS
- Permission to write logs to CloudWatch

EduCloud Guard will not receive permissions to automatically delete or modify monitored resources in Version 1.

---

### Terraform

Purpose:

Provision EduCloud Guard infrastructure and the NorthStar University test environment using Infrastructure as Code.

Terraform will manage:

- IAM
- Lambda
- DynamoDB
- SNS
- EventBridge
- CloudWatch-related configuration
- Test resources

---

## 4. MVP Data Flow

The main workflow will be:

1. EventBridge triggers the Lambda function.
2. Lambda queries AWS resources.
3. Lambda evaluates resources against EduCloud Guard controls.
4. Lambda creates findings for violations.
5. Findings are written to DynamoDB.
6. HIGH and CRITICAL findings are published to SNS.
7. Lambda execution activity is recorded in CloudWatch Logs.

---

## 5. Architecture Diagram

```text
               NORTHSTAR UNIVERSITY AWS ACCOUNT

  ------------------------------------------------------
          University Test / Monitored Resources

       EC2       EBS       S3       Security Groups
        │         │         │              │
        └─────────┴─────────┴──────────────┘
                          │
                          │ AWS API Reads
                          ▼
                ┌────────────────────┐
                │   AWS Lambda       │
                │ Governance Scanner │
                └─────────┬──────────┘
                          │
             ┌────────────┼─────────────┐
             │            │             │
             ▼            ▼             ▼
        DynamoDB          SNS       CloudWatch
        Findings        Alerts        Logs
                          ▲
                          │
                    HIGH / CRITICAL

                ┌────────────────────┐
                │  EventBridge       │
                │  Daily Schedule    │
                └─────────┬──────────┘
                          │
                          ▼
                       Lambda
