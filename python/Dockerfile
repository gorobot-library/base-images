FROM base/alpine:3.5.0


ENV PYTHON_DOWNLOAD_URL=https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}

https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz.asc
ENV PYTHON_VERSION=${version}

RUN apk add --no-cache \
    ca-certificates \
 && apk add --no-cache --virtual .build-deps \
    curl \
    g++ \
    gcc \
    gnupg \
    libgcc \
    libstdc++ \
    linux-headers \
    make \
    openssl \
 && for key in \
      6A45C816 \
      36580288 \
      7D9DC8D2 \
      18ADD4FF \
      A4135B38 \
      A74B06BF \
      EA5BBD71 \
      ED9D77D5 \
      E6DF025C \
      AA65421D \
      6F5E1540 \
      F73C700D \
      487034E5 \
  ; do \
      gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
      gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
    done \
 && curl -sSL "$PYTHON_DOWNLOAD_URL/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
 && curl -sSL "$PYTHON_DOWNLOAD_URL/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
 && gpg --batch --verify python.tar.xz.asc python.tar.xz \
 && tar -C /usr/src/python -xf "python.tar.xz" \
 && rm python.tar.xz \
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
