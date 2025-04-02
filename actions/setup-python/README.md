# Setup Python

`envasetechnologies/.github/actions/setup-python@v3`

Sets python and installs requirements. By default, it installs the requirements listed in `requirements-dev.txt` which is what we use in most projects, but this can be customized using the `requirements-file` parameter.

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **python-version**: Version of python to setup. Installs 3.11 by default.
- **requirements-file**: File containing the requirements. Uses `requirements-dev.txt` by default.
- **index-url**: Index from where to install the packages. Uses PyPI by default to not leak Artifactory credentials, but it should be set to Artifactory in most cases.

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
        uses: envasetechnologies/.github/actions/setup-python@v3
        with:
          python-version: 3.12
          requirements-file: requirements.txt
          index-url: https://artifactory/url
```
