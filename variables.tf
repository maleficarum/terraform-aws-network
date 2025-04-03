variable "vpc_definition" {
    type = object({
      cidr_block = string,
      vpc_name = string,
      public_subnets = list(string),
      internet_gateway_name = string
    })
}