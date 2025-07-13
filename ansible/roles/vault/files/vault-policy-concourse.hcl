# allows read access on "secrets/data/ops/concourse/*"
path "secrets/data/ops/concourse/*" {
  capabilities = ["read"]
}
