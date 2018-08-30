#!/bin/bash

DATASET_DUMP=${1-lahman.pgdump.gz}
DATASET_DUMP_NO_GZ="$DATASET_DUMP"

DATASET_NAME=${2-baseball}

set -e

if [[ "${DATASET_DUMP: -3}" == ".gz" ]]; then
    DATASET_DUMP_NO_GZ="${DATASET_DUMP%.gz}"
    rm -f "$DATASET_DUMP_NO_GZ"
    gunzip -k "${DATASET_DUMP}"
fi

dropdb --if-exists "$DATASET_NAME"
createdb "$DATASET_NAME"
psql -e -d "$DATASET_NAME" < "$DATASET_DUMP_NO_GZ"

if [[ "${DATASET_DUMP: -3}" == ".gz" ]]; then
    rm -f "$DATASET_DUMP_NO_GZ"
fi

echo -e '\nHW1 setup complete'
