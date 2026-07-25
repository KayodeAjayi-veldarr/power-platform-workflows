# Power Platform GitHub Workflows v26

This repository contains four reusable GitHub Actions workflows:

```text
.github/workflows/
├── manage-feature-workspace.yml
├── commit-feature-changes.yml
├── validate-pull-request.yml
└── deploy-solution.yml
```

The project repository contains four small caller workflows generated from
`project-workflows-template`.

## What changed in v26

### Conservative connection handling

The generated project workflows no longer create connections, select existing
connections, generate deployment mappings, or stop an import because a
connection reference is unresolved.

The standard import behaviour is now:

```text
Create or resolve environment
  → import the exact solution package without a deployment-settings file
  → do not request flow or plug-in activation
  → allow unresolved connection references and inactive flows
  → record the connection references in the workflow artifact for manual setup
```

This is the safer default for dynamically created environments because the
workflow does not guess which identity or connection should be used.

After import, a maker or administrator can create the required connections,
update the connection references, and turn on the affected flows.

The reusable workflows still contain the advanced automatic binding capability,
but it is disabled by default and the generated caller workflows do not expose
it. It should be enabled only where connection identities and mapping rules have
been deliberately designed.

### Exact packages and build-environment releases

Source and feature exports are still saved before unpacking:

```text
<solution_folder>/package/source/
├── <solution>_unmanaged.zip
└── <solution>_unmanaged.zip.sha256
```

Managed downstream releases still use the build-environment pattern:

```text
Git source
  → pack unmanaged build input
  → import into the build environment
  → export an exact managed ZIP
  → commit the managed ZIP and SHA256
  → import that exact managed ZIP into the target environment
```

The managed release is stored under:

```text
<solution_folder>/package/release/<solution>_managed.zip
```

### Feature workspace names

When no workspace environment name is entered, the generated name includes the
feature branch. Different feature branches therefore receive different default
environment names.

## Project setup

Populate `project-workflows-template/PROJECT-DETAILS.txt`, then run:

```powershell
.\project-workflows-template\Install-ProjectWorkflows.ps1 -Force
```

No project-level GitHub Actions variables are required. The project repository
must have access to:

```text
PP_TENANT_ID
PP_APP_ID
PP_CLIENT_SECRET
```

For managed releases, enter a clean build environment in the deployment form or
set `Default build environment` in `PROJECT-DETAILS.txt`.

## Normal lifecycle

```text
Create feature branch
  → prepare feature workspace
  → exact source ZIP committed immediately
  → solution imported with connection references left for manual setup
  → make changes
  → exact feature export and unpacked source committed
  → pull request validation in a clean temporary environment
  → merge to main
  → build managed release in build environment
  → deploy exact managed release to target
  → configure target connections and enable affected flows when required
```

Azure Boards linking remains available through `AB#<work-item-id>` references in
commit messages.
