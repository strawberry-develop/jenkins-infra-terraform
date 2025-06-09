# 기본 설정 변수
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "springboot-cicd"
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "리소스 소유자"
  type        = string
  default     = "devops-team"
}

# 네트워크 설정
variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

# EC2 설정
variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.medium"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium", "t3.large",
      "t3a.micro", "t3a.small", "t3a.medium", "t3a.large",
      "m5.large", "m5.xlarge", "m5.2xlarge"
    ], var.instance_type)
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "public_key" {
  description = "EC2 인스턴스 접근용 SSH 공개 키"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.public_key) > 0
    error_message = "Public key cannot be empty."
  }
}

# Jenkins 설정
variable "jenkins_volume_size" {
  description = "Jenkins 서버 EBS 볼륨 크기 (GB)"
  type        = number
  default     = 20
  
  validation {
    condition     = var.jenkins_volume_size >= 20 && var.jenkins_volume_size <= 1000
    error_message = "Jenkins volume size must be between 20 and 1000 GB."
  }
}

# Application 서버 설정
variable "app_volume_size" {
  description = "애플리케이션 서버 EBS 볼륨 크기 (GB)"
  type        = number
  default     = 20
  
  validation {
    condition     = var.app_volume_size >= 20 && var.app_volume_size <= 1000
    error_message = "Application volume size must be between 20 and 1000 GB."
  }
}

# 네트워크 보안 설정
variable "allowed_cidr_blocks" {
  description = "Jenkins 웹 인터페이스 접근 허용 CIDR 블록"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # 프로덕션에서는 특정 IP로 제한 권장
}

variable "ssh_allowed_cidr_blocks" {
  description = "SSH 접근 허용 CIDR 블록"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # 프로덕션에서는 특정 IP로 제한 권장
}

# 태깅 설정
variable "additional_tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
} 