# --------------------------------------------------
# Step 13 - Automated Governance Scanning
# EventBridge invokes the EduCloud Guard Lambda daily.
# --------------------------------------------------

resource "aws_cloudwatch_event_rule" "daily_governance_scan" {
  name                = "${var.project_name}-daily-governance-scan"
  description         = "Runs the EduCloud Guard governance scanner once every 24 hours"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "governance_scanner" {
  rule      = aws_cloudwatch_event_rule.daily_governance_scan.name
  target_id = "EduCloudGuardGovernanceScanner"
  arn       = aws_lambda_function.governance_scanner.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.governance_scanner.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_governance_scan.arn
}
