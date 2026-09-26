variable "aws_region" {
  description = "AWS region where the lab environment is deployed."
  type        = string
  default     = "eu-central-1"
}

variable "availability_zones" {
  description = "Availability Zones used for the highly available architecture."
  type        = list(string)

  default = [
    "eu-central-1a",
    "eu-central-1b"
  ]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones must be specified."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "application_port" {
  description = "TCP port used by the portal application."
  type        = number
  default     = 3000
}

variable "database_port" {
  description = "TCP port used by PostgreSQL."
  type        = number
  default     = 5432
}

variable "alert_email" {
  description = "Email address subscribed to SecuraNova operational alerts"
  type        = string
}
