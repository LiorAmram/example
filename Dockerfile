# syntax=docker/dockerfile:1
# Intel contributions Copyright © 2021, Intel Corporation.

##
## STEP 1 - Build binary
##

# Use the offical golang image (https://hub.docker.com/_/golang) to create a binary.
ARG GO_VERSION=1.19.0
FROM golang:${GO_VERSION}-buster as builder

# Create and change to the app directory.
# and retrieve application dependencies to allow the container build to reuse cached dependencies.
WORKDIR /app/src
COPY ./src/go.mod ./
COPY ./src/go.sum ./
RUN go mod download

# Copy application code.
COPY ./src/ .

# Build the binary.
ARG VERSION
RUN GOOS=linux GOARCH=amd64 go build --ldflags "\
    -X main.version=$VERSION \
    " -v -o microservice

##
## STEP 2 - Generate test image
##

FROM builder as test

WORKDIR /app/src

# Run unit tests.
ENV GOOS=linux
ENV GOARCH=amd64
ENTRYPOINT ["go", "test", "-timeout", "10s", "-v", "./..."]

##
## STEP 3 - Build deployable lean image
##

# Use https://console.cloud.google.com/gcr/images/distroless/global/base-debian11 image for a lean production container.
FROM gcr.io/distroless/base-debian11

WORKDIR /

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/src/microservice /microservice

USER nonroot:nonroot

# Inform Docker that the container listens on the specified network port at runtime.
ARG SERVER_PORT=8080
EXPOSE ${SERVER_PORT}

# Run the microservice on container startup.
ENTRYPOINT ["/microservice"]
