resource "ibm_resource_instance" "es" {
  name              = "${local.basename}-es"
  service           = "messagehub"
  plan              = "standard"
  location          = var.region
  resource_group_id = ibm_resource_group.group.id
  tags              = var.tags
}

resource "ibm_event_streams_topic" "webserver" {
  name                 = "webserver"
  partitions           = 1
  resource_instance_id = ibm_resource_instance.es.crn
  config = {
    "retention.ms" = "86400000"
  }
}

resource "ibm_resource_key" "es-for-log-analysis" {
  name                 = "es-for-log-analysis"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.es.crn
  tags                 = var.tags
}
