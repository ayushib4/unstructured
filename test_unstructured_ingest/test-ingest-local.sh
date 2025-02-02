#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"/.. || exit 1

PYTHONPATH=. ./unstructured/ingest/main.py \
    --metadata-exclude filename,file_directory,metadata.data_source.date_processed \
    --local-input-path example-docs \
    --local-file-glob "*.html" \
    --structured-output-dir local-ingest-output \
    --partition-strategy hi_res \
    --verbose \
    --reprocess

set +e

if [ "$(find 'local-ingest-output' -type f -printf '.' | wc -c)" != 9 ]; then
   echo
   echo "9 files should have been created."
   exit 1
fi
