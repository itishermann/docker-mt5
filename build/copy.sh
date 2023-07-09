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
  echo "copying container: $container_name"

  sudo rm -R ~/docker-server/"$container_name"
  sudo rm -R ~/docker-server/"$container_name"-monitor
  sudo cp -R ~/docker-server/mt5-template ~/docker-server/"$container_name"
  sudo cp -R ~/docker-server/mt5-template ~/docker-server/"$container_name"-monitor
done
