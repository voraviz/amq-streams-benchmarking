#!/bin/bash
#if [ $# -eq 0 ]
if [ $# -ne 2 ]
  then
    echo "Enter the kafka project to run test against, and the payload size"
    exit 1
fi
oc new-project p1
oc new-project p2
oc new-project p3
oc new-project p4
BATCH_NS=$1
RECORD_SIZE=$2
sleep 3
./run-test.sh TestCase-50mil-100k-p1 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 $RECORD_SIZE  50000000 100000 $BATCH_NS p1
sleep 1
./run-test.sh TestCase-50mil-100k-p2 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 $RECORD_SIZE 50000000 100000 $BATCH_NS p2
sleep 1
./run-test.sh TestCase-50mil-100k-p3 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 $RECORD_SIZE 50000000 100000 $BATCH_NS p3
sleep 1
./run-test.sh TestCase-50mil-100k-p4 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 $RECORD_SIZE 50000000 100000 $BATCH_NS p4
