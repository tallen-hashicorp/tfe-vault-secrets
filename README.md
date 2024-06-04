# tfe-vault-secrets
Injecting Vault KV secret into TFE variable example, using details which can be found [here](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-configuration)

## Prereq
* A Vault HCP Dedicated Cluster
* A TFC Account
* A AWS Account

# Vault Setup

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
vault kv put -mount=secret my-secret name=s3-secretname
```

# TFC

## TFC Workspace Setup
All of the following is in the `configure-tf` folder
``bash
cd configure-tf
```

## GET TFC API Token,
Copy the example tfvars with the following command
```bash
cp terraform.tfvars-example terraform.tfvars
```

Now you need to get an User Token from TFC, to do this go to Account Settings > Tokens > Generate API Token, a new token will be generated copy this and update `tfe_token = "your-tfe-token"` with your token in `terraform.tfvars`

Next update `tfe_organization = "your-tfe-org"` in `terraform.tfvars` with your TFC org. 

Now update `vault_addr = "your-vault-public-addr""` in `terraform.tfvars` with your Vault Public address.

Now you can run the required terraform to setup the new workspace
```bash
terraform init
terraform apply
```

## TFC Running TF With Vault Creds
Now we have setup Vault and the TFC workspace we can use it to create a S3 bucket instance with the name `s3-secretname` as defined ealier with the command `vault kv put -mount=secret my-secret name=s3-secretname`

All of the following is in the `create-ec2` folder
```bash
cd ..
cd create-ec2
```

Next update `organization = "tallen-playground"` on line 3 of `main.tf` with your TFC org.

We now need to login to TFC with the following command, follow the instructions on the popup website
```bash
terraform login
```

Now run the terrafrom
```bash
terraform init 
```