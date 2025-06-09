#!/bin/bash

# 로그 설정
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Application Server Setup Started ==="
echo "Project: ${project_name}"
echo "Environment: ${environment}"

# 시스템 업데이트
echo "Updating system packages..."
yum update -y

# 필수 패키지 설치
echo "Installing essential packages..."
yum install -y \
    git \
    wget \
    curl \
    unzip \
    java-11-amazon-corretto \
    htop \
    tree \
    nc

# Docker 설치
echo "Installing Docker..."
yum install -y docker
systemctl start docker
systemctl enable docker

# ec2-user를 docker 그룹에 추가
usermod -aG docker ec2-user

# Docker Compose 설치
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 환경 변수 설정
cat >> /etc/environment << EOF
JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto
PATH=$JAVA_HOME/bin:$PATH
EOF

# 애플리케이션 배포 디렉토리 생성
mkdir -p /opt/app
chown ec2-user:ec2-user /opt/app

# Docker 네트워크 생성 (애플리케이션용)
docker network create app-network || true

# 로그 디렉토리 생성
mkdir -p /var/log/springboot
chown ec2-user:ec2-user /var/log/springboot

# Nginx 설치 (리버스 프록시용 - 옵션)
echo "Installing Nginx..."
yum install -y nginx

# Nginx 기본 설정 (Spring Boot 앱으로 프록시)
cat > /etc/nginx/conf.d/springboot.conf << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 헬스체크 타임아웃 설정
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 헬스체크 엔드포인트
    location /health {
        proxy_pass http://localhost:8080/actuator/health;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Nginx 서비스 시작 및 활성화
systemctl start nginx
systemctl enable nginx

# 배포 스크립트 생성
cat > /opt/app/deploy.sh << 'EOF'
#!/bin/bash

APP_NAME="springboot-app"
IMAGE_NAME="${project_name}-app"
CONTAINER_NAME="$${APP_NAME}-container"

echo "Starting deployment of $${APP_NAME}..."

# 기존 컨테이너 중지 및 제거
if [ $(docker ps -q -f name=$${CONTAINER_NAME}) ]; then
    echo "Stopping existing container..."
    docker stop $${CONTAINER_NAME}
fi

if [ $(docker ps -aq -f name=$${CONTAINER_NAME}) ]; then
    echo "Removing existing container..."
    docker rm $${CONTAINER_NAME}
fi

# 이미지 pull (Jenkins에서 push한 최신 이미지)
echo "Pulling latest image..."
docker pull $${IMAGE_NAME}:latest || {
    echo "Failed to pull image. Using existing local image if available."
}

# 새 컨테이너 실행
echo "Starting new container..."
docker run -d \
    --name $${CONTAINER_NAME} \
    --network app-network \
    -p 8080:8080 \
    -v /var/log/springboot:/app/logs \
    --restart unless-stopped \
    $${IMAGE_NAME}:latest

# 컨테이너 상태 확인
sleep 10
if [ $(docker ps -q -f name=$${CONTAINER_NAME}) ]; then
    echo "Container started successfully!"
    docker ps | grep $${CONTAINER_NAME}
else
    echo "Failed to start container!"
    docker logs $${CONTAINER_NAME}
    exit 1
fi

# 헬스체크
echo "Performing health check..."
for i in {1..30}; do
    if curl -f http://localhost:8080/actuator/health > /dev/null 2>&1; then
        echo "Application is healthy!"
        break
    fi
    echo "Waiting for application to start... ($i/30)"
    sleep 5
done

echo "Deployment completed!"
EOF

chmod +x /opt/app/deploy.sh
chown ec2-user:ec2-user /opt/app/deploy.sh

# AWS CLI 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# CloudWatch 에이전트 설치 (옵션)
echo "Installing CloudWatch agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# 시스템 정보 로그
echo "=== System Information ==="
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME)"
echo "Java Version: $(java -version 2>&1 | head -n 1)"
echo "Docker Version: $(docker --version)"
echo "Nginx Status: $(systemctl is-active nginx)"

# 완료 표시 파일 생성
touch /tmp/app-setup-complete

echo "=== Application Server Setup Completed ==="
echo "Server is ready for Spring Boot application deployment"
echo "Access the application at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080" 