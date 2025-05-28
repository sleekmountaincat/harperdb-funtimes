#!/usr/bin/env bash

# this script creates a table, starts a bulk csv import job on harper and waits for it to complete

# fail on all errors
set -euo pipefail

# create table
#################################################################
echo "creating table..."
RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
  -X POST http://localhost:9925 \
  -u harperdb:test \
  -H "Content-Type: application/json" \
  -d @- <<EOF
  {
    "operation": "create_table",
    "table": "mtg_cards",
    "primary_key": "id"
  }
EOF
)

if [[ "$RESPONSE" -ne 200 ]]; then
  echo "oh no! failed to create table! response code: $RESPONSE"
  cat response.json
  exit 1
else
  echo "done!"
  echo
fi


# start bulk csv load
#################################################################
echo "starting bulk csv load..."
RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
  -X POST http://localhost:9925 \
  -u harperdb:test \
  -H "Content-Type: application/json" \
  -d @- <<EOF
  {
    "operation": "csv_file_load",
    "action": "insert",
    "table": "mtg_cards",
    "file_path": "/home/harperdb/tmpdata/mtg-card-data.csv"
  }
EOF
)

if [[ "$RESPONSE" -ne 200 ]]; then
  echo "oh no! failed to start load job! response code: $RESPONSE"
  cat response.json
  exit 1
else
  JOB_ID=$(jq -r '.job_id' response.json)
  echo "done! job_id: $JOB_ID"
  echo
fi


# wait for job to complete
#################################################################
echo "waiting for job to complete..."
JOB_STATUS=""
while [[ "$JOB_STATUS" != "COMPLETE" ]]; do
  RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
    -X POST http://localhost:9925 \
    -u harperdb:test \
    -H "Content-Type: application/json" \
    -d @- <<EOF
    {
      "operation": "get_job",
      "id": "$JOB_ID"
    }
EOF
  )

  if [[ "$RESPONSE" -ne 200 ]]; then
    echo "oh no! failed to job status! response code: $RESPONSE"
    cat response.json
    exit 1
  else
    JOB_STATUS=$(jq -r '.[].status' response.json)
    sleep .5
  fi
done

START=$(jq -r '.[].created_datetime' response.json)
END=$(jq -r '.[].end_datetime' response.json)
JOB_DURATION=$(echo "scale=3; ($END - $START)/1000" | bc)
echo "done! job took $JOB_DURATION seconds"
echo

