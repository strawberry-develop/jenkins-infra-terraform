# Jenkins 서버용 보안 그룹
resource "aws_security_group" "jenkins" {
  name_prefix = "${var.project_name}-${var.environment}-jenkins-"
  vpc_id      = var.vpc_id
  description = "Security group for Jenkins server"

  # HTTP 포트 (Jenkins 웹 인터페이스)
  ingress {
    description = "Jenkins web interface"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Jenkins 에이전트 포트
  ingress {
    description = "Jenkins agent port"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # SSH 접근
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr_blocks
  }

  # Docker 데몬 포트 (필요시)
  ingress {
    description = "Docker daemon"
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-jenkins-sg"
    Type = "Jenkins"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# 애플리케이션 서버용 보안 그룹
resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-${var.environment}-app-"
  vpc_id      = var.vpc_id
  description = "Security group for application server"

  # HTTP 포트 (Spring Boot 애플리케이션)
  ingress {
    description = "Spring Boot application"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP 포트 (대체 포트)
  ingress {
    description = "HTTP alternative"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH 접근
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr_blocks
  }

  # Jenkins 서버로부터의 배포 접근
  ingress {
    description     = "Deployment from Jenkins"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins.id]
  }

  # Docker 포트 (컨테이너 관리용)
  ingress {
    description     = "Docker from Jenkins"
    from_port       = 2376
    to_port         = 2376
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins.id]
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-sg"
    Type = "Application"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ALB용 보안 그룹 (옵션 - 향후 로드밸런서 사용시)
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 트래픽 (타겟 그룹으로)
  egress {
    description = "To application servers"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
    Type = "LoadBalancer"
  })

  lifecycle {
    create_before_destroy = true
  }
} 