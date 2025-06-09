# Jenkins 서버 인스턴스
resource "aws_instance" "jenkins" {
  ami                     = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.jenkins_sg_id]

  # 스토리지 설정
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.jenkins_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.tags, {
      Name = "${var.project_name}-${var.environment}-jenkins-volume"
    })
  }

  # 사용자 데이터 스크립트 (Jenkins 및 Docker 설치)
  user_data = base64encode(templatefile("${path.module}/user-data/jenkins-setup.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  # 메타데이터 옵션
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-jenkins-server"
    Type = "Jenkins"
    Role = "CI/CD"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami]
  }
}

# 애플리케이션 서버 인스턴스
resource "aws_instance" "app" {
  ami                     = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[1 % length(var.public_subnet_ids)]
  vpc_security_group_ids = [var.app_sg_id]

  # 스토리지 설정
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.app_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.tags, {
      Name = "${var.project_name}-${var.environment}-app-volume"
    })
  }

  # 사용자 데이터 스크립트 (Docker 설치)
  user_data = base64encode(templatefile("${path.module}/user-data/app-setup.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  # 메타데이터 옵션
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-server"
    Type = "Application"
    Role = "SpringBoot"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami]
  }
}

# Elastic IP for Jenkins (선택사항)
resource "aws_eip" "jenkins" {
  count    = var.enable_jenkins_eip ? 1 : 0
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-jenkins-eip"
  })

  depends_on = [aws_instance.jenkins]
}

# Elastic IP for App (선택사항)
resource "aws_eip" "app" {
  count    = var.enable_app_eip ? 1 : 0
  instance = aws_instance.app.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-eip"
  })

  depends_on = [aws_instance.app]
} 