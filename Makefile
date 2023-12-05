DOCKER_COMPOSE_CMD = docker-compose
RAILS_DOCKER_CMD = ${DOCKER_COMPOSE_CMD} exec -e POSTGRES_HOST=db web bundle exec rails

install:
	$(MAKE) stop
	$(DOCKER_COMPOSE_CMD) up --build -d
	$(MAKE) install_database

start:
	$(DOCKER_COMPOSE_CMD) up -d

stop:
	$(DOCKER_COMPOSE_CMD) down

install_database:
	$(RAILS_DOCKER_CMD) db:create
	$(RAILS_DOCKER_CMD) db:schema:load
	$(RAILS_DOCKER_CMD) db:seed:replant

reset_database:
	$(RAILS_DOCKER_CMD) db:reset

