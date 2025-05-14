# Replace with your private registry URL, username, password, and image name
PRIVATE_REGISTRY_URL="your-private-registry.com"
REGISTRY_USERNAME="your-username" 
REGISTRY_PASSWORD="your-password"
IMAGE_NAME="nginx"
FULL_IMAGE_NAME="$PRIVATE_REGISTRY_URL/$IMAGE_NAME"

COMPOSE_FILE_PATH="./docker-compose.yml"
SERVICE_NAME="your-service"
WEBHOOK_URL="https://your-webhook-url.com"

echo "Logging in to the private registry..."
echo "$REGISTRY_PASSWORD" | docker login "$PRIVATE_REGISTRY_URL" -u "$REGISTRY_USERNAME" --password-stdin 

if [ $? -ne 0 ]; then
    echo "Failed to log in to the private registry. Exiting."
    exit 1
fi

echo "Pulling image $FULL_IMAGE_NAME..."
OUTPUT=$(docker pull "$FULL_IMAGE_NAME")

# Check if the image was updated or already up to date
if echo "$OUTPUT" | grep -q "Downloaded newer image"; then
    echo "New image downloaded. Restarting the service..."
    docker-compose -f "$COMPOSE_FILE_PATH" down
    docker-compose -f "$COMPOSE_FILE_PATH" up -d
else
    echo "Image is already up to date. No need to restart."
fi