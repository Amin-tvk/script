#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi
set -x # Enable debugging
# تنظیمات
IMAGE_NAME="nginx"
LOCAL_TAG="latest"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# دریافت تگ جدید از رجیستری
echo "Logging in to the private registry..."
echo "$REGISTRY_PASSWORD" | docker login "$REGISTRY_URL" -u "$REGISTRY_USERNAME" --password-stdin   2>/dev/null 

echo "Pulling image $IMAGE_NAME..."
OUTPUT=$(docker pull $REGISTRY_URL/$IMAGE_NAME:$LOCAL_TAG 2>&1)

# Check if the image was updated or already up to date
if echo "$OUTPUT" | grep -q "Downloaded newer image"; then
    echo "New image downloaded. Restarting the service..."
    docker compose -f "$DOCKER_COMPOSE_FILE" down
    docker compose -f "$DOCKER_COMPOSE_FILE" up -d
else
    echo "Image is already up to date. No need to restart."
fi