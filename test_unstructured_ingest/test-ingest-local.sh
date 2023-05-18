#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"/.. || exit 1

PYTHONPATH=. ./unstructured/ingest/main.py \
    --metadata-exclude filename,file_directory \
    --local-input-path example-docs \
    --local-file-glob "*.html" \
    --structured-output-dir local-ingest-output \
    --partition-strategy hi_res \
    --download-dir files-ingest-download \
    --preserve-downloads \
    --verbose \
    --reprocess

set +e

if [ "$(find 'local-ingest-output' -type f -printf '.' | wc -c)" != 4 ]; then
   echo
   echo "4 files should have been created."
   exit 1
fi
