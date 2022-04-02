# Defines all of the psake tasks used to build, test, and publish this project

Include build-functions.ps1
Include version-functions.ps1

New-Variable -Name MODULE_NAME -Value 'azdo-pwsh' -Option Constant
New-Variable -Name ROOT_PATH -Value (Split-Path -Parent $PSScriptRoot) -Option Constant
New-Variable -Name BUILD_PATH -Value (Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'build') -Option Constant
New-Variable -Name DISTRIBUTION_PATH -Value (Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'dist') -Option Constant
New-Variable -Name MODULE_DISTRIBUTION_PATH -Value (Join-Path -Path $DISTRIBUTION_PATH -ChildPath $MODULE_NAME) -Option Constant
New-Variable -Name SOURCE_PATH -Value (Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'source') -Option Constant
New-Variable -Name TESTS_PATH -Value (Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'tests') -Option Constant

Properties {
	$BuildContext = @{
		BuildPath = $BUILD_PATH
		DistributionPath = $DISTRIBUTION_PATH
		ModuleDistributionPath = $MODULE_DISTRIBUTION_PATH
		ModuleName = $MODULE_NAME
		PsRepository = @{ Source = 'PSGallery'; Url = 'https://www.powershellgallery.com/api/v2' }
		RootPath = $ROOT_PATH
		SourcePath = $SOURCE_PATH
		TestsPath = $TESTS_PATH
		VersionInfo = $null
	}
}

Task Build -depends Clean, Init -description 'Creates a ready to distribute module with all required files' {

	$BuildContext.VersionInfo = Get-VersionInfo
	if ($ENV:BHBuildSystem -eq 'Azure Pipelines') {
		Write-VersionInfoToAzureDevOps -Version $BuildContext.VersionInfo
	}

	New-Item $BuildContext.DistributionPath -ItemType Directory

	Build-Module -BuildContext $BuildContext

}

Task Check-And-Build -depends Build -description 'Conditionally executes a build if no build output is found' -precondition { return Test-BuildRequired -BuildContext $BuildContext }

Task Clean -description 'Deletes all build artifacts and the distribution folder' {

	Remove-Item $BuildContext.DistributionPath -Recurse -Force -ErrorAction SilentlyContinue

}

Task default -depends Test

Task Init -description 'Initializes the build chain by installing dependencies' {

	$psd = Get-Module PSDepend -listAvailable
	if ($null -eq $psd) {
	  Install-Module PSDepend -AcceptLicense -Force
	}
	Import-Module PSDepend

	Invoke-PSDepend $PSScriptRoot -Force

	Set-BuildEnvironment -Force
}

Task Publish -depends Init, Check-And-Build, Test -description "Publishes the module and all submodules to the $BuildContext.PsRepository.Name" {

	# Depending on whether you want to automatically build when a build is not detected or stop, you can either remove the Check-And-Build dependency and uncomment below or remove these comments
	# Assert (Test-Path -Path (Join-Path -Path $BuildContext.DistributionPath -ChildPath "*") -Include "*.psd1") -failureMessage "Module not built. Please build before publishing."
	Publish-Module -Path $BuildContext.ModuleDistributionPath -Repository $BuildContext.PsRepository.Name -NuGetApiKey $ENV:PSGalleryApiKey

}

Task Test -depends Init, Check-And-Build -description 'Executes all unit tests' {

	$configuration = [PesterConfiguration](Import-PowerShellDataFile -Path (Join-Path -Path $BuildContext.TestsPath -ChildPath pester-configuration.default.psd1))
	$configuration.Run.Path = Join-Path -Path $BuildContext.TestsPath -ChildPath *
	Invoke-Pester -Configuration $configuration

}
