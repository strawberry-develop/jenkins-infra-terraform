variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
}

variable "key_name" {
  description = "SSH 키 페어 이름"
  type        = string
}

variable "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 리스트"
  type        = list(string)
}

variable "jenkins_sg_id" {
  description = "Jenkins 보안 그룹 ID"
  type        = string
}

variable "app_sg_id" {
  description = "애플리케이션 보안 그룹 ID"
  type        = string
}

variable "jenkins_volume_size" {
  description = "Jenkins 서버 EBS 볼륨 크기 (GB)"
  type        = number
  default     = 30
}

variable "app_volume_size" {
  description = "애플리케이션 서버 EBS 볼륨 크기 (GB)"
  type        = number
  default     = 20
}

variable "enable_jenkins_eip" {
  description = "Jenkins 서버에 Elastic IP 할당 여부"
  type        = bool
  default     = false
}

variable "enable_app_eip" {
  description = "애플리케이션 서버에 Elastic IP 할당 여부"
  type        = bool
  default     = false
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
} 