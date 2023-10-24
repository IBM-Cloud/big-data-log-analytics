variable "region" {
  type        = string
  default     = "us-south"
  description = "The region where to deploy the resources. One of us-south or eu-de."

  validation {
    condition     = contains(["us-south", "eu-de"], var.region)
    error_message = "Valid values are (us-south, eu-de)"
  }
}

variable "tags" {
  type    = list(string)
  default = ["terraform", "big-data-log-analytics"]
}

provider "ibm" {
  region = var.region
}

variable "prefix" {
  type        = string
  default     = ""
  description = "A prefix for all resources to be created. If none provided a random prefix will be created"
}

resource "random_string" "random" {
  count = var.prefix == "" ? 1 : 0

  length  = 6
  special = false
}

locals {
  basename = lower(var.prefix == "" ? "bdla-${random_string.random.0.result}" : var.prefix)
}

resource "ibm_resource_group" "group" {
  name = "${local.basename}-group"
  tags = var.tags
}
