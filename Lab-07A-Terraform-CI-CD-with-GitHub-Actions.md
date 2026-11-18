# Lab 07 - Terraform CI/CD with GitHub Actions

**Estimated timing:** 100 minutes

## Prerequisites

- Completion of **Lab 05** (the state storage account **sttfstate\<student\>\<digits\>** exists) and **Lab 06** (the GitHub CLI is installed and signed in).
- The lab values from the lab environment setup: **AZURE_SUBSCRIPTION_ID**, **AZURE_TENANT_ID**, **AZURE_CLIENT_ID**, **AZURE_CLIENT_SECRET**, and the resource group **rg-\<student\>-usa**.
- One of the following terminals:
  - **Bash**: **Terminal** on macOS, a Linux shell, or **Git Bash** on Windows.
  - **PowerShell**: **Windows PowerShell 5.1** or **PowerShell 7** on Windows.
- The lab files folders **labfiles/lab07** and **labfiles/shared**.

## Objectives

This lab covers the following objectives:

- Store service principal credentials as GitHub secrets and lab values as variables
- Protect the deployment with an environment that requires approval
- Protect the main branch with a ruleset and a required status check
- Review a Terraform plan posted as a pull request comment
- Apply a saved plan after approval
- Detect drift with a scheduled workflow and correct it
- Destroy the resources with a protected manual workflow

The repository contains the Terraform code in **infra** (a virtual network with subnets created with for_each, and a storage account) and four workflows in **.github/workflows**: **terraform-ci**, **terraform-cd**, **terraform-drift**, and **terraform-destroy**. The state is kept in the state storage account created in Lab 05, with the key **lab07.tfstate**.

## Choose your shell

The **git**, **gh**, **terraform**, and **az** commands are the same in every shell. When the commands differ, each step shows a **Bash** block and a **PowerShell** block. Run only the block for your shell, and use the same shell for the whole lab.

| Action | Bash (macOS, Linux, Git Bash) | PowerShell (Windows) |
|---|---|---|
| Copy a folder | `cp -r source target` | `Copy-Item -Recurse -Force source target` |
| Home folder in a path | `~/source` | `"$HOME/source"` |
| Load the values file | `source ~/.devops-lab-values.env` | See Exercise 1, Task 3 |
| Store a command result | `VAR=$(command)` | `$VAR = command` |
| Read an environment variable | `$TF_STATE_ACCOUNT` | `$env:TF_STATE_ACCOUNT` |
| Replace text in a file | `sed -i 's#old#new#' file` | `(Get-Content file) -replace 'old','new' \| Set-Content file` |
| Run two commands in a row | `command1 && command2` | Run each command on its own line |

## Exercise 1: Prepare the repository

The exercise consists of the following tasks:

- Task 1: Review the workflows
- Task 2: Create the repository without pushing
- Task 3: Store the secrets and the variables
- Task 4: Create the dev environment

### Task 1: Review the workflows

1. Open the **labfiles/lab07** folder in Visual Studio Code and review **.github/workflows/terraform-ci.yml**:
    - The trigger is **pull_request** to **main** for changes in **infra**.
    - The workflow-level **env** maps the secrets to the **ARM_\*** variables read by the azurerm provider and backend, and the variables to **TF_VAR_\*** input variables.
    - **concurrency: group: terraform-state** lets only one Terraform run at a time use the state.
    - The job **Validate and plan** runs fmt, init with **-backend-config**, validate, and plan, and posts the plan as a pull request comment with **gh pr comment**.

2. Review **terraform-cd.yml**:
    - The trigger is **push** to **main** for changes in **infra** (a merged pull request), or a manual run.
    - The job **Plan** uses **-detailed-exitcode** (0 no changes, 1 error, 2 changes) and uploads the saved plan **tfplan** as an artifact.
    - The job **Apply** runs only when changes exist, uses **environment: dev** (the approval), downloads the artifact, and applies exactly the saved plan.

3. Review **drift.yml** (a weekly **schedule** and a manual run that opens an issue when drift is found) and **destroy.yml** (a manual run that requires the input **destroy** and the approval of the **dev** environment).

### Task 2: Create the repository without pushing

1. Copy the lab files to a new working folder and create the first commit. Replace **\<path-to\>** with the location of the lab files:

    **Bash**

    ```bash
    mkdir -p ~/source
    cp -r <path-to>/labfiles/lab07 ~/source/devops-lab07
    cd ~/source/devops-lab07
    git init -b main
    git add .
    git commit -m "Add lab 07 files"
    ```

    **PowerShell**

    ```powershell
    New-Item -ItemType Directory -Force -Path "$HOME/source" | Out-Null
    Copy-Item -Recurse -Force <path-to>/labfiles/lab07 "$HOME/source/devops-lab07"
    Set-Location "$HOME/source/devops-lab07"
    git init -b main
    git add .
    git commit -m "Add lab 07 files"
    ```

2. Create the public repository on GitHub and connect it as **origin**, without pushing yet. A push to **main** starts **terraform-cd**, which needs the secrets first. This command is the same in both shells:

    ```bash
    gh repo create devops-lab07 --public --source=. --remote=origin
    ```

### Task 3: Store the secrets and the variables

1. Find the name of the state storage account created in Lab 05. This command is the same in both shells:

    ```bash
    az storage account list --resource-group rg-student01-usa --query "[?starts_with(name, 'sttfstate')].name" -o tsv
    ```

2. Create a values file outside every repository folder, restrict its permissions, and open it:

    **Bash**

    ```bash
    touch ~/.devops-lab-values.env && chmod 600 ~/.devops-lab-values.env
    code ~/.devops-lab-values.env
    ```

    **PowerShell**

    ```powershell
    $VALUES = "$HOME/.devops-lab-values.env"
    New-Item -ItemType File -Force -Path $VALUES | Out-Null
    icacls $VALUES /inheritance:r /grant:r "$($env:USERNAME):F" | Out-Null
    code $VALUES
    ```

3. Fill in the lab values and save the file. The content is the same for both shells:

    ```bash
    export AZURE_SUBSCRIPTION_ID="<subscription-id>"
    export AZURE_TENANT_ID="<tenant-id>"
    export AZURE_CLIENT_ID="<client-id>"
    export AZURE_CLIENT_SECRET="<client-secret>"
    export AZURE_RESOURCE_GROUP="rg-student01-usa"
    export PREFIX="student01"
    export TF_STATE_ACCOUNT="sttfstatestudent0112345"
    ```

4. Load the values and run the shared script. The script stores four secrets and three variables in the repository:

    **Bash**

    ```bash
    source ~/.devops-lab-values.env
    export REPO="$(gh api user -q .login)/devops-lab07"
    bash <path-to>/labfiles/shared/gh-set-lab-values.sh
    ```

    **PowerShell**: the shared script runs only in Bash, so PowerShell starts it with Git Bash. Replace **\<path-to\>** with the location of the lab files, written with forward slashes (for example **C:/labs**):

    ```powershell
    $REPO = "$(gh api user -q .login)/devops-lab07"
    & "C:\Program Files\Git\bin\bash.exe" -c "source ~/.devops-lab-values.env && export REPO=$REPO && bash '<path-to>/labfiles/shared/gh-set-lab-values.sh'"
    ```

5. **PowerShell only**: load the values file into the current terminal, so that later steps can read **$env:TF_STATE_ACCOUNT**:

    ```powershell
    Get-Content "$HOME/.devops-lab-values.env" | ForEach-Object {
      if ($_ -match '^\s*(export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
        Set-Item -Path "env:$($Matches[2])" -Value $Matches[3].Trim().Trim('"').Trim("'")
      }
    }
    $env:TF_STATE_ACCOUNT
    ```

    > [!NOTE]
    > This is the PowerShell counterpart of **source ~/.devops-lab-values.env**. It reads every **NAME=value** line of the file and sets it as an environment variable of the current terminal.

6. Verify the result in the output, or on GitHub under **Settings** > **Secrets and variables** > **Actions**: the secrets **AZURE_CLIENT_ID**, **AZURE_CLIENT_SECRET**, **AZURE_SUBSCRIPTION_ID**, **AZURE_TENANT_ID**, and the variables **PREFIX**, **RESOURCE_GROUP**, **TF_STATE_ACCOUNT**.

> [!IMPORTANT]
> The values file stays outside every repository and is never committed. Lab 08 uses the same file.

### Task 4: Create the dev environment

1. On GitHub, open the repository **Settings** and select **Environments** > **New environment**. Enter **dev** and select **Configure environment**.

2. Select **Required reviewers**, add your own GitHub user name, and select **Save protection rules**.

3. Under **Deployment branches and tags**, select **Selected branches and tags**, select **Add deployment branch or tag rule**, enter **main**, and select **Add rule**.

> [!NOTE]
> Required reviewers are free on public repositories. In a team, the reviewers are other people and **Prevent self-review** is selected.

## Exercise 2: Run the first deployment

The exercise consists of the following tasks:

- Task 1: Push the code
- Task 2: Approve and verify the deployment

### Task 1: Push the code

1. Push the main branch:

    ```bash
    git push -u origin main
    ```

2. On the **Actions** tab, open the run of **terraform-cd**. Wait for the job **Plan** to finish.

3. Open the run summary page and review the plan written to the job summary: **5 to add** (the random string, the virtual network, two subnets, and the storage account).

4. Note that the job **Apply** shows **Waiting** and the message **Review pending deployments**.

### Task 2: Approve and verify the deployment

1. Select **Review deployments**, select **dev**, optionally enter a comment, and select **Approve and deploy**.

2. Wait for the job **Apply** to finish and review the step **Show outputs**.

3. Verify the resources with the Azure CLI. This command is the same in both shells:

    ```bash
    az resource list --resource-group rg-student01-usa --query "[?tags.lab=='07'].{name:name, type:type}" -o table
    ```

4. Verify that the state blob exists:

    **Bash**

    ```bash
    az storage blob list --account-name $TF_STATE_ACCOUNT --container-name tfstate --auth-mode key --query "[].name" -o tsv
    ```

    **PowerShell**

    ```powershell
    az storage blob list --account-name $env:TF_STATE_ACCOUNT --container-name tfstate --auth-mode key --query "[].name" -o tsv
    ```

5. On the repository home page, select **Deployments** (right column) and note the deployment history of **dev**.

## Exercise 3: Protect the main branch

The exercise consists of the following tasks:

- Task 1: Create a branch ruleset

### Task 1: Create a branch ruleset

1. Open the repository **Settings** and select **Rules** > **Rulesets** > **New ruleset** > **New branch ruleset**.

2. Configure the ruleset with the following settings and select **Create**:
    - **Ruleset name**: **protect-main**; **Enforcement status**: **Active**.
    - **Target branches**: **Add target** > **Include default branch**.
    - **Restrict deletions** and **Block force pushes**: selected.
    - **Require a pull request before merging**: selected, with **Required approvals** set to **0** for a single learner.
    - **Require status checks to pass**: selected. Select **Add checks**, type **Validate and plan**, and add it. The check has not run yet, so it is added by name.

3. Verify that a direct push to main is rejected. These commands are the same in both shells:

    ```bash
    git commit --allow-empty -m "Direct push test"
    git push
    git reset --hard HEAD~1
    ```

4. Note the message **Changes must be made through a pull request** in the output of the push.

> [!NOTE]
> A required check that a **paths** filter skips stays pending and blocks the merge. In this repository, every pull request that matters changes **infra**. In larger repositories, the check workflow runs on every pull request.

## Exercise 4: Change the infrastructure with a pull request

The exercise consists of the following tasks:

- Task 1: Create the change
- Task 2: Review the plan comment
- Task 3: Merge, approve, and apply

### Task 1: Create the change

1. Create a branch:

    ```bash
    git switch -c add-app-subnet
    ```

2. In **infra/variables.tf**, add a third subnet to the default value of **subnets** and save the file:

    ```hcl
    default = {
      web  = 1
      data = 2
      app  = 3
    }
    ```

3. Run the same checks locally before pushing. These commands are the same in both shells:

    ```bash
    terraform -chdir=infra fmt -check -recursive
    terraform -chdir=infra init -backend=false -input=false
    terraform -chdir=infra validate
    ```

4. Commit, push, and open a pull request:

    ```bash
    git commit -am "Add app subnet"
    git push -u origin add-app-subnet
    gh pr create --title "Add app subnet" --body "Adds snet-app (10.40.3.0/24)."
    ```

### Task 2: Review the plan comment

1. Open the pull request on GitHub and wait for the check **terraform-ci / Validate and plan**.

2. Review the comment posted by **github-actions**. Verify that the plan adds exactly one resource, **azurerm_subnet.this["app"]**, and changes or destroys nothing.

3. Note that the merge button is available only after the required check passes.

> [!NOTE]
> Optional peer review: in **Settings** > **Collaborators**, invite a study peer, and request a review from the peer on the pull request. The peer reads the plan comment and approves or requests changes.

### Task 3: Merge, approve, and apply

1. Merge the pull request with **Squash and merge** and delete the branch.

2. On the **Actions** tab, open the new run of **terraform-cd**. When the job **Apply** waits, approve the **dev** deployment.

3. Verify the new subnet. This command is the same in both shells:

    ```bash
    az network vnet subnet list --resource-group rg-student01-usa --vnet-name vnet-student01-lab07 --query "[].{name:name, prefix:addressPrefix}" -o table
    ```

4. Update the local main branch:

    **Bash**

    ```bash
    git switch main && git pull
    ```

    **PowerShell**

    ```powershell
    git switch main
    git pull
    ```

## Exercise 5: Block a broken change

The exercise consists of the following tasks:

- Task 1: Open a pull request that fails the check

### Task 1: Open a pull request that fails the check

1. Create a branch that changes the default of **address_space** in **infra/variables.tf** to an invalid value, and open a pull request:

    **Bash**

    ```bash
    git switch -c broken-change
    sed -i.bak 's#10.40.0.0/16#10.40.0.0/33#' infra/variables.tf && rm infra/variables.tf.bak
    git commit -am "Invalid address space"
    git push -u origin broken-change
    gh pr create --fill
    ```

    **PowerShell**

    ```powershell
    git switch -c broken-change
    (Get-Content infra/variables.tf) -replace '10\.40\.0\.0/16','10.40.0.0/33' | Set-Content infra/variables.tf
    git commit -am "Invalid address space"
    git push -u origin broken-change
    gh pr create --fill
    ```

2. Wait for the check and verify that **Validate and plan** fails in the step **Plan** with an error about the invalid CIDR address.

3. Note that the pull request shows **Merging is blocked** because the required check failed. The broken code never reaches main and never runs against Azure with an apply.

4. Close the pull request and delete the branch:

    ```bash
    gh pr close broken-change --delete-branch
    git switch main
    ```

## Exercise 6: Detect and correct drift

The exercise consists of the following tasks:

- Task 1: Change a resource outside Terraform
- Task 2: Run the drift workflow
- Task 3: Correct the drift

### Task 1: Change a resource outside Terraform

1. Add a tag to the virtual network outside Terraform. This simulates a change made in the Azure portal:

    **Bash**

    ```bash
    VNET_ID=$(az network vnet show -g rg-student01-usa -n vnet-student01-lab07 --query id -o tsv)
    az tag update --resource-id "$VNET_ID" --operation Merge --tags changed_by=portal
    ```

    **PowerShell**

    ```powershell
    $VNET_ID = az network vnet show -g rg-student01-usa -n vnet-student01-lab07 --query id -o tsv
    az tag update --resource-id "$VNET_ID" --operation Merge --tags changed_by=portal
    ```

### Task 2: Run the drift workflow

1. Run **terraform-drift** manually. These commands are the same in both shells:

    ```bash
    gh workflow run terraform-drift
    gh run watch
    ```

2. Note that the step **Plan with detailed exit code** returns **2** (changes present) and that the next step runs.

3. Open the **Issues** tab and review the issue **Terraform drift detected**. The plan shows that Terraform wants to remove the tag **changed_by** from the virtual network.

> [!NOTE]
> The workflow also runs every Monday at 06:00 UTC (**cron: "0 6 \* \* 1"**). Scheduled workflows of public repositories are disabled after 60 days without activity.

### Task 3: Correct the drift

1. Run **terraform-cd** manually. The code is the source of truth, so the plan removes the tag:

    ```bash
    gh workflow run terraform-cd
    ```

2. Approve the **dev** deployment and wait for the apply.

3. Run **terraform-drift** again and verify that the plan returns **0** and that no new issue is created. Close the drift issue. Replace **\<number\>** with the issue number:

    ```bash
    gh issue list
    gh issue close <number> --comment "Corrected by terraform-cd"
    ```

> [!NOTE]
> When the manual change is wanted, the fix is the opposite: add the tag to the code with a pull request.

## Exercise 7: Destroy the resources

The exercise consists of the following tasks:

- Task 1: Run the destroy workflow

### Task 1: Run the destroy workflow

1. Run **terraform-destroy** from the **Actions** tab. In the **confirm** box, type **destroy** and select **Run workflow**.

2. Approve the **dev** deployment and wait for the job **Destroy** to finish.

3. Verify that no resource with the tag **lab=07** remains. This command is the same in both shells:

    ```bash
    az resource list --resource-group rg-student01-usa --query "[?tags.lab=='07'].name" -o tsv
    ```

    > [!NOTE]
    > Any other value in the **confirm** box skips the job, so a mistyped run destroys nothing.

4. Disable the scheduled drift workflow and delete the secrets, so that the credentials exist in as few places as possible:

    **Bash**

    ```bash
    gh workflow disable terraform-drift
    for s in AZURE_CLIENT_ID AZURE_CLIENT_SECRET AZURE_TENANT_ID AZURE_SUBSCRIPTION_ID; do gh secret delete "$s"; done
    ```

    **PowerShell**

    ```powershell
    gh workflow disable terraform-drift
    foreach ($s in "AZURE_CLIENT_ID","AZURE_CLIENT_SECRET","AZURE_TENANT_ID","AZURE_SUBSCRIPTION_ID") { gh secret delete $s }
    ```

> [!IMPORTANT]
> Keep the state storage account: Lab 09 uses it again with the key **lab09.tfstate**. Keep the repository as a reference.

## Review

The following table summarizes the protections of the delivery flow built in this lab.

| Protection | Where | Effect |
|---|---|---|
| Secrets | Repository secrets | Credentials never in code or logs |
| Required status check | Ruleset **protect-main** | Broken code cannot be merged |
| Plan comment | terraform-ci | Reviewers see the effect before the merge |
| Saved plan | Artifact **tfplan** | The apply makes exactly the reviewed changes |
| Required reviewers | Environment **dev** | A person approves every apply and destroy |
| Concurrency group | All four workflows | One run at a time uses the state |
| Drift detection | terraform-drift | Manual changes become visible as issues |
