#!/bin/bash

BOOTSTRAP=$1
TOPIC=$2
RECORD_SIZE=$3
NUM_RECORDS=$4
THROUGHPUT=$5
PERF_NS=$6
echo $PERF_NS
# remove the -t
oc run kafka-producer-perf -n $PERF_NS \
-i --image=registry.redhat.io/amq7/amq-streams-kafka-25-rhel7:1.5.0 \
--rm=true --restart=Never \
-- bin/kafka-producer-perf-test.sh --num-records $NUM_RECORDS \
--throughput $THROUGHPUT --producer-props bootstrap.servers=$BOOTSTRAP  \
key.serializer=org.apache.kafka.common.serialization.StringSerializer value.serializer=org.apache.kafka.common.serialization.StringSerializer  --print-metrics --topic $TOPIC --record-size $RECORD_SIZE --print-metrics > ./$TEST_ID/perf-test.txt
exit 0
