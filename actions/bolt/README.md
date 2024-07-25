# Bolt

`envasetechnologies/.github/actions/bolt@v3`

Executes the specified bolt task. Python and bolt are required for the task to run and must be setup before executing this action.

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.
- **task**: The task to execute. The task must be defined in a `boltfile.py`.

## Example

```yaml
name: Execute Bolt Task

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

      - name: Run Unit Tests in CI Through Bolt Task
        uses: envasetechnologies/.github/actions/bolt@v3
        with:
          task: configured-task
```
