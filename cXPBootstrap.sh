#!/bin/bash

set -e

BASE_DIR="$(dirname $0)"
cd $BASE_DIR

LAUNCHER_DIR="$HOME/.cavexp_com"
LAUNCHER_PATH="$LAUNCHER_DIR/cXPLauncher.jar"

echo ":: Request bootstrap info"
PROPS_RESP="$(wget -qO- https://api.v3.prod.cavexp.com/2.0/launcher/getBootstrapProperties)"
LAUNCHER_URL="$(echo $PROPS_RESP | jq ".launcher.url" -r)"
LAUNCHER_HASH="$(echo $PROPS_RESP | jq ".launcher.hash" -r)"

download_launcher() {
    wget $LAUNCHER_URL -O $LAUNCHER_PATH
}

if [ -f "$LAUNCHER_PATH" ]
then
    ACTUAL_LAUNCHER_HASH="$(md5sum $LAUNCHER_PATH | cut -d ' ' -f 1)"
    if [ "$LAUNCHER_HASH" != "$ACTUAL_LAUNCHER_HASH" ]
    then
        echo ":: Newer launcher is available. Downloading"
        download_launcher
    else
        echo ":: Launcher is already up to date"
    fi
else
    echo ":: There is no launcher. Downloading"
    download_launcher
fi

launch() {
    java -jar $LAUNCHER_PATH
}

launch
