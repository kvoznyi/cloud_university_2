#!/bin/bash
set -euo pipefail
TARGET_URL="${TARGET_URL:?Set TARGET_URL environment variable (e.g. http://localhost:80)}"
DURATION="${DURATION:-30s}"
CONCURRENCY="${CONCURRENCY:-50}"
REQUESTS="${REQUESTS:-500}"
echo "============================================================"
echo "Workout Planner — Load Test"
echo "Target:      ${TARGET_URL}"
echo "Duration:    ${DURATION}"
echo "Concurrency: ${CONCURRENCY}"
echo "Requests:    ${REQUESTS}"
echo "============================================================"
if command -v hey &> /dev/null; then
  echo "Using 'hey' for load testing..."
  echo ""
  echo "--- Test 1: Health Check Endpoint ---"
  hey -n "${REQUESTS}" -c "${CONCURRENCY}" -z "${DURATION}" "${TARGET_URL}/health"
  echo ""
  echo "--- Test 2: Home Page ---"
  hey -n "${REQUESTS}" -c "${CONCURRENCY}" -z "${DURATION}" "${TARGET_URL}/"
  echo ""
  echo "--- Test 3: Prediction API ---"
  hey -n "${REQUESTS}" -c "${CONCURRENCY}" -z "${DURATION}" \
    -m POST \
    -H "Content-Type: application/json" \
    -d '{"age":25,"weight":70,"height":175,"goal":"weight_loss","fitness_level":"intermediate"}' \
    "${TARGET_URL}/api/prediction"
elif command -v curl &> /dev/null; then
  echo "Warning: 'hey' not found, falling back to curl-based test."
  echo "Install hey: go install github.com/rakyll/hey@latest"
  echo ""
  echo "Sending ${REQUESTS} sequential requests..."
  START=$(date +%s)
  SUCCESS=0
  FAIL=0
  for i in $(seq 1 "${REQUESTS}"); do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${TARGET_URL}/health" 2>/dev/null)
    if [ "$HTTP_CODE" -eq 200 ]; then
      SUCCESS=$((SUCCESS + 1))
    else
      FAIL=$((FAIL + 1))
    fi
    if [ $((i % 50)) -eq 0 ]; then
      echo "  Completed: ${i}/${REQUESTS} (${SUCCESS} ok, ${FAIL} failed)"
    fi
  done
  END=$(date +%s)
  ELAPSED=$((END - START))
  echo ""
  echo "Results:"
  echo "  Total:    ${REQUESTS}"
  echo "  Success:  ${SUCCESS}"
  echo "  Failed:   ${FAIL}"
  echo "  Duration: ${ELAPSED}s"
  echo "  RPS:      $(echo "scale=2; ${REQUESTS} / ${ELAPSED}" | bc)"
else
  echo "Error: Neither 'hey' nor 'curl' found. Install one to run load tests."
  exit 1
fi
echo ""
echo "============================================================"
echo "Load test complete!"
echo "Check Grafana dashboard for metrics visualization."
echo "============================================================"