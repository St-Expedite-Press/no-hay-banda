#!/bin/bash
# New Showbiz content pipeline runner
# Usage: ./run-pipeline.sh "research prompt"
# Wraps hermes oneshot with failure logging and timestamped output capture.

set -euo pipefail

PROFILE="newshowbiz"
LOG_DIR="/home/ec2-user/.hermes/profiles/${PROFILE}/logs"
FAIL_LOG="${LOG_DIR}/pipeline-failures.log"
OUTPUT_LOG="${LOG_DIR}/pipeline-output.log"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ $# -eq 0 ]; then
  echo "Usage: $0 \"<research prompt>\""
  exit 1
fi

PROMPT="$*"

echo "[${TIMESTAMP}] START — ${PROMPT:0:80}..." >> "${OUTPUT_LOG}"

hermes -p "${PROFILE}" -z "${PROMPT}"
EXIT=$?

if [ $EXIT -ne 0 ]; then
  echo "[${TIMESTAMP}] FAILED — exit ${EXIT} — prompt: ${PROMPT:0:120}" >> "${FAIL_LOG}"
  echo "Pipeline failed (exit ${EXIT}). Logged to ${FAIL_LOG}" >&2
  exit $EXIT
fi

echo "[${TIMESTAMP}] OK" >> "${OUTPUT_LOG}"
