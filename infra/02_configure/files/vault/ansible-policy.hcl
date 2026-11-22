path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/metadata/*" {
  capabilities = ["read", "list", "delete"]
}
path "sys/auth" {
  capabilities = ["read", "list"]
}
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "auth/oidc/config" {
  capabilities = ["create", "read", "update"]
}
path "auth/oidc/role" {
  capabilities = ["list"]
}
path "auth/oidc/role/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}