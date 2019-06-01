#!/bin/bash

# Image dependencies
# supported by bash 4
declare -A image_dep=( ["bind"]="python" ["python"]="sqlite" ["sqlite"]="openssl" ["openssl"]="" )
declare -A image_ver=( ["bind"]="9.14.2" ["python"]="3.7.3" ["sqlite"]="3.28.0" ["openssl"]="1.1.0k" )

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

build_base() {
    docker build -t base ./base
}

build_all() {
    build_base
    build openssl   1.1.0k
    build sqlite    3.28.0
    build python    3.7.3
    build bind      9.14.2
}

build_only() {
    image=$1
    if [ -z "$image" ]; then return; fi
    iter=${image_dep["$image"]}
    list="$image"
    # while `$iter` is not empty string
    while [ -n "$iter" ]; do
        list="$iter $list"
        iter=${image_dep["$iter"]}
    done
    build_base
    for image in $list; do
        build $image ${image_ver["$image"]}
    done
}
