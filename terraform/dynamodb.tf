# --------------------------------------------------
# EduCloud Guard Findings Database
# --------------------------------------------------

resource "aws_dynamodb_table" "findings" {
  name         = "${var.project_name}-findings"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "finding_id"

  attribute {
    name = "finding_id"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-findings"
    Department  = "LearningTechnology"
    Owner       = "cloud-admin@northstar.edu"
    Environment = var.environment
    Project     = var.project_name
    CostCenter  = "LT-5001"
  }
}
