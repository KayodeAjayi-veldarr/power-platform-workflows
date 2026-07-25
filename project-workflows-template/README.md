# Project Workflow Files v12

This pack creates the four small caller workflows used by a Power Platform
project:

```text
.github/workflows/
├── manage-feature-workspace.yml
├── commit-feature-changes.yml
├── validate-pull-request.yml
└── deploy-solution.yml
```

## Setup

Open `PROJECT-DETAILS.txt` and replace the values written inside angle brackets.
The important fields are shown in a simple format:

```text
Project key: <short project identifier>
Solution: <logical name of the solution>
Solution project folder: <folder containing the solution project>
Solution source folder: <folder containing the unpacked solution files>
Default developer alias: <short developer identifier>
Default developer UPN: <developer Microsoft 365 email address>
```

You can leave the two solution folder values blank. The installer will then use:

```text
power-platform/<Solution>
power-platform/<Solution>/src
```

After completing the file, run:

```powershell
.\Install-ProjectWorkflows.ps1
```

The script reads `PROJECT-DETAILS.txt`, replaces the internal template tokens
and writes the finished workflow files into the project's `.github/workflows`
folder.

Use `-Force` only when replacing existing workflow files:

```powershell
.\Install-ProjectWorkflows.ps1 -Force
```

A different project details file can also be supplied:

```powershell
.\Install-ProjectWorkflows.ps1 `
  -ConfigurationFile "C:\Setup\another-project.txt"
```

## GitHub configuration

No project-level GitHub Actions variables are required.

The project repository must have access to these secrets:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

They can be organisation secrets or repository secrets. Do not place secret
values in `PROJECT-DETAILS.txt` or the workflow files.

## Workflow lifecycle

```text
Create a feature branch
        ↓
Manage Feature Workspace: PrepareOrReuse
        ↓
Build and test in the developer environment
        ↓
Commit Feature Changes
        ↓
Open or update a pull request
        ↓
Validate Power Platform Pull Request
        ↓
Merge into main
        ↓
Deploy Solution from Git
```

To delete an old developer environment, run `Manage Feature Workspace`, select
`DeleteEnvironment`, and enter the exact confirmation value requested by the
workflow.
