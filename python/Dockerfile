FROM        sqlite AS python
LABEL       image=python:3.7.3

ARG         URL_PYTHON_TARBALL=https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
ENV         PATH_PYTHON_PACKAGES="/usr/local/lib/python3.7/site-packages"
ARG         LD_RUN_PATH=$LD_LIBRARY_PATH
# --enable-optimizations
ARG         OPTIONAL_PYTHON_CONFIG=

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
                "$OPTIONAL_PYTHON_CONFIG"
RUN         cat config.log
RUN         make -j4
RUN         cat ./python-config
RUN         cat ./python-config.py
RUN         cat ./python-gdb.py
RUN         find / -name 'libpython*.so*' -type f

RUN         /lib64/ld-linux-x86-64.so.2 --library-path $PATH_APP/python $PATH_APP/python/python -V || echo "Failed python version test."
RUN         /lib64/ld-linux-x86-64.so.2 --library-path $PATH_APP/python $PATH_APP/python/python -c "import ssl" || echo "Failed python openssl test."
RUN         /lib64/ld-linux-x86-64.so.2 --library-path $PATH_APP/python $PATH_APP/python/python -c "import zlib" || echo "Failed python zlib test."
RUN         /lib64/ld-linux-x86-64.so.2 --library-path $PATH_APP/python $PATH_APP/python/python -c "import sqlite3" || echo "Failed python sqlite3 test."

RUN         /lib64/ld-linux-x86-64.so.2 --library-path $PATH_APP/python $PATH_APP/python/python -E -S -m sysconfig --generate-posix-vars
RUN         /lib64/ld-linux-x86-64.so.2 --library-path $PATH_APP/python $PATH_APP/python/python -E setup.py build
RUN         /lib64/ld-linux-x86-64.so.2 --library-path $PATH_APP/python $PATH_APP/python/python -m test.pythoninfo
# breakpoint
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
RUN         python -m pip --upgrade pip
