#!/usr/bin/env bash

RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SYSTEM=$1

echo -e "${BLUE}INFO:${NC} copying aliases $SYSTEM"
cat $CWD/git $CWD/python $CWD/bash

#TODO: SYSTEM specific aliases