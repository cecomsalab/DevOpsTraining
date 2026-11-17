# Lab 06 - YAML and GitHub Actions

**Estimated timing:** 100 minutes

## Prerequisites

- Completion of **Lab 02B - GitHub Flow of Work**: a GitHub account, Git, and Visual Studio Code are ready.
- The lab values from the lab environment setup: **AZURE_CREDENTIALS** (JSON) and the resource group **rg-\<student\>-usa**.
- One of the following terminals:
  - **Bash**: **Terminal** on macOS, a Linux shell, or **Git Bash** on Windows.
  - **PowerShell**: **Windows PowerShell 5.1** or **PowerShell 7** on Windows.
- The lab files folder **labfiles/lab06**.

## Objectives

This lab covers the following objectives:

- Read and write YAML: scalars, maps, lists, lists of maps, and multiline strings
- Find and fix the most common YAML mistakes
- Run workflows manually and from push and pull request events
- Order jobs with needs, pass job outputs, and use a matrix
- Use environment variables, repository variables, and secrets
- Sign in to Azure from a workflow with a service principal
- Call a reusable workflow that checks Terraform code

The lab adds one concept at a time. Each workflow file in **.github/workflows** starts with a comment that names the step and the concept it adds.

## Choose your shell

The **git** and **gh** commands are the same in every shell. Only a few file commands are different. When the commands differ, each step shows a **Bash** block and a **PowerShell** block. Run only the block for your shell.

| Action | Bash (macOS, Linux, Git Bash) | PowerShell (Windows) |
|---|---|---|
| Create a folder | `mkdir -p ~/source` | `New-Item -ItemType Directory -Force "$HOME/source"` |
| Copy a folder | `cp -r source target` | `Copy-Item -Recurse -Force source target` |
| List all files, including hidden ones | `ls -a` | `Get-ChildItem -Force` |
| Send a file to a command | `command < file` | `Get-Content file -Raw \| command` |

> [!NOTE]
> The commands inside the workflow files run on GitHub runners, not on your computer, so they do not depend on your shell.

## Exercise 1: Learn YAML step by step

The exercise consists of the following tasks:

- Task 1: Install the YAML extension
- Task 2: Compare YAML with JSON
- Task 3: Edit the YAML file
- Task 4: Fix a broken workflow file

### Task 1: Install the YAML extension

1. Start Visual Studio Code and open the **labfiles/lab06** folder.

2. Open the **Extensions** view, search for **YAML**, and install the extension published by **Red Hat**. Search for **GitHub Actions** and install the extension published by **GitHub**.

    > [!NOTE]
    > The Red Hat extension reports syntax errors as red underlines. The GitHub Actions extension validates workflow keys and shows the documentation of actions on hover.

### Task 2: Compare YAML with JSON

1. Open **yaml-practice/team.yaml** and **yaml-practice/team.json** side by side (right-click the JSON tab and select **Split Right**).

2. Compare the six numbered sections and note the rules:

    - **Scalars**: **key: value**, with one space after the colon. Quotes are optional, but **"2026-11-02"** stays a string only with quotes.
    - **Maps**: child keys are indented with spaces (two spaces in this course). Tabs are not allowed.
    - **Lists**: one item per line, each item starts with a dash and a space.
    - **Lists of maps**: the dash starts a new item, and the keys of the item line up under the first key. Workflow steps use this shape.
    - **Flow style**: **[a, b]** and **{ k: v }** are the JSON-like inline forms.
    - **Multiline strings**: **|** keeps line breaks (scripts), **>** folds lines into one line.

3. Answer the following question: which JSON characters does YAML replace with indentation?

    <details>
    <summary>Show the answer</summary>

    The braces, the brackets, and most commas and quotes.

    </details>

### Task 3: Edit the YAML file

1. In **team.yaml**, add **- github-cli** as the fourth item of **tools**.

2. Add a third member to **members** with the name **Mia** and the role **monitoring**. Line up **role** under **name**.

3. Indent the new **role** line with one extra space and note the error reported by the extension. Remove the extra space.

4. Replace the two spaces before **cloud: Azure** with a tab character and note the error. Restore the two spaces.

    > [!NOTE]
    > Most YAML errors are indentation errors. Turn on **View** > **Render Whitespace** in Visual Studio Code to see spaces and tabs.

### Task 4: Fix a broken workflow file

1. Open **yaml-practice/broken-workflow.yml**. The file contains four mistakes. The file is outside **.github/workflows**, so GitHub never runs it.

2. Find and fix the four mistakes. Use the red underlines as hints.

3. Compare the result with **solution/fixed-workflow.yml**.

    <details>
    <summary>Show the four mistakes</summary>

    - **runs-on:ubuntu-latest** has no space after the colon, so YAML reads one string instead of a key and a value.
    - The second step is indented one space more than the first step, so the list items do not line up.
    - **echo Message: done** contains a colon followed by a space inside a value; the value needs quotes.
    - **shell bash** has no colon, so it is not a key.

    </details>

## Exercise 2: Create the lab repository

The exercise consists of the following tasks:

- Task 1: Install and sign in to the GitHub CLI
- Task 2: Create a public repository with the lab files

### Task 1: Install and sign in to the GitHub CLI

1. Check whether the GitHub CLI is installed:

    ```bash
    gh --version
    ```

2. If the command is not found, install the GitHub CLI and open a new terminal:

    **Windows (PowerShell)**

    ```powershell
    winget install --id GitHub.cli
    ```

    **macOS (Bash)**

    ```bash
    brew install gh
    ```

    **Linux**: follow the instructions at https://github.com/cli/cli#installation.

3. Sign in and follow the prompts (**GitHub.com**, **HTTPS**, **Login with a web browser**):

    ```bash
    gh auth login
    gh auth status
    ```

### Task 2: Create a public repository with the lab files

1. Copy the lab files, including the hidden **.github** folder, to a new working folder. Replace **\<path-to\>** with the location of the lab files:

    **Bash**

    ```bash
    mkdir -p ~/source && cp -r <path-to>/labfiles/lab06 ~/source/devops-lab06
    cd ~/source/devops-lab06
    ls -a
    ```

    **PowerShell**

    ```powershell
    New-Item -ItemType Directory -Force -Path "$HOME/source" | Out-Null
    Copy-Item -Recurse -Force <path-to>/labfiles/lab06 "$HOME/source/devops-lab06"
    Set-Location "$HOME/source/devops-lab06"
    Get-ChildItem -Force
    ```

    Verify that the **.github** folder appears in the list.

2. Create the local repository and the first commit:

    ```bash
    git init -b main
    git add .
    git commit -m "Add lab 06 files"
    ```

3. Create the public repository on GitHub and push the commit in one command:

    ```bash
    gh repo create devops-lab06 --public --source=. --remote=origin --push
    ```

4. Open the repository in the browser and select the **Actions** tab. Note the list of workflows on the left: **01 Hello** to **07 Terraform check**, and **Reusable Terraform check**.

    ```bash
    gh repo view --web
    ```

    > [!IMPORTANT]
    > The repository is public. Secrets are stored only as GitHub secrets (Exercise 5) and never in a file of the repository.

## Exercise 3: Run the first workflows

The exercise consists of the following tasks:

- Task 1: Run the hello workflow and read the log
- Task 2: Run a workflow with inputs
- Task 3: Trigger a workflow with push and pull request events

### Task 1: Run the hello workflow and read the log

1. In Visual Studio Code, open **.github/workflows/01-hello.yml** and identify the four levels: **name**, **on** (the event), **jobs** (one job named **hello**), and **steps** (two steps).

2. On GitHub, on the **Actions** tab, select **01 Hello**, select **Run workflow**, keep the branch **main**, and select **Run workflow** again.

3. Select the new run, select the job **hello**, and expand each step. Note the steps added by GitHub: **Set up job** and **Complete job**.

4. In the step **Show where the job runs**, note the operating system of the runner and the working folder.

### Task 2: Run a workflow with inputs

1. Open **02-triggers-and-inputs.yml** and note the three events under **on**: **push** (only for changes in **yaml-practice**), **pull_request**, and **workflow_dispatch** with two inputs.

2. Note how the step **Show the event information** reads contexts with **${{ }}** in **env** and uses them in the script as normal environment variables.

3. Run **02 Triggers and inputs** from the **Actions** tab. In the **Run workflow** panel, select **test** as the environment, clear **dry_run**, and run it.

4. Open the log and verify the event **workflow_dispatch**, the environment **test**, and dry run **false**. Note that the step **Runs only for pull requests** shows as skipped.

5. Run the same workflow from the terminal. These commands are the same in both shells:

    ```bash
    gh workflow run "02 Triggers and inputs" -f environment=prod -f dry_run=true
    gh run list --limit 3
    gh run watch
    ```

### Task 3: Trigger a workflow with push and pull request events

1. In the repository folder, open **yaml-practice/team.yaml** and add **- docker** as the last item of **tools**. Commit and push the change. The push matches the **paths** filter, so the workflow starts:

    ```bash
    git add yaml-practice/team.yaml
    git commit -m "Add docker to tools"
    git push
    ```

2. On the **Actions** tab, verify that **02 Triggers and inputs** ran with the event **push** and that **01 Hello** did not run.

3. Create a branch:

    ```bash
    git switch -c yaml-change
    ```

4. In Visual Studio Code, change the text of the folded block (**>**) in **yaml-practice/team.yaml** and save the file.

5. Commit the change, push the branch, and open a pull request:

    ```bash
    git commit -am "Change folded block"
    git push -u origin yaml-change
    gh pr create --fill
    ```

6. On the pull request page, note the check **02 Triggers and inputs / show-context**. Open its log and verify that the step **Runs only for pull requests** ran this time.

7. Merge the pull request and update the local main branch:

    ```bash
    gh pr merge --squash --delete-branch
    git switch main
    git pull
    ```

## Exercise 4: Use several jobs and a matrix

The exercise consists of the following tasks:

- Task 1: Order jobs and pass outputs
- Task 2: Run a matrix

### Task 1: Order jobs and pass outputs

1. Open **03-jobs-and-needs.yml** and review the following parts:

    - The **build** job writes **value=1.0.\<run number\>** to **$GITHUB_OUTPUT** in the step with **id: version**, and exposes it as the job output **version**.
    - **test** and **lint** both have **needs: build**, so they run in parallel after **build**.
    - **report** has **needs: [test, lint]** and **if: always()**, so it runs last, even after a failure.
    - Every job runs on a new runner. Jobs share data only through outputs or artifacts.

2. Run **03 Jobs and needs**. On the run page, note the graph with **build**, then **test** and **lint**, then **report**.

3. Scroll down on the run summary page and note the **Results** table written by **report** to **$GITHUB_STEP_SUMMARY**.

### Task 2: Run a matrix

1. Open **04-matrix.yml** and calculate the number of jobs: 2 operating systems times 2 Terraform versions, plus 1 combination added with **include**.

    <details>
    <summary>Show the answer</summary>

    5 jobs.

    </details>

2. Run **04 Matrix** and verify that five jobs run in parallel, each with its own name built from the matrix values.

3. Note **fail-fast: false**: when one combination fails, the others continue.

    > [!NOTE]
    > Standard GitHub-hosted runners are free for public repositories. For private repositories, Windows and macOS minutes count with a multiplier.

## Exercise 5: Use variables, secrets, and the Azure sign-in

The exercise consists of the following tasks:

- Task 1: Create a repository variable and a secret
- Task 2: Read the values in a workflow
- Task 3: Sign in to Azure from a workflow

### Task 1: Create a repository variable and a secret

1. On GitHub, open the repository **Settings**, and select **Secrets and variables** > **Actions**.

2. Select the **Variables** tab, select **New repository variable**, enter the name **PREFIX** and the student name as the value, and select **Add variable**.

3. Select the **Secrets** tab, select **New repository secret**, enter the name **DEMO_SECRET** and the value **not-a-real-password**, and select **Add secret**.

4. Note that the value of a secret is never displayed again, not even to the owner of the repository. It can only be replaced or deleted.

### Task 2: Read the values in a workflow

1. Open **05-variables-and-secrets.yml** and note the three levels of **env**: workflow (**COURSE**), job (**MODULE**), and step (**STEP_NOTE**).

2. Note the contexts: **vars.PREFIX** reads the variable, **secrets.DEMO_SECRET** reads the secret, **steps.calc.outputs.result** reads a step output.

3. Run **05 Variables and secrets** and open the log. Verify the following results:

    - The first step prints **devops / 06 / step level**.
    - The prefix is printed in clear text.
    - The secret is printed as **\*\*\***, while its length is printed as a number. GitHub masks secret values in logs.
    - The last step prints the date written to **$GITHUB_ENV** and the result written to **$GITHUB_OUTPUT**.

    > [!IMPORTANT]
    > Masking is a safety net, not a reason to print secrets. Transformed values (for example encoded with base64) are not masked.

### Task 3: Sign in to Azure from a workflow

1. Store the service principal credentials as a secret. On the **Secrets** tab, select **New repository secret**, enter the name **AZURE_CREDENTIALS**, paste the complete **AZURE_CREDENTIALS** JSON from the lab values, including the braces, and select **Add secret**.

    > [!NOTE]
    > The GitHub CLI alternative reads the value from a file or from standard input. Delete the file afterward. Values typed directly in a command line stay in the shell history.
    >
    > - **Bash**: `gh secret set AZURE_CREDENTIALS < creds.json`
    > - **PowerShell**: `Get-Content creds.json -Raw | gh secret set AZURE_CREDENTIALS`

2. Store the resource group as a variable, and list the secrets and variables. Replace **student01** with the student name:

    ```bash
    gh variable set RESOURCE_GROUP --body "rg-student01-usa"
    gh secret list
    gh variable list
    ```

3. Open **06-azure-login.yml** and note the following parts:

    - **permissions: contents: read** gives the **GITHUB_TOKEN** of the run only read access.
    - **azure/login@v3** with **creds: ${{ secrets.AZURE_CREDENTIALS }}** signs in the Azure CLI with the service principal.
    - The next step runs normal **az** commands, as in Lab 03.

4. Run **06 Azure login** and verify that the log shows the subscription, the service principal as the user, and the resource group in **southcentralus**.

    > [!NOTE]
    > The service principal has Contributor on the resource group only. The command **az group list** would show only this resource group.

## Exercise 6: Call a reusable workflow

The exercise consists of the following tasks:

- Task 1: Review and run the reusable workflow
- Task 2: Break and fix the check in a pull request

### Task 1: Review and run the reusable workflow

1. Open **reusable-terraform-check.yml** and note **on: workflow_call** with two inputs. The workflow runs only when another workflow calls it.

2. Note **defaults.run.working-directory**, which sets the folder for every **run** step, and the three checks: **fmt -check**, **init -backend=false**, and **validate**. No Azure sign-in is needed.

3. Open **07-call-reusable.yml** and note that the job has no **runs-on** and no **steps**, only **uses:** with the path of the reusable workflow and **with:** for the inputs.

4. Run **07 Terraform check** and verify that the job is named **infra / check** and that the three checks pass.

### Task 2: Break and fix the check in a pull request

1. Create a branch:

    ```bash
    git switch -c format-test
    ```

2. Break the formatting of the Terraform code by adding extra spaces after **name** in **infra/main.tf**:

    **Bash**

    ```bash
    sed -i.bak 's/^  name /  name     /' infra/main.tf && rm infra/main.tf.bak
    ```

    **PowerShell**

    ```powershell
    $file = "infra/main.tf"
    (Get-Content $file -Raw) -replace '(?m)^  name ', '  name     ' | Set-Content $file -NoNewline
    ```

    > [!NOTE]
    > As an alternative in any shell, open **infra/main.tf** in Visual Studio Code, add several spaces after **name** on a line that starts with two spaces and **name**, and save the file.

3. Commit the change, push the branch, and open a pull request:

    ```bash
    git commit -am "Break formatting"
    git push -u origin format-test
    gh pr create --fill
    ```

4. On the pull request page, wait for the check **07 Terraform check / infra / check** and verify that it fails in the step **Format check**.

5. Fix the formatting locally and push again:

    ```bash
    terraform -chdir=infra fmt
    git commit -am "Fix formatting"
    git push
    ```

6. Verify that the check passes, then merge the pull request and update the local main branch:

    ```bash
    gh pr merge --squash --delete-branch
    git switch main
    git pull
    ```

    > [!NOTE]
    > Lab 07 adds a ruleset that makes such a check required, so that a pull request cannot be merged while the check fails.

## Exercise 7: Clean up

The exercise consists of the following tasks:

- Task 1: Remove the Azure credentials from the repository

### Task 1: Remove the Azure credentials from the repository

1. Lab 07 uses a new repository. Delete the Azure secret from this repository, so that the credentials exist in as few places as possible:

    ```bash
    gh secret delete AZURE_CREDENTIALS
    gh secret list
    ```

2. Keep the repository as a reference. It contains no secrets and created no Azure resources.

## Review

The following table summarizes the workflow concepts practiced in this lab.

| Concept | YAML | Workflow |
|---|---|---|
| Manual run with inputs | `on: workflow_dispatch: inputs:` | 01, 02 |
| Event filters | `push: branches:` and `paths:` | 02 |
| Job order and outputs | `needs:`, `outputs:`, `$GITHUB_OUTPUT` | 03 |
| Matrix | `strategy: matrix:` and `include:` | 04 |
| Variables and secrets | `env:`, `vars.NAME`, `secrets.NAME` | 05 |
| Azure sign-in | `azure/login@v3` with `creds:` | 06 |
| Reusable workflow | `on: workflow_call` and `uses: ./.github/workflows/...` | 07 |
