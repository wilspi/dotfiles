#!/usr/bin/env bash

if [ $# -eq 0 ]; then
	# defaults to 5 minutes
	interval=18000
else
	re='^[0-9]+$'
	if ! [[ $1 =~ $re ]]; then
		echo "ERROR: interval must be a number" >&2; exit 1
	fi
	interval=$1
fi

# Push git commits after every $interval
watch -n $interval ./git_push_commits.sh