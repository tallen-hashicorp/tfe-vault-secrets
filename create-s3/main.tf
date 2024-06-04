terraform {
  cloud {
    organization = "tallen-playground"

    workspaces {
      name = "vault-secret-example-workspace"
    }
  }
}

provider "vault" {
  // skip_child_token must be explicitly set to true as HCP Terraform manages the token lifecycle
  skip_child_token = true
  address          = var.tfc_vault_dynamic_credentials.default.address
  namespace        = var.tfc_vault_dynamic_credentials.default.namespace
  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.default.token_filename
  }
}
provider "vault" {
  // skip_child_token must be explicitly set to true as HCP Terraform manages the token lifecycle
  skip_child_token = true
  alias            = "ALIAS1"
  address          = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].address
  namespace        = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].namespace
  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].token_filename
  }
}

resource "random_string" "random_string" {
  length  = 4
  special = false
  upper   = false
}

data "vault_kv_secret_v2" "my-secret" {
  mount = "secret"
  name  = "my-secret"
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "${random_string.random_string.result}-${data.vault_kv_secret_v2.my-secret.data["bucket_name"]}"
}
