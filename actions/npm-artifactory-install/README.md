# NPM Install Packages from Artifactory

`envasetechnologies/.github/actions/npm-artifactory-install@v3`

Installs NPM packages from and Artifactory repository. A virtual repository has been setup to mirror NPM and the hosted packages for envase technologies. This repository can be used as the single source for all the dependencies.

## Inputs
- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **registry**: The Artifactory registry to use. The default points to the Envase registry that can be used as single source of packages.

## Example

```yaml
name: Install from Artifactory Example

on:
  pull_request:
    branches: [main]

jobs:
  install-dependencies:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-sources@v3

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
