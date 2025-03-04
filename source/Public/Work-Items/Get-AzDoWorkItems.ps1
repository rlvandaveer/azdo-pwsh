function Get-AzDoWorkItems {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullorEmpty()]
		[Uri] $OrgOrCollectionUri,

		[Parameter(Mandatory = $true)]
		[ValidateNotNullorEmpty()]
		[string] $Project,

		[Parameter(Mandatory = $true)]
		[ValidateNotNullorEmpty()]
		[int[]] $Ids,

		[Parameter(Mandatory = $false)]
		[object] $Authorization = $null
	)

	New-Variable -Name API_VERSION -Option Constant, Private -Value "7.1"

	$response = Invoke-AzDoRestMethod -Method "GET" `
									  -OrgOrCollectionUri $OrgOrCollectionUri  `
									  -Query "$Project/_apis/wit/workitems/$Ids" `
									  -ApiVersion $API_Version `
									  -Authorization $Authorization `
									  -ProjectQuery

	$response
}