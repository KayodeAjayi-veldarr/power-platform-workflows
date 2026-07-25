# Power Platform GitHub Workflows v12

This repository contains four reusable GitHub Actions workflows:

```text
.github/workflows/
├── manage-feature-workspace.yml
├── commit-feature-changes.yml
├── validate-pull-request.yml
└── deploy-solution.yml
```

Each Power Platform project has four small caller workflows with the same names.
The callers contain the project-specific settings and invoke the shared reusable
workflows in this repository.

## Project setup

Use the files in:

```text
project-workflows-template/
```

Open `PROJECT-DETAILS.txt` and complete the labelled values, including:

```text
Project key: <short project identifier>
Solution: <logical name of the solution>
Solution project folder: <folder containing the solution project>
Solution source folder: <folder containing the unpacked solution files>
Default developer alias: <short developer identifier>
Default developer UPN: <developer Microsoft 365 email address>
```

Then run:

```powershell
.\project-workflows-template\Install-ProjectWorkflows.ps1
```

The installer writes the finished caller workflows into the selected project's
`.github/workflows` folder.

## GitHub configuration

No project-level GitHub Actions variables are required for the project key,
solution name, solution folders, developer defaults, region, currency, language
or Solution Checker settings.

The project repository must have access to these secret names:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

Organisation secrets can be used when several projects share the same Microsoft
Entra application. Make sure each project repository is included in the secret
access policy.

## Lifecycle

```text
Create feature branch
        ↓
Manage Feature Workspace: PrepareOrReuse
        ↓
Build and publish changes
        ↓
Commit Feature Changes
        ↓
Open or update pull request
        ↓
Validate Power Platform Pull Request
        ↓
Merge into main
        ↓
Deploy Solution from Git
```

`Manage Feature Workspace` also supports deleting an old developer environment
using the exact confirmation value requested by the workflow.
