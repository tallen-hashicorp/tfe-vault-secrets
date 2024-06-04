# tfe-vault-secrets
Injecting Vault KV secret into TFE variable example, using details which can be found [here](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-configuration)

## Prereq
* A Vault HCP Dedicated Cluster
* A TFC Account

## Login to Vault
First setup your envrioment variables, change http://127.0.0.1:8200 to your HCP Vault address, alternativly you can copy by clicking Quick Actions > How to access via > Command-line (CLI) > Copy Use Public Url
```bash
export VAULT_ADDR="http://127.0.0.1:8200"; export VAULT_NAMESPACE="admin"
```

Next login to vault with the following command using your root token, this can get gained from the vault dashboard under Quick actions > New admin token > Copy
```bash
vault login
```

## Configure Vault
Run the following commands after logging in, alternaitvly run `sh scripts/01-configure-vault.sh`
```bash
vault auth enable jwt

vault write auth/jwt/config \
    oidc_discovery_url="https://app.terraform.io" \
    bound_issuer="https://app.terraform.io"

vault policy write tfc-policy tfc-policy.hcl

vault write auth/jwt/role/tfc-role @vault-jwt-auth-role.json
```

## Setup a secret
This secret will be used by TF later, use the following to create this, altnaitlvy run `sh scripts/02-setup-vault-secrets.sh`
```bash
vault secrets enable -version=2 -path=secret kv 
vault kv put -mount=secret my-secret name=ec2-secretname qty=5
```