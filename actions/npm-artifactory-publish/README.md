# NPM Publish Package to Artifactory

`envasetechnologies/.github/actions/npm-artifactory-publish@v3`

Publishes the project package to Artifactory. All the configuration happens in `package.json`, and this action publishes the build to an Artifactory registry.

## Inputs
- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **registry**: The local Artifactory registry where the package is published. The default points to the `npm-local` registry in Artifactory.

## Example

```yaml
name: Publish to Artifactory Example

on:
  pull_request:
    branches: [main]

jobs:
  install-dependencies:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-source@v3

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
