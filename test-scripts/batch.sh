#!/bin/bash
KAFKA_CLUSTER=my-cluster
TOPIC=topic1
PREFIX=TestCase
BATCH_NS=$1
SIZE=$2
NUM_OF_RECORDS=$3
THROUGHPUT=$4
NUM_OF_CLIENTS=$5
PROMETHEUS_URL=$6
#PROMETHEUS_URL="http://prometheus-operated-kafka-monitor.apps.cluster-f2cc.f2cc.example.opentlc.com/api/v1/query"
PROJECT_LIST="p1 p2 p3"
CURRENT=0
while [ ${CURRENT} -lt ${NUM_OF_CLIENTS} ];
do
    oc new-project p${CURRENT}
    CURRENT=$(expr $CURRENT + 1)
done

CURRENT=0
while [ ${CURRENT} -lt ${NUM_OF_CLIENTS} ];
do
    project=p${CURRENT}
    echo "Run load test from $project"
     ./run-test.sh \
     ${PREFIX}-${NUM_OF_RECORDS}-${THROUGHPUT}-${project} \
     ${KAFKA_CLUSTER}-kafka-bootstrap.${BATCH_NS}.svc.cluster.local:9092 \
     ${TOPIC} ${SIZE} ${NUM_OF_RECORDS} ${THROUGHPUT} ${BATCH_NS} ${project} \
     ${PROMETHEUS_URL}
    CURRENT=$(expr $CURRENT + 1)
    sleep 1
done
# sleep 3
# ./run-test.sh TestCase-50mil-100k-p1 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 1024 50000000 100000 $BATCH_NS p1
# sleep 1
# ./run-test.sh TestCase-50mil-100k-p2 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 1024 50000000 100000 $BATCH_NS p2
# sleep 1
# ./run-test.sh TestCase-50mil-100k-p3 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 1024 50000000 100000 $BATCH_NS p3
#sleep 1
#./run-test.sh TestCase-50mil-100k-p4 my-cluster-kafka-bootstrap.$BATCH_NS.svc.cluster.local:9092 topic1 1024 50000000 100000 $BATCH_NS p4
