# @see: https://cpython-devguide.readthedocs.io/setup/#build-dependencies
FROM        sqlite AS python

ARG         URL_PYTHON_TARBALL=https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
ENV         PATH_PYTHON_PACKAGES="/usr/local/lib/python3.7/site-packages"
ARG         LD_RUN_PATH=$LD_LIBRARY_PATH

RUN         apt-get -y install libffi-dev

# python
WORKDIR     $PATH_APP
RUN         curl -sL --retry 5 --retry-delay 60 $URL_PYTHON_TARBALL -o python.tar.xz && \
            tar -xf python.tar.xz --one-top-level=python --strip-components 1

WORKDIR     $PATH_APP/python
RUN         ./configure \
                --enable-ipv6 \
                --enable-profiling \
                --enable-shared \
                --with-lto \
                --with-openssl=$OPENSSL_PREFIX \
                --enable-optimizations
RUN         make
RUN         make install
RUN         rm -f $PATH_APP/python.tar.xz

# @see: http://www.yecuizhen.com/archives/20/
# @see: http://www.yanyaozhen.com/archives/392/
# @see: https://www.jianshu.com/p/969a84227829
# Solve exception as follows when executing `python3 -V`:
# `python3: error while loading shared libraries: libpython3.7m.so.1.0: cannot open shared object file: No such file or directory`
RUN         echo "/usr/local/lib/" > "/etc/ld.so.conf.d/python3.conf" && ldconfig && \
            update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 10
# manually check update-alternatives
RUN         update-alternatives --display python

# python test
RUN         python -V || echo "Fail to compile Python!"
RUN         python -c "import ssl" || echo "Fail to compile Python!"
RUN         python -c "import sqlite3" || echo "Fail to compile Python!"

# upgrade pip - package manager
RUN         python -m pip install --upgrade pip || echo "Fail to upgrade pip!"
