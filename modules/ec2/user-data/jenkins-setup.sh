#!/bin/bash

# 로그 설정
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Jenkins Server Setup Started ==="
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
    java-17-amazon-corretto \
    htop \
    tree

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

# Jenkins 저장소 및 설치
echo "Installing Jenkins..."
wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

yum install -y jenkins

# Jenkins 서비스 시작 및 활성화
systemctl start jenkins
systemctl enable jenkins

# Jenkins가 Docker를 사용할 수 있도록 설정
usermod -aG docker jenkins

# Jenkins 플러그인을 위한 추가 도구 설치
echo "Installing additional tools for Jenkins..."

# Maven 설치
cd /opt
wget https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz
tar -xzf apache-maven-3.8.8-bin.tar.gz
mv apache-maven-3.8.8 maven
chown -R jenkins:jenkins /opt/maven

# 환경 변수 설정
cat >> /etc/environment << EOF
JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
MAVEN_HOME=/opt/maven
PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH
EOF

# Jenkins 사용자를 위한 환경 변수 설정
cat >> /var/lib/jenkins/.bashrc << EOF
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
export MAVEN_HOME=/opt/maven
export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH
EOF

# AWS CLI 설치 (최신 버전)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# 서비스 재시작
systemctl restart jenkins
systemctl restart docker

# 방화벽 설정 (iptables 기반)
echo "Configuring firewall..."

# Jenkins 초기 관리자 패스워드 저장 위치 메모
echo "=== IMPORTANT NOTES ==="
echo "Jenkins initial admin password location: /var/lib/jenkins/secrets/initialAdminPassword"
echo "Jenkins web interface will be available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"

# 시스템 정보 로그
echo "=== System Information ==="
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME)"
echo "Java Version: $(java -version 2>&1 | head -n 1)"
echo "Docker Version: $(docker --version)"
echo "Jenkins Status: $(systemctl is-active jenkins)"

# 완료 표시 파일 생성
touch /tmp/jenkins-setup-complete

echo "=== Jenkins Server Setup Completed ===" 