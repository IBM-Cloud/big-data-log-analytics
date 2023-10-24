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