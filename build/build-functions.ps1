<#
.SUMMARY
	Builds the PowerShell module and any submodules
#>
function Build-Module {
	[CmdletBinding()]
	param (
		[ValidateNotNull()]
		[hashtable]
		$BuildContext
	)

	$publicFuncs = Get-ChildItem -Path (Join-Path -Path $BuildContext.SourcePath -ChildPath "Public/*") -Include @("*.ps1", "*.psm1") -Recurse
	$privateFuncs = Get-ChildItem -Path (Join-Path -Path $BuildContext.SourcePath -ChildPath "Private/*") -Include @("*.ps1", "*.psm1") -ErrorAction Ignore
	$classes = Get-ChildItem -Path (Join-Path -Path $BuildContext.SourcePath -ChildPath "Classes/*") -Include @("*.ps1", "*.psm1") -Recurse -ErrorAction Ignore

	New-Item $BuildContext.ModuleDistributionPath -ItemType Directory

	Get-ChildItem -Path (Join-Path -Path $BuildContext.SourcePath -ChildPath "*") -Include @("*.ps1", "*.psm1") -Exclude "*.definition.psd1" | Copy-Item -Destination $BuildContext.ModuleDistributionPath

	$publicFuncs | Copy-Item -Destination $BuildContext.ModuleDistributionPath
	$privateFuncs | Copy-Item -Destination $BuildContext.ModuleDistributionPath
	$classes | Copy-Item -Destination $BuildContext.ModuleDistributionPath

	Build-ModuleDefinition $BuildContext $publicFuncs $privateFuncs $classes

}

<#
.SUMMARY
	Creates the module's manifest using the definition data file
#>
function Build-ModuleDefinition {
	[CmdletBinding()]
	param (
		[ValidateNotNull()] [hashtable] $BuildContext,
		[System.IO.FileInfo[]] $PublicFuncs,
		[System.IO.FileInfo[]] $PrivateFuncs,
		[System.IO.FileInfo[]] $Classes
	)

	$defPath = Get-ChildItem -Path (Join-Path -Path $BuildContext.SourcePath -ChildPath "*") -Include "*.definition.psd1"

	$definition = Import-PowerShellDataFile -Path $defPath.FullName

	$name = $defPath.Name.Split('.')[0]
	$path = (Join-Path -Path $BuildContext.ModuleDistributionPath -ChildPath "$name.psd1")

	$definition.Add("Path", $path)
	$definition.Add("ModuleVersion", $BuildContext.VersionInfo.MajorMinorPatch)

	if ($BuildContext.versionInfo.NuGetPreReleaseTagV2) {
		$definition.PrivateData.PSData.Add('Prerelease', $BuildContext.versionInfo.NuGetPreReleaseTagV2)
	}

	if ($null -ne $PublicFuncs) {
		$definition.FileList += [string[]]$PublicFuncs.Name
		$definition.FunctionsToExport += $PublicFuncs.BaseName
	}
	if ($null -ne $PrivateFuncs) {
		$definition.FileList += [string[]]$PrivateFuncs.Name
	}
	if ($null -ne $Classes) {
		$definition.FileList += [string[]]$Classes.Name
	}
	if (($null -ne $PublicFuncs) -or ($null -ne $PrivateFuncs)) {
		$definition.NestedModules += Get-NestedModules $PublicFuncs $PrivateFuncs #$Classes
	}

	if (($null -ne $Classes)) {
		$definition.ScriptsToProcess += $Classes.Name
	}

	New-ModuleManifest @definition

	# Update PrivateData as New-ModuleManifest butchers it: https://github.com/PowerShell/PowerShell/issues/5922, https://github.com/PowerShell/PowerShellGet/issues/294#issuecomment-401151546
	if ($null -ne $definition.PrivateData) {
		Update-Metadata -Path $path -PropertyName PrivateData -Value $definition.PrivateData
	}
}

<#
.SUMMARY
	Retrieves nested modules
#>
function Get-NestedModules {
	[CmdletBinding()]
	param (
		[System.IO.FileInfo[]] $PublicFuncs,
		[System.IO.FileInfo[]] $PrivateFuncs,
		[System.IO.FileInfo[]] $Classes
	)

	[string[]]$BaseNames = $null
	if ($null -ne $PrivateFuncs) {
		 $BaseNames += $PrivateFuncs.Name
	}

	if ($null -ne $PublicFuncs) {
		$BaseNames += $PublicFuncs.Name
	}

	if ($null -ne $Classes) {
		$BaseNames += $Classes.Name
	}

	return $BaseNames
}

<#
.SUMMARY
	Tests if a build is required by checking if key build outputs are present
#>
function Test-BuildRequired {
	[CmdletBinding()]
	param (
		[ValidateNotNullOrEmpty()] [hashtable] $BuildContext
	)

	return (-not (Test-Path -Path (Join-Path -Path $BuildContext.ModuleDistributionPath -ChildPath "$($BuildContext.ModuleName).psd1")))
}
