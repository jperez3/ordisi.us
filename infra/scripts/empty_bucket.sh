#!/usr/bin/env bash
set -euo pipefail

# Empties an S3 bucket, including all object versions and delete markers.
# Usage: ./empty_bucket.sh <bucket-name>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <bucket-name>" >&2
  exit 1
fi

BUCKET="$1"

if ! aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  echo "Error: bucket '$BUCKET' does not exist or you don't have access to it." >&2
  exit 1
fi

echo "Emptying bucket: $BUCKET"

# Remove all current objects (handles non-versioned buckets and any live objects).
aws s3 rm "s3://$BUCKET" --recursive

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

delete_batch() {
  local key_field="$1" # "Versions" or "DeleteMarkers"
  local next_key_marker="" next_version_id_marker=""
  local page=0

  while :; do
    local args=(--bucket "$BUCKET" --output json
      --query "{Objects: ${key_field}[].{Key:Key,VersionId:VersionId}}")

    if [[ -n "$next_key_marker" ]]; then
      args+=(--key-marker "$next_key_marker" --version-id-marker "$next_version_id_marker")
    fi

    aws s3api list-object-versions "${args[@]}" >"$TMP_DIR/batch.json"

    local count
    count=$(jq '.Objects | length' "$TMP_DIR/batch.json")

    if [[ "$count" -gt 0 ]]; then
      echo "Deleting $count ${key_field} (batch $((++page)))..."
      aws s3api delete-objects --bucket "$BUCKET" --delete "file://$TMP_DIR/batch.json" >/dev/null
    fi

    # Check if there's more to paginate through.
    local truncated
    truncated=$(aws s3api list-object-versions --bucket "$BUCKET" \
      --query 'IsTruncated' --output text 2>/dev/null || echo "False")

    if [[ "$truncated" != "True" ]]; then
      break
    fi

    next_key_marker=$(aws s3api list-object-versions --bucket "$BUCKET" \
      --query 'NextKeyMarker' --output text)
    next_version_id_marker=$(aws s3api list-object-versions --bucket "$BUCKET" \
      --query 'NextVersionIdMarker' --output text)

    if [[ "$next_key_marker" == "None" || -z "$next_key_marker" ]]; then
      break
    fi
  done
}

# Remove all noncurrent object versions.
delete_batch "Versions"

# Remove all delete markers.
delete_batch "DeleteMarkers"

echo "Bucket '$BUCKET' is now empty."
