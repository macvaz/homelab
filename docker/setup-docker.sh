#! /bin/bash

docker network create \
  --driver=bridge \
  --subnet=10.10.10.0/24 \
  --gateway=10.10.10.1 \
  --attachable \
  homelab

docker-compose -f portainer.yml -p portainer up -d
