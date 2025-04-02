# Build Sphinx Docs

``envasetechnologies/.github/actions/build-sphinx-docs@v3`

Builds HTML documentation from a Sphinx project. The action requires Python to be installed. The `sphinx` module will be installed by the action if is not already installed. It is recommended that `sphinx` is installed prior to control the version which will be used. Any other plug-ins and themes must be installed prior to run this action.

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **docs-dir**: Location where the documentation project resides. By default, it uses `./docs`.

## Exmample

```yaml
name: Build Sphinx Docs Example

on:
  pull_request:
    branches: [main]

jobs:
  install-dependencies:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-source@v3

      - name: Build Documentation
        uses: envasetechnologies/.github/actions/build-sphinx-docs@v3
        with:
          docs-dir: ./documentation
```