#!/bin/bash

# Original JSON string
json_data='{
    "policies": ["tfc-policy"],
    "bound_audiences": ["vault.workload.identity"],
    "bound_claims_type": "glob",
    "bound_claims": {
      "sub": "organization:my-org-name:project:*:workspace:vault-secret-example-workspace:run_phase:*"
    },
    "user_claim": "terraform_full_workspace",
    "role_type": "jwt",
    "token_ttl": "20m"
}'

# Prompt the user for the organization name
read -p "Please enter your organization name: " org_name

# Update the 'my-org-name' value in the JSON
updated_json_data=$(echo "$json_data" | sed "s/my-org-name/$org_name/")

# Output the updated JSON data to a file
output_file="vault-jwt-auth-role.json"
echo "$updated_json_data" > "$output_file"

# Inform the user
echo "Updated JSON data has been written to $output_file"
