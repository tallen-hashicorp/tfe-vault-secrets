#!/bin/bash
vault secrets enable -version=2 -path=secret kv 
vault kv put -mount=secret my-secret name=ec2-secretname qty=5