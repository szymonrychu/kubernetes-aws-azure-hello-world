module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = var.environment_name
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  # cost saving measures (1 NAT gateway instead of 3)
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_ipv6          = false
  enable_dhcp_options  = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                        = 1
    "kubernetes.io/cluster/${var.environment_name}" = "owned"
  }

  tags = var.tags
}
