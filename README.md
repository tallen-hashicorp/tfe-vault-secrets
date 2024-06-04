# tfe-vault-secrets

Injecting Vault KV secret into TFE variable example, using details which can be found [here](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-configuration).

## Prerequisites
* A Vault HCP Dedicated Cluster
* A TFC Account
* An AWS Account

# Vault Setup

## Login to Vault
First, set up your environment variables. Change `http://127.0.0.1:8200` to your HCP Vault address. Alternatively, you can copy it by clicking Quick Actions > How to access via > Command-line (CLI) > Copy Use Public URL.
```bash
export VAULT_ADDR="http://127.0.0.1:8200"; export VAULT_NAMESPACE="admin"
```

Next, login to Vault with the following command using your root token. This can be obtained from the Vault dashboard under Quick Actions > New admin token > Copy.
```bash
vault login
```

## Configure Vault
Run the following commands after logging in. Alternatively, run `sh scripts/01-configure-vault.sh`.

First, we need to ensure the [bound claim](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/workload-identity-tokens#custom-claims) for TFC is set up. Run the following command to set the org id in `vault-jwt-auth-role.json`. We will bind to the workspace named `vault-secret-example-workspace`, which we set up later.

```bash
sh scripts/generate-auth-role.sh
```

```bash
vault auth enable jwt

vault write auth/jwt/config \
    oidc_discovery_url="https://app.terraform.io" \
    bound_issuer="https://app.terraform.io"

vault policy write tfc-policy tfc-policy.hcl

vault write auth/jwt/role/tfc-role @vault-jwt-auth-role.json
```

## Setup a secret
This secret will be used by TF later. Use the following to create this, or alternatively run `sh scripts/02-setup-vault-secrets.sh`.
```bash
vault secrets enable -version=2 -path=secret kv 
vault kv put -mount=secret my-secret bucket_name=s3-secret-bucket-name
```

# TFC

## TFC Workspace Setup
All of the following is in the `configure-tf` folder.
```bash
cd configure-tf
```

## GET TFC API Token
Copy the example tfvars with the following command.
```bash
cp terraform.tfvars-example terraform.tfvars
```

Now you need to get a User Token from TFC. To do this, go to Account Settings > Tokens > Generate API Token. A new token will be generated. Copy this and update `tfe_token = "your-tfe-token"` with your token in `terraform.tfvars`.

Next, update `tfe_organization = "your-tfe-org"` in `terraform.tfvars` with your TFC org.

Now update `vault_addr = "your-vault-public-addr"` in `terraform.tfvars` with your Vault Public address.

Now set your AWS Key ID and Secret Access Key by updating the following in `terraform.tfvars` with your AWS credentials.
```text
aws_access_key_id = "your-aws-access-key-id"
aws_secret_access_key = "your-aws-secret-access-key"
```

Now you can run the required terraform to set up the new workspace.
```bash
terraform init
terraform apply
```

## TFC Running TF With Vault Credentials
Now we have set up Vault and the TFC workspace. We can use it to create an S3 bucket instance with the name `s3-secretname` as defined earlier with the command `vault kv put -mount=secret my-secret name=s3-secretname`.

All of the following is in the `create-s3` folder.
```bash
cd ..
cd create-s3
```

Next, update `organization = "tallen-playground"` on line 3 of `main.tf` with your TFC org.

We now need to log in to TFC with the following command and follow the instructions on the popup website.
```bash
terraform login
```

Now run the terraform.
```bash
terraform init 
terraform apply
```

This will now create an S3 bucket which will look something like the following `43qr-s3-secret-bucket-name`. The first 4 characters are random to avoid conflicts; however, `s3-secret-bucket-name` was retrieved from Vault.

If you want to confirm this, you can update the secret in Vault with the command `vault kv put -mount=secret my-secret bucket_name=new-bucket`, then rerun `terraform apply`. This will change the name of the bucket to something like `43qr-new-bucket`. It is worth noting this action will delete the original bucket, so do not use this for actual production resources. This is just a simple example on how to use Vault secrets in Terraform.