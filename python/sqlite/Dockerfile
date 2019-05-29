FROM        openssl AS sqlite
LABEL       image=sqlite:3.28.0

ARG         URL_SQLITE_TARBALL=https://www.sqlite.org/2019/sqlite-autoconf-3280000.tar.gz
ARG         SQLITE_PREFIX=/usr/local

# sqlite
RUN         curl -sL "$URL_SQLITE_TARBALL" -o sqlite.tar.gz && \
            tar -xf sqlite.tar.gz --one-top-level=sqlite --strip-components 1
WORKDIR     $PATH_APP/sqlite
RUN         ./configure --prefix="$SQLITE_PREFIX"
RUN         make -j4
RUN         make install

# @see: [How SQLite Is Tested](https://www.sqlite.org/testing.html)

WORKDIR     $PATH_APP
RUN         rm -rf sqlite sqlite.tar.gz
