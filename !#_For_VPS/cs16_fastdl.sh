#!/bin/bash
#BINDIR=$(dirname "$(readlink -fn "$0")")
#cd "$BINDIR/cs16"
screen -L -Logfile cs16/screenlog_FastDL.log -d -m -S CS16_FastDL npx http-server cs16/cstrike_downloads/ -p 2137
