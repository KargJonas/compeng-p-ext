#!/bin/bash

# get location of this script (= project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPT_DIR

docker container run --rm -it -v ./:/workspace -v /mnt/ramdisk:/ramdisk compeng-env
