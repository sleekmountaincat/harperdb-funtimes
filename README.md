# HarperDB Coding Challenge

Welcome! This repo contains a GitHub Actions workflow that spins up [HarperDB](https://www.harpersystems.dev) alongside some supporting containers to facilitate gathering and displaying metrics, then runs a collection of load tests.

The intention is to have a self-contained solution to gather meaningful metrics and display useful visualizations so that we can understand HarperDB under load. 

![Dashboard](https://github.com/sleekmountaincat/harperdb-funtimes/raw/refs/heads/main/example.png)

## Metrics 
Metrics are collected and ingested in a few different ways:
* HarperDB internal analytics, exposed through a Prometheus exporter custom component
* K6 test results, sent directly to Prometheus through remote-write
* Docker container metrics, created in a custom script and sent to Prometheus via pushgateway

## Load Tests
Four load test are run, each with 50 virtual concurrent users over 30 seconds. We simulate:
* inserts
* NoSQL search by conditions
* NoSQL search by value with wildcard
* SQL analytics

## Results 
Included in each run is an artifact containing a screenshot of a Grafana dashboard showing useful metrics during the load tests, as well as the full K6 summary from each of the load tests. In the GitHub Actions run summary, you will see the Grafana dashboard, as well as a high level overview of the K6 tests. 

## Try It
You should be able to fork this repo, then manually execute the GitHub Action. You can also view previous executions in this repo [here](https://github.com/sleekmountaincat/harperdb-funtimes/actions/workflows/harperdb-load-test.yaml).