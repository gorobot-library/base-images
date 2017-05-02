FROM ${base_image}

ENV PYTHON_VERSION=${version}

ENV PYTHON_DOWNLOAD_URL=https://www.python.org/ftp/python
ENV PYTHON_PIP_VERSION=9.0.1

RUN apk add --no-cache \
    ca-certificates \
 && apk add --no-cache --virtual .build-deps \
    bzip2-dev \
    curl \
    g++ \
    gcc \
    gdbm-dev \
    libgcc \
    libstdc++ \
    linux-headers \
    make \
    ncurses-dev \
    openssl \
    openssl-dev \
    pax-utils \
    readline-dev \
    sqlite-dev \
    tcl-dev \
    tk-dev \
    xz-dev \
    zlib-dev \
 && curl -SLO "$PYTHON_DOWNLOAD_URL/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
 && echo "${checksum}" | sha256sum -c - \
 && mkdir -p "/usr/src/python" \
 && tar -xJf "Python-$PYTHON_VERSION.tar.xz" -C "/usr/src/python" --strip-components=1 \
 && rm "Python-$PYTHON_VERSION.tar.xz" \
 && cd "/usr/src/python" \
 && ./configure \
      --enable-loadable-sqlite-extensions \
      --enable-shared \
 && make -j$(getconf _NPROCESSORS_ONLN) \
 && make install \
 && if [ ! -e /usr/local/bin/pip3 ]; then : \
    && curl -sSL 'https://bootstrap.pypa.io/get-pip.py' -o /tmp/get-pip.py \
    && python3 /tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" \
    && rm /tmp/get-pip.py \
	; fi \
 && pip3 install --no-cache-dir --upgrade --force-reinstall \
    pip \
    setuptools \
 # https://gist.github.com/ncopa/d7c2e816fb09066022ba4e723621bef8
 && find /usr/local -depth \
		\( \
			\( -type d -a -name test -o -name tests \) \
			-o \
			\( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
 && runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
    )" \
 && apk add --virtual .python-rundeps $runDeps \
 && apk del .build-deps \
 && rm -rf /usr/src/python ~/.cache

RUN cd /usr/local/bin \
 && { [ -e easy_install ] || ln -s easy_install-* easy_install; } \
 && ln -s idle3 idle \
 && ln -s pydoc3 pydoc \
 && ln -s python3 python \
 && ln -s python3-config python-config

CMD ["python3"]
