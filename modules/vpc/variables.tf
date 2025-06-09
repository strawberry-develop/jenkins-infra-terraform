variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "azs" {
  description = "사용할 가용 영역 리스트"
  type        = list(string)
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
} 