# Lab 07 Optional - Implement CI/CD with GitHub Actions and IaC with Bicep

**Estimated timing:** 40 minutes

## Objectives

In this lab, you will:

- Implement Infrastructure as Code (IaC) and CI/CD with GitHub Actions and a Bicep template

## Prerequisites

- Completed Lab 01A, Lab 02A, Lab 02B, and Lab 06
- An Azure subscription to which you have at least Contributor-level access

> [!NOTE]
> This lab runs entirely in the web browser, so the steps are the same on every operating system.

## Exercise 1: Implement Infrastructure as Code (IaC) and CI/CD with GitHub Actions and a Bicep template

In this exercise, you'll implement IaC with CI/CD to Azure App Service web apps with GitHub Actions and a Bicep template.

The exercise consists of the following tasks:

- Task 1: Fork and review the GitHub repo containing the source code of a web app, a GitHub Actions workflow, and a Bicep template
- Task 2: Configure the target environment
- Task 3: Validate the IaC and CI/CD functionality

### Task 1: Fork and review the GitHub repo containing the source code of a web app, a GitHub Actions workflow, and a Bicep template

1. Open GitHub and sign in to your GitHub account.

2. Open another tab in the same browser window and navigate to the [eShopOnWeb](https://github.com/MicrosoftLearning/eShopOnWeb) repo. This repo hosts the .NET version of a sample web site, a GitHub Actions workflow, and a Bicep template.

3. On the **eShopOnWeb** repo page, select **Fork**.

4. On the **Create a new fork** page, ensure that the **Owner** drop-down list displays your GitHub user name, accept the default entry **eShopOnWeb** in the **Repository name** text box, confirm that the **Copy the main branch only** checkbox is checked, and then select **Create fork**.

5. On the **eShopOnWeb** page, confirm that the drop-down list displays the current branch **main**.

6. Review the repo structure and note that it includes the following components:
    - the **.github/workflows** directory containing several YAML-based workflows, including one named **eshoponweb-cicd.yml**
    - the **infra** directory containing the Bicep template named **webapp.bicep**
    - the **src/Web** directory containing the .NET code of the source web app

7. Open the **.github/workflows** directory and then select the **eshoponweb-cicd.yml** file to view its content. Note that this GitHub Actions workflow contains the **buildandtest** and **deploy** jobs, which consist of the following steps:
    - **buildandtest**
      - check out the repository
      - prepare the runner for the desired .NET SDK version
      - build, test, and publish the .NET project
      - upload the published website code artifacts
      - upload the Bicep template as an artifact for the next job
    - **deploy**
      - download the published artifacts created in the previous job
      - download the Bicep template uploaded in the previous job
      - sign in to the target Azure subscription using a service principal
      - deploy an Azure App Service web app by using the Bicep template
      - publish the website artifacts into the Azure App Service web app

8. Note that the process of provisioning Azure resources targets a single resource group, which is defined at the beginning of the workflow as the environment variable **RESOURCE-GROUP**.

9. Note that the workflow relies on a secret to authenticate to the target Azure subscription during the **Set-up Azure CLI** step, as shown by the statement `creds: ${{ secrets.AZURE_CREDENTIALS }}`.

10. In addition, note that this workflow can be triggered manually, as indicated by the `on: workflow_dispatch` syntax.

### Task 2: Configure the target environment

1. Switch to the web browser window displaying the forked **eShopOnWeb** GitHub repo page and, in the toolbar, select **Settings**.

2. In the vertical menu on the left side, in the **Security** section, select **Secrets and variables** and, in the drop-down list, select **Actions**.

3. In the **Actions secrets and variables** pane, select **New repository secret**.

4. In the **Actions secrets / New secret** pane, in the **Name** text box, enter **AZURE_CREDENTIALS**.

5. In the **Secret** text box, paste the JSON-formatted text for your account, and then select **Add secret**:

    ```json
    {
      "clientId": "<client-id>",
      "clientSecret": "<client-secret>",
      "subscriptionId": "<subscription-id>",
      "tenantId": "<tenant-id>"
    }
    ```

    ![The New secret pane with the name AZURE_CREDENTIALS and the JSON credentials](images/lab07-optional/image1.png)

### Task 3: Validate the IaC and CI/CD functionality

1. Switch to the web browser window displaying the forked **eShopOnWeb** GitHub repo page and, if needed, select the **Code** tab and confirm in the drop-down list that the current branch is **main**.

2. Navigate to the **.github/workflows** folder and select **eshoponweb-cicd.yml**.

3. In the **.github/workflows/eshoponweb-cicd.yml** pane, select the pencil icon to edit the workflow.

4. In the **Edit** pane, replace line 4 with the following text:

    ```yaml
    on: workflow_dispatch
    ```

5. In the **Edit** pane, replace line 8 with the following text, using the resource group from your lab credentials:

    ```yaml
    RESOURCE-GROUP: rg-myname-usa
    ```

    > [!NOTE]
    > **rg-myname-usa** is only an example. The real resource group is part of the lab credentials used for the access.

6. In the **Edit** pane, replace the **YOUR-SUBS-ID** placeholder in line 11 with the Azure subscription ID used in the lab.

7. In the **Edit** pane, replace the **eshoponweb-webapp-NAME** placeholder in line 12 with the value of the **WEBAPP_USAC_NAME** variable in your lab credentials.

8. Select **Commit changes** and then select **Commit changes** again.

9. Navigate to the **infra** folder and select **webapp.bicep**.

10. In the **infra/webapp.bicep** pane, select the pencil icon to edit the file.

11. In the **Edit** pane, if necessary, replace line 2 with the following text:

    ```bicep
    param sku string = 'S1' // The SKU of App Service Plan
    ```

12. If something was changed in the previous step, select **Commit changes** and then select **Commit changes** again.

13. On the forked **eShopOnWeb** GitHub repo page, select **Actions**.

14. If you're prompted to enable GitHub Actions, select **I understand my workflows, go ahead and enable them**.

15. In the **All workflows** section on the left side, select **eShopOnWeb Build and Test**.

16. In the **eShopOnWeb Build and Test** pane, select **Run workflow**, confirm in the drop-down list that **Branch: main** is selected, and select **Run workflow** again.

17. Select the **eShopOnWeb Build and Test** workflow run.

18. In the **eShopOnWeb Build and Test #1** pane, select **buildandtest**.

19. Monitor the progress of the workflow and verify that all steps of the **buildandtest** job complete successfully.

20. Once this job completes, in the **Summary** section, select **deploy**.

21. Monitor the progress of the workflow and verify that all steps of the **deploy** job complete successfully.
