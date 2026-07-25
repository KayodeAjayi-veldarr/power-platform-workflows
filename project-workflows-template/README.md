# Project Workflow Files v15

This folder is used to generate the four caller workflows for a Power Platform
project.

`PROJECT-DETAILS.txt` is the only file you need to edit.

Complete these five required values:

```text
Destination repository
Project key
Solution
Default developer alias
Default developer UPN
```

The two solution folder fields can remain blank. The installer will use:

```text
power-platform/<Solution>
power-platform/<Solution>/src
```

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

Repository settings are intentionally not included in this project template.
Use the central `REPOSITORY-SETTINGS.txt` file in the shared
`power-platform-workflows` repository when setting up each project repository.

The project repository must have access to these GitHub secrets:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

No project-level GitHub Actions variables are required.
