resource "aws_lambda_function" "governance_scanner" {
  function_name = "${var.project_name}-governance-scanner"

  role = aws_iam_role.scanner_lambda.arn

  runtime = "python3.13"
  handler = "lambda_function.lambda_handler"

  filename = "${path.module}/educloud_guard_lambda.zip"

  source_code_hash = filebase64sha256(
    "${path.module}/educloud_guard_lambda.zip"
  )

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      FINDINGS_TABLE_NAME = aws_dynamodb_table.findings.name
      ALERT_TOPIC_ARN     = aws_sns_topic.security_alerts.arn
    }
  }

  tags = {
    Name       = "${var.project_name}-governance-scanner"
    Department = "LearningTechnology"
    Owner      = "cloud-admin@northstar.edu"
    CostCenter = "LT-5001"
  }
}
