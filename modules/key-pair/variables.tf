variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
}

variable "public_key" {
  description = "SSH 공개 키"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
} 