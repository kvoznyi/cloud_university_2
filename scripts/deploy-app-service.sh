#!/bin/bash
set -euo pipefail
APP_NAME="${APP_NAME:-app-workout-planner}"
RESOURCE_GROUP="${RESOURCE_GROUP:?Set RESOURCE_GROUP environment variable}"
ACR_LOGIN_SERVER="${ACR_LOGIN_SERVER:?Set ACR_LOGIN_SERVER environment variable}"
DOCKER_IMAGE="${DOCKER_IMAGE:-workoutplanner}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
echo "============================================================"
echo "Updating App Service: ${APP_NAME}"
echo "Image: ${ACR_LOGIN_SERVER}/${DOCKER_IMAGE}:${IMAGE_TAG}"
echo "============================================================"
az webapp config container set \
  --name "${APP_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --container-image-name "${ACR_LOGIN_SERVER}/${DOCKER_IMAGE}:${IMAGE_TAG}" \
  --container-registry-url "https://${ACR_LOGIN_SERVER}"
echo "Restarting App Service..."
az webapp restart \
  --name "${APP_NAME}" \
  --resource-group "${RESOURCE_GROUP}"
URL=$(az webapp show \
  --name "${APP_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query "defaultHostName" \
  --output tsv)
echo ""
echo "============================================================"
echo "App Service updated and restarted!"
echo "URL: https://${URL}"
echo "============================================================"