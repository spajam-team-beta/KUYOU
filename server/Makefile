# KUYOU Server Development Makefile
# Rails API + MySQL + Docker environment

.DEFAULT_GOAL := help

# Docker Compose commands
.PHONY: build up down logs shell console test reset migrate generate clean help

## Docker Environment
build: ## Build and start containers (first time setup)
	docker-compose up --build

up: ## Start containers in background
	docker-compose up -d

down: ## Stop and remove containers
	docker-compose down

logs: ## Show container logs
	docker-compose logs -f

## Database Operations
db-create: ## Create database
	docker-compose exec web rails db:create

db-migrate: ## Run database migrations
	docker-compose exec web rails db:migrate

db-reset: ## Reset database (drop, create, migrate, seed)
	docker-compose exec web rails db:reset

db-seed: ## Seed database with sample data
	docker-compose exec web rails db:seed

db-rollback: ## Rollback last migration
	docker-compose exec web rails db:rollback

## Development Tools
shell: ## Access container shell
	docker-compose exec web bash

console: ## Access Rails console
	docker-compose exec web rails console

## Testing
test: ## Run RSpec tests
	docker-compose exec web rspec

test-verbose: ## Run RSpec tests with verbose output
	docker-compose exec web rspec -f documentation

## Code Generation
generate-migration: ## Generate migration (usage: make generate-migration NAME=CreateUsers)
	docker-compose exec web rails generate migration $(NAME)

generate-model: ## Generate model (usage: make generate-model NAME=User)
	docker-compose exec web rails generate model $(NAME)

generate-controller: ## Generate controller (usage: make generate-controller NAME=Users)
	docker-compose exec web rails generate controller $(NAME)

## Development Workflow
setup: build db-create db-migrate db-seed ## Complete setup for new development environment

restart: down up ## Restart all containers

dev: up logs ## Start development environment and show logs

## Maintenance
clean: ## Remove all containers, images, and volumes
	docker-compose down -v --rmi all

clean-cache: ## Clean Docker cache
	docker system prune -f

## Swagger Documentation
swagger: ## Open Swagger UI (available at http://localhost:8080)
	@echo "Swagger UI available at: http://localhost:8080"
	@echo "API server running at: http://localhost:3000"

## Utility
status: ## Show container status
	docker-compose ps

## Help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)