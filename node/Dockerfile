FROM ${base_image}

ENV NODE_VERSION=${version}
ENV NODE_DOWNLOAD_URL=https://nodejs.org/download/release/v$NODE_VERSION

RUN apk add --no-cache \
    ca-certificates \
    libstdc++ \
 && apk add --no-cache --virtual .build-deps \
    curl \
    g++ \
    gcc \
    libgcc \
    linux-headers \
    make \
    openssl \
    python \
 && curl -sSL "$NODE_DOWNLOAD_URL/node-v$NODE_VERSION.tar.xz" -o node.tar.xz \
 && echo "${checksum}  node.tar.gz" | sha256sum -c - \
 && tar -xf "node.tar.xz" \
 && rm node.tar.xz \
 && cd "node" \
 && ./configure \
 && make -j$(getconf _NPROCESSORS_ONLN) \
 && make install \
 && apk del .build-deps \
 && cd .. && rm -Rf "node"

CMD [ "node" ]
