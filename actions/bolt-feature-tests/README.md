# Bolt Feature Tests

`envasetechnologies/.github/actions/bolt@v3`

Executes the feature tests using bolt. It runs the `ftci` task by default, but it can be modified through the task input.

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **task**: Bolt task that defines the execution of feature tests. By default, it uses `ftci` task.

## Example

```yaml
name: Run Feature Tests Exmple

on:
  pull_request:
    branches: [main]

jobs:
  execute-bolt-task:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-sources@v3

      - name: Setup Python (requirements-dev.txt contains bolt-ta)
        uses: envasetechnologies/.github/actions/setup-python@v3

      - name: Run Feature Tests in CI Through Bolt Task
        uses: envasetechnologies/.github/actions/bolt@v3
```
