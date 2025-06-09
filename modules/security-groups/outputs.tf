output "jenkins_sg_id" {
  description = "Jenkins 보안 그룹 ID"
  value       = aws_security_group.jenkins.id
}

output "app_sg_id" {
  description = "애플리케이션 보안 그룹 ID"
  value       = aws_security_group.app.id
}

output "alb_sg_id" {
  description = "ALB 보안 그룹 ID"
  value       = aws_security_group.alb.id
}

output "jenkins_sg_arn" {
  description = "Jenkins 보안 그룹 ARN"
  value       = aws_security_group.jenkins.arn
}

output "app_sg_arn" {
  description = "애플리케이션 보안 그룹 ARN"
  value       = aws_security_group.app.arn
}

output "alb_sg_arn" {
  description = "ALB 보안 그룹 ARN"
  value       = aws_security_group.alb.arn
} 