# ----------------------------------------
# Distribution
#
# Creates the registry binary.
FROM base/golang:1.8 AS distribution

ENV REGISTRY_VERSION=${version}

# Set environment variables.
ENV DISTRIBUTION_DIR=/go/src/github.com/docker/distribution

# Install dependencies.
RUN apk add --no-cache \
    ca-certificates \
 && apk add --no-cache --virtual .build-deps \
    gcc \
    g++ \
    make \
    git

# Set the working directory to the distribution directory.
WORKDIR $DISTRIBUTION_DIR

# Clone the git repo into the container.
RUN git clone https://github.com/docker/distribution . \
 && git checkout tags/v$REGISTRY_VERSION \
 && mkdir -p /etc/docker/registry \
 && cp ./cmd/registry/config-dev.yml /etc/docker/registry/config.yml

# Build the registry binary.
RUN make PREFIX=/go clean binaries

# ----------------------------------------
# Registry
#
# Creates the registry image using the registry binary from the distribution.
FROM ${base_image}

# Install dependencies.
RUN apk add --no-cache \
    ca-certificates \
 && apk add --no-cache --virtual .build-deps \
    apache2-utils

# Copy the registry binary from the distribution.
COPY --from=distribution /go/bin/registry /bin/registry
# Copy the default config from the distribution.
COPY --from=distribution /go/src/github.com/docker/distribution/cmd/registry/config-example.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]

EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
