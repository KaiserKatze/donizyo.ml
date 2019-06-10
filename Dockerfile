FROM        alpine AS base
LABEL       maintainer.name="KaiserKatze"
LABEL       maintainer.mail="donizyo@gmail.com"

ENV         PATH_APP=/root/App
ENV         PATH_TARGET=/tmp/target

# install necessary tools
RUN         echo "Installing necessary packages:"
RUN         apk add curl git
# Install `gcc`, `ld`, `make`, etc.
RUN         apk add build-base
# Install `gpg`
RUN         apk add gnupg
