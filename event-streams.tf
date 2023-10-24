resource "ibm_resource_instance" "es" {
  name              = "log-analysis-es"
  service           = "messagehub"
  plan              = "standard"
  location          = var.region
  resource_group_id = ibm_resource_group.group.id
  tags              = var.tags
}

resource "ibm_resource_key" "es_for_log_analysis" {
  name                 = "es-for-log-analysis"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.es.crn
  tags                 = var.tags
}

# until https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4878 is solved
# resource "ibm_event_streams_topic" "webserver" {
#   name                 = "webserver"
#   partitions           = 1
#   resource_instance_id = ibm_resource_instance.es.crn
#   config = {
#     "retention.ms" = "86400000"
#   }
# }

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4878
# https://cloud.ibm.com/apidocs/event-streams/adminrest#createtopic
resource "null_resource" "event_streams_webserver_topic" {
  provisioner "local-exec" {
    command = join(" ", [
      "curl -i -X POST",
      "-H 'Accept: application/json'",
      "-H 'Content-Type: application/json'",
      "-H 'Authorization: ${data.ibm_iam_auth_token.tokendata.iam_access_token}'",
      "--data",
      "'{ \"name\": \"webserver\", \"partitions\": 1}'",
      "${ibm_resource_key.es_for_log_analysis.credentials.kafka_admin_url}/admin/topics"
    ])
  }
}
