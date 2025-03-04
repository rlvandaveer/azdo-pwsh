<#
.SYNOPSIS
	Creates an authorization header using an Azure DevOps Personal Access Token

.PARAMETER PersonalAccessToken
	A securestring representation of an Azure DevOps personal access token (PAT)
#>
function New-AzDoPatHeader {

	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNullorEmpty()]
		[securestring] $PersonalAccessToken
	)
	$AzureDevOpsAuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$(ConvertFrom-SecureString $PersonalAccessToken -AsPlainText)"))
	$headers = @{
		"Authorization" = "Basic $AzureDevOpsAuthToken"
	}
	$headers
}
