# Project workflow template v26

1. Populate `PROJECT-DETAILS.txt`.
2. Run:

```powershell
.\Install-ProjectWorkflows.ps1 -Force
```

The installer writes only the four caller workflows into the destination
repository's `.github/workflows` folder.

## Required project details

Populate the destination repository, project key, solution logical name,
developer alias and developer UPN. `Default solution folder` can remain blank,
in which case the installer uses `power-platform/<solution-name>`.

`Default build environment` can remain blank, but a build environment must be
entered when running a managed deployment.

## Packages stored in the project repository

```text
<solution_folder>/package/source/
```

contains the exact unmanaged ZIP exported from a source or feature developer
environment.

```text
<solution_folder>/package/release/
```

contains the exact managed ZIP exported from the build environment and used for
downstream deployment. Each ZIP has a matching `.sha256` file.

## Connection references in dynamically created environments

The generated project workflows do not create connections or automatically bind
connection references. They import the solution without a deployment-settings
file and do not request activation of plug-in steps or flows.

The import is allowed to complete when a new environment has no connector
connections. Connection references may remain disconnected and affected cloud
flows may remain off. The workflow artifact includes a text file listing the
connection references found in the package.

After import:

1. Open the solution in the target environment.
2. Create or select the required connector connections.
3. Update each connection reference.
4. Turn on and test the affected flows.

This avoids guessing which connection identity should be used. Advanced
automatic binding remains available in the reusable workflow repository but is
not enabled by the generated project workflows.

## GitHub secrets

The project repository must have access to these organisation secrets:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```
