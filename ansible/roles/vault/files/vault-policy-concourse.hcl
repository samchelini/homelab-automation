# allows read access on "secrets/ops/concourse/*"
path "secrets/ops/concourse/*" {
  capabilities = ["read"]
}
