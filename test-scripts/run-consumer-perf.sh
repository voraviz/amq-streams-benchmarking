#!/bin/bash
NAME=$1
BOOTSTRAP=$2
TOPIC=$3
NUM_RECORDS=$4
PERF_NS=$5
mkdir ${NAME}
oc run kafka-consumer-perf -n $PERF_NS \
-i --image=registry.redhat.io/amq7/amq-streams-kafka-25-rhel7:1.5.0 \
--rm=true --restart=Never \
-- bin/kafka-consumer-perf-test.sh \
--messages $NUM_RECORDS \
--bootstrap-server $BOOTSTRAP \
--topic $TOPIC \
--threads 1 \
--print-metrics \
--timeout 1000000000 \
--group group1 --show-detailed-stats > ./${NAME}/output.csv
exit 0
