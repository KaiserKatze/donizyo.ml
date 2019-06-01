# @see: https://cpython-devguide.readthedocs.io/setup/#build-dependencies

FROM        sqlite AS python
LABEL       image=python:3.7.3

ARG         URL_PYTHON_TARBALL=https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
ENV         PATH_PYTHON_PACKAGES="/usr/local/lib/python3.7/site-packages"
ARG         LD_RUN_PATH=$LD_LIBRARY_PATH

RUN         apt-get -y install libffi-dev

# python
RUN         curl -sL "$URL_PYTHON_TARBALL" -o python.tar.xz && \
            tar -xf python.tar.xz --one-top-level=python --strip-components 1

WORKDIR     $PATH_APP/python
RUN         ./configure \
                --enable-ipv6 \
                --enable-profiling \
                --enable-shared \
                --with-lto \
                --with-openssl="$OPENSSL_PREFIX" \
                --enable-optimizations
RUN         make -j4
RUN         make install

WORKDIR     $PATH_APP
RUN         rm -rf python python.tar.xz

RUN         echo "/usr/local/lib/" > "/etc/ld.so.conf.d/python3.conf" && ldconfig && \
            update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 10
# manually check update-alternatives
RUN         update-alternatives --display python

# python test
RUN         python -V
RUN         python -c "import ssl"
RUN         python -c "import sqlite3"

# upgrade pip - package manager
RUN         python -m pip install --upgrade pip
