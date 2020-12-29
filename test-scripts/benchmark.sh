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

echo "Number of partitions: "
read PARTITIONS

echo "Do you want to test with consumers? (y/n): "
read IS_CONSUMER


KAFKA=$(oc get kafka --no-headers -n $KAFKA_PROJECT|awk '{print $1}'|head -n 1)
CPU=$(oc get kafka $KAFKA -o jsonpath='{.spec.kafka.resources.limits.cpu}' -n $KAFKA_PROJECT)
MEMORY=$(oc get kafka $KAFKA -o jsonpath='{.spec.kafka.resources.limits.memory}' -n $KAFKA_PROJECT)
BOOTSTRAP=$(oc get svc --no-headers -n $KAFKA_PROJECT | grep bootstrap | awk '{print $1}').$KAFKA_PROJECT.svc.cluster.local:9092
PROMETHEUS_URL=http://$(oc get route/prometheus-operated -o jsonpath='{.spec.host}' -n $MONITOR_PROJECT)/api/v1/query
NAME=${CPU}vCPU-$MEMORY-${PARTITIONS}partitions-${NUM_OF_RECORDS}records-unlimited-$(expr $RECORD_SIZE / 1024)KB

echo "********** Parameters for run this benchmark **********"
echo
echo "Kafka: $KAFKA"
echo "Bootstrap: $BOOTSTRAP"
echo "Broker vCPU: $CPU"
echo "Broker Memory: $MEMORY"
echo "Prometheus URL: $PROMETHEUS_URL"
echo "Project Name Prefix: $NAME"
echo
echo
echo "*******************************************************"
echo
echo
echo "Press any key to continue...."
read



echo "********** Create projects for producers/consumers **********"
NUM=1
while [ $NUM -le $PARTITIONS ];
do
    oc new-project p${NUM}
    oc new-project c${NUM}
    NUM=$(expr $NUM + 1)
done

echo
echo  "********** Run producers **********"
NUM=1
while [ $NUM -le $PARTITIONS ];
do
    ./run-test.sh \
    $NAME-p${NUM} \
    $BOOTSTRAP \
    $TOPIC \
    $RECORD_SIZE \
    $NUM_OF_RECORDS \
    $THROUGHPUT \
    $KAFKA_PROJECT p${NUM} $PROMETHEUS_URL  &
    sleep 3
    NUM=$(expr $NUM + 1)
done
if [ "$IS_CONSUMER" = "Y" ] || [ "$IS_CONSUMER" = "y" ];
then
    NUM=1
    while [ $NUM -le $PARTITIONS ];
    do
    ./run-consumer-perf.sh \
    $NAME-c${NUM}-$(date +%F-%T) \
    $BOOTSTRAP \
    $TOPIC \
    $NUM_OF_RECORDS \
    c${NUM} &
    sleep 3
    NUM=$(expr $NUM + 1)
    done
fi