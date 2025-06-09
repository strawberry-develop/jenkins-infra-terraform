.PHONY: help init plan apply destroy validate fmt lint clean dev staging prod

# 기본 변수
ENV ?= dev
TERRAFORM_DIR := .
VAR_FILE := environments/$(ENV)/terraform.tfvars

# 색상 정의
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
RESET := \033[0m

help: ## 도움말 표시
	@echo "$(BLUE)Spring Boot CI/CD Infrastructure$(RESET)"
	@echo ""
	@echo "$(GREEN)사용 가능한 명령어:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-15s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(GREEN)환경별 배포:$(RESET)"
	@echo "  $(YELLOW)make dev$(RESET)        개발 환경 배포"
	@echo "  $(YELLOW)make staging$(RESET)    스테이징 환경 배포"
	@echo "  $(YELLOW)make prod$(RESET)       프로덕션 환경 배포"
	@echo ""
	@echo "$(GREEN)예시:$(RESET)"
	@echo "  $(YELLOW)make init ENV=dev$(RESET)"
	@echo "  $(YELLOW)make plan ENV=prod$(RESET)"
	@echo "  $(YELLOW)make apply ENV=staging$(RESET)"

init: ## Terraform 초기화
	@echo "$(BLUE)Terraform 초기화 중... (환경: $(ENV))$(RESET)"
	@cd $(TERRAFORM_DIR) && terraform init
	@echo "$(GREEN)✅ 초기화 완료$(RESET)"

validate: ## Terraform 설정 검증
	@echo "$(BLUE)Terraform 설정 검증 중...$(RESET)"
	@cd $(TERRAFORM_DIR) && terraform validate
	@echo "$(GREEN)✅ 검증 완료$(RESET)"

fmt: ## Terraform 코드 포맷팅
	@echo "$(BLUE)Terraform 코드 포맷팅 중...$(RESET)"
	@cd $(TERRAFORM_DIR) && terraform fmt -recursive
	@echo "$(GREEN)✅ 포맷팅 완료$(RESET)"

plan: ## Terraform 실행 계획 확인
	@echo "$(BLUE)Terraform 실행 계획 생성 중... (환경: $(ENV))$(RESET)"
	@if [ ! -f $(VAR_FILE) ]; then \
		echo "$(RED)❌ 변수 파일을 찾을 수 없습니다: $(VAR_FILE)$(RESET)"; \
		echo "$(YELLOW)terraform.tfvars.example을 복사하여 $(VAR_FILE)을 생성하세요$(RESET)"; \
		exit 1; \
	fi
	@cd $(TERRAFORM_DIR) && terraform plan -var-file=$(VAR_FILE) -out=tfplan-$(ENV)
	@echo "$(GREEN)✅ 실행 계획 생성 완료$(RESET)"

apply: ## Terraform 적용
	@echo "$(BLUE)Terraform 적용 중... (환경: $(ENV))$(RESET)"
	@if [ ! -f $(VAR_FILE) ]; then \
		echo "$(RED)❌ 변수 파일을 찾을 수 없습니다: $(VAR_FILE)$(RESET)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)⚠️  $(ENV) 환경에 인프라를 배포합니다. 계속하시겠습니까? [y/N]$(RESET)"
	@read -r CONFIRM && [ "$$CONFIRM" = "y" ] || [ "$$CONFIRM" = "Y" ] || (echo "$(RED)배포가 취소되었습니다$(RESET)" && exit 1)
	@cd $(TERRAFORM_DIR) && terraform apply -var-file=$(VAR_FILE) -auto-approve
	@echo "$(GREEN)✅ 배포 완료$(RESET)"

destroy: ## Terraform 리소스 삭제
	@echo "$(RED)⚠️  경고: $(ENV) 환경의 모든 리소스를 삭제합니다!$(RESET)"
	@echo "$(YELLOW)정말로 삭제하시겠습니까? [y/N]$(RESET)"
	@read -r CONFIRM && [ "$$CONFIRM" = "y" ] || [ "$$CONFIRM" = "Y" ] || (echo "$(RED)삭제가 취소되었습니다$(RESET)" && exit 1)
	@cd $(TERRAFORM_DIR) && terraform destroy -var-file=$(VAR_FILE) -auto-approve
	@echo "$(GREEN)✅ 리소스 삭제 완료$(RESET)"

output: ## Terraform 출력값 확인
	@echo "$(BLUE)Terraform 출력값 조회 중...$(RESET)"
	@cd $(TERRAFORM_DIR) && terraform output
	@echo "$(GREEN)✅ 출력값 조회 완료$(RESET)"

clean: ## 임시 파일 정리
	@echo "$(BLUE)임시 파일 정리 중...$(RESET)"
	@rm -f tfplan-*
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@echo "$(GREEN)✅ 정리 완료$(RESET)"

lint: ## Terraform 린트 검사
	@echo "$(BLUE)Terraform 린트 검사 중...$(RESET)"
	@cd $(TERRAFORM_DIR) && terraform fmt -check -recursive
	@cd $(TERRAFORM_DIR) && terraform validate
	@echo "$(GREEN)✅ 린트 검사 완료$(RESET)"

# 환경별 단축 명령어
dev: ## 개발 환경 배포
	@$(MAKE) apply ENV=dev

staging: ## 스테이징 환경 배포
	@$(MAKE) apply ENV=staging

prod: ## 프로덕션 환경 배포
	@$(MAKE) apply ENV=prod

# SSH 접속 명령어
ssh-jenkins: ## Jenkins 서버에 SSH 접속
	@echo "$(BLUE)Jenkins 서버 IP 조회 중...$(RESET)"
	@JENKINS_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw jenkins_public_ip 2>/dev/null) && \
	if [ -n "$$JENKINS_IP" ]; then \
		echo "$(GREEN)Jenkins 서버에 접속 중... ($$JENKINS_IP)$(RESET)"; \
		ssh -i ~/.ssh/your-private-key ec2-user@$$JENKINS_IP; \
	else \
		echo "$(RED)❌ Jenkins 서버 IP를 찾을 수 없습니다. 먼저 인프라를 배포하세요.$(RESET)"; \
	fi

ssh-app: ## 애플리케이션 서버에 SSH 접속
	@echo "$(BLUE)애플리케이션 서버 IP 조회 중...$(RESET)"
	@APP_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw app_public_ip 2>/dev/null) && \
	if [ -n "$$APP_IP" ]; then \
		echo "$(GREEN)애플리케이션 서버에 접속 중... ($$APP_IP)$(RESET)"; \
		ssh -i ~/.ssh/your-private-key ec2-user@$$APP_IP; \
	else \
		echo "$(RED)❌ 애플리케이션 서버 IP를 찾을 수 없습니다. 먼저 인프라를 배포하세요.$(RESET)"; \
	fi

# 설정 파일 생성
setup: ## 초기 설정 파일 생성
	@echo "$(BLUE)초기 설정 파일 생성 중...$(RESET)"
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "$(GREEN)✅ terraform.tfvars 파일이 생성되었습니다$(RESET)"; \
		echo "$(YELLOW)⚠️  terraform.tfvars 파일을 편집하여 SSH 공개 키를 설정하세요$(RESET)"; \
	else \
		echo "$(YELLOW)terraform.tfvars 파일이 이미 존재합니다$(RESET)"; \
	fi 