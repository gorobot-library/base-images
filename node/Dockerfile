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
 && curl -SLO "$NODE_DOWNLOAD_URL/node-v$NODE_VERSION.tar.xz" \
 && echo "${checksum}" | sha256sum -c - \
 && mkdir "node" \
 && tar -xf "node-v$NODE_VERSION.tar.xz" -C "node" --strip-components=1 \
 && rm "node-v$NODE_VERSION.tar.xz" \
 && cd "node" \
 && ./configure \
 && make -j$(getconf _NPROCESSORS_ONLN) \
 && make install \
 && apk del .build-deps \
 && cd .. && rm -Rf "node"

CMD [ "node" ]
