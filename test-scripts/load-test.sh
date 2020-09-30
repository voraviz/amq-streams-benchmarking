#!/bin/bash
echo "Enter name of AMQ Streams's project"
read BATCH_NS

echo "Enter name of Prometheus and Grafana's project"
read MONITOR

echo "Number of records"
read NUM_OF_RECORDS

echo "Number of clients"
read NUMBER_OF_CLIENTS

echo "Message Size in KB"
read SIZE
PROMETHEUS=http://$(oc get route prometheus-operated -n ${MONITOR} -o jsonpath='{.spec.host}')/api/v1/query

#BATCH_NS=${tenant}
THROUGHPUT=1000
# NUMBER_OF_CLIENTS=3
# PROMETHEUS=http://prometheus-operated-kafka-monitor.apps.cluster-f2cc.f2cc.example.opentlc.com/api/v1/query
./batch.sh $BATCH_NS $SIZE $NUM_OF_RECORDS $THROUGHPUT $NUMBER_OF_CLIENTS $PROMETHEUS
