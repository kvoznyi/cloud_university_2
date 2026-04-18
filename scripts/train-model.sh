#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ML_DIR="${PROJECT_ROOT}/ml/training"
echo "============================================================"
echo "Workout Planner — ML Training Pipeline"
echo "============================================================"
if ! command -v python3 &> /dev/null; then
  echo "Error: python3 is required. Install it first."
  exit 1
fi
VENV_DIR="${ML_DIR}/.venv"
if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment..."
  python3 -m venv "$VENV_DIR"
fi
source "${VENV_DIR}/bin/activate"
echo "Installing dependencies..."
pip install -q -r "${ML_DIR}/requirements.txt"
echo ""
echo "Step 1/3: Preparing data..."
cd "${ML_DIR}"
python prepare_data.py
echo ""
echo "Step 2/3: Training model..."
python train.py
echo ""
echo "Step 3/3: Evaluating model..."
python evaluate.py
echo ""
echo "============================================================"
echo "Training pipeline complete!"
echo "Model:   ${ML_DIR}/models/model.joblib"
echo "Metrics: ${ML_DIR}/outputs/metrics.json"
echo "Plot:    ${ML_DIR}/outputs/confusion_matrix.png"
echo "============================================================"
deactivate