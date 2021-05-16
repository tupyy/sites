###################################
# Custom mk for postgres setup    #
###################################

run.postgres: run.postgres.docker
run.postgres.stop: run.postgres.docker.stop
setup.postgres: setup.init setup.postgres.paperless
setup.postgres.paperless: setup.paperless.init setup.paperless.role setup.paperless.user

###############
# Run targets #
###############
DB_HOST=localhost
DB_PORT=5432
DOCKER_CMD=docker
CONTAINER_NAME=postgresql
IMAGE_NAME=postgres
IMAGE_TAG=13
PG_NETWORK=pg_network
PG_DATA=/home/cosmin/tmp/pgdata
ROOT_USER=postgres
USER_ID=$(shell id `whoami` -u)
GROUP_ID=$(shell id `whoami` -g)
RESOURCE_ADMIN_USER=resources_admin
RESOURCE_ADMIN_PWD=$(shell cat $(CURDIR)/.pgpass | grep $(RESOURCE_ADMIN_USER) | cut -d":" -f5)

.PHONY: run.postgres.docker run.postgres.docker.stop run.postgres.docker.restart

#help run.postgres.docker: run postgres using docker
run.postgres.docker:
	$(DOCKER_CMD) network create -d bridge $(PG_NETWORK)
	$(DOCKER_CMD) run --rm -d -p $(DB_PORT):5432 \
	--network=$(PG_NETWORK) \
	-e POSTGRES_USER=$(ROOT_USER) \
	-e POSTGRES_PASSWORD=$(ROOT_PWD) \
	-e VERBOSE=1 \
	-v $(PG_DATA):/var/lib/postgresql/data \
	--user $(USER_ID):$(GROUP_ID) \
	--name $(CONTAINER_NAME) $(IMAGE_NAME):$(IMAGE_TAG)

#help run.postgres.docker.logs: show logs from postgres
run.postgres.docker.logs:
	docker logs	-f $(CONTAINER_NAME)

#help run.postgres.docker.stop: stop postgres docker
run.postgres.docker.stop:
	docker stop postgresql
	docker network rm $(PG_NETWORK)

#help run.postgres.docker.restart: run.postgres.docker.restart
run.postgres.docker.restart: run.postgres.docker.stop run.postgres.docker


#################
# Setup targets #
#################

PGPASSFILE=$(CURDIR)/.pgpass
PSQL_COMMAND=PGPASSFILE=$(PGPASSFILE) psql --quiet --host=$(DB_HOST) --port=$(DB_PORT) --dbname=postgres -v ON_ERROR_STOP=on

.PHONY: postgres.setup.init 

#help postgres.setup.init: init the database
postgres.setup.init:
	$(PSQL_COMMAND) --user=$(ROOT_USER) \
		-v resources_admin_pwd="'$(RESOURCE_ADMIN_PWD)'" \
		-f sql/setup/init.sql


###################
# Setup paperless #
###################

PAPERLESS_SERVICE_USER=paperless
PAPERLESS_SERVICE_PWD=$(shell cat $(CURDIR)/.pgpass | grep $(RESOURCE_ADMIN_USER) | cut -d":" -f5)

.PHONY: postgres.setup.paperless.clean postgres.setup.paperless.init postgres.setup.paperless.role postgres.setup.paperless.user

#help postgres.setup.clean: cleans postgres from all created resources
postgres.setup.paperless.clean:
	$(PSQL_COMMAND) --user=$(ROOT_USER) -f sql/setup_paperless/clean.sql

#help postgres.setup.paperless.init: init paperless db
postgres.setup.paperless.init:
	$(PSQL_COMMAND) --user=$(RESOURCE_ADMIN_USER) \
		-f sql/setup_paperless/init.sql

#help postgres.setup.paperless.role: init postgres roles for paperless
postgres.setup.paperless.role:
	$(PSQL_COMMAND) --user=$(RESOURCE_ADMIN_USER) \
		-f sql/setup_paperless/postgres_roles.sql

#help postgres.setup.users: init postgres users
postgres.setup.paperless.user:
	$(PSQL_COMMAND) --user=$(RESOURCE_ADMIN_USER) \
		-v paperless_service_pwd="'$(PAPERLESS_SERVICE_PWD)'" \
		-f sql/setup_paperless/postgres_users.sql

