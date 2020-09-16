#!/bin/bash
NAMESPACE=$1
PROM_URL=$2
PROCESS_STATE=$(check-process.sh $PERF_ID )
echo 'POD,CPU(Mi),MEMORY(Mi),JVM(Mi),TIMESTAMP' > ./$TEST_ID/output.csv
echo 'POD,CPU(Mi),MEMORY(Mi),JVM(MI),TIMESTAMP' > ./$TEST_ID/kafka-0-output.csv
echo 'POD,CPU(Mi),MEMORY(Mi),JVM(MI),TIMESTAMP' > ./$TEST_ID/kafka-1-output.csv
echo 'POD,CPU(Mi),MEMORY(Mi),JVM(MI),TIMESTAMP' > ./$TEST_ID/kafka-2-output.csv
linecpu=0
totalcpu=0
linemem=0
totalmem=0
counter=1
avgCounter=1
startAvg=15 # start taking average after about 2 minutes after starting test to allow system to ramp up
echo in metrics: $PROCESS_STATE
while
  [[ "${PROCESS_STATE}" !=  "STOPPED" ]]
do
  echo Taking snapshot of resource utilization - $counter to $TEST_ID/output.csv
  # oc adm top pods -n $NAMESPACE -l 'statefulset.kubernetes.io/pod-name in (my-cluster-kafka-0, my-cluster-kafka-1, my-cluster-kafka-2)' | sed 1d |awk -F' ' '{print $0, "F11\t"}' | awk -F ' ' -v timestamp=$(date +%F:%T)  '{print $0 timestamp}' | awk -F' ' 'BEGIN{OFS=",";} {gsub(/[Mi]/,""); print $1,$2,$3,$4,$5;}' | awk '{gsub(/m,/,","); print }' >> ./$TEST_ID/output.csv 
  #http://prometheus-operated-kafka-cluster-1.apps.cluster-83a6.83a6.example.opentlc.com/api/v1/query
  JVM=$(curl -s  $PROM_URL?query="sum(jvm_memory_bytes_used\{namespace='$NAMESPACE',kubernetes_pod_name=~'my-cluster-kafka-0',strimzi_io_name='my-cluster-kafka'\})" | jq -r ".data.result"[].value |  jq -r '.[]' | sed 1d)  
  oc adm top pods -n $NAMESPACE -l 'statefulset.kubernetes.io/pod-name in (my-cluster-kafka-0)' | sed 1d |awk -F' ' -v jvm=$JVM '{print $0, jvm"\t" }' | awk -F ' ' -v timestamp=$(date +%F:%T)  '{print $0 timestamp}' | awk -F' ' 'BEGIN{OFS=",";} {gsub(/[Mi]/,""); print $1,$2,$3,$4,$5;}' | awk '{gsub(/m,/,","); print }' >> ./$TEST_ID/output.csv 
  JVM=$(curl -s  $PROM_URL?query="sum(jvm_memory_bytes_used\{namespace='$NAMESPACE',kubernetes_pod_name=~'my-cluster-kafka-1',strimzi_io_name='my-cluster-kafka'\})" | jq -r ".data.result"[].value |  jq -r '.[]' | sed 1d)  
  oc adm top pods -n $NAMESPACE -l 'statefulset.kubernetes.io/pod-name in (my-cluster-kafka-1)' | sed 1d |awk -F' '  -v jvm=$JVM  '{print $0, jvm"\t" }' | awk -F ' ' -v timestamp=$(date +%F:%T)  '{print $0 timestamp}' | awk -F' ' 'BEGIN{OFS=",";} {gsub(/[Mi]/,""); print $1,$2,$3,$4,$5;}' | awk '{gsub(/m,/,","); print }' >> ./$TEST_ID/output.csv 
  JVM=$(curl -s  $PROM_URL?query="sum(jvm_memory_bytes_used\{namespace='$NAMESPACE',kubernetes_pod_name=~'my-cluster-kafka-2',strimzi_io_name='my-cluster-kafka'\})" | jq -r ".data.result"[].value |  jq -r '.[]' | sed 1d)  
  oc adm top pods -n $NAMESPACE -l 'statefulset.kubernetes.io/pod-name in (my-cluster-kafka-2)' | sed 1d |awk -F' '  -v jvm=$JVM '{print $0, jvm"\t" }' | awk -F ' ' -v timestamp=$(date +%F:%T)  '{print $0 timestamp}' | awk -F' ' 'BEGIN{OFS=",";} {gsub(/[Mi]/,""); print $1,$2,$3,$4,$5;}' | awk '{gsub(/m,/,","); print }' >> ./$TEST_ID/output.csv 
  if 
    [ $counter -gt $startAvg ]
  then 
    linecpu=$(awk -F ',' -v LN=$(( counter+1)) 'NR==LN {print $2}' ./$TEST_ID/output.csv)
    linemem=$(awk -F ',' -v LN=$(( counter+1)) 'NR==LN {print $3}' ./$TEST_ID/output.csv)
    totalcpu=$(( totalcpu + linecpu))
    totalmem=$(( totalmem + linemem))
    echo 'accumulative: '$counter' >  cpu:'$totalcpu 'mem:'$totalmem
    ((avgCounter++))
  fi
  sleep 10
  PROCESS_STATE=$(check-process.sh $PERF_ID )
  echo METRICS:  -$PROCESS_STATE-
  (( counter++))
done
sed -n '/kafka-0/p' ./$TEST_ID/output.csv >> ./$TEST_ID/kafka-0-output.csv
sed -n '/kafka-1/p' ./$TEST_ID/output.csv >> ./$TEST_ID/kafka-1-output.csv
sed -n '/kafka-2/p' ./$TEST_ID/output.csv >> ./$TEST_ID/kafka-2-output.csv
echo 'AVG_CPU(Mi),AVG_MEM(Mi)'  >  ./$TEST_ID/cluster-average.csv
echo 'Avg cluster resource, CPU: ' $((totalcpu / avgCounter))' Mi, MEM: '$((totalmem / avgCounter)) 'Mi'
echo $((totalcpu / avgCounter))','$((totalmem / avgCounter)) >>  ./$TEST_ID/cluster-average.csv

echo done metrics at $(date +%F-%T) 
exit 0
#| awk -F' ' 'BEGIN{OFS=",";} {gsub(/[Mi]/,""); print $1,$2,$3,$4,$5;}' | awk '{gsub(/m,/,","); print }'