# GitHub Actions CICD

A shared set of github composite actions to be used in Envase CICD pipelines

## Node.js Lambda

To use the actions in this repo to bootstrap and deploy a Node.js lambda relies on the serverless framework. Below is an example deployment yaml outlining how to use these composite actions in your repo's github workflow.

```yml
name: Deploy

on:
  push:
    branches: [ main ] # Run automatically when pushed to this branch

  workflow_dispatch: # Allows running of this deployment manually from the GitHub UI

jobs:
  deploy-lambda:
    runs-on: ubuntu-latest
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.CD_DEPLOYER_NON_PROD_KEY }} # Deployer AWS access key
      AWS_SECRET_ACCESS_KEY: ${{ secrets.CD_DEPLOYER_NON_PROD_SECRET }} # Deployer AWS secret key
      AWS_DEFAULT_REGION: us-east-1

    steps:
      - uses: actions/checkout@v3

      - name: Install Node, Serverless, and dependencies
        uses: envasetechnologies/.github/actions/js/setup-environment@v1 # Points to this repo's composite action on the v1 branch
        with:
          node-version: 18
          install-token: ${{ secrets.ENVASE_CONNECT_GPR_TOKEN }} # Optional token for private npm packages
          stage: "test" # Stage to deploy to

      - name: Build # Build commands here
        run: npm run build

      - name: Deploy
        uses: envasetechnologies/.github/actions/js/run-serverless-task@v1
        with:
          stage: test # environment to deploy to (i.e dev, stg, prd, test, sandbox, prod)
```
<br>

## ECS
<br>

To use the actions in this repo to bootstrap and deploy a dockerized ECS instance. The pipeline outlined below will build your `task-definition.json` from the template in your repo. It will also build your docker image, tag it, push it to ECR, and deploy from ECR to your ECS cluster.

This pipeline uses a standardized naming convention: `APP_NAME-VERSION-ENVIRONMENT`

### Requirements

1. Secrets stored in secrets manager must be named `APP_NAME/ENVIRONMENT`

2. `APP_VERSION` is pulled from `package.json` in Node projects and from `build.gradle` in Java projects. This is used to tag your ECR image. If you don't use semantic versioning, you can manually pass in an image tag for ECR as seen in the example below.

3. A file named `task-definition-template.json` must be located in the root of your repo. Secret values will be templated in based on the `ENVIRONMENT` env var and application env vars can be hardcoded into the template or set in the pipeline where noted in the `deploy.yml`

4. An ECR Repository must be created typically named the same as `APP_NAME`

5. An ECS Cluster must be created typically named `APP_NAME-CLUSTER`

6. An ECS Service must be created typically named `APP_NAME-ENVIRONMENT`

7. A file named `Dockerfile` at the root of your repo.

<br>

```json
// task-definition-template.json
{
  "executionRoleArn": "arn:aws:iam::{{AWS_ACCOUNT_ID}}:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "secrets": [
        {
          "name": "DB_HOST",
          "valueFrom": "{{secretArn}}:DB_HOST::" // Secrets get templated in here by the specific named values in AWS Secrets Manager
        },
        {
          "name": "DB_NAME",
          "valueFrom": "{{secretArn}}:DB_NAME::"
        },
        {
          "name": "DB_PASSWORD",
          "valueFrom": "{{secretArn}}:DB_PASSWORD::"
        },
        {
          "name": "DB_USERNAME",
          "valueFrom": "{{secretArn}}:DB_USERNAME::"
        },
        {
          "name": "ENCRYPT_TOKEN",
          "valueFrom": "{{secretArn}}:ENCRYPT_TOKEN::"
        },
        {
          "name": "DB_ROOT_USER",
          "valueFrom": "{{secretArn}}:DB_ROOT_USER::"
        },
        {
          "name": "DB_ROOT_PASSWORD",
          "valueFrom": "{{secretArn}}:DB_ROOT_PASSWORD::"
        },
        {
          "name": "COGNITO_USER_POOL",
          "valueFrom": "{{secretArn}}:COGNITO_USER_POOL::"
        },
        {
          "name": "WHITELIST_ORIGINS",
          "valueFrom": "{{secretArn}}:WHITELIST_ORIGINS::"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/{{APP_NAME}}-{{ENVIRONMENT}}", // Log group must be named this way or change it to whatever your log group is named
          "awslogs-region": "{{AWS_DEFAULT_REGION}}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "hostPort": 8080,
          "protocol": "tcp",
          "containerPort": 8080
        }
      ],
      "cpu": 512,
      "environment": [
        {
          "name": "ENVIRONMENT",
          "value": "{{ENVIRONMENT}}" // Application Environment variable, templated in at build time
        },
        {
          "name": "LOG_LEVEL",
          "value": "{{LOG_LEVEL}}"
        },
        {
          "name": "PORT",
          "value": "8080" // Application Environment variable, hardcoded as it does not change per environment
        },
        {
          "name": "TOKEN_SCOPE",
          "value": "connectdata/events"
        }
      ],
      "memoryReservation": 1024,
      "image": "{{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_DEFAULT_REGION}}.amazonaws.com/{{APP_NAME}}:{{APP_VERSION}}",
      "essential": true,
      "name": "{{APP_NAME}}"
    }
  ],
  "memory": "2048",
  "taskRoleArn": "arn:aws:iam::{{AWS_ACCOUNT_ID}}:role/ecsTaskExecutionRole",
  "family": "{{APP_NAME}}-{{ENVIRONMENT}}",
  "requiresCompatibilities": [
    "EC2",
    "FARGATE"
  ],
  "networkMode": "awsvpc",
  "runtimePlatform": {
    "operatingSystemFamily": "LINUX"
  },
  "cpu": "1024"
}

```

<br>

```dockerfile
# Dockerfile

# Build Stage
FROM amazoncorretto:17 AS build

COPY ./gradlew ./gradlew
COPY ./gradle ./gradle
COPY ./settings.gradle ./settings.gradle
COPY ./src ./src
COPY ./build.gradle ./build.gradle
RUN chmod +x ./gradlew && ./gradlew build

ARG JAR_FILE=build/libs/*.jar
RUN mv ${JAR_FILE} app.jar

# Deploy Stage
FROM amazoncorretto:17

EXPOSE 8080

RUN yum update -y
RUN yum upgrade -y

COPY --from=build app.jar ./

ENTRYPOINT ["java","-jar","/app.jar"]
```

<br>

Below are a few example deployment yaml files outlining how to use these composite actions in your repo's github workflow.

## Java ECS

```yml
name: Deploy

on:
  push:
    branches: [ main ]

  workflow_dispatch:

jobs:
  deploy-ecs:
    runs-on: ubuntu-latest
    env:
      AWS_DEFAULT_REGION: "us-east-1"
      AWS_ACCOUNT_ID: ""
      APP_NAME: envase-sites-api
      ECS_CLUSTER: envase-sites-api-cluster
      # APPLICATION ENV VARS #
      ENVIRONMENT: dev
      KI_EMAIL: data@kestrelinsights.com
      ENABLE_EMAIL: false
      CORS_ORIGINS: "http://localhost:3000,geofences-dev.envaseconnect.cloud"
      GEOFENCE_PROVIDER_CRON_JOB: "0 0 0 * * SUN"

    steps:
      - uses: actions/checkout@v3

      - name: Download scripts
        run: >
          curl -sSL https://raw.githubusercontent.com/envasetechnologies/.github/v1/actions/scripts/build_task_definition.sh -o build_task_definition.sh &&
          curl -sSL https://raw.githubusercontent.com/envasetechnologies/.github/v1/actions/scripts/build_push_docker.sh -o build_push_docker.sh &&
          chmod +x build_task_definition.sh build_push_docker.sh &&
          curl -sS https://raw.githubusercontent.com/envasetechnologies/.github/v1/actions/scripts/envase-connect-ascii.txt

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.CD_DEPLOYER_NON_PROD_KEY }} # Envase Org Deployer Role, contact Envase Admin for access
          aws-secret-access-key: ${{ secrets.CD_DEPLOYER_NON_PROD_SECRET }}
          aws-region: ${{ env.AWS_DEFAULT_REGION }}

      - uses: actions/setup-java@v3
        with:
          distribution: 'corretto'
          java-version: '17' # Set Java version here

      - name: Set AWS account id
        run: >
          AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) &&
          echo "AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}" >> $GITHUB_ENV

      - name: Docker Build, Tag, Push to ECR
        uses: envasetechnologies/.github/actions/common/docker-build-tag@v1
        with:
          ecr-uri: ${{ env.AWS_ACCOUNT_ID }}.dkr.ecr.${{ env.AWS_DEFAULT_REGION }}.amazonaws.com/${{ env.APP_NAME }}
          tag: # Optional tag if not using APP_NAME-ENVIRONMENT as the ECR tag

      - name: Build task def
        uses: envasetechnologies/.github/actions/common/render-ecs-task-def@v1
        with:
          task-def-path: task-definition.json # this should always be at the root of the repo where your task-definition-temaplate.json is

      - name: Docker Deploy
        uses: envasetechnologies/.github/actions/common/deploy-ecs-task@v1
        with:
          task-definition: task-definition.json
          ecs-service: ${{ env.APP_NAME }}-${{ env.ENVIRONMENT }}
          ecs-cluster: ${{ env.ECS_CLUSTER }}
```

## Node ECS

```yml
name: Deploy

on:
  push:
    branches: [ main ]

  workflow_dispatch:

jobs:
  deploy-ecs:
    runs-on: ubuntu-latest
    env:
      AWS_DEFAULT_REGION: "us-east-1"
      APP_NAME: envase-connect-webhooks-api
      AWS_ACCOUNT_ID: ""
      # APPLICATION ENV VARS #
      ENVIRONMENT: test
      LOG_LEVEL: debug

    steps:
      - uses: actions/checkout@v3

      - name: Download scripts
        run: >
          curl -sSL https://raw.githubusercontent.com/envasetechnologies/.github/v1/actions/scripts/build_task_definition.sh -o build_task_definition.sh &&
          curl -sSL https://raw.githubusercontent.com/envasetechnologies/.github/v1/actions/scripts/build_push_docker.sh -o build_push_docker.sh &&
          chmod +x build_task_definition.sh build_push_docker.sh &&
          curl -sS https://raw.githubusercontent.com/envasetechnologies/.github/v1/actions/scripts/envase-connect-ascii.txt

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.CD_DEPLOYER_NON_PROD_KEY }}
          aws-secret-access-key: ${{ secrets.CD_DEPLOYER_NON_PROD_SECRET }}
          aws-region: ${{ env.AWS_DEFAULT_REGION }}

      - uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Set AWS account id
        run: >
          AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) &&
          echo "AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}" >> $GITHUB_ENV

      - name: Docker Build, Tag, Push to ECR
        uses: envasetechnologies/.github/actions/common/docker-build-tag@v1
        with:
          install-token: ${{ secrets.ENVASE_CONNECT_GPR_TOKEN }}
          ecr-uri: 518892363268.dkr.ecr.${{ env.AWS_DEFAULT_REGION }}.amazonaws.com/${{ env.APP_NAME }}

      - name: Build task def
        uses: envasetechnologies/.github/actions/common/render-ecs-task-def@v1
        with:
          task-def-path: task-definition.json

      - name: Docker Deploy
        uses: envasetechnologies/.github/actions/common/deploy-ecs-task@v1
        with:
          task-definition: task-definition.json
          ecs-service: ${{ env.APP_NAME }}-${{ env.ENVIRONMENT }}
          ecs-cluster: envase-connect-cluster
```
