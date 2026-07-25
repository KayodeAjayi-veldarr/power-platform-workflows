# Power Platform GitHub Workflows v15

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

## Project workflow setup

Use the files in:

```text
project-workflows-template/
```

Open `PROJECT-DETAILS.txt` and complete the required values. The two solution
folder fields may remain blank.

Then run:

```powershell
.\project-workflows-template\Install-ProjectWorkflows.ps1
```

The installer writes only the finished caller workflows into the selected
project repository's `.github/workflows` folder. It does not copy the template
support files into the project repository.

## Repository setup

Follow the central checklist at:

```text
REPOSITORY-SETTINGS.txt
```

It is stored at the root of this shared workflow repository because it is a
central setup guide. It should not be copied into every project repository.

The checklist covers the settings that must be applied to the shared repository,
the GitHub organisation, and each project repository.

## GitHub configuration

No project-level GitHub Actions variables are required.

Each project repository must have access to these secret names:

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
