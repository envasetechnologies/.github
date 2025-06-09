# Check Coverage

`envasetechnologies/.github/actions/check-coverage@v3`

This task checks the coverage results and adds the report to a pull request. This task should be used after the a task to execute the unit tests has been executed. The task running the unit tests must generate the code coverage report in XML format.

The main reason for this task is to run the unit tests using `uv` and `bolt` (see example below).

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
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
        uses: envasetechnologies/.github/actions/checkout-source@v3

      - name: Setup Python
        uses: envasetechnologies/.github/actions/setup-python@v3
        with:
          python-version: 3.12
          requirements-file: requirements.txt
          index-url: https://artifactory/url

      - name: Run Unit Tests
        run: uv run bolt cov

      - name: Check Coverage
        uses: envasetechnologies/.github/actions/check-coverage@v3
        with:
          thresholds: '80 90'
          report: coverage.xml
```