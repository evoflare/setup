#!/usr/bin/env bash
set -e

cat << "EOF"
                      __  _                   
                     / _|| |                  
   ___ __   __ ___  | |_ | |  __ _  _ __  ___ 
  / _ \\ \ / // _ \ |  _|| | / _` || '__|/ _ \
 |  __/ \ V /| (_) || |  | || (_| || |  |  __/
  \___|  \_/  \___/ |_|  |_| \__,_||_|   \___|

EOF

cat << EOF
Copyright $(date +'%Y'), Evoflare LLC
===================================================

EOF

#docker --version
#docker-compose --version

echo ""



# Setup
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=`basename "$0"`
SCRIPT_PATH="$DIR/$SCRIPT_NAME"
OUTPUT="$DIR/data"
if [ $# -eq 2 ]
then
    OUTPUT=$2
fi

DOCKER_REGISTRY="evoflare" #"evoflare.docker:50000"
SCRIPTS_DIR="$OUTPUT/scripts"
GITHUB_BASE_URL="https://raw.githubusercontent.com/evoflare/setup/master"
COREVERSION="latest"
WEBVERSION="latest"

# 
echo "Script path = $SCRIPTS_DIR" 
echo "Output path = $OUTPUT" 

echo "Docker registry = $DOCKER_REGISTRY" 
echo "Core module version = $COREVERSION" 
echo "Web module version = $WEBVERSION" 

# Functions

function downloadSelf() {
    curl -s -o $SCRIPT_PATH $GITHUB_BASE_URL/scripts/evoflare.sh
    chmod u+x $SCRIPT_PATH
}

function downloadRunFile() {
    if [ ! -d "$SCRIPTS_DIR" ]
    then
        mkdir $SCRIPTS_DIR
    fi
    curl -s -o $SCRIPTS_DIR/run.sh $GITHUB_BASE_URL/scripts/run.sh
    chmod u+x $SCRIPTS_DIR/run.sh
    rm -f $SCRIPTS_DIR/install.sh
}

function checkOutputDirExists() {
    if [ ! -d "$OUTPUT" ]
    then
        echo "Cannot find a Evoflare installation at $OUTPUT."
        exit 1
    fi
}

function checkOutputDirNotExists() {
    if [ -d "$OUTPUT/docker" ]
    then
        echo "Looks like Evoflare is already installed at $OUTPUT."
        exit 1
    fi
}

# Commands

if [ "$1" == "install" ]
then
    checkOutputDirNotExists
    mkdir -p $OUTPUT
    downloadRunFile
    $SCRIPTS_DIR/run.sh install $OUTPUT $COREVERSION $WEBVERSION $DOCKER_REGISTRY
elif [ "$1" == "start" -o "$1" == "restart" ]
then
    checkOutputDirExists
    $SCRIPTS_DIR/run.sh restart $OUTPUT $COREVERSION $WEBVERSION $DOCKER_REGISTRY
elif [ "$1" == "update" ]
then
    checkOutputDirExists
    downloadRunFile
    $SCRIPTS_DIR/run.sh update $OUTPUT $COREVERSION $WEBVERSION $DOCKER_REGISTRY
elif [ "$1" == "rebuild" ]
then
    checkOutputDirExists
    $SCRIPTS_DIR/run.sh rebuild $OUTPUT $COREVERSION $WEBVERSION $DOCKER_REGISTRY
elif [ "$1" == "updatedb" ]
then
    checkOutputDirExists
    $SCRIPTS_DIR/run.sh updatedb $OUTPUT $COREVERSION $WEBVERSION $DOCKER_REGISTRY
elif [ "$1" == "stop" ]
then
    checkOutputDirExists
    $SCRIPTS_DIR/run.sh stop $OUTPUT $COREVERSION $WEBVERSION
elif [ "$1" == "updateself" ]
then
    downloadSelf && echo "Updated self." && exit
else
    echo "No command found."
fi
