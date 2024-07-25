# Envase Technologies GitHub Actions

This repo contains custom GitHub actions for the Envase Technologies organization. These actions are suitable to be used in workflows for repositories of the `/envasetechnologies` organization.

The following sections document the provided actions.

## Setup Actions

These actions setup tools used on the CI/CD process:

- [checkout-source](./actions/checkout-source): Checkout the repository source.
- [setup-python](./actions/setup-python): Setup of Python and installation of requirements.

## NPM Interaction with Artifactory

These actions work with an NPM index in Artifactory:

- [npm-artifactory-install](./actions/npm-artifactory-install): Installs NPM packages from Artifactory.
- [npm-artifactory-publish](./actions/npm-artifactory-publish): Publishes a NPM package to Artifactory.


## Common Bolt Tasks

These actions execute commonly implemented bolt tasks.

- [bolt](./actions/bolt): Executes the specified bolt task.
- [bolt-unit-tests](./actions/bolt-unit-tests): Executes the project unit tests through bolt.
- [bolt-feature-tests](./actions/bolt-feature-tests): Executes the project feature tests through bolt.
- [bolt-release](./actions/bolt-release): Releases the project through bolt.

## Specialized Deployments

- [bolt-release-zappa](.actions/bolt-release-zappa): Deploys a Flask application to AWS Lambda using Zappa.
