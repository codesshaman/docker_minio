name = MiniO S3

NO_COLOR=\033[0m		# Color Reset
COLOR_OFF='\e[0m'       # Color Off
OK_COLOR=\033[32;01m	# Green Ok
ERROR_COLOR=\033[31;01m	# Error red
WARN_COLOR=\033[33;01m	# Warning yellow
RED='\e[1;31m'          # Red
GREEN='\e[1;32m'        # Green
YELLOW='\e[1;33m'       # Yellow
BLUE='\e[1;34m'         # Blue
PURPLE='\e[1;35m'       # Purple
CYAN='\e[1;36m'         # Cyan
WHITE='\e[1;37m'        # White
UCYAN='\e[4;36m'        # Cyan
USER_ID = $(shell id -u)
ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

all:
	@printf "Launch configuration ${name}...\n"
	@docker-compose -f ./docker-compose.yml up -d

help:
	@echo -e "$(OK_COLOR)==== All commands of ${name} configuration ====$(NO_COLOR)"
	@echo -e "$(WARN_COLOR)- make				: Launch configuration"
	@echo -e "$(WARN_COLOR)- make bucket			: Create S3 bucket"
	@echo -e "$(WARN_COLOR)- make build			: Building configuration"
	@echo -e "$(WARN_COLOR)- make config			: Show configuration"
	@echo -e "$(WARN_COLOR)- make conn			: Connect to container"
	@echo -e "$(WARN_COLOR)- make down			: Stopping configuration"
	@echo -e "$(WARN_COLOR)- make env			: Create environment"
	@echo -e "$(WARN_COLOR)- make git			: Set user and mail for git"
	@echo -e "$(WARN_COLOR)- make re			: Rebuild configuration"
	@echo -e "$(WARN_COLOR)- make ps			: View configuration"
	@echo -e "$(WARN_COLOR)- make push			: Push changes to the github"
	@echo -e "$(WARN_COLOR)- make clean			: Cleaning configuration$(NO_COLOR)"


bucket:
	@printf "$(OK_COLOR)==== Creating new MinIO bucket ====$(NO_COLOR)\n"
	@$(eval args := $(words $(filter-out --,$(MAKECMDGOALS))))
	@if [ "${args}" -eq 2 ]; then \
		BUCKET_NAME="$(word 2,$(MAKECMDGOALS))"; \
		echo "$(OK_COLOR)📦 Creating bucket '$${BUCKET_NAME}'...$(NO_COLOR)"; \
		docker compose exec -T $(MINIO_NAME) \
			mc alias set local http://localhost:9000 $(MINIO_USER) $(MINIO_PASS) >/dev/null 2>&1; \
		docker compose exec -T $(MINIO_NAME) \
			mc mb --ignore-existing local/$${BUCKET_NAME}; \
		echo "$(OK_COLOR)✅ Bucket '$${BUCKET_NAME}' created or already exists.$(NO_COLOR)"; \
	elif [ "${args}" -gt 2 ]; then \
		echo "$(ERROR_COLOR)❌ The bucket name must not contain spaces!$(NO_COLOR)"; \
	else \
		echo "$(ERROR_COLOR)⚠️  Enter the bucket name! Example: make create-bucket mybucket$(NO_COLOR)"; \
	fi

build:
	@printf "$(OK_COLOR)==== Building configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml up -d --build

config:
	@printf "$(OK_COLOR)==== Wiew container configuration... ====$(NO_COLOR)\n"
	@docker-compose config

con:
	@printf "$(OK_COLOR)==== Connect to database ${name}... ====$(NO_COLOR)\n"
	@docker exec -it minio bash

conn:
	@printf "$(OK_COLOR)==== Connect to database ${name}... ====$(NO_COLOR)\n"
	@docker exec -it minio bash

down:
	@printf "$(ERROR_COLOR)==== Stopping configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml down

env:
	@printf "$(WARN_COLOR)==== Create environment file for ${name}... ====$(NO_COLOR)\n"
	@if [ -f .env ]; then \
		echo "$(ERROR_COLOR).env file already exists!$(NO_COLOR)"; \
	else \
		cp .env.example .env; \
		echo "USER_ID=${USER_ID}" >> .env && \
		echo "$(OK_COLOR).env file successfully created!$(NO_COLOR)"; \
	fi

git:
	@printf "$(YELLOW)==== Set user name and email to git for ${name} repo... ====$(NO_COLOR)\n"
	@bash scripts/gituser.sh

re:	down
	@printf "$(OK_COLOR)==== Rebuild configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml up -d --build

ps:
	@printf "$(BLUE)==== View configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml ps

push:
	@bash scripts/push.sh

clean: down
	@printf "$(ERROR_COLOR)==== Cleaning configuration ${name}... ====$(NO_COLOR)\n"
	@yes | docker system prune -a

fclean:
	@printf "$(ERROR_COLOR)==== Total clean of all configurations docker ====$(NO_COLOR)\n"
	# Uncommit if necessary:
	# @docker stop $$(docker ps -qa)
	# @docker system prune --all --force --volumes
	# @docker network prune --force
	# @docker volume prune --force

.PHONY	: all help build conn down re ps clean fclean
