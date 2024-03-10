#!/bin/bash
PROJECT_NAME="local-sonarqube"
FILE=sonar-project.properties
UP_STATUS="UP"
DEFAULT_USER="admin"
DEFAULT_PSW="admin"

response=$(curl -H "Accept: application/json" -X GET http://localhost:9000/api/system/status 2>/dev/null)
status=$(echo "$response" | jq .status | sed 's/\"//g' )
echo "Waiting SonarQube Server..."

while [[ $status != $UP_STATUS ]]
do
  sleep 3
  response=$(curl -H "Accept: application/json" -X GET http://localhost:9000/api/system/status 2>/dev/null)
  status=$(echo "$response" | jq .status | sed 's/\"//g' )
done
echo "SonarQube Server is UP!"

if [[ -f "$FILE" ]]; then
    echo "$FILE already exists."
    exit 0
fi

response_headers=$(curl -s -X POST -d "login=$DEFAULT_USER&password=$DEFAULT_PSW" -D - http://localhost:9000/api/authentication/login -o /dev/null)

# Get the status code from the response headers
status_code=$(echo "$response_headers" | grep -oP 'HTTP/\d+\.\d+ \K\d+')
if [[ $status_code -eq 200 ]]
then
  # Get the JWT-SESSION cookie from the response headers
  jwt_session_cookie=$(echo "$response_headers" | grep -oP 'Set-Cookie: JWT-SESSION=\K[^;]+')

  response_headers=$(curl -s -u $DEFAULT_USER:$DEFAULT_PSW -X POST -d "name=$PROJECT_NAME&project=$PROJECT_NAME" -D - http://localhost:9000/api/projects/create -o /dev/null)
  status_code=$(echo "$response_headers" | grep -oP 'HTTP/\d+\.\d+ \K\d+')
  if [ $status_code -eq 200 ]
  then
    echo "Project $PROJECT_NAME created succesfully!"

    response=$(curl -s -H "Accept: application/json" -u $DEFAULT_USER:$DEFAULT_PSW -X POST -d "name="local_sonarqube_token"&login=$DEFAULT_USER&type="GLOBAL_ANALYSIS_TOKEN"" http://localhost:9000/api/user_tokens/generate /dev/null)
    token=$(echo "$response" | jq .token | sed 's/\"//g')

    if [ $token != "null" ]
    then
      echo "Token created succesfully!"
      # Generate the sonar-project.properties file
      echo "sonar.projectKey=$PROJECT_NAME
sonar.projectName=$PROJECT_NAME
sonar.host.url=http://localhost:9000
sonar.login=$token
sonar.sourceEncoding=UTF-8
sonar.language=go
sonar.sources=.
sonar.exclusions=**/*_test.go,**/vendor/**,**/testdata/*
sonar.tests=.
sonar.test.inclusions=**/*_test.go
sonar.test.exclusions=**/vendor/**
sonar.go.coverage.reportPaths=cov.out" > sonar-project.properties


      echo "sonar-project.properties file has been generated."
    else
      echo "There was a problem creating the token:"
      echo $response
    fi
  else
    echo "There was a problem creating the project..."
    echo "Status code was $status_code"
  fi
else
  echo "SonarQube credentials has been changed"
  echo "Aborting SonarQube initializing..."
fi