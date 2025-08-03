terraform {
  required_version = "~> 1.12.0"
  backend "oci" {
    bucket               = ""
    namespace            = ""
    tenancy_ocid         = ""
    user_ocid            = ""
    fingerprint          = ""
    private_key_path     = ""
    region               = ""
    key                  = ""
    workspace_key_prefix = "envs/"
  }
}
