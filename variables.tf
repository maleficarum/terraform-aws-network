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
