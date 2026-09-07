# --------------------------------------------------
# EduCloud Guard Findings API
# --------------------------------------------------

resource "aws_iam_role" "findings_api_lambda" {
  name = "${var.project_name}-findings-api-lambda-role"

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
    Name        = "${var.project_name}-findings-api-lambda-role"
    Department  = "LearningTechnology"
    Owner       = "cloud-admin@northstar.edu"
    CostCenter  = "LT-5001"
    Environment = "Production"
  }
}


resource "aws_iam_role_policy" "findings_api_lambda" {
  name = "${var.project_name}-findings-api-lambda-policy"
  role = aws_iam_role.findings_api_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadFindings"
        Effect = "Allow"

        Action = [
          "dynamodb:Scan"
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
      }
    ]
  })
}

resource "aws_lambda_function" "findings_api" {
  function_name = "${var.project_name}-findings-api"

  role    = aws_iam_role.findings_api_lambda.arn
  handler = "findings_api.lambda_handler"
  runtime = "python3.13"

  filename = "${path.module}/educloud_guard_findings_api.zip"

  source_code_hash = filebase64sha256(
    "${path.module}/educloud_guard_findings_api.zip"
  )

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      FINDINGS_TABLE_NAME = aws_dynamodb_table.findings.name
    }
  }

  tags = {
    Name        = "${var.project_name}-findings-api"
    Department  = "LearningTechnology"
    Owner       = "cloud-admin@northstar.edu"
    CostCenter  = "LT-5001"
    Environment = "Production"
  }
}

resource "aws_apigatewayv2_api" "findings" {
  name          = "${var.project_name}-findings-api"
  protocol_type = "HTTP"

  tags = {
    Name        = "${var.project_name}-findings-api"
    Department  = "LearningTechnology"
    Owner       = "cloud-admin@northstar.edu"
    CostCenter  = "LT-5001"
    Environment = "Production"
  }
}


resource "aws_apigatewayv2_integration" "findings" {
  api_id = aws_apigatewayv2_api.findings.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.findings_api.invoke_arn
  payload_format_version = "2.0"
}


resource "aws_apigatewayv2_route" "findings" {
  api_id = aws_apigatewayv2_api.findings.id

  route_key          = "GET /findings"
  target             = "integrations/${aws_apigatewayv2_integration.findings.id}"
  authorization_type = "AWS_IAM"
}


resource "aws_apigatewayv2_stage" "findings" {
  api_id = aws_apigatewayv2_api.findings.id

  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.findings_api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.findings.execution_arn}/*/*"
}

output "findings_api_url" {
  description = "EduCloud Guard findings API endpoint"
  value       = "${aws_apigatewayv2_api.findings.api_endpoint}/findings"
}

output "findings_api_execution_arn" {
  description = "Execution ARN for the EduCloud Guard findings API"
  value       = aws_apigatewayv2_api.findings.execution_arn
}
