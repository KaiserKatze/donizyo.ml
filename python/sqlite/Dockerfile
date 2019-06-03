FROM        util AS sqlite

ARG         URL_SQLITE_TARBALL=https://www.sqlite.org/2019/sqlite-autoconf-3280000.tar.gz
ARG         SQLITE_PREFIX=/usr/local

# sqlite
WORKDIR     $PATH_APP
RUN         echo "Downloading SQLite3 source code from: $URL_SQLITE_TARBALL" && \
            curl -sL "$URL_SQLITE_TARBALL" -o sqlite.tar.gz && \
            tar -xf sqlite.tar.gz --one-top-level=sqlite --strip-components 1
WORKDIR     $PATH_APP/sqlite
RUN         ./configure --prefix="$SQLITE_PREFIX"
RUN         make
RUN         make install
RUN         rm -f $PATH_APP/sqlite.tar.gz

# @see: [How SQLite Is Tested](https://www.sqlite.org/testing.html)
