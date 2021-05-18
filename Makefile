.PHONY: help setup tools generate deploy

help: help.all
tools: tools.get
build: build.docker


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

COLOR_LEVEL_TRACE=$(escape)[38;5;87m
COLOR_LEVEL_DEBUG=$(escape)[38;5;87m
COLOR_LEVEL_INFO=$(escape)[92m
COLOR_LEVEL_WARN=$(escape)[38;5;208m
COLOR_LEVEL_ERROR=$(escape)[91m

define COLORIZE
sed -u -e "s/\\\\\"/'/g; \
s/method=\([^ ]*\)/method=$(COLOR_BLUE)\1$(RESET_COLOR)/g; \
s/error=\"\([^\"]*\)\"/error=\"$(COLOR_RED)\1$(RESET_COLOR)\"/g; \
s/msg=\"\([^\"]*\)\"/msg=\"$(COLOR_YELLOW)\1$(RESET_COLOR)\"/g; \
s/TRACE/level=$(COLOR_LEVEL_TRACE)TRACE$(RESET_COLOR)/g; \
s/DEBUG/level=$(COLOR_LEVEL_DEBUG)DEBUG$(RESET_COLOR)/g; \
s/INFO/$(COLOR_LEVEL_INFO)INFO$(RESET_COLOR)/g; \
s/WARNING/level=$(COLOR_LEVEL_WARN)WARNING$(RESET_COLOR)/g; \
s/ERROR/level=$(COLOR_LEVEL_ERROR)ERROR$(RESET_COLOR)/g"
endef

#help help.highlevel: show help for high level targets. Use 'make help.all' to display all help messages
help.highlevel:
	@grep -hE '^[a-z_-]+:' $(MAKEFILE_LIST) | LANG=C sort -d | \
	awk 'BEGIN {FS = ":"}; {printf("$(COLOR_YELLOW)%-25s$(RESET_COLOR) %s\n", $$1, $$2)}'

#help help.all: display all targets' help messages
help.all:
	@grep -hE '^#help|^[a-z_-]+:' $(MAKEFILE_LIST) | sed "s/#help //g" | LANG=C sort -d | \
	awk 'BEGIN {FS = ":"}; {if ($$1 ~ /\./) printf("    $(COLOR_BLUE)%-21s$(RESET_COLOR) %s\n", $$1, $$2); else printf("$(COLOR_YELLOW)%-25s$(RESET_COLOR) %s\n", $$1, $$2)}'

#help run: run postgres and paperless
run.docker: run.postgres run.paperless

run.docker.stop: run.paperless.stop run.postgres.stop


# include postgres
-include postgres/postgres.mk
# include paperless
-include paperless/paperless.mk
