# Setup Node

`envasetechnologies/.github/actions/setup-noden@v3`

Sets node and installs requirements. It installs the requirements from Artifactory, so the parameters to access it are exposed.

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **node-version**: Version of node to install. By default installs version 18.
- **registry**: The Artifactory registry to use. The default points to the Envase registry that can be used as single source of packages.
- **omit-dev**: Omit dev requirements.
- **token**: Token to access Artifactory.

## Example

```yaml
name: Setup Python Example

on:
  pull_request:
    branches: [main]

jobs:
  install-dependencies:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-source@v3

      - name: Setup Python
        uses: envasetechnologies/.github/actions/setup-node@v3
        with:
          node-version: 21
          token: ${{ secrets.ARTIFACTORY_TOKEN }}
```
