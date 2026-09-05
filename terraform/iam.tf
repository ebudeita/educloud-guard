resource "aws_iam_role" "scanner_lambda" {
  name = "${var.project_name}-scanner-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name       = "${var.project_name}-scanner-lambda-role"
    Department = "LearningTechnology"
    Owner      = "cloud-admin@northstar.edu"
    CostCenter = "LT-5001"
  }
}

resource "aws_iam_policy" "scanner_lambda" {
  name = "${var.project_name}-scanner-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadSecurityGroups"
        Effect = "Allow"

        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVolumes"
        ]

        Resource = "*"
      },

      {
        Sid    = "WriteGovernanceFindings"
        Effect = "Allow"

        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]

        Resource = aws_dynamodb_table.findings.arn
      },

      {
        Sid    = "WriteLambdaLogs"
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      },

      {
        Sid    = "PublishSecurityAlerts"
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = aws_sns_topic.security_alerts.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scanner_lambda" {
  role       = aws_iam_role.scanner_lambda.name
  policy_arn = aws_iam_policy.scanner_lambda.arn
}

