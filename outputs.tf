output "kcat_config" {
  value = nonsensitive(<<EOT
bootstrap.servers=${ibm_resource_key.es_for_log_analysis.credentials.bootstrap_endpoints}
sasl.mechanism=PLAIN
security.protocol=SASL_SSL
sasl.username=token
sasl.password=${ibm_resource_key.es_for_log_analysis.credentials.password}
EOT
  )
}

output "iae_01_env_variables" {
  value = <<EOT
REGION=${var.region}
RESOURCE_GROUP_NAME=${ibm_resource_group.group.name}
GUID=${ibm_resource_instance.iae.guid}
COS_BUCKET_NAME=${ibm_cos_bucket.bucket.bucket_name}
ENDPOINT=${ibm_cos_bucket.bucket.s3_endpoint_direct}
ACCESS_KEY=${nonsensitive(ibm_resource_key.cos_for_log_analysis.credentials["cos_hmac_keys.access_key_id"])}
SECRET_KEY=${nonsensitive(ibm_resource_key.cos_for_log_analysis.credentials["cos_hmac_keys.secret_access_key"])}
EOT
}

output "iae_02_run_word_count" {
  value = <<EOT
ibmcloud target -r $REGION -g $RESOURCE_GROUP_NAME
ibmcloud ae-v3 spark-app submit --instance-id $GUID --app "/opt/ibm/spark/examples/src/main/python/wordcount.py" --arg '["/opt/ibm/spark/examples/src/main/resources/people.txt"]'
EOT
}

output "iae_03_run_hello_world" {
  value = <<EOT
ibmcloud target -r $REGION -g $RESOURCE_GROUP_NAME
ibmcloud ae-v3 spark-app submit --instance-id $GUID --app "cos://$COS_BUCKET_NAME.hello/hello.py" --conf '{
  "spark.hadoop.fs.cos.hello.endpoint": "https://'$ENDPOINT'",
  "spark.hadoop.fs.cos.hello.access.key": "'$ACCESS_KEY'",
  "spark.hadoop.fs.cos.hello.secret.key": "'$SECRET_KEY'"
}'
EOT
}

output "iae_04_run_solution" {
  value = <<EOT
ibmcloud target -r $REGION -g $RESOURCE_GROUP_NAME
ibmcloud ae-v3 spark-app submit --instance-id $GUID --app "cos://$COS_BUCKET_NAME.solution/solution.py" --conf '{
  "spark.hadoop.fs.cos.solution.endpoint": "https://'$ENDPOINT'",
  "spark.hadoop.fs.cos.solution.access.key": "'$ACCESS_KEY'",
  "spark.hadoop.fs.cos.solution.secret.key": "'$SECRET_KEY'"
}' --env '{
  "COS_PARQUET": "cos://${ibm_cos_bucket.bucket.bucket_name}.solution/logs-stream-landing/topic=webserver/jobid='$JOB_ID'/"
}'
EOT
}
