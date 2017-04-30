FROM base/alpine:3.5.0

ENV GOLANG_VERSION=${version}
ENV GOLANG_DOWNLOAD_URL=https://storage.googleapis.com/golang

RUN apk add --no-cache \
    ca-certificates \
 && apk add --no-cache --virtual .build-deps \
    bash \
    curl \
    gcc \
    go \
    musl-dev \
    openssl \
 && export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
 && curl -sSL "$GOLANG_DOWNLOAD_URL/go$GOLANG_VERSION.src.tar.gz" -o go.tar.gz \
 && echo "${checksum}  go.tar.gz" | sha256sum -c - \
 && tar -C /usr/local -xzf go.tar.gz \
 && rm go.tar.gz go.tar.gz.sha256 \
 && cd /usr/local/go/src && ./make.bash \
 && mkdir -p "/go/src" "/go/bin" && chmod -R 777 "/go" \
 && apk del .build-deps

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/
