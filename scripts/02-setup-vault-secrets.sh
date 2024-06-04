#!/bin/bash
vault secrets enable -version=2 -path=secret kv 
vault kv put -mount=secret my-secret bucket_name=s3-secret-bucket-name