terraform {
  required_version = "<= 1.5"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.5.0"
    }
    http-full = {
      source = "salrashid123/http-full"
    }
  }
}
