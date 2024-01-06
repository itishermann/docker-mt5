#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <start_number> <end_number>"
  exit 1
fi

start=$1
end=$2

for ((num=start; num<=end; num++))
do
  container_name="mt5-$(printf "%03d" $num)"
  echo "stoping container: $container_name"
  docker stop "$container_name"
done