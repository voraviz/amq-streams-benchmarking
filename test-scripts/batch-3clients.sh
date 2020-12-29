#!/bin/bash
RECORD_SIZE=2048
THROUGHPUT=100000
NUM_OF_RECORDS=5000000
NAME=Run1-3-50M-100K-$RECORD_SIZE
NS=kafka
PROMETHEUS_URL="http://prometheus-operated-kafka-monitor.apps.cluster-7d4d.7d4d.example.opentlc.com/api/v1/query"
# if [ $# -ne 2 ]
#   then
#     echo "Enter the kafka project to run the test against, and the payload size in bytes, e.g. 1024"
#     exit 1
# fi

oc new-project p1
oc new-project p2
oc new-project p3
#oc new-project p4
# BATCH_NS=$1
# RECORD_SIZE=$2
sleep 3
./run-test.sh $NAME-p1 my-cluster-kafka-bootstrap.$NS.svc.cluster.local:9092 topic1 $RECORD_SIZE $NUM_OF_RECORDS $THROUGHPUT $NS p1 $PROMETHEUS_URL
sleep 1
./run-test.sh $NAME-p2 my-cluster-kafka-bootstrap.$NS.svc.cluster.local:9092 topic1 $RECORD_SIZE $NUM_OF_RECORDS $THROUGHPUT $NS p2 $PROMETHEUS_URL
sleep 1
./run-test.sh $NAME-p3 my-cluster-kafka-bootstrap.$NS.svc.cluster.local:9092 topic1 $RECORD_SIZE $NUM_OF_RECORDS $THROUGHPUT $NS p3 $PROMETHEUS_URL
sleep 1
#./run-test.sh Run1-4-50Mil-100K-$RECORD_SIZE-p4 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 $RECORD_SIZE 50000000 100000 $BATCH_NS p4
