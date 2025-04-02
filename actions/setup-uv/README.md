# Setup UV

`envasetechnologies/.github/actions/setup-uv@v3`

Sets Python and UV, and installs the dependencies to create the workflow environment. The dependencies are installed by synching from the `uv.lock` file.

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **python-version**: Version of python to setup. Installs 3.11 by default.

## Environment Variables

Most of our projects use Artifactory to host dependencies and will want to use that index to install them. The workflow must set the `UV_INDEX` environment variable to the Artifactory index with the valid credentials.

## Example

```yaml
name: Setup UV Example

on:
  pull_request:
    branches: [main]

jobs:
  install-dependencies:
    runs-on: ubuntu-latest
    env:
      url = "https://admin:${{secrets.ARTIFACTORY_PASSWORD}}profittools.jfrog.io/profittools/api/pypi/pypi/simple"
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-source@v3

      - name: Setup Python
        uses: envasetechnologies/.github/actions/setup-uv@v3
        with:
          python-version: 3.12
```
