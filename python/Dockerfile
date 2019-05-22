# Compile and Install Python
# @see: https://github.com/docker-library/python/blob/34c9df35e9a69e9f0edde88e861b543edb8bc07a/3.7/stretch/Dockerfile

FROM        openssl:1.1.1b AS base
LABEL       maintainer.name="KaiserKatze" \
            maintainer.mail="donizyo@gmail.com"
WORKDIR     /tmp/workdir

ARG         PATH_APP=/root/App
ARG         URL_SQLITE_TARBALL=https://www.sqlite.org/2019/sqlite-autoconf-3280000.tar.gz
ARG         URL_PYTHON_TARBALL=https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
ARG         SQLITE_PREFIX=/usr/local/sqlite

# sqlite
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_SQLITE_TARBALL" -o sqlite.tar.gz && \
            tar -xf sqlite.tar.gz --one-top-level=sqlite --strip-components 1 && \
            cd "$PATH_APP/sqlite" && \
            ./configure --prefix="$SQLITE_PREFIX" && \
            make && \
            make install
# python
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_PYTHON_TARBALL" -o python.tar.xz && \
            tar -xf python.tar.xz --one-top-level=python --strip-components 1 &&  \
            cd "$PATH_APP/python" && \
            ./configure \
                --enable-loadable-sqlite-extensions \
                --enable-ipv6 \
                --enable-shared \
                --enable-profiling \
                --enable-optimizations \
                --with-lto \
                --with-ssl-default-suites=python \
            cat "/usr/local/lib/" > "/etc/ld.so.conf.d/python3.conf" && ldconfig && \
            update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 1 && \
            python -m pip --upgrade pip

