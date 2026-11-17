# Lab 05 - Terraform Remote State, Modules, and a Linux VM

**Estimated timing:** 90 minutes

## Prerequisites

- Completion of **Lab 04 - Terraform Fundamentals**: Terraform, the Visual Studio Code extension, and the Azure CLI are installed.
- The lab values: the student name, the subscription ID (`<subscription-id>`), and the resource group **rg-\<student\>-usa**.
- The OpenSSH client and one of the following terminals:
  - **Bash**: **Terminal** on macOS, a Linux shell, or **Git Bash** on Windows.
  - **PowerShell**: **Windows PowerShell 5.1** or **PowerShell 7** on Windows.
- The lab files folders **labfiles/lab05** and **labfiles/shared**.

## Objectives

This lab covers the following objectives:

- Call a local module and read its outputs
- Create subnets with for_each and security rules with a dynamic block
- Deploy a small Linux virtual machine and connect to it with SSH
- Move the state from a local file to Azure Storage and observe state locking
- Rename a module without destroying resources by using a moved block
- Optionally deploy a storage account with Bicep and compare the experience

The configuration reads the assigned resource group, calls the **modules/network** module to create a virtual network with subnets, adds a network security group with a dynamic block, and creates an Ubuntu virtual machine of size **Standard_B1s** with a public IP address.

> [!NOTE]
> The virtual machine has a small hourly cost. Exercise 6 destroys everything except the state storage account, which Labs 07 and 09 use again.

## Choose your shell

The **terraform** and **az** commands are the same in every shell. Environment variables, file commands, and a few helpers are different. When the commands differ, each step shows a **Bash** block and a **PowerShell** block. Run only the block for your shell, and use the same shell for the whole lab.

| Action | Bash (macOS, Linux, Git Bash) | PowerShell (Windows) |
|---|---|---|
| Set an environment variable | `export NAME="value"` | `$env:NAME = "value"` |
| Copy a file | `cp source target` | `Copy-Item source target` |
| Delete files | `rm -f file1 file2` | `Remove-Item file1, file2` |
| Home folder in a path | `~/.ssh/file` | `"$HOME/.ssh/file"` |
| Filter output lines | `... \| grep text` | `... \| Select-String text` |
| First lines of output | `... \| head -20` | `... \| Select-Object -First 20` |
| Continue a command on the next line | `\` at the end of the line | `` ` `` (backtick) at the end of the line |

> [!IMPORTANT]
> Environment variables exist only in the current terminal. If the terminal is closed, set them again before continuing.

## Exercise 1: Prepare the lab

The exercise consists of the following tasks:

- Task 1: Sign in and create the values file
- Task 2: Create an SSH key pair
- Task 3: Review the module and the root configuration

### Task 1: Sign in and create the values file

1. In Visual Studio Code, select **File** > **Open Folder** and open the **labfiles/lab05** folder. Select **Terminal** > **New Terminal** and open a Bash or PowerShell terminal.

2. Sign in and set the subscription for the azurerm provider:

    **Bash**

    ```bash
    az login
    az account set --subscription "<subscription-id>"
    export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    ```

    **PowerShell**

    ```powershell
    az login
    az account set --subscription "<subscription-id>"
    $env:ARM_SUBSCRIPTION_ID = az account show --query id -o tsv
    ```

3. Find the public IP address of the computer. The network security group allows SSH only from this address:

    **Bash**

    ```bash
    curl -s https://api.ipify.org; echo
    ```

    **PowerShell**

    ```powershell
    Invoke-RestMethod -Uri https://api.ipify.org
    ```

4. Create the values file:

    **Bash**

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

    **PowerShell**

    ```powershell
    Copy-Item terraform.tfvars.example terraform.tfvars
    ```

5. Open **terraform.tfvars** and replace the placeholders with the lab values and the IP address followed by **/32**, for example:

    ```hcl
    resource_group_name = "rg-student01-usa"
    prefix              = "student01"
    allowed_ssh_cidr    = "203.0.113.10/32"
    ```

    > [!NOTE]
    > Corporate networks and VPNs often leave through a different address. If the SSH connection in Exercise 2 times out, find the IP address again from the same network and update **allowed_ssh_cidr**.

### Task 2: Create an SSH key pair

1. Create a key pair dedicated to this lab. Press **Enter** twice to accept an empty passphrase, or type a passphrase:

    **Bash**

    ```bash
    ssh-keygen -t ed25519 -f ~/.ssh/lab05_ed25519 -C "student01-lab05"
    ```

    **PowerShell**

    ```powershell
    New-Item -ItemType Directory -Force -Path "$HOME/.ssh" | Out-Null
    ssh-keygen -t ed25519 -f "$HOME/.ssh/lab05_ed25519" -C "student01-lab05"
    ```

2. Verify that the public key exists. The variable **ssh_public_key_path** points to this file:

    **Bash**

    ```bash
    ls ~/.ssh/lab05_ed25519*
    ```

    **PowerShell**

    ```powershell
    Get-ChildItem "$HOME/.ssh/lab05_ed25519*"
    ```

    > [!IMPORTANT]
    > Only the public key (**.pub**) goes to Azure. The private key stays on the computer and is never committed to a repository.

### Task 3: Review the module and the root configuration

1. Open the files of **modules/network** and review the module interface:

    - **variables.tf**: the inputs **name**, **location**, **resource_group_name**, **address_space**, **subnets** (a map of name to prefix), and **tags**.
    - **main.tf**: one virtual network and **azurerm_subnet.this** with **for_each = var.subnets**. Every subnet is an instance identified by its key, for example **this["web"]**.
    - **outputs.tf**: **vnet_id** and **subnet_ids**, a map built with a for expression.
    - **versions.tf**: the module declares the provider source but no provider block. The root module configures the provider.

2. Open **main.tf** in the root folder and review the following parts:

    - **local.subnet_prefixes** uses **cidrsubnet(var.address_space, 8, index)** to turn the index of each subnet into a /24 prefix.
    - **module "network"** passes the inputs to the module. **source = "./modules/network"** is a local path.
    - **azurerm_network_security_group.web** builds its rules with **dynamic "security_rule"**. One rule (ssh) exists for now.
    - **azurerm_subnet_network_security_group_association.web** reads **module.network.subnet_ids["web"]**.

3. Open **vm.tf** and note the public IP address, the network interface in the web subnet, and the virtual machine with **admin_ssh_key** and **disable_password_authentication = true**.

4. Open **versions.tf** and note that the **backend** line is commented. Terraform starts with local state.

## Exercise 2: Deploy with local state

The exercise consists of the following tasks:

- Task 1: Initialize, plan, and apply
- Task 2: Inspect module addresses in the state
- Task 3: Connect to the virtual machine

### Task 1: Initialize, plan, and apply

1. Initialize the folder. Note the line **Initializing modules...** and the module **network**:

    ```bash
    terraform init
    ```

2. Create and review a plan:

    ```bash
    terraform plan -out=tfplan
    ```

3. Verify that the plan adds **8** resources and changes or destroys nothing: the virtual network, two subnet instances, the network security group, the association, the public IP address, the network interface, and the virtual machine.

4. Apply the plan. The virtual machine takes one to three minutes:

    ```bash
    terraform apply tfplan
    ```

    > [!NOTE]
    > If the apply fails with **SkuNotAvailable**, the size is not offered to the subscription in the region. Set **vm_size = "Standard_B2ats_v2"** in **terraform.tfvars** and run the plan and apply again. The command **az vm list-skus --location southcentralus --size Standard_B --output table** lists the sizes and their restrictions.

### Task 2: Inspect module addresses in the state

1. List the resources in the state:

    ```bash
    terraform state list
    ```

2. Note the addresses of the resources created by the module, for example **module.network.azurerm_subnet.this["web"]**. The prefix **module.network** identifies the module call, and the key in brackets identifies the for_each instance.

3. Show one subnet and its address prefix:

    **Bash**

    ```bash
    terraform state show 'module.network.azurerm_subnet.this["data"]'
    ```

    **PowerShell 7.3 or later**

    ```powershell
    terraform state show 'module.network.azurerm_subnet.this["data"]'
    ```

    **Windows PowerShell 5.1**

    ```powershell
    terraform state show 'module.network.azurerm_subnet.this[\"data\"]'
    ```

    > [!NOTE]
    > Single quotes around the address keep the double quotes and brackets intact. Windows PowerShell 5.1 removes double quotes inside arguments passed to external programs, so they must be escaped with a backslash. Run **$PSVersionTable.PSVersion** to check the PowerShell version.

### Task 3: Connect to the virtual machine

1. Display the ready-made SSH command from the outputs, and then connect:

    **Bash**

    ```bash
    terraform output -raw ssh_command; echo
    ssh -i ~/.ssh/lab05_ed25519 azureuser@$(terraform output -raw vm_public_ip)
    ```

    **PowerShell**

    ```powershell
    terraform output -raw ssh_command; Write-Output ""
    ssh -i "$HOME/.ssh/lab05_ed25519" "azureuser@$(terraform output -raw vm_public_ip)"
    ```

2. Type **yes** to trust the host key. In the virtual machine, run a few commands and disconnect. The session runs Bash on the virtual machine, so these commands are the same for every student:

    ```bash
    hostname
    lsb_release -d
    ip -4 addr show eth0 | grep inet
    exit
    ```

3. Note that the private IP address belongs to the **snet-web** subnet (10.30.1.0/24).

## Exercise 3: Move the state to Azure Storage

The exercise consists of the following tasks:

- Task 1: Create the state storage account
- Task 2: Configure the backend and migrate the state

### Task 1: Create the state storage account

1. Review **labfiles/shared/create-state-storage.sh**. The script creates a storage account named **sttfstate\<student\>\<digits\>**, turns on blob versioning, and creates the **tfstate** container.

2. Create the storage account with the lab values:

    **Bash**: run the script.

    ```bash
    export RESOURCE_GROUP=rg-student01-usa
    export STUDENT=student01
    bash ../shared/create-state-storage.sh
    ```

    **PowerShell**: run the same steps as the script.

    ```powershell
    $RESOURCE_GROUP   = "rg-student01-usa"
    $STUDENT          = "student01"
    $TF_STATE_ACCOUNT = "sttfstate$STUDENT$(Get-Random -Minimum 10000 -Maximum 99999)"

    az storage account create --resource-group $RESOURCE_GROUP --name $TF_STATE_ACCOUNT `
      --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false
    az storage account blob-service-properties update --resource-group $RESOURCE_GROUP `
      --account-name $TF_STATE_ACCOUNT --enable-versioning true
    az storage container create --account-name $TF_STATE_ACCOUNT --name tfstate --auth-mode key

    "TF_STATE_ACCOUNT=$TF_STATE_ACCOUNT"
    ```

3. Copy the value of **TF_STATE_ACCOUNT** from the last line of the output.

    > [!NOTE]
    > The container is created with **--auth-mode key**, because the lab identity has Contributor on the resource group but no data plane role. The azurerm backend reads the access key of the account in the same way.

### Task 2: Configure the backend and migrate the state

1. Create the backend values file:

    **Bash**

    ```bash
    cp backend.hcl.example backend.hcl
    ```

    **PowerShell**

    ```powershell
    Copy-Item backend.hcl.example backend.hcl
    ```

2. Open **backend.hcl** and set the values, using the storage account name from the previous task:

    ```hcl
    resource_group_name  = "rg-student01-usa"
    storage_account_name = "sttfstatestudent0112345"
    container_name       = "tfstate"
    key                  = "lab05.tfstate"
    ```

3. Open **versions.tf** and remove the comment character from the backend line, so that it reads:

    ```hcl
    backend "azurerm" {}
    ```

4. Initialize again with the backend configuration and the migrate option. This command is the same in both shells:

    ```bash
    terraform init "-backend-config=backend.hcl" -migrate-state
    ```

    > [!NOTE]
    > The quotes around the whole **-backend-config** option are needed in PowerShell. Without them, PowerShell splits an option that starts with a dash and contains a dot into two arguments.

5. When Terraform asks **Do you want to copy existing state to the new backend?**, type **yes**.

6. Verify that the state blob exists in the container. Replace **\<TF_STATE_ACCOUNT\>** with the storage account name:

    **Bash**

    ```bash
    az storage blob list --account-name <TF_STATE_ACCOUNT> --container-name tfstate --auth-mode key \
      --query "[].{name:name, size:properties.contentLength}" --output table
    ```

    **PowerShell**

    ```powershell
    az storage blob list --account-name <TF_STATE_ACCOUNT> --container-name tfstate --auth-mode key `
      --query "[].{name:name, size:properties.contentLength}" --output table
    ```

7. Run a plan and verify that it shows **No changes**. Terraform now reads the state from Azure Storage.

    ```bash
    terraform plan
    ```

8. Delete the local state files, which Terraform no longer uses:

    **Bash**

    ```bash
    rm -f terraform.tfstate terraform.tfstate.backup
    ```

    **PowerShell**

    ```powershell
    Remove-Item terraform.tfstate, terraform.tfstate.backup -ErrorAction SilentlyContinue
    ```

    > [!NOTE]
    > The partial configuration keeps the storage account name out of the code, so every learner and every environment can use the same **versions.tf** with a different **backend.hcl**.

## Exercise 4: Use for_each and a dynamic block

The exercise consists of the following tasks:

- Task 1: Add a subnet and observe state locking
- Task 2: Add a security rule
- Task 3: Remove a subnet

### Task 1: Add a subnet and observe state locking

1. Test the function that calculates the prefixes in the Terraform console. Type each line after the **>** prompt:

    ```text
    terraform console
    > cidrsubnet("10.30.0.0/16", 8, 3)
    > local.subnet_prefixes
    > exit
    ```

2. Open **terraform.tfvars** and add a subnets value with a third subnet:

    ```hcl
    subnets = {
      web  = 1
      data = 2
      app  = 3
    }
    ```

3. Run an apply without a saved plan. Verify that the plan adds exactly one resource, **module.network.azurerm_subnet.this["app"]**, with the prefix **10.30.3.0/24**, and do not answer the confirmation question yet:

    ```bash
    terraform apply
    ```

4. While Terraform waits, open a second terminal in the same folder, set **ARM_SUBSCRIPTION_ID** again, and run a plan:

    **Bash**

    ```bash
    export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    terraform plan
    ```

    **PowerShell**

    ```powershell
    $env:ARM_SUBSCRIPTION_ID = az account show --query id -o tsv
    terraform plan
    ```

5. Note the error **Error acquiring the state lock** with the lock ID, the operation, and the user who holds the lock. The azurerm backend implements the lock as a lease on the state blob.

6. In the first terminal, type **yes** to apply. When the apply completes, run the plan in the second terminal again and note that it succeeds with **No changes**.

    > [!IMPORTANT]
    > Use **terraform force-unlock \<LOCK_ID\>** only when a lock remains after a crashed run and no other run is active.

### Task 2: Add a security rule

1. In **main.tf**, add an **http** entry to the for_each map of the dynamic block:

    ```hcl
    for_each = {
      ssh  = { priority = 100, port = "22", source = var.allowed_ssh_cidr }
      http = { priority = 110, port = "80", source = var.allowed_ssh_cidr }
    }
    ```

2. Create a plan and apply it. Note that the network security group is **updated in-place** and that the plan shows a new **security_rule** block named **allow-http**:

    ```bash
    terraform plan -out=tfplan
    terraform apply tfplan
    ```

3. Answer the following question: how many rules would a third entry add, and how many lines of code?

    <details>
    <summary>Show the answer</summary>

    One rule, one line. The dynamic block generates the nested blocks.

    </details>

### Task 3: Remove a subnet

1. In **terraform.tfvars**, remove the **data** entry from the subnets map:

    ```hcl
    subnets = {
      web = 1
      app = 3
    }
    ```

2. Create a plan and verify that it destroys only **module.network.azurerm_subnet.this["data"]**. The **web** and **app** subnets are untouched, because for_each identifies instances by key. Then apply the plan:

    ```bash
    terraform plan -out=tfplan
    terraform apply tfplan
    ```

3. Answer the following question: what would happen with **count** and a list **["web", "data", "app"]** if **data** were removed?

    <details>
    <summary>Show the answer</summary>

    **app** would move from index 2 to index 1, so Terraform would change or replace it. With count, removing an element shifts every element after it.

    </details>

## Exercise 5: Refactor with a moved block

The exercise consists of the following tasks:

- Task 1: Rename the module call
- Task 2: Add the moved block

### Task 1: Rename the module call

1. In **main.tf**, rename the module call from **network** to **vnet**:

    ```hcl
    module "vnet" {
      source = "./modules/network"
      ...
    ```

2. Update the three references from **module.network** to **module.vnet**: the subnet association in **main.tf**, the network interface in **vm.tf**, and the **subnet_ids** output in **outputs.tf**.

3. Create a plan without applying it:

    ```bash
    terraform plan
    ```

4. Note that the plan wants to destroy the virtual network and the subnets under **module.network** and create them again under **module.vnet**. For Terraform, a new address is a new resource. Do not apply this plan.

### Task 2: Add the moved block

1. Add the following block at the end of **main.tf**:

    ```hcl
    moved {
      from = module.network
      to   = module.vnet
    }
    ```

2. Create a plan again:

    ```bash
    terraform plan -out=tfplan
    ```

3. Note the messages **has moved to module.vnet** and the summary **0 to add, 0 to change, 0 to destroy**. Apply the plan to record the new addresses in the state, and list the module resources:

    **Bash**

    ```bash
    terraform apply tfplan
    terraform state list | grep module
    ```

    **PowerShell**

    ```powershell
    terraform apply tfplan
    terraform state list | Select-String module
    ```

    > [!NOTE]
    > Keep moved blocks in the code until every copy of the state (every environment) has been applied. Older Terraform versions used **terraform state mv** for the same purpose, which changes the state without a plan or a review.

## Exercise 6: Clean up

The exercise consists of the following tasks:

- Task 1: Destroy the lab resources

### Task 1: Destroy the lab resources

1. Destroy the resources and type **yes** when asked:

    ```bash
    terraform destroy
    ```

2. Verify that no resource with the tag **lab=05** remains. This command is the same in both shells:

    ```bash
    az resource list --resource-group rg-student01-usa --query "[?tags.lab=='05'].name" --output table
    ```

3. Verify that the state storage account still exists. Labs 07 and 09 use it again:

    ```bash
    az storage account list --resource-group rg-student01-usa --query "[?starts_with(name, 'sttfstate')].name" --output table
    ```

    > [!IMPORTANT]
    > Do not delete the state storage account or the resource group. Blob versioning keeps the previous versions of **lab05.tfstate**.

## Exercise 7 (optional): Deploy a storage account with Bicep

The exercise consists of the following tasks:

- Task 1: Build and preview the Bicep file
- Task 2: Deploy, inspect, and delete

> [!NOTE]
> This exercise compares the Bicep experience with Terraform. It takes about 15 minutes.

### Task 1: Build and preview the Bicep file

1. Install the **Bicep** extension for Visual Studio Code (publisher **Microsoft**) and open **bicep/main.bicep**.

2. Review the file and compare it with the Terraform code:

    - **param prefix string** with **@minLength(3)** and **@maxLength(10)** plays the role of a variable with validation.
    - **resourceGroup().location** reads the location of the target resource group; no data source is needed.
    - **uniqueString(resourceGroup().id)** gives a stable suffix; no random provider is needed.
    - There is no state file: Azure Resource Manager is the source of truth.

3. Install or update the Bicep CLI and build the file to an ARM template:

    **Bash**

    ```bash
    az bicep install
    az bicep build --file bicep/main.bicep --stdout | head -20
    ```

    **PowerShell**

    ```powershell
    az bicep install
    az bicep build --file bicep/main.bicep --stdout | Select-Object -First 20
    ```

4. Preview the deployment. **what-if** plays the role of **terraform plan**:

    **Bash**

    ```bash
    az deployment group what-if --resource-group rg-student01-usa \
      --template-file bicep/main.bicep --parameters prefix=student01
    ```

    **PowerShell**

    ```powershell
    az deployment group what-if --resource-group rg-student01-usa `
      --template-file bicep/main.bicep --parameters prefix=student01
    ```

### Task 2: Deploy, inspect, and delete

1. Deploy the file and display the outputs:

    **Bash**

    ```bash
    az deployment group create --resource-group rg-student01-usa --name lab05-bicep \
      --template-file bicep/main.bicep --parameters prefix=student01 \
      --query properties.outputs
    ```

    **PowerShell**

    ```powershell
    az deployment group create --resource-group rg-student01-usa --name lab05-bicep `
      --template-file bicep/main.bicep --parameters prefix=student01 `
      --query properties.outputs
    ```

2. Run the same deployment again and note that it succeeds without changes. Bicep deployments are idempotent as well.

3. List the deployment history of the resource group. This history replaces the state file of Terraform. This command is the same in both shells:

    ```bash
    az deployment group list --resource-group rg-student01-usa --query "[].{name:name, state:properties.provisioningState}" --output table
    ```

4. Delete the storage account created by Bicep. Bicep has no destroy command for a single deployment:

    **Bash**

    ```bash
    az storage account delete --resource-group rg-student01-usa --yes \
      --name $(az deployment group show --resource-group rg-student01-usa --name lab05-bicep --query properties.outputs.storageAccountName.value -o tsv)
    ```

    **PowerShell**

    ```powershell
    $BICEP_ST = az deployment group show --resource-group rg-student01-usa --name lab05-bicep `
      --query properties.outputs.storageAccountName.value -o tsv
    az storage account delete --resource-group rg-student01-usa --name $BICEP_ST --yes
    ```

## Review

The following table summarizes the techniques practiced in this lab.

| Technique | Code | Benefit |
|---|---|---|
| Local module | `module "vnet" { source = "./modules/network" }` | Reuse a tested group of resources |
| for_each | `for_each = var.subnets` | Instances identified by key; safe to add and remove |
| Dynamic block | `dynamic "security_rule" { ... }` | Generate nested blocks from data |
| Remote state | `backend "azurerm" {}` + `backend.hcl` | Shared, locked, versioned state |
| Moved block | `moved` with `from` and `to` | Rename without destroy and create |
| Bicep what-if | `az deployment group what-if` | Preview of an ARM deployment |
