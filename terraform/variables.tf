variable "aws_region" {
  description = "AWS region used to deploy EduCloud Guard"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the cloud governance project"
  type        = string
  default     = "educloud-guard"
}

variable "organization_name" {
  description = "Name of the fictional university"
  type        = string
  default     = "NorthStar-University"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "Development"
}

variable "notification_email" {
  description = "Email address that will receive governance alerts"
  type        = string
  sensitive   = true
  default     = ""
}

variable "alert_email" {
  description = "Email address that receives EduCloud Guard security alerts"
  type        = string
  sensitive   = true
}
