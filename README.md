# Power Platform GitHub Workflows v19

This repository contains four reusable GitHub Actions workflows:

```text
.github/workflows/
├── manage-feature-workspace.yml
├── commit-feature-changes.yml
├── validate-pull-request.yml
└── deploy-solution.yml
```

Each Power Platform project has four small caller workflows with the same names.
The callers contain the project settings and invoke the shared reusable workflows.

## Project workflow setup

Use the files in:

```text
project-workflows-template/
```

Open `PROJECT-DETAILS.txt`, complete the required values, and run:

```powershell
.\project-workflows-template\Install-ProjectWorkflows.ps1
```

The installer writes only the completed caller workflows into the selected
project repository's `.github/workflows` folder.

## Selecting a solution folder

The solution logical name remains a project setting, but the repository folder is
now a workflow input. This allows the same solution to be exported, committed,
validated, or deployed from different repository folders.

The default folder comes from `PROJECT-DETAILS.txt`. Each manual workflow run can
override it. The source folder is always derived as `<solution_folder>/src`.
Automatic pull request validation detects the changed solution folder when one
folder is changed.

## Generated deployment ZIP in the project repository

`Deploy Solution from Git` now packs the solution automatically, uploads the
exact ZIP as a GitHub Actions artifact, and commits the same ZIP into the project
repository before import.

The default project caller stores the package under the selected solution folder:

```text
<solution_folder>/package/<solution_name>.zip
```

Managed packages use:

```text
<solution_folder>/package/<solution_name>_managed.zip
```

The paths are generated from workflow inputs. No solution name or project folder
is hardcoded in the shared workflow. Because the workflow pushes the ZIP back to
the project repository, the deployment caller and reusable workflow require
`contents: write`.

## Repository setup

Follow the central checklist at:

```text
REPOSITORY-SETTINGS.txt
```

No project-level GitHub Actions variables are required. Each project repository
must have access to these secret names:

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


## Azure Boards work item linking

Connect each GitHub project repository to the correct Azure Boards project using the Azure Boards GitHub app. After the connection is active, enter one or more work item IDs in the **Commit Feature Changes** workflow. The workflow adds the required `AB#<id>` references to the Git commit message and pull request description.

Examples:

```text
123
123,456
AB#123 AB#456
```

The resulting commit message will look like:

```text
Update chess move validation AB#123 AB#456
```

The workflow only creates links. It does not automatically change the state of a work item. To transition a work item, use Azure Boards supported wording such as `Fixed AB#123` deliberately.
