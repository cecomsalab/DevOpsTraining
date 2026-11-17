# Lab 05 Terraform in depth

Remote state in Azure Storage, a local module, for_each, a dynamic block, a moved block, and a small Linux VM.

```bash
az login
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
cp terraform.tfvars.example terraform.tfvars  # edit the values
ssh-keygen -t ed25519 -f ~/.ssh/lab05_ed25519 -C "<student>-lab05"

# 1. Local state first
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# 2. Move the state to Azure Storage
export RESOURCE_GROUP=rg-<student>-usa STUDENT=<student>
../shared/create-state-storage.sh
cp backend.hcl.example backend.hcl            # edit the values
# remove the comment character from the backend line in versions.tf
terraform init -backend-config=backend.hcl -migrate-state

# 3. Changes: for_each, dynamic block, moved block (see the lab document)
terraform destroy
```

Keep the state storage account: Labs 07 and 09 use it again.

Optional: `bicep/main.bicep` deploys a storage account with Bicep for comparison.
