FROM alpine

RUN adduser -S lux

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN apk --no-cache --virtual build-dependendencies add autoconf \
    automake \
    boost-dev \
    build-base \
    chrpath \
    file \
    git \
    gnupg \
    libevent-dev \
    openssl \
    openssl-dev \
    libtool \
    linux-headers \
    protobuf-dev \
    zeromq-dev \
  && mkdir -p /tmp/build \
  && wget -O /tmp/build/${BERKELEYDB_VERSION}.tar.gz http://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz \
  && tar -xzf /tmp/build/${BERKELEYDB_VERSION}.tar.gz -C /tmp/build/ \
  && sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i /tmp/build/${BERKELEYDB_VERSION}/dbinc/atomic.h \
  && mkdir -p ${BERKELEYDB_PREFIX} \
  && cd /tmp/build/${BERKELEYDB_VERSION}/build_unix \
  && ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX} \
  && make install \
  && cd /tmp/build \
  && git clone https://github.com/daemonp/lux \
  && cd lux \
  && ./autogen.sh \
  && ./configure LDFLAGS=-L${BERKELEYDB_PREFIX}/lib/ CPPFLAGS=-I${BERKELEYDB_PREFIX}/include/ \
    --mandir=/usr/share/man \
    --disable-tests \
    --disable-bench \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon \
  && make install \
  && rm -rf /tmp/build ${BERKELEYDB_PREFIX}/docs \
  && apk --no-cache --purge del build-dependendencies \
  && apk --no-cache add boost \
    boost-program_options \
    libevent \
    openssl \
    openssl-dev \
    libzmq \
    su-exec

