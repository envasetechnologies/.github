# Envase Workflows and Custom Actions

This repo contains reusable starter workflow, workflow templates, and custom actions that can be used as CI/CD for Envase projects. Since the Envase organization uses multiple programming languages and technologies, the organization of these workflows and actions, as well as their naming schemes have been design to avoid confusion when integrating them in CI/CD pipelines.

Starter workflows should be prefixed with the language they target. For example, a starter workflow for a python process that tests and packages a library can be named `python-library-build`. The same workflow for .NET can be named `net-library-build` or `csharp-library-build`.

Workflow templates and actions should be placed in the corresponding language folder: `workflow-templates/<language>` and `actions/<language>`.

# Python: Provided Functionality

This section documents the workflows and actions provided for [Python](https://www.python.org/) projects and that can be reused in new Python projects.
## Python Starter Workflows

There are different starter workflows defined to setup CI/CD for different Python projects. The following sections document which workflows are provided.

### python-ci-library-build

This starter workflow allows you to set CI/CD integration for a Python library, which will test the library, build the package, build the documentation, and post the package to Artifactory on new versions of the library. The workflow invokes the job defined in `envasetechnologies/.github/.github/workflows/python-library-build.yml`, and provides the following configuration options:

* `default-shell`: Overrides the default shell which is set to `bash`.
* `python-version`: String representation of a JSON array containing the versions of Python where to test. By default, it uses 3.7, 3.8, and 3.9.
* `has-documentation`: Indicates whether the library has documentation or not. If the library doesn't have documentation, it skips the documentation build.

It also requires the following secrets:

* `artifactory-password`: The password use for Artifactory access.

## Python Callable Workflows

Starter workflows invoke callable workflows that implement the steps, so that we can easily apply fixes and changes to all projects using the same workflow. The following callable workflows have been provided.

### python-library-build

This workflow implements the steps to test, build and release a Python library used in Envase projects. The workflow exposes the following inputs:

* `default-shell`: Overrides the default shell which is set to `bash`.
* `python-version`: String representation of a JSON array containing the versions of Python where to test. By default, it uses 3.7, 3.8, and 3.9.
* `has-documentation`: Indicates whether the library has documentation or not. If the library doesn't have documentation, it skips the documentation build.
* `runner`: Runner to use for the workflow. By default, it uses `ubuntu-latest`.

It also requires the following secrets:

* `artifactory-password`: The password use for Artifactory access.

## Python Custom Actions

This section documents the usage of the provided custom actions that can be used in Python projects.\

### build-library

This action uses `bolt` to execute the `setup` task and build the library package that can be posted to an index. The action installs the `wheel` package just in case; although, it is recommended to install it as part of the project requirements.

The following shows how to integrate the action:

```yaml
steps:
  - uses: envasetechnologies/.github/actions/python/build-library@v1
```

You can customize the shell to use specifying the `default-shell` parameter:

```yaml
steps:
  - uses: envasetechnologies/.github/actions/python/build-library@v1
    with:
      default-shell: pwsh
```

### build-sphinx-docs

This action builds a [Sphinx](https://www.sphinx-doc.org/) documentation project. The action installs the `sphinx` library; although, it is recommended to list it as part of the project requirements.

The following shows how to integrate the action:

```yaml
steps:
  - uses: envasetechnologies/.github/actions/python/build-sphinx-docs@v1
```

The action runs on `bash` and assumes the documentation project is located in a `docs` folder.

You can customize the shell used by specifying the `default-shell` parameter. Also, you can use a different directory for you documentation project by specifying the `docs-dir` parameter.

```yaml
steps:
  - uses: envasetechnologies/.github/actions/python/build-library@v1
    with:
      docs-dir: ./documentation
      default-shell: pwsh
```

### install-requirements

Installs the necessary requirements for a Python project according to the specified requirements file. The action insures that the latest version of `pip` is installed, so that there are no errors/warnings caused by the tool. It also allows to specify some additional parameters to customize how requirements are installed.

The following shows how to integrate this action using all the default values:

```yaml
steps:
    - uses: envasetechnologies/.github/actions/python/install-requirements@v1
```

The following is the behavior of the default values:

1. Upgrades `pip` to ensure there are no failures/warnings when installing packages caused by the tool.
2. Installs the requirements using the default requirements file and uses **PyPI** as the package index. The default requirements file is set to `requirements-dev.txt` because it is the file used in most projects, so we avoid having to specify it.
3. Displays the packages and versions installed.
4. Creates the default output folder `output`.
5. Generates the installed packages manifest in the default output folder `output/installed-requirements.txt`

The action can be customized in several ways. The following example shows the different parameters supported:

```yaml
steps:
    - uses: envasetechnologies/.github/actions/python/install-requirements@v1
      with:
        requirements-file: requirements.txt
        index-url: https://admin:${{ secrets.ARTIFACTORY_PASSWORD }}@profittools.jfrog.io/profittools/api/pypi/pypi/simple
        output-dir: artifacts
        default-shell: pwsh
```

The following input parameters are supported on the task:

- `requirements-file`: It allows overriding the default requirements file `requirements-dev.txt` as the source to install requirements. We use that file name as default because most project use it or will use it after the migration.
- `index-url`: The index URL from where to install requirements. Most projects will install requirements from [Artifactory](https://profittools.jfrog.io), but the URL requires the password to be used; therefore, we force the URL to be specified as a parameter and by default we use [PyPI](https://pypi.org/).
- `output-dir`: Directory where the requirements manifest will be generated. By default, it will use an `output` folder at the root, but it can be customized by the caller.
- `default-shell`: Most of our projects run on Linux using `bash` as the default shell, but to make the action cross-platform we support overriding the default shell. The value can potentially be any of the supported shell; however, the action is only known to work on `bash` and `pwsh`.

### release

This action uses `bolt` to release a library. The action uses the `post-release` task defined in the project to release the library.

The following shows how to integrate this action:

```yaml
steps:
  - uses: envasetechnologies/.github/actions/python/release@v1
```

You can customize the default shell for this action:

```yaml
steps:
  - uses: envasetechnologies/.github/actions/python/build-library@v1
    with:
      default-shell: pwsh
```

### run-unit-tests

This action uses `bolt` to test a library. The action uses the `cov` task defined in the project to test the library and generate reports for results and coverage.

The following shows how to integrate this action:

```yaml
steps:
  - uses: envasetechnologies/.github/actions/python/release@v1
```

You can customize the default shell for this action:

```yaml
steps:
  - uses: envasetechnologies/.github/actions/python/build-library@v1
    with:
      default-shell: pwsh
```

