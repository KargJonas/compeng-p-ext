#!/bin/bash

# get location of this script (= project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPT_DIR

# docker container run -it -v ./:/workspace --env-file .env compeng-env
docker container run -it -v ./:/workspace compeng-env