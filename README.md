# EduCloud Guard

EduCloud Guard is a serverless AWS cloud governance, security, and cost-monitoring solution designed for a simulated university environment.

The project demonstrates how a university can automatically scan AWS resources, identify governance and security violations, track findings through their lifecycle, generate alerts for high-severity issues, and provide administrators with a centralized dashboard for reviewing cloud posture.

The simulated organization used throughout the project is **NorthStar University**.

---

## Problem

Universities often operate decentralized cloud environments where different departments create and manage their own resources.

Without centralized governance, this can lead to:

- Missing or inconsistent resource tags
- Resources assigned to unauthorized departments
- Publicly exposed administrative ports
- Unused resources continuing to generate costs
- Limited visibility into cloud security posture
- Manual and inconsistent compliance reviews

EduCloud Guard automates these checks and stores the results in a centralized findings database.

---

## Solution

EduCloud Guard periodically scans selected AWS resources and evaluates them against university governance policies.

The system:

1. Runs automated governance scans using AWS Lambda.
2. Evaluates AWS resources against security, governance, and cost controls.
3. Stores findings in Amazon DynamoDB.
4. Tracks finding lifecycle information such as first detection, last detection, status, and scan count.
5. Sends notifications for high-severity findings using Amazon SNS.
6. Runs automatically every 24 hours using Amazon EventBridge.
7. Exposes finding data through an API.
8. Displays cloud posture information through a web dashboard.

---

## Architecture

```text
                    Amazon EventBridge
                           |
                           | Daily Scan
                           v
                    AWS Lambda Scanner
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
        Governance      Security       Cost
          Checks         Checks        Checks
             |             |             |
             +-------------+-------------+
                           |
                           v
                    Amazon DynamoDB
                    Findings Database
                           |
                +----------+----------+
                |                     |
                v                     v
           Amazon SNS            API Gateway
          High-Severity               |
             Alerts                   v
                               Flask Backend
                                      |
                                      v
                                Web Dashboard
```

Infrastructure is provisioned and managed using **Terraform**.

---

## AWS Services Used

| Service | Purpose |
|---|---|
| AWS Lambda | Executes automated governance, security, and cost scans |
| Amazon DynamoDB | Stores and tracks findings |
| Amazon EventBridge | Runs the scanner automatically every 24 hours |
| Amazon SNS | Sends notifications for high-severity findings |
| Amazon API Gateway | Provides API access to findings |
| Amazon EC2 / EBS | Provides resources used for governance and cost-control testing |
| AWS IAM | Provides least-privilege permissions for project components |
| Amazon CloudWatch | Provides Lambda execution logs and operational visibility |

---

## Infrastructure as Code

Terraform is used to provision and manage the AWS infrastructure required by EduCloud Guard.

This makes the environment:

- Reproducible
- Version controlled
- Easier to audit
- Easier to deploy and destroy
- Less dependent on manual AWS Console configuration

---

## Governance Controls

EduCloud Guard currently implements the following controls:

| Control | Category | Severity | Description |
|---|---|---|---|
| GOV-001 | Governance | Low | Detects resources missing required governance tags |
| GOV-002 | Governance | Low | Detects resources assigned to an unapproved department |
| SEC-001 | Security | High | Detects security groups allowing public SSH access |
| SEC-002 | Security | High | Detects security groups allowing public RDP access |
| COST-001 | Cost | Medium | Detects unattached EBS volumes that may generate unnecessary costs |

---

## Required Governance Tags

NorthStar University resources are expected to contain the following tags:

- Department
- Owner
- Environment
- Project
- CostCenter

Approved departments include:

- ComputerScience
- Engineering
- Research
- Admissions
- LearningTechnology

---

## Finding Lifecycle Management

Findings use a stable identifier based on the control and affected AWS resource.

Example:

```text
SEC-001#sg-xxxxxxxx
```

Instead of creating a duplicate finding every time the scanner runs, EduCloud Guard updates the existing record.

Each finding can track information such as:

- First detected timestamp
- Last detected timestamp
- Scan count
- Severity
- Category
- Department
- Resource
- Finding status
- Recommended remediation

This allows the system to distinguish between newly discovered, persistent, and resolved cloud governance issues.

---

## Automated Scanning

Amazon EventBridge invokes the governance scanner automatically.

Current schedule:

```text
rate(1 day)
```

This allows EduCloud Guard to continuously evaluate the environment without requiring manual scans.

---

## Security Alerts

High-severity security findings can trigger Amazon SNS notifications.

Examples include:

- SSH (TCP/22) exposed to `0.0.0.0/0`
- RDP (TCP/3389) exposed to `0.0.0.0/0`

These controls demonstrate how cloud governance findings can be converted into actionable security notifications.

---

## Dashboard

EduCloud Guard includes a web dashboard for reviewing findings.

Dashboard functionality includes:

- Cloud posture summary
- Security, governance, and cost finding counts
- Severity filtering
- Category filtering
- Department filtering
- Status filtering
- Finding search
- Finding sorting
- Pagination
- Finding detail view
- Open and resolved finding visibility

The dashboard consumes finding data through the project's API rather than requiring AWS credentials in the browser.

---

## Security Design

The project follows several security-focused design principles:

- AWS credentials are not embedded in frontend JavaScript.
- AWS API requests are handled by the backend.
- IAM permissions are scoped to the services required by the scanner.
- Security findings include recommended remediation.
- Public SSH and RDP exposure are treated as high-severity findings.
- Test vulnerabilities are intentionally created only for controlled project validation.

---

## Project Structure

```text
educloud-guard/
├── src/
│   ├── scanners/
│   │   ├── tag_scanner.py
│   │   ├── security_group_scanner.py
│   │   └── cost_scanner.py
│   ├── web-dashboard/
│   │   ├── index.html
│   │   ├── styles.css
│   │   └── app.js
│   └── lambda_function.py
├── terraform/
└── README.md
```

---

## Skills Demonstrated

This project demonstrates hands-on experience with:

- AWS architecture
- AWS Lambda
- Amazon DynamoDB
- Amazon EventBridge
- Amazon SNS
- Amazon API Gateway
- Amazon EC2 and EBS
- AWS IAM
- CloudWatch
- Terraform
- Python
- Boto3
- Linux
- REST APIs
- JavaScript
- Cloud governance
- Cloud security
- Cost optimization
- Infrastructure as Code
- Git and GitHub

---

## Key Design Decisions

### Stable Finding IDs

Findings use deterministic identifiers rather than timestamps. This prevents repeated scans from creating duplicate database records.

### Serverless Scanning

AWS Lambda allows the governance scanner to run only when required rather than maintaining a continuously running server.

### Automated Scheduling

EventBridge removes the need for administrators to manually initiate governance scans.

### Separation of Controls

Governance, security, and cost checks are implemented as separate scanner modules, making the project easier to maintain and extend.

### Infrastructure as Code

Terraform allows the test environment and supporting infrastructure to be recreated consistently.

---

## Future Enhancements

Potential future improvements include:

- Additional AWS resource scanners
- S3 security configuration controls
- IAM governance controls
- Multi-account scanning
- AWS Organizations integration
- Historical posture trends
- Automated remediation workflows
- Authentication and role-based dashboard access
- CI/CD deployment pipeline
- Expanded cost optimization controls

---

## Disclaimer

EduCloud Guard is a portfolio and learning project built in a controlled AWS environment.

Some resources are intentionally configured with governance or security violations so the scanner can detect them. These configurations should not be used in production environments.

---

## Author

**Ita Ebude**

AWS Certified Solutions Architect – Associate  
Cloud Support / Cloud Security
