provider "tfe" {
  hostname = "app.terraform.io"
  token    = var.tfe_token
}

resource "tfe_workspace" "example-workspace" {
  name         = "vault-secret-example-workspace"
  organization = var.tfe_organization
}

resource "tfe_variable" "tfc_vault_provider_auth" {
  key          = "TFC_VAULT_PROVIDER_AUTH"
  value        = "true	"
  category     = "env"
  workspace_id = tfe_workspace.example-workspace.id
}

resource "tfe_variable" "tfc_vault_addr" {
  key          = "TFC_VAULT_ADDR"
  value        = var.vault_addr
  category     = "env"
  workspace_id = tfe_workspace.example-workspace.id
}

resource "tfe_variable" "tfc_vault_run_role" {
  key          = "TFC_VAULT_RUN_ROLE"
  value        = "tfc-role"
  category     = "env"
  workspace_id = tfe_workspace.example-workspace.id
}

resource "tfe_variable" "tfc_vault_namespace" {
  key          = "TFC_VAULT_NAMESPACE"
  value        = "admin"
  category     = "env"
  workspace_id = tfe_workspace.example-workspace.id
}


