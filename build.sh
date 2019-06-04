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
declare -A image_dep=( ["bind"]="python" ["python"]="sqlite" ["sqlite"]="" )

pull() {
    image=$1
    if [ -z "$image" ]; then exit 1; fi
    repo=$DOCKER_USERNAME/$image
    docker pull $repo
    docker tag  $repo  $image
    docker rmi  $repo
}

build() {
    image=$1
    repo=$DOCKER_USERNAME/$image
    docker build -t $image ./$image
    push $image
}

build_base() {
    docker build -t base ./base
    docker build -t util ./util
}

build_all() {
    build_base
    build sqlite
    build python
    build bind
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
        build $image
    done
}

push() {
    image=$1
    repo=$DOCKER_USERNAME/$image
    docker tag  $image  $repo
    docker push         $repo
}

push_all() {
    list=$(docker images | awk 'NR>1' | cut -d' ' -f1)
    for image in $list; do
        push $image
    done
}

easy() {
    docker build -t base ./base
    docker build -t util ./util
    docker build -t nginx ./nginx
    docker build -t sqlite ./python/sqlite
    docker build -t python ./python
    docker build -t bind ./bind

    docker images

    echo -n "Do you want to push newly built images? (Y/n) "
    read do_push_images
    if [ "$do_push_images" == "Y" ] || [ "$do_push_images" == "y" ]; then
        if [ -z "$DOCKER_USERNAME" ]; then
            # no username is provided
            echo -n "Please input username: "
            read DOCKER_USERNAME
        fi
        if [ -z "$DOCKER_PASSWORD" ]; then
            # no password is provided
            echo -n "Please input password: "
            read DOCKER_PASSWORD
        fi

        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

        docker tag nginx $DOCKER_USERNAME/nginx && \
            docker push $DOCKER_USERNAME/nginx
        docker tag sqlite $DOCKER_USERNAME/sqlite && \
            docker push $DOCKER_USERNAME/sqlite
        docker tag python $DOCKER_USERNAME/python && \
            docker push $DOCKER_USERNAME/python
        docker tag bind $DOCKER_USERNAME/bind && \
            docker push $DOCKER_USERNAME/bind

        docker logout
    fi
}

clean() {
    CONTAINERS=$(docker ps -qa)
    [ -n "$CONTAINERS" ] && docker rm $CONTAINERS
    IMAGES=$(docker images --format "{{.Repository}}:{{.ID}}" | sed '/^ubuntu/d' | cut -d: -f2)
    [ -n "$IMAGES" ] && docker rmi -f $IMAGES
}

case "$1" in
    all)
    build_all && push_all
    ;;

    only)
    build_only "$2" && push_all
    ;;

    pull)
    pull "$2"
    ;;

    push)
    push "$2"
    ;;

    easy)
    easy
    ;;

    clean)
    clean
    ;;

    *)
    echo "Usage: $0 all"
    echo "       $0 only <image>"
    echo "       $0 pull <image> [version]"
    echo "       $0 push <image> [version]"
    echo "       $0 easy"
    echo "       $0 clean"
    exit 1
    ;;
esac

exit 0
