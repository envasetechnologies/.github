#!/bin/bash

##############################
# $1 = ecr-uri
# $2 = optional - install token
# $3 = optional - image tag
##############################

set -eu
set -o pipefail

PACKAGE_JSON=./package.json
BUILD_GRADLE=./build.gradle

node_build(){
    echo  ---------- Node Variation ----------
    echo Node Version: "$(node -v)"
    APP_VERSION=$(node -pe "require('./package.json').version")
    export APP_VERSION
    echo "APP_VERSION=${APP_VERSION}" >> $GITHUB_ENV
    echo running build for version $APP_VERSION
}

java_build(){
    echo ---------- Java Variation ----------
    echo Java Version: "$(java --version)"
    chmod +x ./gradlew
    APP_VERSION=$(./gradlew properties | grep ^version: | tr -d version: | cut -c2-)
    echo "APP_VERSION=${APP_VERSION}" >> $GITHUB_ENV
    export APP_VERSION
}

if [ -f "$PACKAGE_JSON" ]; then
    node_build
elif [ -f "$BUILD_GRADLE" ]; then
    java_build
else
    echo Unsupported language - supported languages are Java and JavaScript/Typescript
    exit 1
fi

if [ -n "${2:-}" ]; then
    echo ---------- Using install token ----------
    echo ---------- App version: $APP_VERSION ----------

    docker build -t $APP_NAME --build-arg ENVASE_CONNECT_GPR_TOKEN=$2 .
else
    echo ---------- App version: $APP_VERSION ----------
    docker build -t $APP_NAME .
fi

if [ -n "${3:-}" ]; then
    echo ---------- Using image tag ----------
    docker tag $APP_NAME $1:$3

    echo pushing
    docker push $1 -a
    echo "image=$1:$3" >> $GITHUB_OUTPUT
else
    echo ---------- Tagging with app version $APP_VERSION ----------
    docker tag $APP_NAME $1:$APP_VERSION

    echo pushing $1
    docker push $1 -a
    echo "image=$1:$APP_VERSION" >> $GITHUB_OUTPUT
fi

