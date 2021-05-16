###################################
# If you are using a local installation of postgres, make sure to set a password to the postgres user
# to be able to use it:
#
# > sudo -u postgres psql
# =># \password postgres
###################################

DB_HOST=localhost
DB_PORT=5432

.PHONY: help setup tools generate deploy

help: help.all
tools: tools.get
build: build.docker
run: run.docker
setup: setup.init setup.paperless.role setup.paperless.user


################
# Help targets #
################

.PHONY: help.highlevel help.all

# Colors used in this Makefile
escape=$(shell printf '\033')
RESET_COLOR=$(escape)[0m
COLOR_YELLOW=$(escape)[38;5;220m
COLOR_BLUE=$(escape)[94m
COLOR_RED=$(escape)[91m

#help help.highlevel: show help for high level targets. Use 'make help.all' to display all help messages
help.highlevel:
	@grep -hE '^[a-z_-]+:' $(MAKEFILE_LIST) | LANG=C sort -d | \
	awk 'BEGIN {FS = ":"}; {printf("$(COLOR_YELLOW)%-25s$(RESET_COLOR) %s\n", $$1, $$2)}'

#help help.all: display all targets' help messages
help.all:
	@grep -hE '^#help|^[a-z_-]+:' $(MAKEFILE_LIST) | sed "s/#help //g" | LANG=C sort -d | \
	awk 'BEGIN {FS = ":"}; {if ($$1 ~ /\./) printf("    $(COLOR_BLUE)%-21s$(RESET_COLOR) %s\n", $$1, $$2); else printf("$(COLOR_YELLOW)%-25s$(RESET_COLOR) %s\n", $$1, $$2)}'


#################
# Build targets #
#################


.PHONY: build.docker build.get.imagename build.get.tag

#help build.docker.local: build docker image for local dev
build.docker:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f local/Dockerfile .

#help build.get.imagename: Allows to get the name of the service (for the CI)
build.get.imagename:
	@echo -n $(IMAGE_NAME)

#help build.get.tag: Allows to get the tag of the service (for the CI)
build.get.tag:
	@echo -n $(IMAGE_TAG)


###############
# Run targets #
###############

CONTAINER_NAME=postgresql
IMAGE_NAME=postgres
IMAGE_TAG=13
PG_DATA=/home/cosmin/tmp/pgdata
ROOT_USER=postgres
ROOT_PWD=$(shell cat $(CUR_DIR)/.root_pass)
RESOURCE_ADMIN_USER=resources_admin
RESOURCE_ADMIN_PWD=$(shell cat $(CUR_DIR)/.pgpass)

.PHONY: run.docker run.docker.stop run.docker.restart

#help run.docker: run postgres using docker
run.docker:
	@docker run --rm -d \ 
	-p $(DB_PORT):5432 \
	-e PGDATA=$(PG_DATA) \
	-e POSTGRES_USER=$(ROOT_USER) \
	-e POSTGRES_PASSWORD=$(ROOT_PWD) \
	-e VERBOSE=1 \
	--name $(CONTAINER_NAME) $(IMAGE_NAME):$(IMAGE_TAG)
	docker logs	-f $(CONTAINER_NAME)

#help run.docker.stop: stop postgres docker
run.docker.stop:
	docker stop postgresql

#help run.docker.restart: run.docker.restart
run.docker.restart: run.docker.stop run.docker


#################
# Setup targets #
#################

PAPERLESS_SERVICE_PWD=azerty

PGPASSFILE=$(CURDIR)/sql/.pgpass
PSQL_COMMAND=PGPASSFILE=$(PGPASSFILE) psql --quiet --host=$(DB_HOST) --port=$(DB_PORT) --dbname=postgres -v ON_ERROR_STOP=on

.PHONY: setup.clean setup.init setup.paperless

#help setup.clean: cleans postgres from all created resources
setup.clean:
	$(PSQL_COMMAND) --user=$(ROOT_USER) -f sql/clean/clean.sql

#help setup.init: init the database
setup.init:
	$(PSQL_COMMAND) --user=$(ROOT_USER) \
		-v resources_admin_pwd="'$(RESOURCE_ADMIN_PWD)'" \
		-f sql/setup_device_mgt/init.sql

#help setup.paperless.role: init postgres roles for paperless
setup.paperless.role:
	$(PSQL_COMMAND) --user=$(RESOURCE_ADMIN_USER) \
		-f sql/setup_paperless/postgres_roles.sql

#help setup.users: init postgres users
setup.paperless.user:
	$(PSQL_COMMAND) --user=$(RESOURCE_ADMIN_USER) \
		-v paperless_service_pwd="'$(PAPERLESS_SERVICE_PWD)'" \
		-f sql/setup_paperless/postgres_users.sql

