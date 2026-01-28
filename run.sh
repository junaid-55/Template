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

curl -X GET http://localhost:8081/api/service-a/preferences \
     -H "Authorization: Bearer eyJhbGciOiJFZERTQSIsImtpZCI6IldpbWZ4TjJuajZKRnVNWkI5V3RGUEpJY2s2cmdlNlpRIn0.eyJpYXQiOjE3Njk2MDcxODUsIm5hbWUiOiJUZXN0ZXIiLCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJlbWFpbFZlcmlmaWVkIjpmYWxzZSwiaW1hZ2UiOm51bGwsImNyZWF0ZWRBdCI6IjIwMjYtMDEtMjhUMTM6MzI6NTMuOTk5WiIsInVwZGF0ZWRBdCI6IjIwMjYtMDEtMjhUMTM6MzI6NTMuOTk5WiIsImlkIjoiRHZIRFlHMWQyRWpyY09FMmhpbDl4bzF6eTdXMnE1T20iLCJzdWIiOiJEdkhEWUcxZDJFanJjT0UyaGlsOXhvMXp5N1cycTVPbSIsImV4cCI6MTc2OTYxMDc4NSwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgxIiwiYXVkIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgxIn0.0PmBU8O_wLKCJkZ5WePRBTigrFGOFDp_czVkTSIcoOiK_3c0rVnlbn6oLdJj0kWczSt1DfHzNW9hXfkFvG9tDg"