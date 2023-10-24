resource "ibm_resource_instance" "sql_query" {
  name              = "${local.basename}-sql"
  service           = "sql-query"
  plan              = "standard"
  location          = var.region
  resource_group_id = ibm_resource_group.group.id

  parameters = {
    customerKeyEncrypted = true
    kms_instance_id = jsonencode({
      guid = ibm_resource_instance.kms.guid
      url  = ibm_resource_instance.kms.extensions["endpoints.public"]
    })
    kms_rootkey_id = ibm_kms_key.root.key_id
  }

  tags = var.tags
}

resource "ibm_iam_authorization_policy" "sql_query_to_kms" {
  source_resource_instance_id = ibm_resource_instance.sql_query.guid
  source_service_name         = "sql-query"
  target_service_name         = "kms"
  target_resource_instance_id = ibm_resource_instance.kms.guid
  roles = [
    "Reader",
    "ReaderPlus"
  ]
}
