# Power Platform GitHub Workflows

This repository contains reusable GitHub Actions workflows for a Power Platform
feature-development lifecycle.

The shared workflows contain the implementation. Each Power Platform project
contains four small caller workflows that pass project settings into the
shared workflows.

## What changed in version 9

Earlier versions used two files named `_internal-start-feature-workspace.yml`
and `_internal-delete-workspace.yml`. They were not old copies, but helper
workflows called by `manage-feature-workspace.yml`.

They are no longer needed. Their logic has been moved directly into
`manage-feature-workspace.yml`.

The shared repository now has only four workflow files:

```text
.github/workflows/
├── manage-feature-workspace.yml
├── commit-feature-changes.yml
├── validate-pull-request.yml
└── deploy-solution.yml
```

The project template also exposes the same four workflows:

```text
project-workflows-template/.github/workflows/
├── manage-feature-workspace.yml
├── commit-feature-changes.yml
├── validate-pull-request.yml
└── deploy-solution.yml
```



---

## The development lifecycle

The intended process is:

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
Validate Pull Request
        ↓
Merge into main
        ↓
Deploy Solution from Git
```

When a developer environment is no longer needed:

```text
Manage Feature Workspace: DeleteEnvironment
```

---

## The four workflows

### 1. Manage Feature Workspace

This workflow has two actions.

#### PrepareOrReuse

It:

1. Exports the selected solution from a source environment.
2. Unpacks the solution into the selected feature branch.
3. Commits the baseline solution files when changes are detected.
4. Finds an existing developer environment or creates a new one.
5. Assigns the automation application user.
6. Assigns the developer.
7. Packs the solution from the branch.
8. Imports it into the developer environment.
9. Returns environment and solution links in the workflow summary.

The workspace environment can be left blank. When blank, the workflow creates
a name using:

```text
PROJECT-KEY + DEVELOPER-ALIAS + SUFFIX
```

Example format:

```text
PROJECT-DEVELOPER-DEV
```

When reusing an environment, enter its exact display name in the workflow
popup or configure `PP_DEFAULT_DEVELOPER_ENVIRONMENT`.

#### DeleteEnvironment

It:

1. Finds the environment.
2. Resolves its exact ID, name, URL and type.
3. Checks that its name begins with the project prefix.
4. Blocks protected environment types.
5. Requires an exact confirmation value.
6. Deletes the environment.

The confirmation must be:

```text
DELETE:resolved-environment-name
```

For example, when the resolved environment name is:

```text
PROJECT-DEVELOPER-DEV
```

the confirmation is:

```text
DELETE:PROJECT-DEVELOPER-DEV
```

Production and Default environments are blocked from deletion.

---

### 2. Commit Feature Changes

Run this after making and publishing changes in the developer environment.

It:

1. Exports the solution from the developer environment.
2. Unpacks it into the selected feature branch.
3. Detects source changes.
4. Commits and pushes the changes.
5. Creates or finds a pull request.
6. Returns the comparison and pull-request links.

Always run it from the same feature branch used to prepare the workspace.

---

### 3. Validate Pull Request

This normally runs automatically when a pull request into `main` is opened,
updated or reopened.

It:

1. Checks out the pull-request commit.
2. Packs the solution once.
3. Creates a unique temporary validation environment.
4. Imports the exact packed ZIP into that clean environment.
5. Runs Power Apps Solution Checker.
6. Uploads the exact ZIP and logs as a GitHub artifact.
7. Deletes the temporary environment.
8. Passes or fails the pull request validation.

The validation environment is deleted after success and failure by default.

For a manual troubleshooting run, the user can select:

```text
Retain validation environment on failure: true
```

That keeps the failed environment so Solution History can be inspected.

This workflow is important because a solution can pack successfully but still
fail during Dataverse import.

---

### 4. Deploy Solution from Git

Use this after a pull request has been merged.

It:

1. Checks out a selected branch, tag or commit.
2. Packs the solution.
3. Resolves the target environment.
4. Imports the solution.
5. Publishes changes when requested.
6. Uploads the exact deployed ZIP and logs.
7. Returns environment and solution links.

The target environment can be supplied as:

```text
Environment display name
Environment URL
Environment ID
```

This is the normal workflow for promoting `main` into a shared test,
demonstration, preparation or production-like environment.

---

## Repository structure

```text
power-platform-workflows/
├── .github/
│   └── workflows/
│       ├── manage-feature-workspace.yml
│       ├── commit-feature-changes.yml
│       ├── validate-pull-request.yml
│       └── deploy-solution.yml
│
└── project-workflows-template/
    ├── .github/
    │   └── workflows/
    │       ├── manage-feature-workspace.yml
    │       ├── commit-feature-changes.yml
    │       ├── validate-pull-request.yml
    │       └── deploy-solution.yml
    │
    ├── Copy-ProjectWorkflows.ps1
    ├── REPOSITORY-SETTINGS.example.txt
    └── README.md
```

---

## Prerequisites

Before running the workflows, you need:

1. A GitHub repository for the Power Platform project.
2. Access to this reusable workflow repository.
3. A Microsoft Entra application registration.
4. A client secret for the application.
5. Power Platform and Dataverse permissions for the application.
6. A Power Platform solution with a stable unique name.
7. A source-control folder for the unpacked solution.

A typical project folder looks like:

```text
power-platform/
└── SolutionUniqueName/
    ├── SolutionUniqueName.cdsproj
    └── src/
```

---

## Required GitHub secrets

Create these in every project repository, or provide them as organisation
secrets:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

They are used for non-interactive PAC authentication.

Optional source-environment secrets are available when the source environment
uses a different tenant or application:

```text
SOURCE_PP_TENANT_ID
SOURCE_PP_APP_ID
SOURCE_PP_CLIENT_SECRET
```

---

## Required project variables

Create these under:

```text
Repository Settings
→ Secrets and variables
→ Actions
→ Variables
```

| Variable | Purpose | Example format |
|---|---|---|
| `PP_PROJECT_KEY` | Short identifier used for names and safety checks | `PROJECT` |
| `PP_SOLUTION_NAME` | Power Platform solution unique name | `ProjectSolution` |
| `PP_SOLUTION_PROJECT_FOLDER` | Folder containing the cdsproj and `src` | `power-platform/ProjectSolution` |
| `PP_SOLUTION_SOURCE_FOLDER` | Unpacked solution source folder | `power-platform/ProjectSolution/src` |
| `PP_DEFAULT_DEVELOPER_ALIAS` | Default short developer name | `KAYODE` |
| `PP_DEFAULT_DEVELOPER_UPN` | Default Microsoft 365 developer email | `developer@company.com` |
| `PP_TARGET_REGION` | Region used when creating environments | `europe` |
| `PP_TARGET_CURRENCY` | Dataverse currency code | `GBP` |
| `PP_TARGET_LANGUAGE` | Environment language | `English` |
| `PP_CHECKER_GEO` | Solution Checker geography | `UnitedKingdom` |

---

## Optional environment variables

These are intentionally blank in the template:

```text
PP_DEFAULT_SOURCE_ENVIRONMENT
PP_DEFAULT_DEVELOPER_ENVIRONMENT
PP_DEFAULT_DEPLOYMENT_ENVIRONMENT
```

You can leave them blank and enter the environment during each workflow run.

You can also configure them once at repository level to reduce repeated
typing. The popup value takes priority when the user enters one.

Other optional variables include:

```text
PP_BASE_BRANCH
PP_DEVELOPER_ENVIRONMENT_SUFFIX
PP_VALIDATION_ENVIRONMENT_PREFIX
PP_VALIDATION_ENVIRONMENT_TYPE
PP_CHECKER_RULE_SET
PP_DEPLOYMENT_SETTINGS_FILE
PP_TARGET_TEMPLATES
PP_TARGET_SECURITY_GROUP_ID
PP_VALIDATION_TEMPLATES
PP_VALIDATION_SECURITY_GROUP_ID
PP_AUTOMATION_ROLE
PP_DEVELOPER_ROLE
```

---

## Starting a new project

### Option A: Copy the folder manually

Copy:

```text
project-workflows-template/.github
```

into the root of the new project repository.

Then configure the variables and secrets listed above.

### Option B: Use the copy script

From the template folder:

```powershell
.\Copy-ProjectWorkflows.ps1 `
  -DestinationRepositoryPath "C:\Repos\new-power-platform-project"
```

The script copies the `.github` folder only. It does not insert environment
values into the files.

After copying:

1. Configure repository variables.
2. Configure repository secrets.
3. Commit `.github` to `main`.
4. Create the feature branch from the updated `main`.
5. Run **Manage Feature Workspace**.

---

## First controlled test

Use a small solution or a safe test branch first.

1. Confirm the four caller workflows are present on `main`.
2. Create a new feature branch from `main`.
3. Open **Actions → Manage Feature Workspace**.
4. Select the feature branch under **Use workflow from**.
5. Choose `PrepareOrReuse`.
6. Enter or confirm the source environment.
7. Enter the developer UPN.
8. Enter an exact developer environment display name, or leave it blank to
   generate one.
9. Run the workflow.
10. Open the environment and solution links in the summary.
11. Make and publish a small change.
12. Run **Commit Feature Changes** from the same branch.
13. Review the pull request.
14. Confirm validation creates and removes its temporary environment.
15. Merge the pull request.
16. Run **Deploy Solution from Git** using `main`.

---

## GitHub permissions

The project workflows request only the permissions they need.

`Manage Feature Workspace` and `Commit Feature Changes` can push source files
to a feature branch.

The project repository must allow GitHub Actions write access:

```text
Settings
→ Actions
→ General
→ Workflow permissions
→ Read and write permissions
```

To let GitHub Actions create a pull request, also enable:

```text
Allow GitHub Actions to create and approve pull requests
```

Organisation policy may control these settings.

---

## Environment safety

The workflow does not silently delete developer environments.

Deletion requires:

```text
workspace_action = DeleteEnvironment
```

and an exact confirmation value:

```text
DELETE:environment-name
```

The workflow also checks:

```text
The environment exists
The resolved name begins with the project prefix
The environment type is allowed
The environment is not Production or Default
```

Temporary pull-request validation environments are different. They are created
by the validation workflow, uniquely named for the run, and automatically
deleted by the same workflow.

---

## Artifacts

The workflows upload useful artifacts such as:

```text
Exported source ZIP
Packed branch ZIP
Pack logs
Unpack logs
Import logs
Solution Checker results
Environment creation and deletion logs
```

Use these artifacts when diagnosing a failed solution import.

---

## Common troubleshooting

### The workflow is visible but cannot run on the feature branch

The feature branch probably does not contain the caller workflow file.

Create the branch from the latest `main`, or merge the latest `main` into the
branch.

### The workflow tries to create an environment instead of reusing one

For `PrepareOrReuse`, use the exact environment display name.

The Delete and Deploy workflows accept a name, URL or ID.

### PAC authenticates without a browser sign-in

The workflow signs in as the Microsoft Entra application using:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

The GitHub runner is temporary. PAC creates a fresh authentication profile on
each run.

### A solution packs but fails to import

Packing confirms that SolutionPackager could build the ZIP. It does not prove
Dataverse can import every component.

Open Solution History in the target environment and download the import log.
The validation workflow is designed to catch this problem before merge.

### Pull-request creation is blocked

Enable repository or organisation permission for GitHub Actions to create pull
requests.

---

## Updating the shared workflows

During testing, caller workflows may reference:

```yaml
@main
```

After the workflows are stable, create a release tag such as:

```text
v1
```

Then update callers to use:

```yaml
@v1
```

A tag or commit SHA prevents an untested shared change from affecting every
project immediately.

---

## Validation performed on this release

The release pack checks:

```text
All YAML files parse successfully
Project callers use declared reusable inputs
Required secrets are supplied
Reusable job outputs reference declared step IDs
No project environment name, URL, ID or domain is hardcoded
```

The workflows still need a controlled live test against your Power Platform
tenant after each major change.
