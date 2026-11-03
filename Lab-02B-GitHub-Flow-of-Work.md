# Lab 02B - Implement Flow of Work with GitHub

**Estimated timing:** 30 minutes

## Objectives

In this lab, you will:

- Implement and manage repos with GitHub

## Prerequisites

- Completed Lab 01A and Lab 02A

## Exercise 1: Implement and manage repos with GitHub

In this exercise, you’ll fork a Git repo and manage it by using GitHub. A fork is a repository that shares code and visibility settings with an existing upstream repository.

The exercise consists of the following tasks:

- Task 1: Fork a GitHub repo

- Task 2: Configure a GitHub repo

- Task 3: Create an issue

- Task 4: Create a branch

- Task 5: Update files in the branch

- Task 6: Create and merge a pull request

- Task 7: Close the issue

- Task 8: Validate the changes

### Task 1: Fork a GitHub repo

1.  Start a web browser and navigate to the [GitHub](https://github.com/) home page.

2.  When prompted to authenticate, sign in by using your GitHub user account.

3.  Open another tab in the same browser window and navigate to the [Spoon-Knife](https://github.com/octocat/Spoon-Knife) repo: <https://github.com/octocat/Spoon-Knife>

4.  On the **Spoon-Knife** repo page, select **Fork**.

5.  On the **Create a new fork** page, ensure that the **Owner** drop-down list entry displays your GitHub user name, accept the default entry **Spoon-Knife** in the **Repository name** text box, leave the **Copy the main branch only** checkbox enabled, and then select **Create fork**.

### Task 2: Configure a GitHub repo

1.  On the forked **Spoon-Knife** repo page, in the toolbar, select **Settings**.

2.  In the **General** section of the **Settings** tab, note that the default branch is set to **main**.

3.  Navigate to the **Features** area of the **General** section and enable the **Issues** checkbox.

4.  In the left side navigational menu, in the **Code and automation** grouping, select the **Pages** entry.

5.  In the **GitHub Pages** pane, in the Branch section, change the **None** entry in the drop-down list to **main** and then select **Save**.

6.  In the **GitHub Pages** pane, select the **Visit site** button. This will automatically open another web browser tab and display the page representing the current content of the index.html file.

7.  Back on the forked **Spoon-Knife** repo page, in the toolbar, select **Projects**.

8.  On the **Projects** pane, select **Link a project**, and, in the drop-down menu, select **DevOps Core Intro Project**.

9.  Click **Save.**

### Task 3: Create an issue

1.  On the forked **Spoon-Knife** page, select the **Issues** tab.

2.  On the **Issues** page, select **New issue**.

3.  In the **Add a title** text box, enter **index.html looks rather austere**.

4.  In the **Add a description** text box, enter **index.html file can use a modern touch**.

5.  In the current pane, in the Assignees section, select **Add assignees…**, and, in the **Suggestions** section, select your GitHub username.

6.  Select the gear icon next to the **Labels** entry and, in the drop-down list, select **enhancement**.

7.  Select the gear icon next to the **Projects** entry and, in the drop-down list, select **DevOps Core Intro Project**.

8.  Click **Create** to save the new issue.

9.  On the **index.html looks rather austere** pane, in the **Projects** section, set **Status** to **In Progress**.

10. On the forked **Spoon-Knife** page, select the **Projects** tab.

11. On the **Projects** page, select **DevOps Core Intro Project**.

12. In the board view of the **DevOps Core Intro Project**, review the **In Progress** column and note that it includes the newly created issue.

### Task 4: Create a branch

1.  Switch back to the **Code** tab.

2.  In the upper left corner of the page, select the **main** entry to display the **Switch branches/tags** drop-down list.

3.  In the **Find or create a branch…** text box, enter **update index.html** and then select **Create branch: update index.html from ‘main’** entry to create a new branch.

### Task 5: Update files in the branch

1.  On the forked **Spoon-Knife** repo page, in the listing of files, select **index.html**.

2.  On the **Spoon-Knife/index.html** page, on the right side in the code editor toolbar, select the pencil icon to switch to the editor mode.

3.  In the editor pane, replace the entire body element of the page (lines 12-17) with the following HTML code:

    ```html
    <div id="octocat">
    <img src="https://octodex.github.com/images/NUX_Octodex.gif" alt="Octocat Image">
    </div>
    <p>
    Ready to team up? Let's collaborate, @octocat!
    </p>
    ```

4.  In the upper right corner of the editor page, select **Commit changes…**.

5.  In the **Commit changes** window, in the **Extended description** text box, enter **Modified the image and paragraph text**, accept the default commit message, and select **Commit changes**.

6.  In the listing of repo files on the left side, select **styles.css**.

7.  On the **Spoon-Knife/styles.css** page, on the right side in the code editor toolbar, select the pencil icon to switch to the editor mode.

8.  In the editor pane, replace line 17 with the entire following CSS code:

    ```css
    color: #333;
    line-height: 1.5;
    text-align: center;
    }
    body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f8f9fa;
    }
    #octocat img {
    display: block;
    width: 100%;
    height: auto;
    }
    ```

9.  In the upper right corner of the editor page, select **Commit changes…**.

10. In the **Commit changes** window, in the **Extended description** text box, enter **Modified CSS tags and selectors**, accept the default commit message, and select **Commit changes** to commit changes to the update-index.html branch.

### Task 6: Create and merge a pull request

1.  Navigate back to the forked **Spoon-Knife** repo page.

2.  Ensure that you’re currently viewing the **update-index.html** branch, as indicated by the label appearing in the drop-down list in the upper-left corner of the page. If that label displays **main**, select it first and then, in the drop-down list containing the list of branches, select **update-index.html**.

3.  On the forked **Spoon-Knife** repo page, select **Contribute** and then select **Open pull request**.

4.  On the **Open a pull request** page, select the entry **base repository: octocat/Spoon-Knife**.

5.  In the **Choose a Base Repository** drop-down list, select the name of the forked repository you created at the beginning of this lab.

    > [!NOTE]
    > The name will start with your GitHub name, followed by a forward slash, followed by **Spoon-Knife**. Once you select it, the entry should change to **base: main**.

    > [!NOTE]
    > It might take a couple of minutes before the page displays your forked new repo.

6.  In the **Add a title** text box, replace **Update index.html** with **Update index.html and styles.css**.

7.  In the **Add a description** text box, enter **Addressing \#1** and select **Create pull request**.

8.  Verify that the current branch has no conflicts with the base branch, select **Merge pull request**, and then select **Confirm merge**.

9.  Verify that the pull request has been successfully merged and closed and select **Delete branch**.

### Task 7: Close the issue

1.  In the toolbar of the GitHub page, select the **Issues** tab.

2.  Select the checkbox to the left of the first issue **index.html looks rather austere**, select **Mark as**, and in the drop-down list, select **Completed**.

3.  Navigate back to the board view of the **DevOps Core Intro Project** and note that the issue appears now in the **Done** column.

### Task 8: Validate the changes

1.  In the web browser window, navigate back to your forked **Spoon-Knife** repo page, select the **Settings** tab and then, in the left side navigation menu, in the **Code and automation** grouping, select **Pages** to display the **GitHub Pages** pane.

2.  In the **GitHub Pages** pane, select **Visit site** to open another browser tab displaying the updated content of the index.html file.

3.  Verify that the page has been updated to include the visual elements referenced in the HTML and CSS files.
