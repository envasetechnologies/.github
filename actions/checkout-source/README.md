# Checkout Source

`envasetechnologies/.github/actions/checkout-source@v3`

This task wraps the standard `checkout` action. This allows us to use the same version of the action in all workflows and update it when needed.

# Example

```yaml
name: Checkout Source Example

on:
  pull_request:
    branches: [main]

jobs:
  checkout-source:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: envasetechnologies/.github/actions/checkout-source@v3
```
