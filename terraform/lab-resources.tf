# --------------------------------------------------
# NorthStar University Test Environment
# --------------------------------------------------

resource "aws_security_group" "computer_science_compliant" {
  name        = "${var.project_name}-cs-compliant-sg"
  description = "Compliant test security group for Computer Science"

  tags = {
    Name        = "${var.project_name}-cs-compliant-sg"
    Department  = "ComputerScience"
    Owner       = "cloud-admin@northstar.edu"
    Environment = "Development"
    Project     = "CS-Student-Lab"
    CostCenter  = "CS-1001"
  }
}

resource "aws_security_group" "research_public_ssh" {
  name        = "${var.project_name}-research-public-ssh-sg"
  description = "Test security group with intentionally exposed SSH"

  ingress {
    description = "Remediated SSH access - internal network only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  tags = {
    Name        = "${var.project_name}-research-public-ssh-sg"
    Department  = "Research"
    Owner       = "research-admin@northstar.edu"
    Environment = "Research"
    Project     = "Climate-Modeling"
    CostCenter  = "RES-3001"
  }
}

resource "aws_security_group" "admissions_missing_tags" {
  name        = "${var.project_name}-admissions-incomplete-tags-sg"
  description = "Test resource with intentionally missing governance tags"

  tags = {
    Name        = "${var.project_name}-admissions-incomplete-tags-sg"
    Department  = "Admissions"
    Environment = "Development"

    # INTENTIONAL GOVERNANCE VIOLATION
    # Missing Owner and CostCenter
  }
}

resource "aws_security_group" "invalid_department" {
  name        = "${var.project_name}-invalid-department-sg"
  description = "Test resource with invalid university department"

  tags = {
    Name        = "${var.project_name}-invalid-department-sg"
    Department  = "Biology"
    Owner       = "bio-admin@northstar.edu"
    Environment = "Research"
    Project     = "Genomics-Research"
    CostCenter  = "BIO-9001"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "unused_research_volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 1
  type              = "gp3"

  tags = {
    Name        = "${var.project_name}-unused-research-volume"
    Department  = "Research"
    Owner       = "research-admin@northstar.edu"
    Environment = "Research"
    Project     = "Climate-Modeling"
    CostCenter  = "RES-3001"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "learning_technology_compliant" {
  bucket = "${var.project_name}-lt-compliant-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.project_name}-lt-compliant"
    Department  = "LearningTechnology"
    Owner       = "lms-admin@northstar.edu"
    Environment = "Development"
    Project     = "Learning-Platform"
    CostCenter  = "LT-5001"
  }
}

resource "aws_s3_bucket_public_access_block" "learning_technology_compliant" {
  bucket = aws_s3_bucket.learning_technology_compliant.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "educloud_s3" {
  description             = "KMS key for EduCloud Guard university S3 test resources"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name       = "${var.project_name}-s3-key"
    Department = "LearningTechnology"
    Owner      = "cloud-admin@northstar.edu"
    CostCenter = "LT-5001"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "learning_technology_compliant" {
  bucket = aws_s3_bucket.learning_technology_compliant.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.educloud_s3.arn
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket" "engineering_weak_controls" {
  bucket = "${var.project_name}-eng-weak-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.project_name}-eng-weak-controls"
    Department  = "Engineering"
    Owner       = "engineering-admin@northstar.edu"
    Environment = "Testing"
    Project     = "Robotics-Lab"
    CostCenter  = "ENG-2001"
  }
}

resource "aws_s3_bucket_public_access_block" "engineering_weak_controls" {
  bucket = aws_s3_bucket.engineering_weak_controls.id

  # INTENTIONAL LAB GOVERNANCE VIOLATION
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_security_group" "engineering_public_rdp" {
  name        = "${var.project_name}-engineering-public-rdp-sg"
  description = "Test security group with intentionally exposed RDP"

  ingress {
    description = "INTENTIONAL LAB VIOLATION - public RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-engineering-public-rdp-sg"
    Department  = "Engineering"
    Owner       = "engineering-admin@northstar.edu"
    Environment = "Testing"
    Project     = "Robotics-Lab"
    CostCenter  = "ENG-2001"
  }
}

# --------------------------------------------------
# Step 15 Test Resource
# New HIGH-severity finding used to verify
# intelligent SNS alert suppression.
# --------------------------------------------------

resource "aws_security_group" "admissions_public_ssh" {
  name        = "${var.project_name}-admissions-public-ssh-sg"
  description = "Test security group with intentionally exposed SSH"

  ingress {
    description = "INTENTIONAL LAB VIOLATION - public SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-admissions-public-ssh-sg"
    Department  = "Admissions"
    Owner       = "admissions-admin@northstar.edu"
    Environment = "Testing"
    Project     = "Admissions-Portal"
    CostCenter  = "ADM-4001"
  }
}
