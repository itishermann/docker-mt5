#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <start_number> <end_number>"
  exit 1
fi

start=$1
end=$2
compose_file="./docker-compose.yml"

for ((num=start; num<=end; num++))
do
  container_number="$(printf "%03d" $num)"
  container_name="mt5-$(printf "%03d" $num)"
  echo "generating for container: $container_name"

  destination=./"$container_name"/docker-compose.yml
  rm $destination
  cp $compose_file $destination

  # Use sed to replace the placeholder with the container number
  sed -i "s/{container-number}/$container_number/g" "$destination"
done