FROM ${base_image}

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
 && curl -SLO "$GOLANG_DOWNLOAD_URL/go$GOLANG_VERSION.src.tar.gz" \
 && echo "${checksum}" | sha256sum -c - \
 && mkdir -p "/usr/local/go" \
 && tar -xzf "go$GOLANG_VERSION.src.tar.gz" -C "/usr/local/go" --strip-components=1 \
 && rm "go$GOLANG_VERSION.src.tar.gz" \
 && cd /usr/local/go/src && ./make.bash \
 && mkdir -p "/go/src" "/go/bin" && chmod -R 777 "/go" \
 && apk del .build-deps

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/
