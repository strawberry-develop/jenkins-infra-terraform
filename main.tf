# Terraform 설정
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider 설정
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}

# 데이터 소스: 사용 가능한 AZ 조회
data "aws_availability_zones" "available" {
  state = "available"
}

# 데이터 소스: 최신 Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 로컬 변수
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

# VPC 모듈
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  azs          = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = local.common_tags
}

# 키 페어 모듈
module "key_pair" {
  source = "./modules/key-pair"

  project_name = var.project_name
  environment  = var.environment
  public_key   = var.public_key

  tags = local.common_tags
}

# 보안 그룹 모듈
module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  allowed_cidr_blocks     = var.allowed_cidr_blocks
  ssh_allowed_cidr_blocks = var.ssh_allowed_cidr_blocks

  tags = local.common_tags
}

# EC2 인스턴스 모듈
module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  environment        = var.environment
  ami_id            = data.aws_ami.amazon_linux.id
  instance_type     = var.instance_type
  key_name          = module.key_pair.key_name
  
  # 서브넷 및 보안 그룹
  public_subnet_ids = module.vpc.public_subnet_ids
  jenkins_sg_id     = module.security_groups.jenkins_sg_id
  app_sg_id         = module.security_groups.app_sg_id
  
  # 스토리지 설정
  jenkins_volume_size = var.jenkins_volume_size
  app_volume_size     = var.app_volume_size

  tags = local.common_tags
} 