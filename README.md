# AWS Elasticsearch SaaS Cheat Sheet

### Purpose
- To help folks get started making remote Elasticsearch queries.


###### Kibana Web UI AWS Elastic SaaS 
- Note: requires VPN connection.
- https://mycompanyvpcelasticurl.us-west-2.es.amazonaws.com/_plugin/kibana/app/kibana#/home?_g=()
###### Kibana Dashboards: 
https://mycompanyvpcelastickibanaurl.us-west-2.es.amazonaws.com/_plugin/kibana/app/kibana#/dashboards
#### Kibana Dev Tools Query Tool
https://mycompanyvpcelastickibanaurl.us-west-2.es.amazonaws.com/_plugin/kibana/app/kibana#/dev_tools/console?_g=()

#### Elasticsearch-HQ
If you think you need this tool, then your can run it locally with docker and remote connect to the cloud service:
- Run elasticsearch-hq docker image locally and connect to remote Elasticsearch service
- ref: https://github.com/ElasticHQ/elasticsearch-HQ
```console
docker run -p 5000:5000 elastichq/elasticsearch-hq
```
- Now access HQ in browser: http://localhost:5000

- For configuring remote Elastic SaaS cluster, use the connection string:
- https://mycompanyvpcelasticurl.us-west-2.es.amazonaws.com.us-west-2.es.amazonaws.com:443

#### Now admin the cluster at:
- http://localhost:5000/#!/clusters/076613928512:dev


#### Useful vars and commands, etc.
- ref: https://www.elastic.co/guide/en/elasticsearch/reference/7.5/cat.html

- command-line? recommend using httpie (http)
```console
brew install httpie
```

- Set var for ES cluster SaaS endpoint
```console
export es="https://mycompanyvpcelasticurl.us-west-2.es.amazonaws.com.us-west-2.es.amazonaws.com"
```

```console
http $es/_cat/indices
```


```console
http "$es/_cat/indices?bytes=b&s=store.size:desc&v"
```

```console
http $es/_cat/nodes?h=ip,port,heapPercent,name
```

#### Troubleshooting, notes, etc.
###### My Amazon ES cluster has more nodes than I originally provisioned
ref: https://aws.amazon.com/premiumsupport/knowledge-center/elasticsearch-more-nodes/

In the Monitoring tab of the Amazon Elasticsearch Service (Amazon ES) console, a cluster appears to have twice the number of nodes than were originally provisioned. Why?

###### Resolution
Amazon ES uses blue/green deployments to make most cluster configuration changes. During this process, Amazon ES provisions a new cluster with the specified number of nodes, copying the entire dataset from the existing cluster to the new cluster. When the data migration is complete, Amazon ES terminates the existing cluster, and the number of nodes returns to normal.

i.e. we can see that here:
- https://us-west-2.console.aws.amazon.com/es/home?region=us-west-2#domain:resource=dev;action=dashboard;tab=TAB_INSTANCE_HEALTH_ID


#### Generate and Upload Randomized Test Data
- Note only if needed.  We can and do install the AWS provided initial sample data.
  - The below additional test data would be supplemental if needed for further testing, etc.
- https://github.com/oliver006/elasticsearch-test-data
```console
python es_test_data.py --es_url=https://mycompanyvpcelasticurl.us-west-2.es.amazonaws.com.us-west-2.es.amazonaws.com
```