#!/bin/bash
[ $# -ge 1 -a -f "$1" ] && input="$1" || input="-"

cat $input | grep "lang:" | tr -d " ,}" | sed "s/lang://" | sort | uniq -c |  sed -e 's/^[ \t]*//' | awk 'BEGIN {fs = " "}; { print $2 " " $1 }' | sort
