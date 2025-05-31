# HarperDB Coding Challenge

Welcome! This repo contains a GitHub Actions workflow that spins up [HarperDB](https://www.harpersystems.dev) alongside some supporting containers to facilitate gathering and displaying metrics, then runs a suite of load tests.

The intention is to have a self-contained solution to gather meaningful metrics and display useful visualizations so that we can understand HarperDB under load. 

![Dashboard](https://github.com/sleekmountaincat/harperdb-funtimes/raw/refs/heads/main/example.png)

## Metrics 
Metrics are collected and ingested in a few different ways:
* HarperDB internal analytics, exposed through a Prometheus exporter custom component
* K6 test results, sent directly to Prometheus through remote-write
* Docker container metrics, created in a custom script and sent to Prometheus via pushgateway

## Load Tests
First, we seed the database with about 105K records (all Magic: The Gathering cards). Then, four load test are run, each with 50 virtual concurrent users over 30 seconds. We simulate:
* Inserts
* NoSQL search by conditions
* NoSQL search by value with wildcard
* SQL analytics

## Results 
Included in each run is an artifact containing a screenshot of a Grafana dashboard visualizing collected metrics during the load tests, as well as the full K6 summary from each of the load tests. In the GitHub Actions run summary, you will see the Grafana dashboard, as well as a high level overview of the K6 tests. 

## Try It
### In GitHub Actions
You should be able to fork this repo, then manually execute the GitHub Action. You can also view previous executions in this repo [here](https://github.com/sleekmountaincat/harperdb-funtimes/actions/workflows/harperdb-load-test.yaml).

### Locally
You can run the load test locally via the `run.sh` script at the root of the repo. The only prerequisites are Docker and K6 (`brew install k6`).

This script will:
1. Remove previous containers and volumes from previous executions, if they exist
2. Start the stack: `docker compose -f ./.ci/harperdb-metric-stack-compose.yaml up -d`
3. Install HarperDB Prometheus exporter: `.ci/scripts/wait-for-harperdb-install-prom-exporter.sh`
4. Start the custom container monitor (remember to kill this afterward): `.ci/scripts/harperdb-container-monitor.sh &` 
5. Load the test data: `.ci/scripts/load-data.sh`
6. Run the load tests: `.ci/scripts/run-load-tests.sh`
7. Display summary of the K6 load test results, and provide links to view the grafana dashboard

## Troubleshooting
If you see no data in the Grafana dashboard for HarperDB metrics, this may be due to an issue with the self-signed cert on the RESTful API. To verify, look at the [Prometheus targets](http://localhost:9090/targets). If you see the following for the HarperDB exporter target, you will need to start over.

`Error scraping target: Get "https://harperdb:9926/prometheus_exporter/metrics": tls: failed to parse certificate from server: x509: negative serial number`

This happens because occasionally, when HarperDB spins up, the self-signed cert it generates will have a negative serial number.  Certificates with negative serial numbers are a spec violation, and Prometheus cannot ignore that error. 

I tried disabling HTTPS on the RESTful API to avoid this issue, but was not quite able to get it to work. 
From the config:
```
http:
  port: 9926         
  https: false       
  securePort: null  
```
I tried setting environment variable to disable with `HTTP_HTTPS=false`, but 9926 was still using SSL
