#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi
set -x # Enable debugging
# تنظیمات
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <IMAGE_NAME> <LOCAL_TAG>"
    exit 1
fi

IMAGE_NAME="$1"
LOCAL_TAG="$2"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# دریافت تگ جدید از رجیستری
echo "Logging in to the private registry..."
echo "$REGISTRY_PASSWORD" | docker login "$REGISTRY_URL" -u "$REGISTRY_USERNAME" --password-stdin   2>/dev/null 

echo "Pulling image $IMAGE_NAME..."
OUTPUT=$(docker pull $REGISTRY_URL/$IMAGE_NAME:$LOCAL_TAG 2>&1)
STATUS=$?

# Check if the docker pull command failed
if [ $STATUS -ne 0 ]; then
    echo "Error: Failed to pull the image from the registry. Status code: $STATUS"
    echo "$OUTPUT"
    exit $STATUS
fi

# Check if there was an error during the pull
if echo "$OUTPUT" | grep -q "Error"; then
    echo "Error occurred while pulling the image:"
    echo "$OUTPUT"
    exit 1
fi

# Check if the image was updated or already up to date
if echo "$OUTPUT" | grep -q "Downloaded newer image"; then
    echo "New image downloaded. Restarting the service..."
    docker compose -f "$DOCKER_COMPOSE_FILE" down
    docker compose -f "$DOCKER_COMPOSE_FILE" up -d
else
    echo "Image is already up to date. No need to restart."
fi
