#!/bin/bash

set -Ee
onerror() {
    echo "Fail to execute: $0 $@ ($?)"
    exit 1
}
# exit 1 on error
trap onerror ERR

# Image dependencies
# supported by bash 4
declare -A image_dep=( ["bind"]="python" ["python"]="sqlite" ["sqlite"]="openssl" ["openssl"]="" )
declare -A image_ver=( ["bind"]="9.14.2" ["python"]="3.7.3" ["sqlite"]="3.28.0" ["openssl"]="1.1.0k" )

pull() {
    image=$1
    version=$2
    if [ -z "$image" ]; then exit 1; fi
    if [ -z "$version" ]; then version="latest"; fi
    repo=$DOCKER_USERNAME/$image
    docker pull $repo:$version
    docker tag  $repo:$version  $image
    docker tag  $repo:$version  $image:$version
    docker rmi  $repo:$version
}

check_dep() {
    image=$1
    dep=${image_dep["$image"]}
    if [ -n "$dep" ]; then
        dep_ver=${image_ver["$dep"]}
        docker images $dep:$dep_ver || exit 1
    fi
}

build() {
    image=$1
    version=$2
    repo=$DOCKER_USERNAME/$image
    check_dep $image
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
    if [ -z "$image" ]; then exit 1; fi
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

push() {
    image=$1
    version=$2
    repo=$DOCKER_USERNAME/$image
    docker tag  $image  $repo:$version
    docker push         $repo:$version
    docker tag  $image  $repo
    docker push         $repo
}

push_all() {
    list=$(docker images | awk 'NR>1' | cut -d' ' -f1)
    for image in $list; do
        push $image ${image_ver["$image"]}
    done
}

easy() {
    cat .travis.yml | grep -P '^\s+- docker \w+' | awk 'BEGIN{print "git pull && \\"}{print "\t" substr($0,5) " && \\"}END{print "\tdocker rmi $(docker images -f dangling=true -q)"}' | bash
}

case "$1" in
    all)
    build_all && push_all
    ;;

    only)
    build_only "$2"
    ;;

    pull)
    pull "$2" "$3"
    ;;

    push)
    push "$2" "$3"
    ;;

    *)
    echo "Usage: $0 all"
    echo "       $0 only <image>"
    echo "       $0 push <image> [version]"
    echo "       $0 pull <image> [version]"
    exit 1
    ;;
esac

exit 0
