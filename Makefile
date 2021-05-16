.PHONY: help setup tools generate deploy

help: help.all
tools: tools.get
build: build.docker
run: run.docker
setup: setup.init
setup.paperless: setup.paperless.init setup.paperless.role setup.paperless.user


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

# include postgres
-include postgres/postgres.mk
# include paperless
-include paperless/paperless.mk
