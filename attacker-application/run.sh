#!/bin/bash

# Script for starting an attacker node within a docker container
# If no argument is supplied the script assumes the coordinator runs in the local host
# If one or more arguments are supplied the first argument will be used as the host name

if [ $# -eq 0 ]
then
    HOSTNAME=$(cat /etc/hostname);
else
    HOSTNAME=$1
fi

RAND_NAME=$(mktemp -u XXXXXX | tr '[:upper:]' '[:lower:]')

iex --sname $RAND_NAME --cookie HARALD -S mix run -- $HOSTNAME