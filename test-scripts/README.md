## Test scripts

### for producer


```
/run-test.sh &lt; test id  &gt; &lt; bootstrap server  &gt; &lt; topic  &gt; &lt; message size &gt; &lt; num of records  &gt; &lt; throughput  &gt; &lt; cluster name  &gt; 
	
e.g:  

/run-test.sh TestCase1 my-cluster-kafka-bootstrap.kafka-cluster.svc.cluster.local:9092 topic1 1024 10000000 50000 kafka-cluster

```

- `test id` will be prepended with a timestamp 
- new directory will be created under the `${test id - timestamp}` 
- all the output files will be created there

The scripts will produce 2 files
- the output of the kafka-producer-perf.sh command, `perf-test.txt`
- a csv file snapshot of CPU and RAM utilization of all 3 kafka pods in 5 seconds intervals - `output.csv`

