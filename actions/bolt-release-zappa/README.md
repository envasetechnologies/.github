# Bolt Release

Releases a project through Zappa using bolt.

## Inputs

- default-shell: Uses `bash` but can be overwritten to use `pwsh` in windows.
- fetch-tags: Whether tags should be fetch from origin. By default, it doesn't fetch the tags.
- task: Configured release task. By default, it invokes `post-release`.
- requirements-file: The production requirements file. It defaults to `requirements.txt` which should have frozen requirements.

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
        uses: envasetechnologies/.github/actions/checkout-sourcet@v3

      - name: Setup Python (requirements-dev.txt contains bolt-ta)
        uses: envasetechnologies/.github/actions/setup-python@v3

      - name: Run Feature Tests in CI Through Bolt Task
        uses: envasetechnologies/.github/actions/bolt-release-zappa@v3
        with:
          fetch-tags: true
          task: deploy-production
```