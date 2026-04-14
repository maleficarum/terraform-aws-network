variable "vpc_definition" {
  description = "VPC Definition"
    type = object({
      cidr_block = string,
      vpc_name = string,
      public_subnets = number,
      private_subnets = number,
      internet_gateway_name = string
    })
}

variable "health_check_application" {
  type = string
  description = "Health check application endpoint"
}

variable "create_load_balancer" {
  type = bool
  default = false
  description = "Create or not a LB"
}

# variables.tf (add this)
variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS (required if create_load_balancer is true)"
  type        = string
  default     = ""
  
  validation {
    condition     = !var.create_load_balancer || (var.create_load_balancer && var.certificate_arn != "")
    error_message = "certificate_arn is required when create_load_balancer is true"
  }
}

variable "author" {
  type = string
  default = "terraform"
  description = "The author of the resources"
}

variable "allowed_ingress_cidr" {
  type = list(string)
  default = ["0.0.0.0/0"]
  description = "Allowed sources"
}