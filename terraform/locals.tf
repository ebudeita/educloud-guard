locals {
  common_tags = {
    Project      = var.project_name
    Organization = var.organization_name
    Environment  = var.environment
    ManagedBy    = "Terraform"
  }

  approved_departments = [
    "ComputerScience",
    "Engineering",
    "Research",
    "Admissions",
    "LearningTechnology"
  ]

  required_governance_tags = [
    "Department",
    "Owner",
    "Environment",
    "Project",
    "CostCenter"
  ]
}
