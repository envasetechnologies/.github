#! /bin/bash
# install deps
curl -sSL https://raw.githubusercontent.com/tests-always-included/mo/master/mo -o mo
chmod +x mo
sudo mv mo /usr/local/bin/

SECRET_ID="$APP_NAME/$ENVIRONMENT"
# Determine dev or prod env & set jq path
JQ_PATH=$(which jq)

echo "---------- $SECRET_ID -------------"

output=$(aws secretsmanager get-secret-value --secret-id $SECRET_ID --output text)
splitOutput=$output
secretArn=${splitOutput[0]}
export secretArn=$secretArn

add_xray_deamon() {
  cat task-definition-template.json | $JQ_PATH '.containerDefinitions += [{
            "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "/ecs/{{APP_NAME}}-{{ENVIRONMENT}}",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs"
            }
          },
          "portMappings": [
            {
              "hostPort": 2000,
              "protocol": "udp",
              "containerPort": 2000
            }
          ],
          "cpu": 128,
          "environment": [],
          "mountPoints": [],
          "memoryReservation": 256,
          "volumesFrom": [],
          "image": "amazon/aws-xray-daemon",
          "name": "xray-daemon"
        }]' | mo > task-definition.json
}

# Create task-def file with populated secrets
echo "Creating task-definition.json file"
cat task-definition-template.json | mo > task-definition.json

if [ "$ENVIRONMENT" == "prod" ] || [ "$ENVIRONMENT" == "prd" ]; then
  add_xray_deamon
fi

echo "Task definition created"
ls -la
cat task-definition.json
