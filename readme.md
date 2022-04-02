# Azure DevOps PowerShell (azdo-pwsh)

Welcome to AzDo PowerShell a cross platform module for managing Azure DevOps using things I learned over a few years of working on various client's Azure DevOps installations and migrations.

## Getting Started

### Prerequisites

In order to use this project you need the following:

* [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
* [psake](https://github.com/psake/psake)

The following steps will clone the repo, install all dependencies and execute a build and all unit tests.

1. `git clone git@github.com:rlvandaveer/azdo-pwsh.git`
2. `sl azdo-powershell`
3. `Install-Module -Name psake`
4. `Invoke-psake ./build/tasks.ps1 -taskList Test`

### Running the tests

* `Invoke-psake ./build/tasks.ps1 -taskList Test`

## Structure
- `/build` - contains the code for distributing the module contained in the project
- `/cicd` - contains continuous integration-continuous delivery code
- `/docs` - contains documentation for using and maintaining the project
- `/dist` - created automatically when a build is executed. Contains everything needed to distribute the PowerShell module.
- `/source` - contains the source code for the module
- `/tests` - contains unit tests for the PowerShell module

## Dependencies

This project depends on the following modules/applications to manage dependencies, build, test, version, and publish, and will install them if they are not present when executed:

* [BuildHelpers](https://github.com/RamblingCookieMonster/BuildHelpers)
* [GitVersion](https://gitversion.readthedocs.io/en/latest/)
* [Nuget](https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools)
* [Pester](https://github.com/pester/Pester)
* [Psake](https://github.com/psake/psake)
* [PSDepend](https://github.com/RamblingCookieMonster/PSDepend)
* [PSDeploy](https://github.com/RamblingCookieMonster/PSDeploy)


## Contributing

See the [contribution guide](CONTRIBUTING.md)

## Versioning

This project uses [GitVersion](https://gitversion.readthedocs.io/en/latest/) to automatically version the PowerShell module and Nuget package generated.

## Authors

* **[Robb Vandaveer](https://github.com/rlvandaveer)** - *Creator*

## License

No License

## Code of Conduct

[No Code of Conduct](CODE_OF_CONDUCT.md)