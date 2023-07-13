DOCKER_COMPOSE_CMD = docker-compose
RAILS_DOCKER_CMD = ${DOCKER_COMPOSE_CMD} exec -e POSTGRES_HOST=db web bundle exec rails

start:
	docker-compose up --build

stop:
	docker-compose down

install_database:
	$(RAILS_DOCKER_CMD) db:create
	$(RAILS_DOCKER_CMD) db:schema:load
	$(RAILS_DOCKER_CMD) db:seed:replant

reinstall_database:
	$(RAILS_DOCKER_CMD) db:drop
	$(MAKE) install_database
