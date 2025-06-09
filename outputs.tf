# VPC 정보
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR 블록"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  value       = module.vpc.private_subnet_ids
}

# EC2 인스턴스 정보
output "jenkins_instance_id" {
  description = "Jenkins 서버 인스턴스 ID"
  value       = module.ec2.jenkins_instance_id
}

output "jenkins_public_ip" {
  description = "Jenkins 서버 퍼블릭 IP"
  value       = module.ec2.jenkins_public_ip
}

output "jenkins_private_ip" {
  description = "Jenkins 서버 프라이빗 IP"
  value       = module.ec2.jenkins_private_ip
}

output "app_instance_id" {
  description = "애플리케이션 서버 인스턴스 ID"
  value       = module.ec2.app_instance_id
}

output "app_public_ip" {
  description = "애플리케이션 서버 퍼블릭 IP"
  value       = module.ec2.app_public_ip
}

output "app_private_ip" {
  description = "애플리케이션 서버 프라이빗 IP"
  value       = module.ec2.app_private_ip
}

# 보안 그룹 정보
output "jenkins_security_group_id" {
  description = "Jenkins 보안 그룹 ID"
  value       = module.security_groups.jenkins_sg_id
}

output "app_security_group_id" {
  description = "애플리케이션 보안 그룹 ID"
  value       = module.security_groups.app_sg_id
}

# SSH 키 정보
output "key_pair_name" {
  description = "SSH 키 페어 이름"
  value       = module.key_pair.key_name
}

# 접속 정보
output "jenkins_url" {
  description = "Jenkins 웹 인터페이스 URL"
  value       = "http://${module.ec2.jenkins_public_ip}:8080"
}

output "app_url" {
  description = "애플리케이션 URL"
  value       = "http://${module.ec2.app_public_ip}:8080"
}

# SSH 접속 명령어
output "ssh_commands" {
  description = "SSH 접속 명령어"
  value = {
    jenkins = "ssh -i ~/.ssh/your-private-key ec2-user@${module.ec2.jenkins_public_ip}"
    app     = "ssh -i ~/.ssh/your-private-key ec2-user@${module.ec2.app_public_ip}"
  }
}

# 배포 완료 메시지
output "deployment_info" {
  description = "배포 완료 정보"
  value = <<-EOT
    
    🎉 인프라 배포가 완료되었습니다!
    
    📋 접속 정보:
    - Jenkins 서버: http://${module.ec2.jenkins_public_ip}:8080
    - 애플리케이션 서버: http://${module.ec2.app_public_ip}:8080
    
    🔑 SSH 접속:
    - Jenkins: ssh -i ~/.ssh/your-private-key ec2-user@${module.ec2.jenkins_public_ip}
    - App: ssh -i ~/.ssh/your-private-key ec2-user@${module.ec2.app_public_ip}
    
    ⚙️ 다음 단계:
    1. Jenkins 초기 설정 (관리자 패스워드: /var/lib/jenkins/secrets/initialAdminPassword)
    2. Docker 설치 및 설정
    3. GitHub 웹훅 설정
    4. Jenkins 파이프라인 구성
    
  EOT
} 