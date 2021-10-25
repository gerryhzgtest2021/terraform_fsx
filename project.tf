data "aws_ami" "sample" {
  owners     = ["amazon"]
  name_regex = "amzn2-ami-hvm-2\\.0\\.20210525\\.0-x86_64-gp2"
}

locals {
  aws_region = "us-east-1"
  env_code   = "test"
}

provider "aws" {
  region = local.aws_region
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "3.2.0"
  azs                  = ["us-east-1a", "us-east-1b"]
  name                 = "${local.env_code}-vpc"
  private_subnets      = ["10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.0.0/24", "10.0.1.0/24"]
  cidr                 = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_classiclink   = false
  enable_nat_gateway   = true
}

resource "aws_fsx_ontap_file_system" "test" {
  storage_capacity    = 1024
  subnet_ids          = module.vpc.private_subnets
  deployment_type     = "MULTI_AZ_1"
  throughput_capacity = 512
  preferred_subnet_id = module.vpc.private_subnets[0]
  tags = {
    Name = "${local.env_code}-fsx-ontap"
  }
}
