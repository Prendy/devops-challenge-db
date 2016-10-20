#! /bin/bash

set +e
docker stop devops-db
docker rm devops-db
set -e

#builds a new mysql database image

pushd ~/config/docker/devops-db
docker build --tag devops-db:latest .
popd

#builds Java data image

pushd ~/config/docker/devops-db-data-java
docker build --tag devops-db-data-java:latest .
popd

#builds PHP data image

pushd ~/config/docker/devops-db-data-php
docker build --tag devops-db-data-php:latest .
popd

#checks for java data store

echo -e "\033[0;31mChecking for devops-db-data-java \033[0m"
set +e
docker ps -a | grep devops-db-data-java > /dev/null
FOUND_JAVA=$?
set -e

if [[ "$FOUND_JAVA" == "0" ]]; then
  echo -e "\033[0;32mJava data store already exists\033[0m"
else
  echo -e "\033[0;34mCreating Java data container\033[0m"
  docker create --name devops-db-data-java devops-db-data-java:latest
fi

#checks for php data store

echo -e "\033[0;31mChecking for devops-db-data-php \033[0m"
set +e
docker ps -a | grep devops-db-data-php > /dev/null
FOUND_PHP=$?
set -e

if [[ "$FOUND_PHP" == "0" ]]; then
  echo -e "\033[0;32mPHP data store already exists\033[0m"
else
  echo -e "\033[0;34mCreating PHP data container\033[0m"
  docker create --name devops-db-data-php devops-db-data-php:latest
fi

#run the database

echo "Running MYSQL server"

#OLD LINE
docker run --name devops-db -e MYSQL_ROOT_PASSWORD=devops -p 3306:3306 --volumes-from devops-db-data-java --volumes-from devops-db-data-php -d devops-db:latest

#docker run --name devops-db -e MYSQL_ROOT_PASSWORD=devops -p 3306:3306 -d devops-db:latest
