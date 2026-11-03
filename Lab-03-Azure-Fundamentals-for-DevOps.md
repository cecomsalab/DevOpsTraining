# Lab 03 - Azure Fundamentals for DevOps

**Estimated timing:** 70 minutes

## Prerequisites

- The lab values provided by the instructor from the course setup script: the student name, the resource group **rg-\<student\>-usa**, the subscription ID (`<subscription-id>`), the tenant ID (`<tenant-id>`), and the service principal client ID (`<client-id>`) and client secret (`<client-secret>`).
- One of the following terminals:
  - **Bash**: **Git Bash** on Windows (installed in Lab 02A), **Terminal** on macOS, or a Linux shell.
  - **PowerShell**: **Windows PowerShell 5.1** or **PowerShell 7** on Windows, macOS, or Linux.
- The Azure CLI. Exercise 1 installs it if needed.
- The lab files folder **labfiles/lab03**, which contains every Bash command of this lab in **lab03-commands.sh**.

## Objectives

This lab covers the following objectives:

- Install the Azure CLI and sign in with the user account and with the service principal
- Explore the assigned resource group and its role assignment
- Filter and format Azure CLI output with JMESPath queries
- Create a virtual network with two subnets and a network security group
- Create a storage account, a private container, and a blob
- Create a Linux virtual machine with an SSH key and connect to it
- Delete every resource that the lab created

Every resource in this lab is created with the Azure CLI. Lab 04 and Lab 05 create the same kind of resources with Terraform, which shows the difference between imperative commands and declarative code.

## Choose your shell

The **az** commands are the same in every shell. Variables, line continuation, and a few helper commands are different. When the commands differ, each step shows a **Bash** block and a **PowerShell** block. Run only the block for your shell, and use the same shell for the whole lab.

| Item | Bash (Linux, macOS, Git Bash) | PowerShell |
|---|---|---|
| Define a variable | `RG="rg-lab"` (no spaces around `=`) | `$RG = "rg-lab"` |
| Use a variable | `"$RG"` | `$RG` |
| Continue a command on the next line | `\` at the end of the line | `` ` `` (backtick) at the end of the line |
| Store the output of a command | `VAR=$(az ... --output tsv)` | `$VAR = az ... --output tsv` |
| Home folder in a path | `~/.ssh/file` | `"$HOME/.ssh/file"` |
| Display a file | `cat file` | `Get-Content file` |

## Exercise 1: Sign in and explore the lab environment

The exercise consists of the following tasks:

- Task 1: Install or verify the Azure CLI
- Task 2: Sign in and select the subscription
- Task 3: Explore the resource group and the role assignment
- Task 4: Query the output with JMESPath

### Task 1: Install or verify the Azure CLI

1. Open the terminal and run the following command:

    ```bash
    az version
    ```

2. If the command returns version information, continue with **Task 2**. Otherwise, install the Azure CLI with the command for the operating system, open a new terminal, and run **az version** again:

    ```bash
    # Windows (PowerShell)
    winget install --exact --id Microsoft.AzureCLI

    # macOS
    brew install azure-cli

    # Ubuntu or Debian
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    ```

    > [!NOTE]
    > On Windows, the Azure CLI installed with winget works in PowerShell and in Git Bash after a new terminal window is opened.

### Task 2: Sign in and select the subscription

1. Run the following command and complete the sign-in with the course user account in the browser window that opens:

    ```bash
    az login
    ```

    > [!NOTE]
    > On a computer without a browser, run **az login --use-device-code** and enter the displayed code at https://microsoft.com/devicelogin.

2. If the account has access to several subscriptions, the command lists them. Select the course subscription by number, or run the following command with the subscription ID from the lab values:

    ```bash
    az account set --subscription "<subscription-id>"
    ```

3. Verify the active subscription:

    ```bash
    az account show --output table
    ```

4. Define the variables used in the rest of the lab. Replace **student01** with the assigned student name.

    **Bash**

    ```bash
    STUDENT="student01"
    RG="rg-${STUDENT}-usa"
    LOCATION="southcentralus"
    TAGS="course=devops lab=03 owner=${STUDENT}"
    ```

    **PowerShell**

    ```powershell
    $STUDENT  = "student01"
    $RG       = "rg-$STUDENT-usa"
    $LOCATION = "southcentralus"
    $TAGS     = @("course=devops", "lab=03", "owner=$STUDENT")
    ```

    > [!NOTE]
    > In Bash, **$TAGS** is used without quotes so that the shell splits it into three tags. PowerShell does not split strings, so **$TAGS** is an array with one item per tag.

    > [!IMPORTANT]
    > Variables exist only in the current terminal. If the terminal is closed, define them again before continuing.

### Task 3: Explore the resource group and the role assignment

1. Show the resource group:

    **Bash**

    ```bash
    az group show --name "$RG" --output table
    ```

    **PowerShell**

    ```powershell
    az group show --name $RG --output table
    ```

2. List the role assignments of the resource group:

    **Bash**

    ```bash
    az role assignment list --resource-group "$RG" \
      --query "[].{principal:principalName, role:roleDefinitionName, scope:scope}" --output table
    ```

    **PowerShell**

    ```powershell
    az role assignment list --resource-group $RG `
      --query "[].{principal:principalName, role:roleDefinitionName, scope:scope}" --output table
    ```

3. Note the assignment of the **Contributor** role to the service principal **sp-devops-\<student\>** at the scope of the resource group. The service principal can create and delete resources in this group, but it cannot assign roles or create resource groups.

4. List the resources in the group. The list is empty or contains only resources created by the course setup:

    **Bash**

    ```bash
    az resource list --resource-group "$RG" --output table
    ```

    **PowerShell**

    ```powershell
    az resource list --resource-group $RG --output table
    ```

### Task 4: Query the output with JMESPath

1. Compare the default JSON output with the table output:

    **Bash**

    ```bash
    az group show --name "$RG"
    az group show --name "$RG" --output table
    ```

    **PowerShell**

    ```powershell
    az group show --name $RG
    az group show --name $RG --output table
    ```

2. Select only some fields with a query:

    **Bash**

    ```bash
    az group show --name "$RG" --query "{name:name, location:location, state:properties.provisioningState}"
    ```

    **PowerShell**

    ```powershell
    az group show --name $RG --query "{name:name, location:location, state:properties.provisioningState}"
    ```

3. List the names of the physical regions in the United States. This command is the same in both shells:

    ```bash
    az account list-locations --query "[?metadata.geographyGroup=='US' && metadata.regionType=='Physical'].name" --output tsv
    ```

4. List the VM sizes in the region with at most two vCPUs and 4 GB of memory:

    **Bash**

    ```bash
    az vm list-sizes --location "$LOCATION" \
      --query '[?numberOfCores<=`2` && memoryInMB<=`4096`].{name:name, cores:numberOfCores, memory:memoryInMB}' \
      --output table
    ```

    **PowerShell**

    ```powershell
    az vm list-sizes --location $LOCATION `
      --query '[?numberOfCores<=`2` && memoryInMB<=`4096`].{name:name, cores:numberOfCores, memory:memoryInMB}' `
      --output table
    ```

5. Verify that **Standard_B1s** (1 vCPU, 1 GB) is in the list. Lab 03 uses this size for the virtual machine.

    > [!NOTE]
    > In JMESPath, literal numbers are written between backticks, as in `` `2` ``. The query is enclosed in **single quotes** so that neither shell changes the backticks: Bash treats backticks inside double quotes as a command, and PowerShell treats a backtick inside double quotes as an escape character.

## Exercise 2: Create the network

The exercise consists of the following tasks:

- Task 1: Create the virtual network and the subnets
- Task 2: Create a network security group that allows SSH only from the admin IP address

### Task 1: Create the virtual network and the subnets

1. Create the virtual network with the first subnet:

    **Bash**

    ```bash
    az network vnet create --resource-group "$RG" --name vnet-lab03 --location "$LOCATION" \
      --address-prefixes 10.20.0.0/16 --subnet-name snet-web --subnet-prefixes 10.20.1.0/24 \
      --tags $TAGS
    ```

    **PowerShell**

    ```powershell
    az network vnet create --resource-group $RG --name vnet-lab03 --location $LOCATION `
      --address-prefixes 10.20.0.0/16 --subnet-name snet-web --subnet-prefixes 10.20.1.0/24 `
      --tags $TAGS
    ```

2. Add the second subnet:

    **Bash**

    ```bash
    az network vnet subnet create --resource-group "$RG" --vnet-name vnet-lab03 \
      --name snet-data --address-prefixes 10.20.2.0/24
    ```

    **PowerShell**

    ```powershell
    az network vnet subnet create --resource-group $RG --vnet-name vnet-lab03 `
      --name snet-data --address-prefixes 10.20.2.0/24
    ```

3. List the subnets and their address ranges:

    **Bash**

    ```bash
    az network vnet subnet list --resource-group "$RG" --vnet-name vnet-lab03 \
      --query "[].{name:name, prefix:addressPrefix}" --output table
    ```

    **PowerShell**

    ```powershell
    az network vnet subnet list --resource-group $RG --vnet-name vnet-lab03 `
      --query "[].{name:name, prefix:addressPrefix}" --output table
    ```

    > [!NOTE]
    > Each /24 subnet has 256 addresses, of which 251 are usable: Azure reserves the first four and the last address of every subnet.

### Task 2: Create a network security group that allows SSH only from the admin IP address

1. Find the public IP address of the computer:

    **Bash**

    ```bash
    MY_IP=$(curl -s https://api.ipify.org)
    echo "$MY_IP"
    ```

    **PowerShell**

    ```powershell
    $MY_IP = Invoke-RestMethod -Uri https://api.ipify.org
    $MY_IP
    ```

2. Create the network security group:

    **Bash**

    ```bash
    az network nsg create --resource-group "$RG" --name nsg-web-lab03 --location "$LOCATION" --tags $TAGS
    ```

    **PowerShell**

    ```powershell
    az network nsg create --resource-group $RG --name nsg-web-lab03 --location $LOCATION --tags $TAGS
    ```

3. Add an inbound rule that allows SSH (TCP 22) only from this IP address:

    **Bash**

    ```bash
    az network nsg rule create --resource-group "$RG" --nsg-name nsg-web-lab03 \
      --name allow-ssh-from-my-ip --priority 100 --direction Inbound --access Allow \
      --protocol Tcp --source-address-prefixes "${MY_IP}/32" --destination-port-ranges 22
    ```

    **PowerShell**

    ```powershell
    az network nsg rule create --resource-group $RG --nsg-name nsg-web-lab03 `
      --name allow-ssh-from-my-ip --priority 100 --direction Inbound --access Allow `
      --protocol Tcp --source-address-prefixes "$MY_IP/32" --destination-port-ranges 22
    ```

4. Associate the network security group with the web subnet:

    **Bash**

    ```bash
    az network vnet subnet update --resource-group "$RG" --vnet-name vnet-lab03 \
      --name snet-web --network-security-group nsg-web-lab03
    ```

    **PowerShell**

    ```powershell
    az network vnet subnet update --resource-group $RG --vnet-name vnet-lab03 `
      --name snet-web --network-security-group nsg-web-lab03
    ```

5. List all rules of the network security group, including the default rules:

    **Bash**

    ```bash
    az network nsg rule list --resource-group "$RG" --nsg-name nsg-web-lab03 --include-default \
      --query "[].{priority:priority, name:name, access:access, source:sourceAddressPrefix}" --output table
    ```

    **PowerShell**

    ```powershell
    az network nsg rule list --resource-group $RG --nsg-name nsg-web-lab03 --include-default `
      --query "[].{priority:priority, name:name, access:access, source:sourceAddressPrefix}" --output table
    ```

6. Note that the default rule **DenyAllInBound** (priority 65500) blocks every other inbound connection from the internet.

    > [!IMPORTANT]
    > Never allow SSH from **Any** or **Internet**. Open ports are scanned within minutes of their creation.

## Exercise 3: Create a storage account

The exercise consists of the following tasks:

- Task 1: Create the storage account
- Task 2: Create a container and upload a blob

### Task 1: Create the storage account

1. Define a globally unique storage account name (3 to 24 lowercase letters and numbers):

    **Bash**

    ```bash
    ST="st${STUDENT}lab03${RANDOM}"
    echo "$ST"
    ```

    **PowerShell**

    ```powershell
    $ST = "st${STUDENT}lab03$(Get-Random -Maximum 32768)"
    $ST
    ```

2. Create the storage account with secure settings:

    **Bash**

    ```bash
    az storage account create --resource-group "$RG" --name "$ST" --location "$LOCATION" \
      --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 \
      --allow-blob-public-access false --tags $TAGS
    ```

    **PowerShell**

    ```powershell
    az storage account create --resource-group $RG --name $ST --location $LOCATION `
      --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 `
      --allow-blob-public-access false --tags $TAGS
    ```

3. Verify the settings:

    **Bash**

    ```bash
    az storage account show --resource-group "$RG" --name "$ST" \
      --query "{name:name, sku:sku.name, tls:minimumTlsVersion, publicBlob:allowBlobPublicAccess}" --output table
    ```

    **PowerShell**

    ```powershell
    az storage account show --resource-group $RG --name $ST `
      --query "{name:name, sku:sku.name, tls:minimumTlsVersion, publicBlob:allowBlobPublicAccess}" --output table
    ```

### Task 2: Create a container and upload a blob

1. Create a private container. The option **--auth-mode key** uses the account key, which the Contributor role can read:

    **Bash**

    ```bash
    az storage container create --account-name "$ST" --name notes --auth-mode key
    ```

    **PowerShell**

    ```powershell
    az storage container create --account-name $ST --name notes --auth-mode key
    ```

2. Create a small file and upload it:

    **Bash**

    ```bash
    echo "Hello from Lab 03" > hello.txt
    az storage blob upload --account-name "$ST" --container-name notes \
      --name hello.txt --file hello.txt --auth-mode key
    ```

    **PowerShell**

    ```powershell
    Set-Content -Path hello.txt -Value "Hello from Lab 03"
    az storage blob upload --account-name $ST --container-name notes `
      --name hello.txt --file hello.txt --auth-mode key
    ```

3. List the blobs in the container:

    **Bash**

    ```bash
    az storage blob list --account-name "$ST" --container-name notes --auth-mode key \
      --query "[].{name:name, size:properties.contentLength}" --output table
    ```

    **PowerShell**

    ```powershell
    az storage blob list --account-name $ST --container-name notes --auth-mode key `
      --query "[].{name:name, size:properties.contentLength}" --output table
    ```

    > [!NOTE]
    > With **--auth-mode login**, the Azure CLI uses Microsoft Entra ID for data access, which requires a data role such as **Storage Blob Data Contributor**. The lab identities have no data roles, so the lab uses the account key.

## Exercise 4: Create a Linux virtual machine with an SSH key

The exercise consists of the following tasks:

- Task 1: Generate an SSH key pair
- Task 2: Create the virtual machine
- Task 3: Connect with SSH and review the created resources

### Task 1: Generate an SSH key pair

1. Verify that the OpenSSH client is available. Windows 10 and Windows 11 include it.

    ```bash
    ssh -V
    ```

2. Generate an Ed25519 key pair for the lab. Press **Enter** twice to leave the passphrase empty:

    **Bash**

    ```bash
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    ssh-keygen -t ed25519 -f ~/.ssh/lab03_ed25519 -C "${STUDENT}-lab03"
    ```

    **PowerShell**

    ```powershell
    New-Item -ItemType Directory -Force -Path "$HOME/.ssh" | Out-Null
    ssh-keygen -t ed25519 -f "$HOME/.ssh/lab03_ed25519" -C "$STUDENT-lab03"
    ```

    > [!NOTE]
    > PowerShell does not expand **~** in the arguments of external programs such as **ssh-keygen**, so the PowerShell commands use **$HOME** instead.

3. Display the public key. This is the only part of the key pair that is given to the virtual machine:

    **Bash**

    ```bash
    cat ~/.ssh/lab03_ed25519.pub
    ```

    **PowerShell**

    ```powershell
    Get-Content "$HOME/.ssh/lab03_ed25519.pub"
    ```

    > [!IMPORTANT]
    > The private key **lab03_ed25519** (without **.pub**) stays on the computer. It is never copied, shared, or committed to a repository.

### Task 2: Create the virtual machine

1. Create a Standard_B1s Ubuntu 24.04 virtual machine in the web subnet. The empty value of the option **--nsg** skips a network security group on the network interface, because the subnet already has one:

    **Bash**

    ```bash
    az vm create --resource-group "$RG" --name vm-lab03 --location "$LOCATION" \
      --image Ubuntu2404 --size Standard_B1s \
      --vnet-name vnet-lab03 --subnet snet-web --nsg "" \
      --public-ip-sku Standard --admin-username azureuser \
      --ssh-key-values ~/.ssh/lab03_ed25519.pub --tags $TAGS
    ```

    **PowerShell**

    ```powershell
    az vm create --resource-group $RG --name vm-lab03 --location $LOCATION `
      --image Ubuntu2404 --size Standard_B1s `
      --vnet-name vnet-lab03 --subnet snet-web --nsg '""' `
      --public-ip-sku Standard --admin-username azureuser `
      --ssh-key-values "$HOME/.ssh/lab03_ed25519.pub" --tags $TAGS
    ```

    > [!IMPORTANT]
    > PowerShell on Windows does not pass a plain empty string (**""**) to the Azure CLI, so the empty value is written as **'""'**. In PowerShell 7 on macOS or Linux, use **--nsg ""** instead.

2. Wait until the command completes (about two minutes). Note the **publicIpAddress** value in the output.

    > [!NOTE]
    > If the size is not available in the region, the command reports an error such as **SkuNotAvailable**. Use the query from Exercise 1, Task 4 to select another small size, such as **Standard_B1ms**, and run the command again with that size.

### Task 3: Connect with SSH and review the created resources

1. Store the public IP address in a variable and connect:

    **Bash**

    ```bash
    VM_IP=$(az vm show --resource-group "$RG" --name vm-lab03 --show-details --query publicIps --output tsv)
    ssh -i ~/.ssh/lab03_ed25519 "azureuser@${VM_IP}"
    ```

    **PowerShell**

    ```powershell
    $VM_IP = az vm show --resource-group $RG --name vm-lab03 --show-details --query publicIps --output tsv
    ssh -i "$HOME/.ssh/lab03_ed25519" "azureuser@$VM_IP"
    ```

2. Type **yes** to accept the host key fingerprint at the first connection.

3. In the SSH session, run the following commands to display information about the virtual machine, and then close the session. The session runs Bash on the virtual machine, so these commands are the same for every student:

    ```bash
    hostname
    cat /etc/os-release | head -2
    cat ~/.ssh/authorized_keys
    exit
    ```

4. Back on the computer, list the resources that the **az vm create** command created:

    **Bash**

    ```bash
    az resource list --resource-group "$RG" --query "[?contains(name, 'vm-lab03')].{name:name, type:type}" --output table
    ```

    **PowerShell**

    ```powershell
    az resource list --resource-group $RG --query "[?contains(name, 'vm-lab03')].{name:name, type:type}" --output table
    ```

5. Note that one command created four resources: the virtual machine, the network interface, the public IP address, and the OS disk.

## Exercise 5: Sign in as the service principal

The exercise consists of the following tasks:

- Task 1: Sign in with the service principal
- Task 2: Test the limits of the role assignment

### Task 1: Sign in with the service principal

1. Read the service principal values into variables. When prompted, enter the client ID (`<client-id>`), the client secret (`<client-secret>`), and the tenant ID (`<tenant-id>`) from the lab values. The secret is read without showing it on the screen:

    **Bash**

    ```bash
    read -r -p "AZURE_CLIENT_ID (<client-id>): " AZURE_CLIENT_ID
    read -r -s -p "AZURE_CLIENT_SECRET (<client-secret>): " AZURE_CLIENT_SECRET; echo
    read -r -p "AZURE_TENANT_ID (<tenant-id>): " AZURE_TENANT_ID
    ```

    **PowerShell**

    ```powershell
    $AZURE_CLIENT_ID     = Read-Host "AZURE_CLIENT_ID (<client-id>)"
    $SecureSecret        = Read-Host "AZURE_CLIENT_SECRET (<client-secret>)" -AsSecureString
    $AZURE_CLIENT_SECRET = [System.Net.NetworkCredential]::new("", $SecureSecret).Password
    $AZURE_TENANT_ID     = Read-Host "AZURE_TENANT_ID (<tenant-id>)"
    ```

2. Sign in as the service principal. The option **--username** takes the client ID, and **--password** takes the client secret:

    **Bash**

    ```bash
    az login --service-principal --username "$AZURE_CLIENT_ID" \
      --password "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID"
    ```

    **PowerShell**

    ```powershell
    az login --service-principal --username $AZURE_CLIENT_ID `
      --password $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
    ```

3. Verify the signed-in identity and list the resources of the resource group:

    **Bash**

    ```bash
    az account show --query "{subscription:name, user:user.name, type:user.type}" --output table
    az resource list --resource-group "$RG" --output table
    ```

    **PowerShell**

    ```powershell
    az account show --query "{subscription:name, user:user.name, type:user.type}" --output table
    az resource list --resource-group $RG --output table
    ```

    Note that **user.name** shows the client ID of the service principal and **user.type** shows **servicePrincipal**.

### Task 2: Test the limits of the role assignment

1. Try to create a new resource group. The command fails with **AuthorizationFailed**, because the service principal has no permission at the subscription scope:

    **Bash**

    ```bash
    az group create --name "rg-${STUDENT}-test" --location "$LOCATION"
    ```

    **PowerShell**

    ```powershell
    az group create --name "rg-$STUDENT-test" --location $LOCATION
    ```

2. Try to assign the **Reader** role on the resource group to the service principal itself, identified by its client ID (`<client-id>`). The command fails, because the **Contributor** role does not allow role assignments:

    **Bash**

    ```bash
    az role assignment create --assignee "$AZURE_CLIENT_ID" --role Reader --resource-group "$RG"
    ```

    **PowerShell**

    ```powershell
    az role assignment create --assignee $AZURE_CLIENT_ID --role Reader --resource-group $RG
    ```

3. Sign out of the service principal and sign in again with the user account. This step is the same in both shells:

    ```bash
    az logout
    az login
    az account set --subscription "<subscription-id>"
    ```

    > [!NOTE]
    > This is the identity that the pipelines use from Lab 06 onward. Its secret is stored only as a GitHub secret or in an Azure DevOps service connection, never in a file of a repository.

4. Remove the client secret from the terminal session:

    **Bash**

    ```bash
    unset AZURE_CLIENT_SECRET
    ```

    **PowerShell**

    ```powershell
    Remove-Variable AZURE_CLIENT_SECRET, SecureSecret
    ```

## Exercise 6: Clean up the resources

The exercise consists of the following tasks:

- Task 1: Delete the lab resources

### Task 1: Delete the lab resources

1. Delete the virtual machine:

    **Bash**

    ```bash
    az vm delete --resource-group "$RG" --name vm-lab03 --yes
    ```

    **PowerShell**

    ```powershell
    az vm delete --resource-group $RG --name vm-lab03 --yes
    ```

2. Delete the network interface, the public IP address, and the OS disk that remain after the virtual machine is deleted:

    **Bash**

    ```bash
    for type in Microsoft.Network/networkInterfaces Microsoft.Network/publicIPAddresses Microsoft.Compute/disks; do
      az resource list --resource-group "$RG" --resource-type "$type" \
        --query "[?contains(name, 'vm-lab03')].id" --output tsv |
      while read -r id; do az resource delete --ids "$id"; done
    done
    ```

    **PowerShell**

    ```powershell
    $types = "Microsoft.Network/networkInterfaces", "Microsoft.Network/publicIPAddresses", "Microsoft.Compute/disks"
    foreach ($type in $types) {
      $ids = az resource list --resource-group $RG --resource-type $type `
        --query "[?contains(name, 'vm-lab03')].id" --output tsv
      foreach ($id in $ids) { az resource delete --ids $id }
    }
    ```

3. Delete the virtual network, the network security group, and the storage account:

    **Bash**

    ```bash
    az network vnet delete --resource-group "$RG" --name vnet-lab03
    az network nsg delete --resource-group "$RG" --name nsg-web-lab03
    az storage account delete --resource-group "$RG" --name "$ST" --yes
    ```

    **PowerShell**

    ```powershell
    az network vnet delete --resource-group $RG --name vnet-lab03
    az network nsg delete --resource-group $RG --name nsg-web-lab03
    az storage account delete --resource-group $RG --name $ST --yes
    ```

4. Verify that no resource with the tag **lab=03** remains:

    **Bash**

    ```bash
    az resource list --resource-group "$RG" --query "[?tags.lab=='03'].name" --output table
    ```

    **PowerShell**

    ```powershell
    az resource list --resource-group $RG --query "[?tags.lab=='03'].name" --output table
    ```

    > [!IMPORTANT]
    > Do not delete the resource group itself. It belongs to the course environment and is used by every following lab.

## Review

The following table summarizes the Azure CLI commands practiced in this lab. Lab 04 creates the same kind of resources with Terraform.

| Task | Azure CLI command |
|---|---|
| Sign in (user, service principal) | `az login`, `az login --service-principal` |
| Select the subscription | `az account set --subscription <subscription-id>` |
| Filter and format output | `--query "<JMESPath>"`, `--output table` or `tsv` |
| Virtual network and subnets | `az network vnet create`, `az network vnet subnet create` |
| Network security group and rule | `az network nsg create`, `az network nsg rule create` |
| Storage account and container | `az storage account create`, `az storage container create --auth-mode key` |
| Linux virtual machine | `az vm create --image Ubuntu2404 --size Standard_B1s --ssh-key-values <file>` |
| Clean up | `az vm delete`, `az resource delete`, `az network vnet delete` |

The following table summarizes the shell differences used in this lab:

| Action | Bash | PowerShell |
|---|---|---|
| Define a variable | `RG="rg-lab"` | `$RG = "rg-lab"` |
| List of tags | `TAGS="a=1 b=2"` and `--tags $TAGS` | `$TAGS = @("a=1", "b=2")` and `--tags $TAGS` |
| Store command output | `VM_IP=$(az ... -o tsv)` | `$VM_IP = az ... -o tsv` |
| Call a web service | `curl -s <url>` | `Invoke-RestMethod -Uri <url>` |
| Random number | `$RANDOM` | `Get-Random -Maximum 32768` |
| Read a secret | `read -s -p "Prompt: " VAR` | `Read-Host "Prompt" -AsSecureString` |
| Loop over results | `... \| while read -r id; do ...; done` | `foreach ($id in $ids) { ... }` |
