# Lab 04 Terraform fundamentals

Local state, Azure CLI sign in.

```bash
az login
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
cp terraform.tfvars.example terraform.tfvars   # edit the values
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
terraform destroy
```
