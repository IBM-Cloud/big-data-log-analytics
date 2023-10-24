resource "ibm_resource_instance" "iae" {
  name              = "${local.basename}-iae"
  service           = "ibmanalyticsengine"
  plan              = "standard-serverless-spark"
  location          = var.region
  resource_group_id = ibm_resource_group.group.id

  parameters_json = jsonencode({
    default_runtime = {
      spark_version       = "3.4"
      additional_packages = []
    },
    instance_home = {
      guid            = ibm_resource_instance.cos.guid,
      provider        = "ibm",
      type            = "objectstore",
      region          = ibm_cos_bucket.bucket.region_location,
      endpoint        = ibm_cos_bucket.bucket.s3_endpoint_direct,
      hmac_access_key = ibm_resource_key.cos_for_log_analysis.credentials["cos_hmac_keys.access_key_id"],
      hmac_secret_key = ibm_resource_key.cos_for_log_analysis.credentials["cos_hmac_keys.secret_access_key"]
    }
  })

  tags = var.tags
}

data "ibm_iam_auth_token" "tokendata" {
}

# https://cloud.ibm.com/apidocs/ibm-analytics-engine/ibm-analytics-engine-v3#replace-log-forwarding-config
data "http" "iae_to_platform_logs" {
  provider = http-full

  url    = "https://api.${var.region}.ae.cloud.ibm.com/v3/analytics_engines/${ibm_resource_instance.iae.guid}/log_forwarding_config"
  method = "PUT"
  request_headers = {
    content-type  = "application/json"
    Authorization = data.ibm_iam_auth_token.tokendata.iam_access_token
  }
  request_body = jsonencode({
    enabled = true
  })
}
