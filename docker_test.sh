#!/bin/sh
sudo docker run --rm --privileged -v $(pwd)/mlxn_install.sh:/mlxn_install.sh fedora bash ./mlxn_install.sh
sudo docker run --rm --privileged -v $(pwd)/mlxn_install.sh:/mlxn_install.sh ubuntu bash ./mlxn_install.sh
