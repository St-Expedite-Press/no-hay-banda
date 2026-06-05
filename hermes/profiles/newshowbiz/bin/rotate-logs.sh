#!/bin/bash
# Rotate old session files and compress pipeline logs.
# Run weekly via cron.

PROFILE_ROOT="/home/ec2-user/.hermes/profiles/newshowbiz"
SESSION_DIR="${PROFILE_ROOT}/sessions"
ARCHIVE_DIR="${SESSION_DIR}/archive"
LOG_DIR="${PROFILE_ROOT}/logs"
CUTOFF_DAYS=30

mkdir -p "${ARCHIVE_DIR}"

# Archive sessions older than CUTOFF_DAYS
find "${SESSION_DIR}" -maxdepth 1 -name "*.json" -mtime +${CUTOFF_DAYS} \
  -exec mv {} "${ARCHIVE_DIR}/" \;

ARCHIVED=$(find "${ARCHIVE_DIR}" -name "*.json" | wc -l)

# Compress pipeline-output.log if over 5MB
OUTPUT_LOG="${LOG_DIR}/pipeline-output.log"
if [ -f "${OUTPUT_LOG}" ] && [ $(stat -c%s "${OUTPUT_LOG}" 2>/dev/null || echo 0) -gt 5242880 ]; then
  gzip -k "${OUTPUT_LOG}"
  > "${OUTPUT_LOG}"
fi

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] rotate-logs: ${ARCHIVED} sessions archived"
