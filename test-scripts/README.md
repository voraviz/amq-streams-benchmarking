## Test scripts

### for producer

#### Pre-req

- Running kafka cluster (asusming it is created with this project's scripts with default naming and labels, if not adjust in run-metrics.sh)
- login to the ocp cluster

```
./run-test.sh <test id> <bootstrap server> <topic> <message size> <num of records> <throughput> <cluster name> <client-namespace>
	
e.g:  

./run-test.sh TestCase1 my-cluster-kafka-bootstrap.kafka-cluster.svc.cluster.local:9092 topic1 1024 10000000 50000 kafka-cluster producer1 

```

- `test id` will be prepended with a timestamp 
- new directory will be created under the `${test id - timestamp}` 
- all the output files will be created there
- needs client workspace to be created , the name to be passed as a param. The producer pod will be deployed there. This is to facilitate running multiple clients

The scripts will produce a few files
- the output of the kafka-producer-perf.sh command, `perf-test.txt`
- a csv file snapshot of CPU and RAM utilization of all 3 kafka pods in 5 seconds intervals - `output.csv`
- individual csv files for the respective kafka brokers , currently supports 3, based on the default naming / labelling used in the create script

