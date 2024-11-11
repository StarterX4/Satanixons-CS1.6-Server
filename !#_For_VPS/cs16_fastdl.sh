#!/bin/bash
DIR=cs16
# Check if npx (npm) is installed
if ! command -v npx &>/dev/null;
then
    echo "Error: npm/npx is not installed."
    exit 1
fi
screen -L -Logfile $DIR/screenlog_FastDL.log -d -m -S CS16_FastDL npx -y http-server $DIR/cstrike_downloads/ -p 2137
