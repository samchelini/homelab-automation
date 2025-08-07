terraform {
  backend "s3" {
    access_key                  = ""
    secret_key                  = ""
    bucket                      = ""
    region                      = ""
    key                         = ""
    use_lockfile                = true
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
    skip_metadata_api_check     = true
    endpoints                   = {}
  }
}
