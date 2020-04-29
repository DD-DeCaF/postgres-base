.PHONY: build-alpine build-alpine-compiler build push-alpine push-alpine-compiler push

################################################################################
# Variables                                                                    #
################################################################################

IMAGE ?= dddecaf/postgres-base
BUILD_COMMIT ?= $(shell git rev-parse HEAD)
SHORT_COMMIT ?= $(shell git rev-parse --short HEAD)
BUILD_TIMESTAMP ?= $(shell date --utc --iso-8601=seconds)
BUILD_DATE ?= $(shell date --utc --iso-8601=date)
ALPINE_TAG := alpine_${BUILD_DATE}_${SHORT_COMMIT}
ALPINE_COMPILER_TAG := alpine-compiler_${BUILD_DATE}_${SHORT_COMMIT}

################################################################################
# Commands                                                                     #
################################################################################

## Build the Alpine Linux base image.
build-alpine:
	docker pull dddecaf/tag-spy:latest
	$(eval ALPINE_BASE_TAG := $(shell docker run --rm dddecaf/tag-spy:latest tag-spy dddecaf/wsgi-base alpine dk.dtu.biosustain.wsgi-base.alpine.build.timestamp))
	docker pull dddecaf/wsgi-base:$(ALPINE_BASE_TAG)
	docker build --build-arg BASE_TAG=$(ALPINE_BASE_TAG) \
		--build-arg BUILD_COMMIT=$(BUILD_COMMIT) \
		--build-arg BUILD_TIMESTAMP=$(BUILD_TIMESTAMP) \
		--tag $(IMAGE):alpine \
		--tag $(IMAGE):$(ALPINE_TAG) \
		./alpine

## Build the Alpine Linux compiler image.
build-alpine-compiler:
	docker pull dddecaf/tag-spy:latest
	$(eval ALPINE_COMPILER_BASE_TAG := $(shell docker run --rm dddecaf/tag-spy:latest tag-spy dddecaf/wsgi-base alpine-compiler dk.dtu.biosustain.wsgi-base.alpine-compiler.build.timestamp))
	docker build --build-arg BASE_TAG=$(ALPINE_TAG) \
		--build-arg BUILD_COMMIT=$(BUILD_COMMIT) \
		--build-arg BUILD_TIMESTAMP=$(BUILD_TIMESTAMP) \
		--tag $(IMAGE):alpine-compiler \
		--tag $(IMAGE):$(ALPINE_COMPILER_TAG) \
		./alpine-compiler

## Build all local Docker images.
build: build-alpine build-alpine-compiler
	$(info Successfully built all images!)

## Push the Alpine Linux base image to its registry.
push-alpine:
	docker push $(IMAGE):alpine
	docker push $(IMAGE):$(ALPINE_TAG)

## Push the Alpine Linux compiler image to its registry.
push-alpine-compiler:
	docker push $(IMAGE):alpine-compiler
	docker push $(IMAGE):$(ALPINE_COMPILER_TAG)

## Push all locally built Docker images to their registries.
push: push-alpine push-alpine-compiler
	$(info Successfully pushed all images!)

################################################################################
# Self Documenting Commands                                                    #
################################################################################

.DEFAULT_GOAL := show-help

# Inspired by
# <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin \
	&& echo '--no-init --raw-control-chars')
