# Envase Technologies GitHub Actions

This repo contains custom GitHub actions for the Envase Technologies organization. These actions are suitable to be used in workflows for repositories of the `/envasetechnologies` organization.

The following sections document the provided actions.

> The documentation must be up-to-date and maintained in alphabetical order by the action name.


## Bolt

Executes the specified bolt task. Python and bolt are required for the task to run, but they are not installed by the task, so they should be setup prior to executing this task.

### Inputs

- default-shell: Uses `bash` but can be overwritten to use `pwsh` in windows.
- task: The task to execute. The task must be defined in a `boltfile.py`.

### Example

```yaml
name: Execute Bolt Task

on:
  pull_request:
    branches: [main]

jobs:
  execute-bolt-task:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
              uses: envasetechnologies/.github/actions/checkout-sourcet@v3
        
      - name: Setup Python (requirements-dev.txt contains bolt-ta)
        uses: envasetechnologies/.github/actions/setup-python@v3

      - name: Run Unit Tests in CI Through Bolt Task
        uses: envasetechnologies/.github/actions/bolt@v3
        with:
          task: cov
```

## Checkout Source

This task wraps the standard `checkout` action. This allows us to use the same version of the action in all workflows and update it when needed.

### Example

```yaml
name: Checkout Source

on: 
    pull_request:
        branches: [main]

jobs:
    checkout-sources:
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Source
              uses: envasetechnologies/.github/actions/checkout-sourcet@v3
```

## NPM Install Packages from Artifactory

Installs npm packages from and Artifactory repository. A virtual repository has been setup to mirror npm and the hosted packages for envase technologies. This repository can be used as the single source for all the dependencies.

### Inputs
- default-shell: Uses `bash` but can be overwritten to use `pwsh` in windows.
- registry: The Artifactory registry to use. The default points to the Envase registry that can be used as single source of packages.

### Example

```yaml
name: Install NPM from Artifactory

on: 
    pull_request:
        branches: [main]

jobs:
    install-dependencies:
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Source
              uses: envasetechnologies/.github/actions/checkout-sourcet@v3

            - name: Setup Node
              uses: actions/setup-node@v4
              with:
                node-version: 18
                registry-url: https://npm.pkg.github.com
                scope: '@envasetechnologies'

            - name: Install Dependencies
              uses: envasetechnologies/.github/actions/npm-artifactory-install@v3
              with:
                token: ${{ secrets.ARTIFACTORY_TOKEN }}

```

## NPM Publish Package to Artifactory

Publishes the project package to Artifactory. All the configuration happens in `package.json`, and this action publishes the build to an Artifactory registry.

### Inputs
- default-shell: Uses `bash` but can be overwritten to use `pwsh` in windows.
- registry: The local Artifactory registry where the package is published. The default points to the `npm-local` registry in Artifactory.

### Example

```yaml
name: Install NPM from ARtifactory

on:
    pull_request:
        branches: [main]

jobs:
    install-dependencies:
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Source
              uses: envasetechnologies/.github/actions/checkout-sourcet@v3

            - name: Setup Node
              uses: actions/setup-node@v4
              with:
                node-version: 18
                registry-url: https://npm.pkg.github.com
                scope: '@envasetechnologies'

            - name: Install Dependencies
              uses: envasetechnologies/.github/actions/npm-artifactory-publish@v3
              with:
                token: ${{ secrets.ARTIFACTORY_TOKEN }}
```

## Setup Python

Sets python and installs requirements. By default, it installs the requirements listed in `requirements-dev.txt` which is what we use in most projects, but this can be customized using the `requirements-file` parameter.

### Inputs

- default-shell: Uses `bash` but can be overwritten to use `pwsh` in windows.
- python-version: Version of python to setup. Installs 3.11 by default.
- requirements-file: File containing the requirements. Uses `requirements-dev.txt` by default.
- index-url: Index from where to install the packages. Uses PyPI by default to not leak Artifactory credentials, but it should be set to Artifactory in most cases.

### Example

```yaml
name: Install NPM from ARtifactory

on:
    pull_request:
        branches: [main]

jobs:
    install-dependencies:
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Source
              uses: envasetechnologies/.github/actions/checkout-sourcet@v3

            - name: Setup Python
              uses: envasetechnologies/.github/actions/setup-python@v3
              with:
                python-version: 3.12
                requirements-file: requirements.txt
                index-url: https://artifactory/url
```

> INFO: Additional actions coming soon. Use v1 or v2 for earlier workflows.