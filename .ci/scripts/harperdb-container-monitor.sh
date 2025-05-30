#!/usr/bin/env bash

while true; do
  METRICS=$(docker stats harperdb --no-stream --format "table {{.CPUPerc}}\t{{.MemPerc}}" 2>/dev/null | tail -n 1)

  CPU=$(echo "$METRICS" | awk '{print $1}' | sed 's/%//')
  MEM=$(echo "$METRICS" | awk '{print $2}' | sed 's/%//')


  PROM_METRICS="docker_container_cpu_percent{container=\"harperdb\"} $CPU
                docker_container_memory_percent{container=\"harperdb\"} $MEM"

  echo "$PROM_METRICS" | curl -s http://localhost:9091/metrics/job/docker_stats --data-binary @-
  echo $PROM_METRICS
  sleep 2
done
