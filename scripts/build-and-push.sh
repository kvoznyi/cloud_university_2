#!/bin/bash
set -euo pipefail
ACR_NAME="${ACR_NAME:-acrworkoutplanner}"
ACR_LOGIN_SERVER="${ACR_LOGIN_SERVER:-${ACR_NAME}.azurecr.io}"
WEB_IMAGE_NAME="${WEB_IMAGE_NAME:-workoutplanner}"
ML_IMAGE_NAME="${ML_IMAGE_NAME:-workoutplanner-ml}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
echo "============================================================"
echo "Building and pushing images to ACR"
echo "ACR: ${ACR_LOGIN_SERVER}"
echo "============================================================"
echo "Logging in to ACR..."
az acr login --name "${ACR_NAME}"
echo ""
echo "--- Building web app image ---"
docker build \
  -t "${ACR_LOGIN_SERVER}/${WEB_IMAGE_NAME}:${IMAGE_TAG}" \
  -f "${PROJECT_ROOT}/app/web/Dockerfile" \
  "${PROJECT_ROOT}/app/web"
echo "--- Pushing web app image ---"
docker push "${ACR_LOGIN_SERVER}/${WEB_IMAGE_NAME}:${IMAGE_TAG}"
if [ -f "${PROJECT_ROOT}/ml/api/Dockerfile" ]; then
  echo ""
  echo "--- Building ML API image ---"
  cp "${PROJECT_ROOT}/ml/training/activity_labels.py" "${PROJECT_ROOT}/ml/api/activity_labels.py"
  if [ -d "${PROJECT_ROOT}/ml/training/models" ]; then
    mkdir -p "${PROJECT_ROOT}/ml/api/model"
    cp "${PROJECT_ROOT}/ml/training/models/"* "${PROJECT_ROOT}/ml/api/model/" 2>/dev/null || true
  fi
  docker build \
    -t "${ACR_LOGIN_SERVER}/${ML_IMAGE_NAME}:${IMAGE_TAG}" \
    -f "${PROJECT_ROOT}/ml/api/Dockerfile" \
    "${PROJECT_ROOT}/ml/api"
  echo "--- Pushing ML API image ---"
  docker push "${ACR_LOGIN_SERVER}/${ML_IMAGE_NAME}:${IMAGE_TAG}"
  rm -f "${PROJECT_ROOT}/ml/api/activity_labels.py"
fi
echo ""
echo "============================================================"
echo "Done! Images pushed to ${ACR_LOGIN_SERVER}"
echo "  - ${WEB_IMAGE_NAME}:${IMAGE_TAG}"
echo "  - ${ML_IMAGE_NAME}:${IMAGE_TAG}"
echo "============================================================"