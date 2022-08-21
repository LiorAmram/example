# Intel contributions Copyright © 2021, Intel Corporation.

.PHONY: build test clean check go-test go-build publish
all: build check test

SERVICE_DIR := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := ${SERVICE_DIR}/scripts
SERVICE_NAME ?= $(shell basename ${SERVICE_DIR})
VERSION = $(shell ${SCRIPTS_DIR}/version.sh full ${SERVICE_DIR})
DOCKER_IMAGE_REL = ${DOCKER_REGISTRY}${SERVICE_NAME}:${VERSION}

ifneq (${DOCKER_REGISTRY},)
	ifneq ($(patsubst %/,,$(lastword ${DOCKER_REGISTRY})),)
		$(error DOCKER_REGISTRY should be unset or end with / )
	endif
endif

build:
	docker build --build-arg VERSION=${VERSION} -t ${SERVICE_NAME}:latest -t ${SERVICE_NAME}:${VERSION} .

test:
	docker build --target=test -t ${SERVICE_NAME}-test .
	docker run --rm ${SERVICE_NAME}-test

clean:
	docker rmi -f ${SERVICE_NAME}:latest ${SERVICE_NAME}:${VERSION} ${SERVICE_NAME}-test

go-build:
	cd src && go build -v ./...

go-test:
	cd src && go test -v ./...
