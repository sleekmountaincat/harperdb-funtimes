#!/usr/bin/env bash

echo "running load tests"

echo "::group::k6 sql-analytics load test"
k6 run --quiet --summary-export=sql-analytics-summary.json --out experimental-prometheus-rw=http://localhost:9090/api/v1/write --tag testid=sql-analytics .ci/scripts/load-tests/load-test-sql-analytics.js
echo "::endgroup::"

echo "::group::k6 search-by-conditions load test"
k6 run --quiet --summary-export=search-by-conditions-summary.json --out experimental-prometheus-rw=http://localhost:9090/api/v1/write --tag testid=search-by-conditions .ci/scripts/load-tests/load-test-nosql-search-by-conditions.js
echo "::endgroup::"

echo "::group::k6 search-by-value-wildcard load test"
k6 run --quiet --summary-export=search-by-value-wildcard-summary.json --out experimental-prometheus-rw=http://localhost:9090/api/v1/write --tag testid=search-by-value-wildcard .ci/scripts/load-tests/load-test-nosql-search-by-value-wildcard.js
echo "::endgroup::"

echo "::group::k6 insert load test"
k6 run --quiet --summary-export=insert-summary.json --out experimental-prometheus-rw=http://localhost:9090/api/v1/write --tag testid=insert .ci/scripts/load-tests/load-test-nosql-insert.js
echo "::endgroup::"






