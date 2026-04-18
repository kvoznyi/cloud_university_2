#!/bin/bash
set -euo pipefail
VM_IP="${VM_IP:?Set VM_IP environment variable}"
VM_USER="${VM_USER:-azureuser}"
ACR_LOGIN_SERVER="${ACR_LOGIN_SERVER:?Set ACR_LOGIN_SERVER environment variable}"
ACR_USERNAME="${ACR_USERNAME:?Set ACR_USERNAME environment variable}"
ACR_PASSWORD="${ACR_PASSWORD:?Set ACR_PASSWORD environment variable}"
DOCKER_IMAGE="${DOCKER_IMAGE:-workoutplanner:latest}"
echo "============================================================"
echo "Deploying to VM: ${VM_USER}@${VM_IP}"
echo "Image: ${ACR_LOGIN_SERVER}/${DOCKER_IMAGE}"
echo "============================================================"
ssh "${VM_USER}@${VM_IP}" << EOF
  docker login ${ACR_LOGIN_SERVER} -u ${ACR_USERNAME} -p ${ACR_PASSWORD}
  docker stop workoutplanner 2>/dev/null || true
  docker rm workoutplanner 2>/dev/null || true
  docker pull ${ACR_LOGIN_SERVER}/${DOCKER_IMAGE}
  docker run -d \
    --name workoutplanner \
    --restart unless-stopped \
    -p 80:80 \
    -p 443:443 \
    ${ACR_LOGIN_SERVER}/${DOCKER_IMAGE}
  echo "Container is running:"
  docker ps --filter name=workoutplanner
EOF
echo ""
echo "Deployment complete! App available at http://${VM_IP}"