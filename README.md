# Envase Technologies GitHub Actions

This repo contains custom GitHub actions for the Envase Technologies organization. These actions are suitable to be used in workflows for repositories of the `/envasetechnologies` organization.

The following sections document the provided actions.

> The documentation must be up-to-date and maintained in alphabetical order by the action name.

## NPM Install Packages from Artifactory

Installs npm packages from and Artifactory repository. A virtual repository has been setup to mirror npm and the hosted packages for envase technologies. This repository can be used as the single source for all the dependencies.

### Inputs
- default-shell: Uses `bash` but can be overwritten to use `pwsh` in windows.
- registry: The artifactory registry to use. The default points to the Envase registry that can be used as single source of packages.

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
            - uses: actions/checkout@v4

            - uses: actions/setup-node@v4
              with:
                  node-version: 18
                  registry-url: https://npm.pkg.github.com
                  scope: '@envasetechnologies'

            - name: Install Dependencies
              uses: envasetechnologies/.github/actions/npm-artifactory-install@v3

```

## NPM Publish Package to Artifactory

Publishes the project package to artifactory. All the configuration happens in `package.json`, and this action publishes the build to an Artifactory registry.

### Inputs
- default-shell: Uses `bash` but can be overwritten to use `pwsh` in windows.
- registry: The local artifactory registry where the package is published. The default points to the `npm-local` registry in Artifactory.

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
            - uses: actions/checkout@v4

            - uses: actions/setup-node@v4
              with:
                  node-version: 18
                  registry-url: https://npm.pkg.github.com
                  scope: '@envasetechnologies'

            - name: Install Dependencies
              uses: envasetechnologies/.github/actions/npm-artifactory-publish@v3
```

> INFO: Additional actions coming soon. Use v1 or v2 for earlier workflows.