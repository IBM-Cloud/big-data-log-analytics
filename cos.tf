resource "ibm_resource_instance" "cos" {
  name              = "log-analysis-cos"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = ibm_resource_group.group.id
  tags              = var.tags
}

resource "ibm_resource_key" "cos_for_log_analysis" {
  name                 = "cos-for-log-analysis"
  resource_instance_id = ibm_resource_instance.cos.crn
  role                 = "Writer"
  parameters = {
    "HMAC" = true
  }
}

resource "ibm_iam_authorization_policy" "cos_to_kms" {
  source_resource_instance_id = ibm_resource_instance.cos.guid
  source_service_name         = "cloud-object-storage"
  target_service_name         = "kms"
  target_resource_instance_id = ibm_resource_instance.kms.guid
  roles = [
    "Reader"
  ]
}

resource "ibm_cos_bucket" "bucket" {
  bucket_name          = "${local.basename}-bucket"
  resource_instance_id = ibm_resource_instance.cos.crn
  region_location      = var.region
  kms_key_crn          = ibm_kms_key.root.crn
}

resource "ibm_cos_bucket_object" "hello" {
  bucket_crn = ibm_cos_bucket.bucket.crn
  bucket_location = ibm_cos_bucket.bucket.region_location
  key = "hello.py"
  content = <<EOT
def main():
  print("hello world")

if __name__ == '__main__':
  main()
EOT
}

resource "ibm_cos_bucket_object" "solution" {
  bucket_crn = ibm_cos_bucket.bucket.crn
  bucket_location = ibm_cos_bucket.bucket.region_location
  key = "solution.py"
  content = <<EOT
from pyspark.sql import SparkSession
from pyspark.sql import SQLContext
import os
import sys

def main():
  # COS_PARQUET in format: cos://<bucket>.<service>/landing_folder/topic=<topic>/jobid=<jobid>/
  # like cos://ABC-log-analysis.solution/logs-stream-landing/topic=webserver/jobid=48914a16-1d33-4d3e-93e3-7efb855b662e/
  print("solution v1.0")
  if "COS_PARQUET" not in os.environ:
    print("COS_PARQUET must be in environment")
    return 1
  cos_parquet = os.environ["COS_PARQUET"]
  print(f"cos_parquet: {cos_parquet}")

  spark = SparkSession.builder.appName("solution").getOrCreate()
  sc = spark.sparkContext
  sqlContext = SQLContext(sc)

  df = spark.read.parquet(cos_parquet)
  sqlContext.registerDataFrameAsTable(df, "Table")
  df_query = sqlContext.sql("SELECT * FROM Table LIMIT 10")
  df_query.show(10)
  return 0

if __name__ == '__main__':
  sys.exit(main())
EOT
}
