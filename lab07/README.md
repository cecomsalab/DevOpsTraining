# Lab 07 Terraform CI/CD with GitHub Actions

| Workflow | Trigger | Result |
|---|---|---|
| terraform-ci.yml | pull request to main | fmt, validate, plan as a PR comment |
| terraform-cd.yml | push to main | saved plan, approval on environment `dev`, apply |
| drift.yml | weekly schedule or manual | issue when the resources differ from the code |
| destroy.yml | manual, type destroy | removes the resources |

Required secrets: AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID.
Required variables: RESOURCE_GROUP, PREFIX, TF_STATE_ACCOUNT.
