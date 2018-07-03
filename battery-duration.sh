#!/usr/bin/env bash

x=1

while getopts "hqf:" opt; do
	case "$opt" in
		q) quiet=true;;
		f) file="${OPTARG}";;
		h|\?) printf 'Usage: %s [-q] [-f FILE]
	-q	Quiet mode. Only show daily totals, not each event.
	-f	Use file for input instead of `pmset -g log`. Use - for STDIN.\n' \
		"$(basename "$0")"; exit 0;;
	esac
	x=$OPTIND
done
shift $((x-1))

if hash gawk 2> /dev/null; then
	hash -p "$(hash -t gawk)" awk
fi

printf 'Reading input from: '
if [[ -n "$file" && -r "$file" ]]; then
	printf '%s\n' "$file"
	awk -v quiet="$quiet" -f battery-duration.awk "$file"
elif [[ -n "$file" && "$file" == "-" ]]; then
	printf '%s\n' "STDIN"
	awk -v quiet="$quiet" -f battery-duration.awk
else
	printf '%s\n' "pmset -g log"
	pmset -g log | awk -v quiet="$quiet" -f battery-duration.awk
fi
