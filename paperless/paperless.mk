###################################
# Custom mk for paperless setup   #
###################################

run.paperless: run.paperless.network run.paperless.broker run.paperless.website

###############
# Run targets #
###############
DOCKER_CMD=docker

DB_HOST=postgresql
DB_PORT=5432
DB_NETWORK=pg_network
DB_NAME=paperless

PAPERLESS_PORT=8080

REDIS_IMAGE=redis:6.0
PAPERLESS_BROKER=paperless_broker

PAPERLESS_CONTAINER=paperless
PAPERLESS_IMAGE_NAME=jonaswinkler/paperless-ng
PAPERLESS_IMAGE_TAG=latest
PAPERLESS_NETWORK=paperless_network
PAPERLESS_ADMIN_PWD=$(shell cat $(CURDIR)/paperless/.paperless_admin_pwd)

DATA_FOLDER=/home/cosmin/tmp/paperless
USER_ID=$(shell id `whoami` -u)
GROUP_ID=$(shell id `whoami` -g)

PAPERLESS_SECRET_KEY=$(shell cat $(CURDIR)/paperless/.paperless_key)
PAPERLESS_REDIS=redis://broker:6379
PAPERLESS_DBHOSY=db

run.paperless.network:
	$(DOCKER_CMD) network create $(PAPERLESS_NETWORK)

run.paperless.broker:
	$(DOCKER_CMD) run --rm -d --network $(PAPERLESS_NETWORK) --name $(PAPERLESS_BROKER) $(REDIS_IMAGE)

run.paperless.website:
	$(DOCKER_CMD) run --rm -d -p $(PAPERLESS_PORT):8000 \
		--network=$(PAPERLESS_NETWORK) \
		-v $(DATA_FOLDER)/data:/usr/src/paperless/data \
		-v $(DATA_FOLDER)/media:/usr/src/paperless/media \
		-v $(DATA_FOLDER)/export:/usr/src/paperless/export \
		-v $(DATA_FOLDER)/consume:/usr/src/paperless/consume \
		-e PAPERLESS_REDIS=redis://$(PAPERLESS_BROKER):6379 \
		-e PAPERLESS_SECRET_KEY=$(PAPERLESS_SECRET_KEY) \
		-e PAPERLESS_DB=$(DB_HOST) \
		-e PAPERLESS_HOST=$(DB_PORT) \
		-e PAPERLESS_DBNAME=$(DB_NAME) \
		-e PAPERLESS_DBUSER=$(DB_USER) \
		-e PAPERLESS_DBPASS=$(DB_PASS) \
		-e PAPERLESS_ADMIN_USER=admin \
		-e PAPERLESS_ADMIN_PASSWORD=$(PAPERLESS_ADMIN_PWD) \
		-e USERMAP_UID=$(USER_ID) \
		-e USERMAP_GID=$(GROUP_ID) \
		--name $(PAPERLESS_CONTAINER) $(PAPERLESS_IMAGE_NAME):$(PAPERLESS_IMAGE_TAG)
	$(DOCKER_CMD) network connect $(DB_NETWORK) $(PAPERLESS_CONTAINER)

run.paperless.stop:
	$(DOCKER_CMD) stop $(PAPERLESS_BROKER)
	$(DOCKER_CMD) stop $(PAPERLESS_CONTAINER)
	$(DOCKER_CMD) network rm $(PAPERLESS_NETWORK)
