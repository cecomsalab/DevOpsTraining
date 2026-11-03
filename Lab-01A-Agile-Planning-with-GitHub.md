# Lab 01A - Agile Planning and Management using GitHub

**Estimated timing:** 40 minutes

## Objectives

In this lab, you will:

- Create a GitHub account

- Create a GitHub repo, project, and project board

- Create and manage project board items

## Exercise 1: Creating an account on GitHub

1.  Navigate to [https://github.com/signup](https://github.com/signup?ref_product=github&ref_type=engagement&ref_style=text).

2.  Sign up creating a GitHub account or use an Apple or Google social login to complete the registration.

3.  Follow the prompts to create the personal account.

During sign up, you'll be asked to verify your email address. Without a verified email address, you won't be able to complete some basic GitHub tasks, such as creating a repository.

## Exercise 2: Create a GitHub repo, project, and project board

The exercise consists of the following tasks:

- Task 1: Create a GitHub repo

- Task 2: Create GitHub milestones and issues

- Task 3: Create a GitHub project

- Task 4: Create a GitHub project board

### Task 1: Create a GitHub repo

1.  Start a web browser and navigate to the [GitHub](https://github.com/) home page.

2.  When prompted to authenticate, sign in by using your GitHub user account.

3.  On the GitHub main page, select the **Repositories** tab and then select **New**.

    ![Screenshot](images/lab01a/image1.png)

4.  On the **Create a new repository** page, do the following actions:

    - In the **Owner** drop-down list, select your GitHub user account name.

    - In the **Repository name** text box, enter **DevOpsCoreIntroRepo**.

    - Change the visibility of the repo to **Private**.

    - Enable the **Add a README file** checkbox.

    - In the **Add .gitignore** drop-down list, select **Visual Studio**.

    - In the **Choose a license** drop-down list, select **MIT License**.

5.  Select **Create repository**.

### Task 2: Create GitHub milestones and issues

1.  On the **DevOpsCoreIntroRepo** page, select the **Issues** tab.

2.  On the **Issues** page, to the left of the **New issue** button, select **Milestones**.

3.  On the **Milestones** page, select **New milestone**.

4.  On the **New milestone** page, do the following actions:

    - In the **Title** text box, enter **alpha release**.

    - In the **Due date (optional)** text box, enter the date one week ahead from the current date.

    - In the **Description** text box, enter **Completion of the alpha release**.

5.  Select **New milestone**.

6.  Repeat the last three steps to create an **beta release** milestone with the due date two weeks ahead of the current date. In the **Description** text box, enter **Completion of the beta release**.

7.  Navigate back to the **Issues** page and select **New issue**.

8.  In the **Add a title** text box, enter **Repo README page is empty**.

9.  In the **Add a description** text box, enter **Brevity might be a virtue, but this README page can really use some text**.

10. Select the gear icon next to the **Milestone** entry and, in the drop-down list, select **alpha release**.

11. Select the gear icon next to the **Labels** entry and, in the drop-down list, select **bug**.

12. Select **Create**. Note that the issue has been automatically assigned **\#1**.

### Task 3: Create a GitHub project

1.  On the GitHub main page, select the avatar icon at the right side of the toolbar and, in the drop-down menu, select **New project**.

2.  On the Projects page, select **New project**

3.  In the **Select a template** pane, select **Team planning**

4.  In the **Project name** text box, enter **DevOps Core Intro Project**.

5.  Check the **Import items from repository** checkbox. For the Items to import, select **Open issues and pull requests** and from Repository select **DevOpsCoreIntroRepo**.

6.  Click **Create project**.

7.  On the DevOps Core Intro Project page, open the project settings using the ellipsis at the end of the right bar

    ![Screenshot](images/lab01a/image2.png)

8.  In the **Short description** text box, enter **Introduction to GitHub Projects** and select **Save**.

9.  In the **README** section, enter the following text

    ```markdown
    ### Welcome to DevOps Core Intro Project ###
    
    **Projects are a customizable, flexible tool for planning and tracking your work.**
    
    To find out more, refer to GitHub documentation [about Projects](https://docs.github.com/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects).
    ```

10. Select **Preview** to review the resulting page.

11. Select **Save changes**.

12. Scroll down to the **Danger zone** and **note** the option allowing you to switch the visibility of the project between **Private** and **Public**. Notice that this area includes also options for closing or deleting the project (Do not click on them).

13. Scroll up to the top of the page and note that you have the options to **Manage access** to the project and create custom fields in the project interface.

14. Select the left facing arrow in the **\<- Settings** label to exit the **Settings** page.

### Task 4: Create a GitHub project board

1.  On the **DevOps Core Intro Project** page, select the down-facing caret next to the **Backlog** tab and, in the **Layout** section, select **Board**.

2.  Review the resulting page that consists of three predefined columns labeled:

    - **Todo** - including items which haven’t been started

    - **In Progress** - including items being actively worked on

    - **Done** - including items that have been completed

3.  To add an extra column, select the **+** icon to the right of the **Done** column and then select **+ New Column**.

4.  In the **New option** window, in the **Label text** text box, enter **Review In Progress** and select a color you want to assign to the column. In the **Description** text box, enter **This item is being reviewed**, and then select **Save**.

5.  Select the small circle next to the **Review in Progress** label of the newly added column and use it to drag it between the **In Progress** and **Done** column.

## Exercise 3: Create and manage project board items

In this exercise, you’ll create and manage project board items

The exercise consists of the following tasks:

- Task 1: Add a draft item

- Task 2: Add an item based on an issue

- Task 3: Review automation settings

### Task 1: Add a draft item

1.  On the **DevOps Core Intro Project** page, in the **Todo** column, select **+ Add item**.

2.  In the text box, enter **Missing Wiki** and then press **Ctrl**+**Enter** on the keyboard. This will add a new draft item to the **Todo** column.

3.  In the newly added draft item, select the ellipsis symbol and, in the drop-down menu, select **Convert to issue**.

4.  In the **Select an item** drop-down list, select **DevOpsCoreIntroRepo** to add the item to the repo you created in the previous exercise. Note that the issue has been automatically labeled with **\#N**. (The displayed number will depend from previous issues created)

5.  Select the ellipsis next to **Missing Wiki** issue and click “Open in new tab”.

6.  In the **Missing Wiki \#N** pane, note that you have another configuration settings available at this point, including labels and milestones.

7.  Select **labels** and, in the **Select items** drop-down list, select **enhancement**.

8.  Select **milestone** and, in the **Select an item** drop-down list, select **alpha release**.

9.  Close the **Missing Wiki \#N tab**

10. On the **DevOps Core Intro Project** page, in the **Todo** column, select **+ Add item**.

11. In the text box, enter **Additional collaborators needed** and then press **CTRL + Enter** on the keyboard. This will add a new draft item to the **Todo** column.

12. In the newly added draft item, select the ellipsis symbol and, in the drop-down menu, select **Convert to issue** and select **DevOpsCoreIntroRepo** to add the item to the repo.

### Task 2: Add an item based on an issue

1.  From the plus (+) symbol at the top of the page, select **New issue.**

    ![Screenshot](images/lab01a/image3.png)

2.  For the **title**, type: “Install GitHub on Pilot Computers”. For the **Milestone**, select alpha release. Then, click **Create**

3.  Using the top left menu, go to the **Projects** page

4.  Click on the **DevOps Core Intro Project**.

5.  On the **DevOps Core Intro Project** page, Open the **Board** tab.

6.  If the Install GitHub on Pilot Computers does not appear in the Board, add it following these steps:

    1)  In the **Todo** column, select **+ Add item**.

    2)  In the text box, enter **\#** to display a list of existing repositories. In the list, select **DevOpsCoreIntroRepo**.

    3)  Next, in the list of existing issues, select **Install GitHub on Pilot Computers**. This will automatically add that issue to the **Todo** column.

7.  Select **Repo README page is empty** to display the corresponding pane.

8.  In the **Repo README page is empty** pane, in the Assignees section, select **Assign yourself,** and close the **Repo README page is empty** pane.

9.  Drag the **Repo README page is empty** item from the **Todo** column and drop it in the **In Progress** column.

### Task 3: Review automation settings

1.  In the **DevOps Core Intro Project** page, directly under the avatar icon, select **Workflows**.

2.  On the **Workflows** page, in the menu on the left side, review the list of default workflows.

3.  Select **Item closed** and review the workflow. The workflow automatically sets the status of an issue to **Done**, whenever that item is closed.

4.  Select the avatar icon at the upper right corner of the page and, in the drop-down menu, select **All Repositories**, then click **My repositories**.

5.  In the list of repositories, select **DevOpsCoreIntroRepo**.

6.  In the **README** section, select the pencil icon to open the file in the edit mode.

7.  Replace the existing content with the following text:

    ```markdown
    ### Welcome to DevOps Core Intro Project Repository ###
    
    **Projects are a customizable, flexible tool for planning and tracking your work.**
    
    To find out more, refer to GitHub documentation [about Projects](https://docs.github.com/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects).
    ```

8.  Select **Commit changes**.

9.  In the **Commit changes** window, accept the default settings and select **Commit changes** again.

10. Select the **Issues** tab.

11. Select **Repo README page is empty**.

12. On the **Repo README page is empty \#1** page, select **Close issue**.

13. Note that closing the item resulted in the following actions:

    - The status of the item was automatically changed to **Done**, as indicated by an extra comment stating that **github-project-automation** bot moved the item from **In Progress** to **Done** in **DevOps Core Intro Project**.

    - **alpha release** milestone has been marked as ˜50% complete, as indicated by the green horizontal bar in the **Milestone** section of the page.

14. To verify this, navigate back to the board view of **DevOps Core Intro Project** and note that the **Repo README page is empty** item appears in the **Done** column.
