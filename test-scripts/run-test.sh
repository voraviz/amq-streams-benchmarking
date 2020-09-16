#!/bin/bash
if [ $# -ne 9 ]
  then
    echo "Enter the kafka following parameters:"
    echo "- Test_ID: any arbituary string to describe your test"
    echo "- BootStrap server url" 
    echo "- topic name"
    echo "- payload size, in bytes"
    echo "- Number of records"
    echo "- throughput"
    echo "- namespace where kafka is deployed"
    echo "- namespace where test client is to be deployed, please create beforehand"
    echo "- promethius url "
    echo "e.g:"
    echo "./run-test.sh TestCase-50mil-100k-1024-p1 my-cluster-kafka-bootstrap.kafka-cluster.svc.cluster.local:9092 topic1 1024 50000000 100000 kafka-cluster p1 http://prometheus-operated-kafka-cluster-1.apps.cluster-83a6.83a6.example.opentlc.com/api/v1/query"
    exit 1
fi

echo Running test: $1
export TEST_ID=$1-$(date +%F-%T)
echo $TEST_ID
mkdir $TEST_ID
echo $2 $3 $4 $5 $6 $7 $8 
./run-perf.sh $2 $3 $4 $5 $6 $8 &
export PERF_ID=$!
echo Perf test PID: $PERF_ID
sleep 1
./run-metrics.sh $7 $9 &
exit 0
