# allows all access on "secrets/*"
path "secrets/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list", "recover"]
}
