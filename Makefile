DOCKER_COMPOSE_CMD = docker-compose
RAILS_DOCKER_CMD = ${DOCKER_COMPOSE_CMD} exec -e POSTGRES_HOST=db web bundle exec rails

start:
	$(DOCKER_COMPOSE_CMD) up --build

stop:
	$(DOCKER_COMPOSE_CMD) down

reset_database:
	$(RAILS_DOCKER_CMD) db:reset
