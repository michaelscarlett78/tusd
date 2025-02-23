FROM --platform=linux/amd64 golang:1.20.5-alpine AS builder
WORKDIR /go/src/github.com/tus/tusd

# Add gcc and libc-dev early so it is cached
RUN set -xe \
	&& apk add --no-cache gcc libc-dev

# Install dependencies earlier so they are cached between builds
COPY go.mod go.sum ./
RUN set -xe \
	&& go mod download

# Copy the source code, because directories are special, there are separate layers
COPY cmd/ ./cmd/
COPY internal/ ./internal/
COPY pkg/ ./pkg/

# Get the version name and git commit as a build argument
ARG GIT_VERSION
ARG GIT_COMMIT

# Get the operating system and architecture to build for
ARG TARGETOS
ARG TARGETARCH

RUN set -xe \
	&& GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
        -ldflags="-X github.com/tus/tusd/cmd/tusd/cli.VersionName=${GIT_VERSION} -X github.com/tus/tusd/cmd/tusd/cli.GitCommit=${GIT_COMMIT} -X 'github.com/tus/tusd/cmd/tusd/cli.BuildDate=$(date --utc)'" \
        -o /go/bin/tusd ./cmd/tusd/main.go

# start a new stage that copies in the binary built in the previous stage
FROM alpine:3.18.2
WORKDIR /srv/tusd-data

COPY ./docker/entrypoint.sh /usr/local/share/docker-entrypoint.sh
COPY ./docker/load-env.sh /usr/local/share/load-env.sh

RUN apk add --no-cache ca-certificates jq bash \
    && addgroup -g 1000 tusd \
    && adduser -u 1000 -G tusd -s /bin/sh -D tusd \
    && mkdir -p /srv/tusd-hooks \
	&& mkdir -p /srv/tusd-data/logs \
    && chown tusd:tusd /srv/tusd-data \
	&& chown tusd:tusd /srv/tusd-data/logs \
    && chmod +x /usr/local/share/docker-entrypoint.sh /usr/local/share/load-env.sh

# python setup
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools requests

# timezone 
RUN apk add --no-cache tzdata
ENV TZ=Pacific/Auckland

# samba and mount of remote server 
# RUN apk add samba-client samba-utils


COPY --from=builder /go/bin/tusd /usr/local/bin/tusd
COPY hooks/ /srv/tusd-hooks/

EXPOSE 1080
USER tusd

ENTRYPOINT ["/usr/local/share/docker-entrypoint.sh"]
CMD [ "--upload-dir", "/srv17-test", "--hooks-dir", "/srv/tusd-hooks", "--hooks-enabled-events", "pre-create,pre-finish,post-finish"]
