resource "ibm_resource_instance" "kms" {
  name              = "${local.basename}-kp"
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.region
  resource_group_id = ibm_resource_group.group.id
  tags              = var.tags
}

resource "ibm_kms_key" "root" {
  instance_id  = ibm_resource_instance.kms.guid
  key_name     = "log-analysis-root-enckey"
  standard_key = false
  force_delete = true
}