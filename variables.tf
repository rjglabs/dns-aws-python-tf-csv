# ============================================================================
# Terraform Variables for Route53 DNS Record Automation
# ============================================================================

variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "python_script_path" {
  description = "Path to the Python script for DNS CSV parsing."
  type        = string
  default     = "./parse_dns_csvs.py"
}
