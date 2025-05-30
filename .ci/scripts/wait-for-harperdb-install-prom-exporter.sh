#!/usr/bin/env bash

# wait for harper to come up, then install prometheus exporter custom component

# make sure to include timeout in any CI steps that use
# this script in case harperdb has issues starting


# fail on all errors
set -euo pipefail

# wait for harperdb
#################################################################
echo "waiting for harperdb operations api..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9925)" != "200" ]]; do
  sleep .5;
done
echo "done!"
echo

echo "waiting for harperdb RESTful api..."
until nc -zv localhost 9926 > /dev/null 2>&1;
  do sleep .5;
done
echo "done!"
echo

# install prometheus exporter
# (see https://docs.harperdb.io/docs/developers/operations-api/components#deploy-component)
#################################################################
echo "installing prometheus exporter and restarting harperdb..."
RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
  -X POST http://localhost:9925 \
  -u harperdb:test \
  -H "Content-Type: application/json" \
  -d @- <<EOF
  {
    "operation": "deploy_component",
    "project": "prometheus-exporter",
    "package": "sleekmountaincat/prometheus-exporter",
    "restart": true
  }
EOF
)

if [[ "$RESPONSE" -ne 200 ]]; then
  echo "oh no! failed to install prometheus exporter! response code: $RESPONSE"
  cat response.json
  exit 1
else
  echo "done!"
  echo
fi

# wait for harperdb again
#################################################################
echo "waiting for harperdb operations api..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9925)" != "200" ]]; do
  sleep .5;
done
echo "done!"
echo

echo "waiting for harperdb RESTful api..."
while [[ "$(curl -k -s -o /dev/null -w ''%{http_code}'' -u harperdb:test https://localhost:9926/prometheus_exporter/PrometheusExporterSettings/forceAuthorization)" != "200" ]]; do
  sleep .5;
done
echo "done!"
echo

# configure prometheus exporter
#################################################################
echo "configuring prometheus exporter..."
sleep 5
RESPONSE=$(curl -s -k -o response.json -w "%{http_code}" \
  -X PUT https://localhost:9926/prometheus_exporter/PrometheusExporterSettings/forceAuthorization \
  -u harperdb:test \
  -H "Content-Type: application/json" \
  -d @- <<EOF
    {
      "value": "false"
    }
EOF
)

if [[ "$RESPONSE" -ne 204 ]]; then
  echo "oh no! failed to configure prometheus exporter! response code: $RESPONSE"
  cat response.json
  exit 1
else
  echo "done!"
  echo
fi