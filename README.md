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

A repository created from this template does not need access to the original template repository. The project workflows call reusable workflows stored in the same repository.

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
5. Open a pull request.
6. Run **3. Validate Power Platform Pull Request** to test the solution in a temporary validation environment.
7. Merge the approved pull request into `main`.
8. Run **4. Build and Deploy Solution** to create and import the managed release.

Hotfixes use the same flow. The only difference is the branch name and urgency.

## The Actions

| Action | Use it for |
| --- | --- |
| **1. Manage Power Platform Development Environment** | Prepare, reuse, or delete a maker development environment. |
| **2. Commit Solution Changes** | Export an unmanaged solution and commit the unpacked source. |
| **3. Validate Power Platform Pull Request** | Pack and import the solution into a temporary validation environment. |
| **4. Build and Deploy Solution** | Build a managed ZIP and deploy the exact release package. |

The `Internal - Reusable ...` workflows are implementation details used by the numbered project workflows.

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

## AI Setup Prompt

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

## Troubleshooting

- If Actions cannot commit or create a pull request, check workflow permissions.
- If Power Platform authentication fails, check the three `PP_*` secrets and the Entra app registration.
- If import/export fails, confirm the Entra app exists as an application user in the relevant environments and has the required Dataverse role.
- If Azure Boards links do not appear, confirm the Azure Boards GitHub app is connected to the repository and the commit or PR contains `AB#<id>`.
