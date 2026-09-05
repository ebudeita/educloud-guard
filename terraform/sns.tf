# --------------------------------------------------
# Step 14 - Security Alert Notifications
# SNS topic used by EduCloud Guard for HIGH-severity
# governance/security findings.
# --------------------------------------------------

resource "aws_sns_topic" "security_alerts" {
  name = "${var.project_name}-security-alerts"

  tags = {
    Name       = "${var.project_name}-security-alerts"
    Department = "LearningTechnology"
    Owner      = "cloud-admin@northstar.edu"
    Project    = var.project_name
    CostCenter = "LT-3001"
  }
}

resource "aws_sns_topic_subscription" "security_alert_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
