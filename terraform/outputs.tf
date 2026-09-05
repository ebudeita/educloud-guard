output "deployment_region" {
  description = "AWS region where EduCloud Guard is deployed"
  value       = var.aws_region
}

output "project_name" {
  description = "EduCloud Guard project name"
  value       = var.project_name
}

output "organization_name" {
  description = "Organization represented by the project"
  value       = var.organization_name
}

output "findings_table_name" {
  description = "Name of the EduCloud Guard DynamoDB findings table"
  value       = aws_dynamodb_table.findings.name
}

output "findings_table_arn" {
  description = "ARN of the EduCloud Guard DynamoDB findings table"
  value       = aws_dynamodb_table.findings.arn
}

output "governance_scanner_function_name" {
  description = "Name of the EduCloud Guard governance scanner Lambda"
  value       = aws_lambda_function.governance_scanner.function_name
}
