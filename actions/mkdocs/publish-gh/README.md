# Publish to GitHub Pages

`envasetechnologies/.github/actions/mkdocs/publish-gh`

Uses MkDocs to documentation to GitHub pages. MkDocs requires Python to be installed, and this task uses `uv` to execute the command, so setting up `uv` is a requirement.

## Inputs

- **default-shell**: Uses `bash` but can be overwritten to use `pwsh` in windows.

## Example

```yaml
name: Build Documentation Example

on:
  pull_request:
    branches: [main]

jobs:
  execute-bolt-task:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-source@v3

      - name: Setup Python with UV
        uses: envasetechnologies/.github/actions/setup-uv@v3
        with:
          python-version: 3.12

      - name: Build Documentation
        uses: envasetechnologies/.github/actions/mkdocs/build-docs@v3

      - name: Publish Documentation
        uses: envasetechnologies/.github/actions/mkdocs/publish-gh@v3
```
