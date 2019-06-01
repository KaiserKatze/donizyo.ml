#!/bin/sh

pull() {
    image=$1
    version=$2
    repo=$DOCKER_USERNAME/$image
    docker pull $repo:$version
    docker tag  $repo:$version  $image
    docker rmi  $repo:$version
}

build() {
    image=$1
    version=$2
    repo=$DOCKER_USERNAME/$image
    docker build -t $image ./$image
    docker tag  $image  $repo:$version
    docker push         $repo:$version
    docker tag  $image  $repo
    docker push         $repo
}

build_all() {
    docker build -t base ./base
    build openssl   1.1.0k
    build sqlite    3.28.0
    build python    3.7.3
    build bind      9.14.2
}
