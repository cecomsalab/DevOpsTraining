# Lab 04 - Terraform Fundamentals

**Estimated timing:** 70 minutes

## Prerequisites

- Completion of **Lab 03 - Azure Fundamentals for DevOps**: the Azure CLI is installed and the course user account can sign in.
- The lab values: the student name, the subscription ID (`<subscription-id>`), and the resource group **rg-\<student\>-usa**.
- Visual Studio Code and one of the following terminals:
  - **Bash**: **Terminal** on macOS, a Linux shell, or **Git Bash** on Windows.
  - **PowerShell**: **Windows PowerShell 5.1** or **PowerShell 7** on Windows.
- The lab files folder **labfiles/lab04**.

## Objectives

This lab covers the following objectives:

- Install Terraform and the Visual Studio Code extension
- Authenticate Terraform to Azure with the Azure CLI
- Read a configuration with providers, variables, locals, a data source, resources, and outputs
- Run the init, fmt, validate, plan, apply, and destroy workflow
- Read update-in-place and replace actions in a plan
- Use variable validation and variable precedence

The configuration reads the assigned resource group with a data source and creates a virtual network with two subnets and a storage account. These are the same resources that Lab 03 created with the Azure CLI.

## Choose your shell

The **terraform** and **az** commands are the same in every shell. Environment variables and a few file commands are different. When the commands differ, each step shows a **Bash** block and a **PowerShell** block. Run only the block for your shell, and use the same shell for the whole lab.

| Action | Bash (macOS, Linux, Git Bash) | PowerShell (Windows) |
|---|---|---|
| Set an environment variable | `export NAME="value"` | `$env:NAME = "value"` |
| Read an environment variable | `echo "$NAME"` | `$env:NAME` |
| Remove an environment variable | `unset NAME` | `Remove-Item Env:NAME` |
| Copy a file | `cp source target` | `Copy-Item source target` |
| List all files, including hidden ones | `ls -a` | `Get-ChildItem -Force` |
| Delete files | `rm -f file1 file2` | `Remove-Item file1, file2` |

> [!IMPORTANT]
> Environment variables exist only in the current terminal. If the terminal is closed, set them again before continuing.

## Exercise 1: Prepare the tools

The exercise consists of the following tasks:

- Task 1: Install Terraform
- Task 2: Install the Visual Studio Code extension
- Task 3: Sign in to Azure for Terraform

### Task 1: Install Terraform

1. Open a terminal and check whether Terraform is installed:

    ```bash
    terraform version
    ```

2. If the command is not found or the version is older than 1.9, install Terraform with the command for the operating system and open a new terminal:

    **Windows (PowerShell)**

    ```powershell
    winget install --exact --id HashiCorp.Terraform
    ```

    **macOS (Bash)**

    ```bash
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    ```

    **Ubuntu or Debian (Bash)**: add the HashiCorp apt repository, then run:

    ```bash
    sudo apt update && sudo apt install terraform
    ```

3. Run **terraform version** again and verify that the version is **1.17** or later.

    > [!NOTE]
    > The Linux repository steps are described at https://developer.hashicorp.com/terraform/install. Terraform is a single binary, so any installation method gives the same tool. If **winget** fails on Windows, download the Windows zip file from the same page, extract **terraform.exe** to a folder, and add that folder to the **PATH**.

### Task 2: Install the Visual Studio Code extension

1. Start Visual Studio Code, open the **Extensions** view (**Ctrl+Shift+X** on Windows, or **Shift+Command+X** on macOS), search for **HashiCorp Terraform**, and select **Install** on the extension published by **HashiCorp**.

2. Select **File** > **Open Folder** and open the **labfiles/lab04** folder.

3. Open **main.tf** and note the syntax highlighting. Hover over **azurerm_virtual_network** to display the documentation of the resource.

### Task 3: Sign in to Azure for Terraform

1. In Visual Studio Code, select **Terminal** > **New Terminal**. On Windows, select **PowerShell** or **Git Bash** as the terminal profile from the drop-down list next to the **+** icon. On macOS, the default **zsh** or **bash** terminal works with the Bash commands.

2. Sign in with the course user account and select the course subscription. These commands are the same in both shells:

    ```bash
    az login
    az account set --subscription "<subscription-id>"
    ```

3. Set the subscription ID for the azurerm provider. Versions 4 and later of the provider require it:

    **Bash**

    ```bash
    export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    echo "$ARM_SUBSCRIPTION_ID"
    ```

    **PowerShell**

    ```powershell
    $env:ARM_SUBSCRIPTION_ID = az account show --query id -o tsv
    $env:ARM_SUBSCRIPTION_ID
    ```

    > [!NOTE]
    > Terraform reads **ARM_SUBSCRIPTION_ID** from the environment, so it must be an environment variable: **export** in Bash, **$env:** in PowerShell. A regular PowerShell variable such as **$ARM_SUBSCRIPTION_ID** is not visible to Terraform. Set the variable again in every new terminal.

## Exercise 2: Review the configuration

The exercise consists of the following tasks:

- Task 1: Review the terraform and provider blocks
- Task 2: Review the variables and the values file
- Task 3: Review the data source, the locals, and the resources
- Task 4: Review the outputs

### Task 1: Review the terraform and provider blocks

1. Open **versions.tf** and review the following settings:

    - **required_version = ">= 1.9.0"**: older Terraform versions refuse to run the code.
    - **azurerm** with **version = "~> 5.0"**: any 5.x version of the Azure provider, never 6.0.
    - **random** with **version = "~> 3.6"**: the provider that generates the storage account suffix.
    - **provider "azurerm" { features {} }**: the required, empty features block. The subscription comes from **ARM_SUBSCRIPTION_ID**.

### Task 2: Review the variables and the values file

1. Open **variables.tf** and note the four variables. **resource_group_name** and **prefix** have no default, so values are required. **address_space** and **tags** have defaults.

2. Review the **validation** block of **prefix**. It accepts only 3 to 10 lowercase letters or numbers, which keeps the storage account name valid.

3. In the terminal, create the values file from the example:

    **Bash**

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

    **PowerShell**

    ```powershell
    Copy-Item terraform.tfvars.example terraform.tfvars
    ```

4. Open **terraform.tfvars** and replace the placeholders with the lab values, for example:

    ```hcl
    resource_group_name = "rg-student01-usa"
    prefix              = "student01"
    ```

    > [!NOTE]
    > Terraform loads **terraform.tfvars** automatically. The file is listed in **.gitignore**, because values files often contain environment-specific or secret values.

### Task 3: Review the data source, the locals, and the resources

1. Open **main.tf** and review the blocks from top to bottom:

    - **data "azurerm_resource_group" "lab"** reads the existing resource group. Terraform never changes or deletes it.
    - **resource "random_string" "suffix"** generates five random lowercase characters.
    - **locals** defines the name prefix, the location taken from the resource group, and the tags.
    - **azurerm_virtual_network.main** references **data.azurerm_resource_group.lab.name**, which creates an implicit dependency.
    - **azurerm_subnet.web** and **azurerm_subnet.data** reference **azurerm_virtual_network.main.name**, so they are created after the virtual network.
    - **azurerm_storage_account.main** builds its name from the prefix and the random suffix.

2. Answer the following question before continuing: in which order does Terraform create the resources?

    <details>
    <summary>Show the answer</summary>

    The random string and the virtual network in parallel, then the two subnets in parallel; the storage account after the random string.

    </details>

### Task 4: Review the outputs

1. Open **outputs.tf** and note the four outputs: **vnet_id**, **subnet_ids** (a map), **storage_account_name**, and **primary_blob_endpoint**.

## Exercise 3: Run the Terraform workflow

The exercise consists of the following tasks:

- Task 1: Initialize the working folder
- Task 2: Format and validate the code
- Task 3: Create and review a plan
- Task 4: Apply the plan and inspect the state

### Task 1: Initialize the working folder

1. In the terminal, in the **labfiles/lab04** folder, run:

    ```bash
    terraform init
    ```

2. Note the providers that Terraform installs and the message about the lock file.

3. List the new files and folders:

    **Bash**

    ```bash
    ls -a
    ls .terraform/providers/registry.terraform.io/hashicorp
    ```

    **PowerShell**

    ```powershell
    Get-ChildItem -Force
    Get-ChildItem .terraform/providers/registry.terraform.io/hashicorp
    ```

4. Open **.terraform.lock.hcl** and note the exact versions and checksums of **azurerm** and **random**. In a team, this file is committed so that everyone uses the same provider versions.

### Task 2: Format and validate the code

1. In **main.tf**, add several spaces before an equal sign, save the file, and run:

    ```bash
    terraform fmt -check
    terraform fmt
    ```

2. Note that **-check** lists the file that is not formatted and that **terraform fmt** fixes it.

3. Validate the configuration:

    ```bash
    terraform validate
    ```

4. Test the validation rule of the prefix with an invalid value. This command is the same in both shells:

    ```bash
    terraform plan -var="prefix=Student_01"
    ```

5. Note the error message from the **validation** block. Terraform stops before contacting Azure.

### Task 3: Create and review a plan

1. Create a plan and save it to a file:

    ```bash
    terraform plan -out=tfplan
    ```

2. Review the output and answer the following questions:

    - How many resources will be added? (Expected: 5, the random string, the virtual network, two subnets, and the storage account.)
    - Which attributes show **(known after apply)**, and why? (IDs and generated values are known only after Azure creates the resources.)
    - Does the plan change or destroy anything? (Expected: no.)

### Task 4: Apply the plan and inspect the state

1. Apply the saved plan. No confirmation is requested, because the plan was already reviewed:

    ```bash
    terraform apply tfplan
    ```

2. Review the outputs at the end of the apply, and print one output as a raw value:

    ```bash
    terraform output
    terraform output -raw storage_account_name
    ```

3. List the resources in the state and show the details of the virtual network:

    ```bash
    terraform state list
    terraform state show azurerm_virtual_network.main
    ```

4. Verify the result with the Azure CLI. Replace **\<student\>** with the student name. This command is the same in both shells:

    ```bash
    az resource list --resource-group rg-<student>-usa --query "[?tags.lab=='04'].{name:name, type:type}" --output table
    ```

5. Run the plan again and note the message **No changes. Your infrastructure matches the configuration.** This is idempotency: the same code applied again changes nothing.

    ```bash
    terraform plan
    ```

## Exercise 4: Change the configuration and read the plan

The exercise consists of the following tasks:

- Task 1: Update a resource in place
- Task 2: Replace a resource
- Task 3: Use variable precedence

### Task 1: Update a resource in place

1. Open **terraform.tfvars** and add a tags value:

    ```hcl
    tags = {
      environment = "lab"
      owner       = "student01"
    }
    ```

2. Create a plan:

    ```bash
    terraform plan -out=tfplan
    ```

3. Note the **~** symbol and the text **will be updated in-place** for the virtual network and the storage account, and the line **+ "owner" = "student01"** inside the tags.

4. Apply the plan:

    ```bash
    terraform apply tfplan
    ```

### Task 2: Replace a resource

1. In **main.tf**, change the length of the random suffix from **5** to **6**:

    ```hcl
    resource "random_string" "suffix" {
      length  = 6
      upper   = false
      special = false
    }
    ```

2. Create a plan:

    ```bash
    terraform plan -out=tfplan
    ```

3. Note the **-/+** symbol and the text **must be replaced** for the random string and the storage account, and the comment **# forces replacement** next to the changed attributes. A new suffix means a new storage account name, and a storage account cannot be renamed.

4. Apply the plan and note that the storage account is destroyed and created again:

    ```bash
    terraform apply tfplan
    ```

    > [!IMPORTANT]
    > A replaced storage account loses its data. In real environments, read every **-/+** in a plan before applying it.

### Task 3: Use variable precedence

1. Set the prefix as an environment variable and run a plan. The value from **terraform.tfvars** still wins, because the values file has a higher precedence than environment variables:

    **Bash**

    ```bash
    export TF_VAR_prefix="envvalue"
    terraform plan
    ```

    **PowerShell**

    ```powershell
    $env:TF_VAR_prefix = "envvalue"
    terraform plan
    ```

2. Note that the plan shows no changes.

3. Pass the prefix on the command line. Command line options have the highest precedence. This command is the same in both shells:

    ```bash
    terraform plan -var="prefix=cmdvalue"
    ```

4. Note that the plan now wants to replace the virtual network and the storage account, because their names change. Do not apply this plan.

5. Remove the environment variable:

    **Bash**

    ```bash
    unset TF_VAR_prefix
    ```

    **PowerShell**

    ```powershell
    Remove-Item Env:TF_VAR_prefix
    ```

## Exercise 5: Destroy the resources

The exercise consists of the following tasks:

- Task 1: Preview and run the destroy

### Task 1: Preview and run the destroy

1. Preview what will be destroyed:

    ```bash
    terraform plan -destroy
    ```

2. Note that the plan lists five resources to destroy and does not include the resource group, which is only read by a data source.

3. Destroy the resources and type **yes** when asked:

    ```bash
    terraform destroy
    ```

4. Verify that no resource with the tag **lab=04** remains. Replace **\<student\>** with the student name:

    ```bash
    az resource list --resource-group rg-<student>-usa --query "[?tags.lab=='04'].name" --output table
    ```

5. The **terraform.tfstate** file still exists but contains no resources. If the folder is reused, delete the plan and state files. Never commit them to a repository:

    **Bash**

    ```bash
    rm -f tfplan terraform.tfstate terraform.tfstate.backup
    ```

    **PowerShell**

    ```powershell
    Remove-Item tfplan, terraform.tfstate, terraform.tfstate.backup -ErrorAction SilentlyContinue
    ```

## Review

The following table summarizes the commands of the Terraform workflow practiced in this lab. These commands are the same in Bash and PowerShell.

| Command | Purpose | Changes Azure? |
|---|---|---|
| `terraform init` | Download providers, create the lock file, configure the backend | No |
| `terraform fmt` / `terraform validate` | Format the code; check syntax and references | No |
| `terraform plan -out=tfplan` | Show and save the changes | No |
| `terraform apply tfplan` | Make exactly the saved changes | Yes |
| `terraform output` | Show output values | No |
| `terraform state list` / `show` | Inspect the state | No |
| `terraform destroy` | Remove every managed resource | Yes |
