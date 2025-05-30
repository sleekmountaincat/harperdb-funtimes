#!/usr/bin/env bash

# runs the stack locally, configures HarperDB, loads data, and executes load tests

# cleanup old volumes and containers
docker compose -f ./.ci/harperdb-metric-stack-compose.yaml down -v --remove-orphans

# start the stack
docker compose -f ./.ci/harperdb-metric-stack-compose.yaml up -d

# install and configure prometheus exporter
.ci/scripts/wait-for-harperdb-install-prom-exporter.sh

# start custom container monitor
.ci/scripts/harperdb-container-monitor.sh > harperdb_container_metrics.prom &
PID=$!

# load data
.ci/scripts/load-data.sh

# run load tests
.ci/scripts/run-load-tests.sh

# grab screenshot
curl -s -u "admin:admin" "http://localhost:3000/render/d/load-test/dashboard?width=1920&height=1200&from=now-7m&to=now&kiosk" --output dashboard.png

# kill monitor
kill $PID > /dev/null 2>&1

echo
echo
echo
echo "load tests complete!"
echo
echo "you can view a screen shot of the grafana dashboard here: $(pwd)/dashboard.png"
echo "you can also view the dashboard here (admin:admin): "http://localhost:3000/d/load-test/load-test?orgId=1&from=now-12h&to=now&timezone=browser
echo
echo
cat << EOF
Test                | Avg (ms)  | Requests | Rate (req/s) | Failed %
------------------- | --------- | -------- | ------------ | --------
SQL Analytics       | $(printf "%9.2f" $(jq -r '.metrics.http_req_duration.avg' sql-analytics-summary.json)) | $(printf "%8s" $(jq -r '.metrics.http_reqs.count' sql-analytics-summary.json)) | $(printf "%12.2f" $(jq -r '.metrics.http_reqs.rate' sql-analytics-summary.json)) | $(printf "%8.2f" $(jq -r '.metrics.http_req_failed.rate' sql-analytics-summary.json | awk '{printf "%.2f", $1*100}'))
Search Conditions   | $(printf "%9.2f" $(jq -r '.metrics.http_req_duration.avg' search-by-conditions-summary.json)) | $(printf "%8s" $(jq -r '.metrics.http_reqs.count' search-by-conditions-summary.json)) | $(printf "%12.2f" $(jq -r '.metrics.http_reqs.rate' search-by-conditions-summary.json)) | $(printf "%8.2f" $(jq -r '.metrics.http_req_failed.rate' search-by-conditions-summary.json | awk '{printf "%.2f", $1*100}'))
Search Wildcard     | $(printf "%9.2f" $(jq -r '.metrics.http_req_duration.avg' search-by-value-wildcard-summary.json)) | $(printf "%8s" $(jq -r '.metrics.http_reqs.count' search-by-value-wildcard-summary.json)) | $(printf "%12.2f" $(jq -r '.metrics.http_reqs.rate' search-by-value-wildcard-summary.json)) | $(printf "%8.2f" $(jq -r '.metrics.http_req_failed.rate' search-by-value-wildcard-summary.json | awk '{printf "%.2f", $1*100}'))
Insert              | $(printf "%9.2f" $(jq -r '.metrics.http_req_duration.avg' insert-summary.json)) | $(printf "%8s" $(jq -r '.metrics.http_reqs.count' insert-summary.json)) | $(printf "%12.2f" $(jq -r '.metrics.http_reqs.rate' insert-summary.json)) | $(printf "%8.2f" $(jq -r '.metrics.http_req_failed.rate' insert-summary.json | awk '{printf "%.2f", $1*100}'))

EOF

echo "additionally, full K6 results of the load tests are at <test-name>-summary.json in $(pwd)"