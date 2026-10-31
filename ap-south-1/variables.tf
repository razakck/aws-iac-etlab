variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "aws-etlab-iac"
}

variable "github_org" {
  description = "razakck"
  type        = string
  default = "razakck@69842830"
}

variable "github_repo" {
  description = "aws-iac-etlab"
  type        = string
  default = "aws-deploy-php-app@1359034496"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-2a", "ap-south-2b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"//"db.t4g.micro"//
}

variable "db_name" {
  type    = string
  default = "etlabdb"
}

variable "db_username" {
  type    = string
  default = "etlabuser"
}

variable "db_password" {
  description = "Assignment password. Use Secrets Manager instead for production."
  type        = string
  sensitive   = true
  default     = "etlabpass"
}

variable "db_engine_version" {
  type    = string
  default = "8.0"
}

variable "website_hostname" {
  description = "etlab.com"
  type        = string
  default     = "etlab.com"
}

variable "route53_zone_name" {
  description = "Existing public Route 53 zone, e.g. example.com"
  type        = string
  default     = "etlabappzone"
}

variable "enable_https" {
  description = "Set true only after an ACM certificate ARN is provided."
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN in the same region as the ALB."
  type        = string
  default     = ""
}

variable "deployment_config_name" {
  description = "CodeDeploy deployment configuration."
  type        = string
  default     = "CodeDeployDefault.HalfAtATime"
}
