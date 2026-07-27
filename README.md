# Power Platform GitHub Workflows

A self-contained GitHub template for Power Platform ALM.

Create a repository from this template, update one project config file, add the Power Platform secrets, then use the numbered GitHub Actions workflows to manage changes from branch to deployment.

## What You Get

- Short-lived change or hotfix branches from `main`
- Developer environment prepare/reuse/delete workflow
- Solution export and commit workflow
- Pull request validation in a clean test environment
- Managed build and deployment workflow
- Optional Azure Boards linking with `AB#` work item references

A repository created from this template does not need access to the original template repository. The numbered project workflows call reusable workflows stored in the same repository.

## Quick Setup

1. Create a new repository from this template.
2. Edit `.github/power-platform-project.json`.
3. Add or grant access to these GitHub Actions secrets:
   - `PP_TENANT_ID`
   - `PP_APP_ID`
   - `PP_CLIENT_SECRET`
4. In GitHub, open `Settings > Actions > General`.
5. Set workflow permissions to `Read and write permissions`.
6. Enable `Allow GitHub Actions to create and approve pull requests`.
7. Use the numbered workflows in the Actions tab.

No project-level GitHub Actions variables are required.

## Project Config

Update `.github/power-platform-project.json` with your project values:

```json
{
  "project_key": "chess-demo",
  "solution_name": "ChessPlayingAgent",
  "default_solution_folder": "power-platform-solution",
  "default_developer_alias": "kayode",
  "default_developer_upn": "maker@contoso.com",
  "base_branch": "main"
}
```

Keep the other fields when you need default region, currency, validation, build, or role settings.

## Normal Flow

1. Create a short-lived branch from `main`, for example `change/482-instruction-screen` or `hotfix/login-error`.
2. Run **1. Manage Power Platform Development Environment** to prepare or reuse a developer environment.
3. Make the change in Power Platform.
4. Run **2. Commit Solution Changes** to export and commit the solution source.
5. Open or review the pull request.
6. Run **3. Validate Power Platform Pull Request** to test the solution in a temporary validation environment.
7. Merge the approved pull request into `main`.
8. Run **4. Build and Deploy Solution** to create and import the managed release.

Hotfixes use the same flow. The only difference is the branch name and urgency.

## Which Workflow To Run

Run the numbered workflows. The `Internal - Reusable ...` workflows are implementation details used by the numbered project workflows.

| Workflow | When to use it | Main result |
| --- | --- | --- |
| **1. Manage Power Platform Development Environment** | At the start of a change, or when cleaning up a feature environment. | A maker-ready environment, optional baseline commit, and links in the run summary. |
| **2. Commit Solution Changes** | After making changes in the Power Platform maker portal. | Exported solution source committed to the branch, optional PR, and solution artifact. |
| **3. Validate Power Platform Pull Request** | Automatically on PRs to `main`, or manually before review. | Temporary validation import, optional Solution Checker results, and artifacts. |
| **4. Build and Deploy Solution** | After PR approval/merge when releasing to test, UAT, or production. | Managed ZIP built from source, stored artifact, optional committed ZIP, and target import. |

## Workflow 1: Manage Power Platform Development Environment

Use this to prepare a maker environment for the current branch, or delete one when the work is finished.

Typical start-of-work values:

| Input | What to enter |
| --- | --- |
| `workspace_action` | `PrepareOrReuse` |
| `developer_alias` | Short maker name, for example `kayode`. Blank uses project config. |
| `developer_upn` | Maker email address. Blank uses project config. |
| `source_environment` | Optional existing environment to copy the baseline solution from. Leave blank if no baseline import is needed. |
| `source_solution_name` | Optional source solution unique name. Blank uses project config. |
| `solution_folder` | Optional repo folder. Blank uses project config. |
| `workspace_environment` | Optional existing dev environment name, URL, or ID. Blank lets the workflow generate one. |
| `workspace_environment_domain` | Optional URL prefix for a new environment, 2-32 characters. Blank auto-generates. |
| `workspace_environment_type` | `Developer` for individual maker work. `Sandbox` or `Trial` only when needed. |
| `workspace_environment_mode` | `ReuseOrCreate` for normal use. `CreateOnly` if you want failure when the environment exists. |
| `commit_baseline_to_branch` | `true` when you want the source baseline committed to the branch. |

Deletion values:

| Input | What to enter |
| --- | --- |
| `workspace_action` | `DeleteEnvironment` |
| `workspace_environment` | The exact environment name, URL, or ID to delete. |
| `deletion_confirmation` | `DELETE:<exact-environment-name>` |

Outputs to look for:

- GitHub run summary with environment name and maker portal link
- Environment URL and ID in the job output
- Optional baseline commit on the branch
- Optional exported solution artifact

## Workflow 2: Commit Solution Changes

Use this after the maker has changed the app, flow, table, agent, or other solution component in the developer environment.

| Input | What to enter |
| --- | --- |
| `developer_alias` | Short maker name for commit and PR text. |
| `developer_environment` | Environment name, URL, or ID where the changes were made. |
| `solution_folder` | Optional repo folder. Blank uses project config. |
| `commit_message` | Optional Git message. Blank generates one. Include `AB#123` if linking manually. |
| `azure_work_item_ids` | Optional Azure Boards IDs, for example `123` or `123,456`. |
| `create_pull_request` | `true` to create or update a PR back to the base branch. |
| `pull_request_title` | Optional PR title. Blank generates one. |
| `pull_request_draft` | `true` while still reviewing. Set `false` when ready for normal review. |

Outputs to look for:

- Exported unmanaged solution ZIP artifact
- Updated unpacked solution source under the configured solution folder
- Git commit pushed to the current branch
- Pull request link when PR creation is enabled
- Azure Boards links when the repo is connected and `AB#` references are present

## Workflow 3: Validate Power Platform Pull Request

This runs automatically when a PR targets `main`. You can also run it manually from Actions.

| Input | What to enter |
| --- | --- |
| `source_ref` | Manual runs only. Branch or commit to validate. Blank uses the selected branch. |
| `solution_folder` | Optional repo folder. Blank uses project config. |
| `validation_environment_type` | `Sandbox` is normal. |
| `validation_environment_region` | Optional region. Blank uses project config. |
| `validation_environment_currency` | Optional currency. Blank uses project config. |
| `validation_environment_language` | Optional language. Blank uses project config. |
| `retain_validation_environment_on_failure` | `true` only when someone needs to inspect a failed temporary environment. |
| `run_solution_checker` | `true` to run Solution Checker. |
| `checker_fail_on_errors` | `true` if error-level checker findings should fail the workflow. |

Outputs to look for:

- Temporary validation environment name and URL
- Import result
- Solution Checker output, when enabled
- Validation artifacts
- The temporary environment is deleted after validation unless retention is requested on failure

## Workflow 4: Build and Deploy Solution

Use this after a change is approved and merged, usually from `main`.

| Input | What to enter |
| --- | --- |
| `source_ref` | Approved branch, tag, or commit to release. Usually `main`. |
| `solution_folder` | Optional repo folder. Blank uses project config. |
| `build_environment` | Clean build environment name, URL, or ID. Blank uses project config. |
| `target_environment` | Environment name, URL, or ID that receives the release. |
| `solution_package_type` | `Managed` for test/UAT/production. `Unmanaged` only for special cases. |
| `commit_solution_zip` | `true` to store the exact generated release ZIP in the repo. |

Outputs to look for:

- Managed or unmanaged release ZIP artifact
- Optional committed release ZIP under the solution package folder
- Target import result
- Deployment summary with source ref, package type, and target environment

## Azure Boards

Azure Boards linking is optional. If the Azure Boards GitHub app is connected to the repository, include work item references when running **2. Commit Solution Changes**.

Examples:

```text
482
482,483
AB#482 AB#483
```

The workflow adds the references to the commit message and pull request body so Azure Boards can link the development work. No Azure DevOps PAT or extra secret is required.

## Connection References

By default, the project workflows use conservative import behaviour:

- They do not create connector connections.
- They do not guess connection reference bindings.
- Imports can complete with unresolved connection references.
- Cloud flows may need to be turned on manually after connections are configured.

This avoids binding a solution to the wrong identity during demos, tests, and production deployments.

## AI Agent Setup Prompt

Use this with Codex, ChatGPT, or GitHub Copilot when starting a new project:

```text
Help me configure this repository for the Power Platform workflow template already present in the repo.

Project details:
- Project key: <short-project-key>
- Power Platform solution unique name: <solution-name>
- Default solution folder: <repo-folder-for-solution-source>
- Base branch: main
- Default developer alias: <name>
- Default developer UPN: <email>
- Build environment, if known: <environment-name-or-url>

Please update .github/power-platform-project.json only. Keep PP_TENANT_ID, PP_APP_ID, and PP_CLIENT_SECRET as the only required Power Platform secrets. Do not add Azure DevOps secrets or project-level GitHub Actions variables. Preserve unrelated files.

After setup, verify the workflow YAML references local reusable workflows and explain the normal maker workflow in plain English.
```

## AI Agent Run Prompt

Use this when asking an AI agent to help run or troubleshoot the workflow process:

```text
We are using the self-contained Power Platform GitHub workflow template in this repo.

Please inspect .github/power-platform-project.json and the numbered workflows before advising.
Only the numbered workflows are user-facing:
1. Manage Power Platform Development Environment
2. Commit Solution Changes
3. Validate Power Platform Pull Request
4. Build and Deploy Solution

Explain which workflow to run next, which inputs to fill in, which values can be left blank because they come from project config, and what output should confirm success. Do not ask for new secrets unless the existing PP_TENANT_ID, PP_APP_ID, and PP_CLIENT_SECRET are genuinely missing or inaccessible.
```

## Troubleshooting

- If Actions cannot commit or create a pull request, check workflow permissions.
- If a workflow cannot find a solution folder, confirm `.github/power-platform-project.json` points to the folder that contains `src`.
- If Power Platform authentication fails, check the three `PP_*` secrets and the Entra app registration.
- If environment creation fails on `--domain`, use a short lowercase domain such as `chessappdemo` or leave the field blank so the workflow generates one.
- If import/export fails, confirm the Entra app exists as an application user in the relevant environments and has the required Dataverse role.
- If Azure Boards links do not appear, confirm the Azure Boards GitHub app is connected to the repository and the commit or PR contains `AB#<id>`.
