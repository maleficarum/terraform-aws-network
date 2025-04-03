variable "vpc_definition" {
  description = "VPC Definition"
    type = object({
      cidr_block = string,
      vpc_name = string,
      public_subnets = number,
      internet_gateway_name = string
    })
}
