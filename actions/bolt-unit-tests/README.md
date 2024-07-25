# Bolt Unit Tests

`envasetechnologies/.github/actions/bolt-unit-tests@v3`

This task runs unit tests with coverage generating a report on the PR. The task uses bolt to execute the unit tests, but it doesn't set it up, so it has to be setup prior this task is executed.

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **task**: Bolt task that defines the execution of unit tests. By default, it uses the `cov` task.
- **thresholds**: Thresholds for warning and error on the covered lines. If the coverage rate falls below the minimum allowed, the workflow fails.
- **report**: Location of the coverage XML file after the tests are run.

## Example

```yaml
name: Run Unit Tests Example

on:
  pull_request:
    branches: [main]

jobs:
  install-dependencies:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-sources@v3

      - name: Setup Python
        uses: envasetechnologies/.github/actions/setup-python@v3
        with:
          python-version: 3.12
          requirements-file: requirements.txt
          index-url: https://artifactory/url

      - name: Run Unit Tests
        uses: envasetechnologies/.github/actions/bolt-unit-tests@v3
        with:
          thresholds: '80 90'
          report: coverage.xml
```