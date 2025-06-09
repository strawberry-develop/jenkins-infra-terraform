# SSH 키 페어 생성
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-${var.environment}-keypair"
  public_key = var.public_key

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-keypair"
    Type = "SSH-KeyPair"
  })
} 