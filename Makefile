ifeq ($(shell which docker-compose),)
	DOCKER_COMPOSE = docker compose
else
	DOCKER_COMPOSE = docker-compose
endif
RAILS_DOCKER_CMD = ${DOCKER_COMPOSE} exec -e POSTGRES_HOST=db web bundle exec rails

install:
	$(MAKE) stop
	$(DOCKER_COMPOSE) up --build -d
	$(MAKE) install_database

start:
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) down

install_database:
	$(RAILS_DOCKER_CMD) db:create
	$(RAILS_DOCKER_CMD) db:schema:load
	$(RAILS_DOCKER_CMD) db:seed:replant

reset_database:
	$(RAILS_DOCKER_CMD) db:reset

