#!/bin/bash

printerr() { echo "$@" 1>&2; }

get_host_ip() {
    adapters=$(ip -4 a | awk '/inet/{print $2}' | cut -d'/' -f1)
    for adapter in $adapters;
    do
        # exclude address of loopback interface
        if [ "$adapter" == 127.0.0.1 ];
        then
            continue
        fi

        part1=$(echo $adapter | cut -d'.' -f1)
        part2=$(echo $adapter | cut -d'.' -f2)
        # exclude address reserved for private internets
        case "$part1" in
            # class A
            10)
            continue
            ;;

            172)
            case "$part2" in
                # class b
                16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31)
                continue
                ;;

                *)
                echo "$adapter"
                return 0
                ;;
            esac
            ;;

            192)
            case "$part2" in
                # class c
                168)
                continue
                ;;

                *)
                echo "$adapter"
                return 0
                ;;
            esac
            ;;

            *)
            echo "$adapter"
            return 0
            ;;
        esac
    done
    printerr "External IP not found!"
    return 1
}

get_host_ip
