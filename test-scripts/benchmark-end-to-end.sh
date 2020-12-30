#!/bin/bash
IMAGE=registry.redhat.io/amq7/amq-streams-kafka-25-rhel7:1.5.0
THROUGHPUT=-1
WAIT=60
TOPIC=topic1
echo

echo "Enter AMQ Streams project: "
read KAFKA_PROJECT
echo

echo "Enter AMQ Streams Monitoring project: "
read MONITOR_PROJECT
echo

echo "Enter message size (bytes): "
read RECORD_SIZE
echo

echo "Number of records: "
read NUM_OF_RECORDS
echo

# echo "Number of transaction/sec (Throughput): "
# read THROUGHPUT
# echo 

echo "Number of topics: "
read TOPICS

KAFKA=$(oc get kafka --no-headers -n $KAFKA_PROJECT|awk '{print $1}'|head -n 1)
CPU=$(oc get kafka $KAFKA -o jsonpath='{.spec.kafka.resources.limits.cpu}' -n $KAFKA_PROJECT)
MEMORY=$(oc get kafka $KAFKA -o jsonpath='{.spec.kafka.resources.limits.memory}' -n $KAFKA_PROJECT)
BOOTSTRAP=$(oc get svc --no-headers -n $KAFKA_PROJECT | grep bootstrap | awk '{print $1}').$KAFKA_PROJECT.svc.cluster.local:9092
PROMETHEUS_URL=http://$(oc get route/prometheus-operated -o jsonpath='{.spec.host}' -n $MONITOR_PROJECT)/api/v1/query
NAME=${CPU}vCPU-$MEMORY-${TOPICS}topics-${NUM_OF_RECORDS}records-$(expr $RECORD_SIZE / 1024)KB

echo "********** Parameters for run this benchmark **********"
echo
echo "Kafka: $KAFKA"
echo "Bootstrap: $BOOTSTRAP"
echo "Broker vCPU: $CPU"
echo "Broker Memory: $MEMORY"
echo "Prometheus URL: $PROMETHEUS_URL"
echo "Project Name Prefix: $NAME"
# echo "Topics: $TOPICS"
echo
echo "*******************************************************"
echo
echo
echo "Press any key to continue...."
read
echo  "********** Run End-to-End **********"
# oc new-project p1
# oc delete pods --all -n p1
# sleep 3
# NUM=1
# ./run-test-end-to-end.sh \
#     $NAME-p1 \
#     $BOOTSTRAP \
#     $TOPIC \
#     $RECORD_SIZE \
#     $NUM_OF_RECORDS \
#     $THROUGHPUT \
#     $KAFKA_PROJECT p1 $PROMETHEUS_URL &

echo "********** Creating projects **********"
NUM=1
while [ $NUM -le $TOPICS ];
do
    oc new-project p${NUM}
    NUM=$(expr $NUM + 1)
done
echo  "********** Run End-to-End test **********"



echo

NUM=1
while [ $NUM -le $TOPICS ];
do
    ./run-test-end-to-end.sh \
    $NAME-p${NUM} \
    $BOOTSTRAP \
    topic${NUM} \
    $RECORD_SIZE \
    $NUM_OF_RECORDS \
    $THROUGHPUT \
    $KAFKA_PROJECT p${NUM} $PROMETHEUS_URL   &
    sleep 3
    NUM=$(expr $NUM + 1)
done

