#!/bin/bash

set -eu
set -o pipefail

PACKAGE_JSON=./package.json
BUILD_GRADLE=./build.gradle

INSTALL_TOKEN=""
ECR_URI=""
IMAGE_TAG=""

function help() {
    echo
    echo "The available options for this script are:"
    echo
    echo "-e (required)     Sets the AWS ECR URI"
    echo "-i     Sets the install token"
    echo "-t     Sets the image tag to be used in ECR"
    echo "-h     Shows this help screen."
    echo
    exit
}

while getopts e:i:t:h flag; do
    case "${flag}" in
    e) ECR_URI=${OPTARG} ;;
    i) INSTALL_TOKEN=${OPTARG} ;;
    t) IMAGE_TAG=${OPTARG} ;;
    h) help ;;
    *) help ;;
    esac
done

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
    ex
    it 1
fi

if [ -n "$INSTALL_TOKEN" ]; then
    echo ---------- Using install token ----------
    echo ---------- App version: $APP_VERSION ----------

    docker build -t $APP_NAME --build-arg ENVASE_CONNECT_GPR_TOKEN=$INSTALL_TOKEN .
else
    echo ---------- App version: $APP_VERSION ----------
    docker build -t $APP_NAME .
fi

if [ -n "$IMAGE_TAG" ]; then
    echo ---------- Using image tag ----------
    docker tag $APP_NAME $ECR_URI:$IMAGE_TAG

    echo pushing
    docker push $ECR_URI -a
    echo "image=$ECR_URI:$IMAGE_TAG" >> $GITHUB_OUTPUT
else
    echo ---------- Tagging with app version $APP_VERSION ----------
    docker tag $APP_NAME $ECR_URI:$APP_VERSION

    echo pushing $ECR_URI
    docker push $ECR_URI -a
    echo "image=$ECR_URI:$APP_VERSION" >> $GITHUB_OUTPUT
fi

