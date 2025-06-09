variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "Jenkins 웹 인터페이스 접근 허용 CIDR 블록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidr_blocks" {
  description = "SSH 접근 허용 CIDR 블록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
} 