#!/bin/bash
RECORD_SIZE=2048
THROUGHPUT=-1
NUM_OF_RECORDS=10000000
NAME=Run1-10-10M-unlimited-2KB
NS=kafka
PROMETHEUS_URL="http://prometheus-operated-kafka-monitor.apps.cluster-7d4d.7d4d.example.opentlc.com/api/v1/query"
# if [ $# -ne 2 ]
#   then
#     echo "Enter the kafka project to run the test against, and the payload size in bytes, e.g. 1024"
#     exit 1
# fi
for project in p1 p2 p3 p4 p5 p6 p7 p8 p9 p10
do
 oc new-project $project
done
# BATCH_NS=$1
# RECORD_SIZE=$2
sleep 3
for project in p1 p2 p3 p4 p5 p6 p7 p8 p9 p10
do
./run-test.sh $NAME-$project my-cluster-kafka-bootstrap.$NS.svc.cluster.local:9092 topic1 $RECORD_SIZE $NUM_OF_RECORDS $THROUGHPUT $NS $project $PROMETHEUS_URL
sleep 1
done


# for project in p1 p2 p3 p4 p5 p6 p7 p8 p9 p10
# do
#  oc delete project $project
# done
