#!/bin/bash

# Create top-level files
touch docker-compose.yml .env

# Create Infrastructure folder (Database)
mkdir -p infra/db
touch infra/db/init.sql

# Create API Gateway folder
mkdir -p api-gateway
touch api-gateway/default.conf
touch api-gateway/Dockerfile

# Create Services folder
mkdir -p services/auth-service/src
mkdir -p services/service-a/src
mkdir -p services/service-b/src

# Create Dockerfiles and package.json placeholders for each service
services=("auth-service" "service-a" "service-b")

for service in "${services[@]}"
do
    touch services/$service/Dockerfile
    touch services/$service/package.json
    touch services/$service/src/index.ts
done

# Add basic Better-Auth config file for the auth service
touch services/auth-service/src/auth.ts

echo "Structure created successfully"