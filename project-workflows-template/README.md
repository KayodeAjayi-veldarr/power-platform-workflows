# Project Workflows Template

This folder is copied into a new Power Platform project repository.

It gives the project four workflows:

```text
.github/workflows/
├── manage-feature-workspace.yml
├── commit-feature-changes.yml
├── validate-pull-request.yml
└── deploy-solution.yml
```

The files do not contain a fixed environment name, URL, ID or Dataverse
domain.

Environment values come from the workflow popup or GitHub repository
variables.

---

## Quick start

### 1. Copy the workflow folder

Copy:

```text
project-workflows-template/.github
```

into the root of the new project repository.

Or run:

```powershell
.\Copy-ProjectWorkflows.ps1 `
  -DestinationRepositoryPath "C:\Repos\new-project"
```

### 2. Add repository secrets

Create:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

under:

```text
Settings
→ Secrets and variables
→ Actions
→ Secrets
```

### 3. Add repository variables

At minimum, configure:

```text
PP_PROJECT_KEY
PP_SOLUTION_NAME
PP_SOLUTION_PROJECT_FOLDER
PP_SOLUTION_SOURCE_FOLDER
PP_DEFAULT_DEVELOPER_ALIAS
PP_DEFAULT_DEVELOPER_UPN
PP_TARGET_REGION
PP_TARGET_CURRENCY
PP_TARGET_LANGUAGE
PP_CHECKER_GEO
```

The file `REPOSITORY-SETTINGS.example.txt` contains the full list.

### 4. Commit the workflows to main

The caller workflows must exist on `main` before creating the feature branch.

### 5. Create a feature branch

Create it from the latest `main`.

### 6. Prepare the workspace

Open:

```text
Actions
→ Manage Feature Workspace
```

Choose:

```text
workspace_action: PrepareOrReuse
```

Enter a source environment in the popup, or configure:

```text
PP_DEFAULT_SOURCE_ENVIRONMENT
```

Enter an exact developer environment display name, configure:

```text
PP_DEFAULT_DEVELOPER_ENVIRONMENT
```

or leave it blank so the workflow generates a name.

---

## Environment variables are optional

These values are intentionally blank in the template:

```text
PP_DEFAULT_SOURCE_ENVIRONMENT
PP_DEFAULT_DEVELOPER_ENVIRONMENT
PP_DEFAULT_DEPLOYMENT_ENVIRONMENT
```

Leaving them blank means the user enters the environment when running the
workflow.

Configuring them means the project has a convenient default, but the popup can
still override it for a single run.

---

## Normal development flow

### Start work

```text
Manage Feature Workspace
→ PrepareOrReuse
```

### Bring Power Platform changes back into Git

```text
Commit Feature Changes
```

Run it from the same feature branch.

### Validate the pull request

```text
Validate Power Platform Pull Request
```

This runs automatically for pull requests into `main`.

It creates and removes its own temporary validation environment.

### Deploy the merged solution

```text
Deploy Solution from Git
```

Use `main` as the source ref and enter the target environment name, URL or ID.

### Delete an old developer environment

```text
Manage Feature Workspace
→ DeleteEnvironment
```

Enter:

```text
DELETE:resolved-environment-name
```

in the deletion confirmation field.

---

## What the user enters in each workflow

### Manage Feature Workspace

For `PrepareOrReuse`:

```text
Developer alias
Developer UPN
Source environment
Source solution name
Developer environment display name or blank
Environment type
Region
Currency
Language
```

For `DeleteEnvironment`:

```text
Environment name, URL or ID
Deletion confirmation
```

### Commit Feature Changes

```text
Developer environment name, URL or ID
Commit message
Create pull request
Draft pull request
```

### Validate Pull Request

Normally no manual input is needed.

A manual run can select:

```text
Source ref
Validation environment type
Region
Currency
Language
Retain environment on failure
Run Solution Checker
Fail on checker errors
```

### Deploy Solution from Git

```text
Source branch, tag or commit
Target environment name, URL or ID
Managed or unmanaged package
Publish changes
```

---

## Important notes

The `PrepareOrReuse` action currently expects an exact display name when
reusing an existing developer environment.

The Commit, Delete and Deploy operations accept an environment name, URL or
ID.

The validation environment is temporary and should not be used for
development or test data.

The persistent developer environment can be reused for the next feature after
the current changes have been committed and merged.

---

## Before the first live run

Check:

```text
The service principal can access the source environment
The service principal can create or access developer environments
The service principal can import and export solutions
The developer UPN exists in Microsoft Entra ID
The project folders match the repository structure
The selected feature branch contains the caller workflows
```

Use a controlled test before relying on the workflows for an important
deployment.
