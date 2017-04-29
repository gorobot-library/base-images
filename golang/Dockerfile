FROM base/alpine:3.5.0

ARG GOLANG_VERSION
ARG GOLANG_SHA256

ENV GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz
ENV GOROOT /usr/local/go

RUN apk add --no-cache ca-certificates \
 && apk add --no-cache --virtual .build-deps \
    bash \
    curl \
    gcc \
    musl-dev \
    openssl \
    go \
 && export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
 && curl -sSL "$GOLANG_DOWNLOAD_URL" -o go.tar.gz \
 && curl -sSL "$GOLANG_DOWNLOAD_URL.sha256" -o go.tar.gz.sha256 \
 && echo '$GOLANG_SHA256  go.tar.gz' | sha256sum -c - \
 && tar -C /usr/local -xzf go.tar.gz \
 && rm -f go.tar.gz
 && cd /usr/local/go/src && ./make.bash \
 && mkdir -p "/go/src" "/go/bin" && chmod -R 777 "/go" \
 && apk del .build-deps

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/
