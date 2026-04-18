#!/bin/bash
set -euo pipefail
RESOURCE_GROUP="${RESOURCE_GROUP:?Set RESOURCE_GROUP environment variable}"
CLUSTER_NAME="${CLUSTER_NAME:-aks-workout-planner}"
ACR_LOGIN_SERVER="${ACR_LOGIN_SERVER:?Set ACR_LOGIN_SERVER environment variable}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MANIFESTS_DIR="${PROJECT_ROOT}/infra/k8s/manifests"
echo "============================================================"
echo "Deploying Workout Planner to AKS"
echo "Cluster: ${CLUSTER_NAME}"
echo "ACR:     ${ACR_LOGIN_SERVER}"
echo "============================================================"
echo "Getting AKS credentials..."
az aks get-credentials \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${CLUSTER_NAME}" \
  --overwrite-existing
echo "Updating manifests with ACR server..."
TEMP_DIR=$(mktemp -d)
for f in "${MANIFESTS_DIR}"