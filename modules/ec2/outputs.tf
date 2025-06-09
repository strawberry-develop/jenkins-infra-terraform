# Jenkins 인스턴스 정보
output "jenkins_instance_id" {
  description = "Jenkins 인스턴스 ID"
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Jenkins 퍼블릭 IP"
  value       = length(aws_eip.jenkins) > 0 ? aws_eip.jenkins[0].public_ip : aws_instance.jenkins.public_ip
}

output "jenkins_private_ip" {
  description = "Jenkins 프라이빗 IP"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_public_dns" {
  description = "Jenkins 퍼블릭 DNS"
  value       = aws_instance.jenkins.public_dns
}

# 애플리케이션 인스턴스 정보
output "app_instance_id" {
  description = "애플리케이션 인스턴스 ID"
  value       = aws_instance.app.id
}

output "app_public_ip" {
  description = "애플리케이션 퍼블릭 IP"
  value       = length(aws_eip.app) > 0 ? aws_eip.app[0].public_ip : aws_instance.app.public_ip
}

output "app_private_ip" {
  description = "애플리케이션 프라이빗 IP"
  value       = aws_instance.app.private_ip
}

output "app_public_dns" {
  description = "애플리케이션 퍼블릭 DNS"
  value       = aws_instance.app.public_dns
}

# Elastic IP 정보
output "jenkins_eip" {
  description = "Jenkins Elastic IP (할당된 경우)"
  value       = length(aws_eip.jenkins) > 0 ? aws_eip.jenkins[0].public_ip : null
}

output "app_eip" {
  description = "애플리케이션 Elastic IP (할당된 경우)"
  value       = length(aws_eip.app) > 0 ? aws_eip.app[0].public_ip : null
} 