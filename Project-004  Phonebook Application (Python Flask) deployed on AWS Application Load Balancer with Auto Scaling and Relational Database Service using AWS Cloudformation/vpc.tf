# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"
  
  # VPC Basic Details
  name             = "vpc-dev"
  cidr             = "10.0.0.0/16"
  instance_tenancy = "default"
  azs              = ["us-east-1a", "us-east-1b"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Type = "public-subnets"
  }

  private_subnet_tags = {
    Type = "private-subnets"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  vpc_tags = {
    Name = "vpc-dev"
  }
}



