#!/bin/bash
vault auth enable jwt

vault write auth/jwt/config \
    oidc_discovery_url="https://app.terraform.io" \
    bound_issuer="https://app.terraform.io"

vault policy write tfc-policy tfc-policy.hcl

vault write auth/jwt/role/tfc-role @vault-jwt-auth-role.json