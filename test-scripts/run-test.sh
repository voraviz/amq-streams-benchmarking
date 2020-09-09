#!/bin/bash
echo Running test: $1
export TEST_ID=$1-$(date +%F-%T)
echo $TEST_ID
mkdir $TEST_ID
echo $2 $3 $4 $5 $6 $7  
./run-perf.sh $2 $3 $4 $5 $6 &
export PERF_ID=$!
echo Perf test PID: $PERF_ID
sleep 1
./run-metrics.sh $7 &
exit 0
