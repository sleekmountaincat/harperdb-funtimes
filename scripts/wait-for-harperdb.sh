#!/usr/bin/env bash

echo "waiting for harperdb operations api..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9925)" != "200" ]]; do
  sleep .5;
done
echo "done!"
echo

echo "waiting for harperdb application api..."
until nc -zv localhost 9926 > /dev/null 2>&1;
  do sleep .5;
done
echo "done!"
echo