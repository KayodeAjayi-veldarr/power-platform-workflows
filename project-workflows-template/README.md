# Project Workflow Files v17

This folder generates the four caller workflows for a Power Platform project.

`PROJECT-DETAILS.txt` is the only file you need to edit. Complete these required values:

```text
Destination repository
Project key
Solution
Default developer alias
Default developer UPN
```

`Default solution folder` is optional. When it is blank, the installer uses:

```text
power-platform/<Solution>
```

This value is only the default shown in GitHub. **Manage Feature Workspace**,
**Commit Feature Changes**, **Deploy Solution from Git**, and manual pull request
validation now include a `solution_folder` input, so the same solution logical name
can be used with different repository folders. The source folder is derived as:

```text
<solution_folder>/src
```

For automatic pull request validation, the caller workflow detects the changed
solution folder from files below a `/src/` path. When no changed solution folder
is found, it uses the configured default. If more than one solution folder changes,
the workflow stops and asks for separate pull requests or a manual validation run.

Run the installer from this template folder:

```powershell
.\Install-ProjectWorkflows.ps1
```

Use `-Force` only when replacing existing workflow files:

```powershell
.\Install-ProjectWorkflows.ps1 -Force
```

The installer writes only the four generated YAML files to the destination
repository's `.github/workflows` folder. It does not copy `PROJECT-DETAILS.txt`,
the installer, or this README into the project repository.

Repository settings are not included in this project template. Follow the central
`REPOSITORY-SETTINGS.txt` file in the shared `power-platform-workflows` repository.

The project repository must have access to these GitHub secrets:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

No project-level GitHub Actions variables are required.


## Link commits to Azure Boards

In **Commit Feature Changes**, enter the Azure Boards work item IDs in the **Azure work item IDs** field. Use numeric IDs such as `123` or multiple IDs such as `123,456`. The workflow adds `AB#123` references to the commit message and pull request description automatically.

This requires the GitHub repository to be connected to the correct Azure Boards project first.
