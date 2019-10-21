#!/usr/bin/make
# Makefile readme (ru): <http://linux.yaroslavl.ru/docs/prog/gnu_make_3-79_russian_manual.html>
# Makefile readme (en): <https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents>

# [ -f (pwd)/.env ] && include .env || include .env.example;
COPY_ENV := $(shell [ -f .env ] || cp .env.example .env)

include .env
export

MYSQL_DUMP := $(REMOTE_HOST):$(REMOTE_DUMP_PATH)/db.sql
RSYNC_ROOT := $(REMOTE_HOST):/home/bitrix/www/

MYSQL_CONTAINER_NAME := $(shell docker ps --filter name=mysql --format {{.Names}})

SHELL = /bin/sh

BACKUP_NAME := db
CURRENT_TIME := $(shell date --iso=seconds)

docker_bin := $(shell command -v docker 2> /dev/null)
docker_compose_bin := $(shell command -v docker-compose 2> /dev/null)

.DEFAULT_GOAL := help

# This will output the help for each task. thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n  Allowed for overriding next properties:\n\n\
		Usage example:\n\
		make up"

# --- [ Application ] -------------------------------------------------------------------------------------------------

init: rsync restore-first app-composer-install ## init project

rsync: ## rsync bitrix folder
	@echo "Starting rsync bitrix and upload folders"
	rsync -avz --exclude 'bitrix/backup/' --exclude 'bitrix/*cache/' $(RSYNC_ROOT)/bitrix ./src/app/
	rsync -av --exclude 'upload/disk/' $(RSYNC_ROOT)/upload ./src/app/

# --- [ MySQL ] -------------------------------------------------------------------------------------------------

restore-first: download-dump create-database restore-mysql ## dowload dump and restore mysql database

update-db: get-fresh-dump restore-mysql # update mysql database from remote

get-fresh-dump: create-dump download-dump ## create and download dump

create-dump:  ## create mysql dump on remote
	@echo "Starting create database dump"
	ssh -p $(REMOTE_PORT) $(REMOTE_HOST) 'mysqldump --user=$(REMOTE_DB_LOGIN) --password="$(REMOTE_DB_PASSWORD)" $(REMOTE_DB_NAME) > $(REMOTE_DUMP_PATH)/$(BACKUP_NAME).sql'

download-dump:  ## restore mysql database
	@echo "Starting download database dump"
	scp $(MYSQL_DUMP) ./data/backup/db.sql

create-database:
	docker exec -it $(MYSQL_CONTAINER_NAME) sh -c "echo 'CREATE DATABASE db CHARACTER SET utf8 COLLATE utf8_unicode_ci;' | mysql -u root -p$(MYSQL_ROOT_PASSWORD)"

restore-mysql:  ## restore mysql database
	@echo "Starting restore MySQL database"
	docker exec -it $(MYSQL_CONTAINER_NAME) sh -c "mysql -u root -p$(MYSQL_ROOT_PASSWORD) db < /backup/$(BACKUP_NAME).sql"

backup-mysql:  ## backup mysql database
	@echo "Starting backup MySQL database"
	docker exec -it $(MYSQL_CONTAINER_NAME) sh -c "mkdir -p /backup/$(CURRENT_TIME)" \
		&& docker exec -it $(MYSQL_CONTAINER_NAME) \
			sh -c "mysqldump -u root -p$(MYSQL_ROOT_PASSWORD) db > /backup/$(CURRENT_TIME)/$(BACKUP_NAME).sql"

# --- [ Docker ] -------------------------------------------------------------------------------------------------

build: ## rebuild all containers
	$(docker_compose_bin) build

up: build ## rebuild and up all containers
	$(docker_compose_bin) up -d --remove-orphans

down: ## down all containers
	$(docker_compose_bin) down

restart: build down up ## rebuild and restart all containers

stop: ## stop all containers
	@$(docker_bin) ps -aq | xargs $(docker_bin) stop

app-composer-install: ## front composer install
	@cd ./src/app && composer install

app-composer: ## front composer update
	@cd ./src/app && composer update

# --- [ Documentation ] -------------------------------------------------------------------------------------------------

build-doc: ## build doc
	@cd ./doc && npm i npm audit fix --force && vuepress build src

doc-export: ## export doc to single docx file
	@cd ./doc && $(docker_compose_bin) run --rm foliant make docx

dev-doc: ## dev doc
	vuepress dev ./doc/src
