# Power Platform GitHub Workflows

Reusable and starter GitHub Actions workflows for moving Power Platform solutions through a simple ALM flow:

```text
create a short-lived change branch from main
manage a Power Platform development environment
export and commit solution changes
validate a pull request in a clean test environment
build a managed release
import the managed release into the target environment
```

The workflows are designed for low-code teams who want GitHub version control without making every maker learn YAML, PAC CLI, or repository plumbing first.

## What You Get

A repository created from this template already contains runnable project workflows:

- `project-1-manage-power-platform-development-environment.yml` - **1. Manage Power Platform Development Environment**: create, reuse, or delete a development environment and sync a solution baseline.
- `project-2-commit-solution-changes.yml` - **2. Commit Solution Changes**: export an unmanaged solution from a developer environment and commit the unpacked source from a short-lived change branch.
- `project-3-validate-power-platform-pull-request.yml` - **3. Validate Power Platform Pull Request**: pack the solution and validate it in a temporary Power Platform environment.
- `project-4-build-and-deploy-solution.yml` - **4. Build and Deploy Solution**: build a managed release through a clean build environment and deploy it to a target environment.

Those project workflows call the reusable workflows in this repository. No setup workflow needs to create or update `.github/workflows` files, so the template avoids GitHub's workflow-file permission restriction.

## Requirements

Your project repository needs GitHub Actions enabled with read/write workflow permissions.

It must have access to these GitHub Actions secrets, usually as organisation secrets:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

The Entra application behind those secrets must be able to access the Power Platform environments and perform solution import/export. For environment creation and deletion, it also needs the tenant permissions required by Power Platform administration.

For the full repository checklist, see `REPOSITORY-SETTINGS.txt`.

## Quick Setup

### Start From The Template

1. Create a new repository from this template repository.
2. Edit `.github/power-platform-project.json` in the new repository.
3. Replace the starter values with your project details:
   - `project_key`, for example `chess-demo`
   - `solution_name`, for example `ChessPlayingAgent`
   - `default_solution_folder`, for example `power-platform-solution`
   - `default_developer_alias`
   - `default_developer_upn`
   - `base_branch`, usually `main`
   - optional build, validation, and target environment defaults
4. Confirm the project repository can access `PP_TENANT_ID`, `PP_APP_ID`, and `PP_CLIENT_SECRET`.
5. Use the numbered workflows from the Actions tab.

No project-level Actions variables are required. No extra GitHub secret is required beyond the three Power Platform secrets.

### Add To An Existing Repo

Copy these files into the existing project repository:

```text
.github/power-platform-project.json
.github/workflows/project-1-manage-power-platform-development-environment.yml
.github/workflows/project-2-commit-solution-changes.yml
.github/workflows/project-3-validate-power-platform-pull-request.yml
.github/workflows/project-4-build-and-deploy-solution.yml
```

Then edit `.github/power-platform-project.json` and commit the files.

### Local Generated Setup

If you prefer generated per-project workflow files, populate `project-workflows-template/PROJECT-DETAILS.txt`, then run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\project-workflows-template\Install-ProjectWorkflows.ps1 -Force
```

## Normal Workflow

1. Create a short-lived change branch from `main`, such as `change/<work-item>` or `hotfix/<issue>`.
2. Run **1. Manage Power Platform Development Environment** to prepare or reuse a developer environment.
3. Make changes in Power Platform.
4. Run **2. Commit Solution Changes** to export and commit the solution source.
5. Open a pull request.
6. Let **3. Validate Power Platform Pull Request** test the solution in a clean test validation environment.
7. Merge to `main`.
8. Run **4. Build and Deploy Solution** to build and import the managed release.

Hotfixes use the same flow: create a short-lived `hotfix/<issue>` branch from `main`, validate through a pull request, merge back to `main`, then deploy.

## Important Defaults

The project workflows use conservative import behaviour:

- they do not create or guess connector connections
- they do not automatically bind connection references
- they allow unresolved connection references during import
- affected cloud flows may need to be turned on manually after connections are configured

This avoids binding a solution to the wrong identity. Advanced connection binding exists in the reusable workflows, but it is not exposed by default.

Managed deployments should use a clean build environment. The workflow imports unmanaged source there, exports a managed ZIP, stores that ZIP in the repo, and imports the exact same ZIP into the target environment.

Azure Boards linking works through commit messages containing `AB#<work-item-id>`. No Azure DevOps PAT is required when the Azure Boards GitHub integration is connected.

## AI Setup Prompt

Use this prompt with Codex or ChatGPT when setting up a new project repository:

```text
I want to set up this repository to use KayodeAjayi-veldarr/power-platform-workflows for Power Platform ALM.

Please inspect the repository first, then help me configure the project workflow files without adding project-level Actions variables or extra secrets.

Project details:
- Project key: <short-project-key>
- Power Platform solution unique name: <solution-name>
- Default solution folder: <repo-folder-for-solution-source>
- Base branch: main
- Default developer alias: <name>
- Default developer UPN: <email>
- Build environment, if known: <environment-name-or-url>

Update .github/power-platform-project.json with these values. Keep PP_TENANT_ID, PP_APP_ID, and PP_CLIENT_SECRET as the only required Power Platform secrets. Do not create Azure DevOps secrets. Preserve unrelated files and existing workflow conventions.

After setup, verify the workflow YAML parses and explain the normal maker workflow in plain English.
```

## Troubleshooting

- If a reusable workflow cannot be found, confirm this repo is accessible to the project repository from GitHub Actions settings.
- If commits or pull requests fail, confirm workflow permissions are set to read/write and Actions can create pull requests.
- If Power Platform commands fail, confirm the three PP secrets are available to the repository and the Entra application has access to the target environments.
- If imports complete with connection reference warnings, configure the connections in the target environment and turn on the affected flows manually.
