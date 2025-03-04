function Invoke-AzDoRestMethod {

	[CmdletBinding(SupportsShouldProcess = $true)]
	param(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateSet("GET", "POST", "PATCH", "PUT", "DELETE")]
		[string] $Method,

		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNullorEmpty()]
		[Uri] $OrgOrCollectionUri,

		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNullorEmpty()]
		[string] $Query,

		[Parameter(Mandatory = $true, Position = 3)]
		[ValidateNotNullorEmpty()]
		[string] $ApiVersion,

		[Parameter(Mandatory = $false, Position = 4)]
		[string] $ContentType = "application/json",

		[Parameter(Mandatory = $false, Position = 5)]
		[securestring] $Pat = $null,

		[Parameter(Mandatory = $false, Position = 6)]
		[object] $Body = $null,

		[Parameter(Mandatory = $false, Position = 7)]
		[string] $AdditionalQueryParams = [string]::empty,

		[Parameter(Mandatory = $false, Position = 8)]
		[switch] $ProjectQuery
	)

	[hashtable]$headers = @{
		Accept = $ContentType
	}

	if ($Pat) {
		$headers += New-AzDoAuthHeader $Pat
	}

	[hashtable]$invokeParams = @{ }
	$invokeParams.Add('Headers', $headers)

	if ($ProjectQuery) {
		$tokenizedUri = "$OrganizationUri/${Query}?api-version=$ApiVersion"
	}
	else {
		$tokenizedUri = "$OrganizationUri/_apis/${Query}?api-version=$ApiVersion"
	}

	if (-not [string]::IsNullOrEmpty($AdditionalQueryParams)) {
		$tokenizedUri = "$tokenizedUri&$AdditionalQueryParams"
	}

	if ($PSCmdlet.ShouldProcess($tokenizedUri, $Method)) {

		$response = Invoke-RestMethod -Method					$Method `
									  -ContentType				$ContentType `
									  -Uri						$tokenizedUri `
									  -Body						$Body `
									  -ErrorAction				Stop `
									  -ErrorVariable			responseError `
									  -ResponseHeadersVariable	responseHeader `
									  -StatusCodeVariable		statusCode `
									  -SkipHttpErrorCheck `
									  @invokeParams

		if (($response -isnot [System.Xml.XmlDocument]) -and ($response -isnot [PSCustomObject])) {
			throw ("Invalid response received from '$OrgOrCollectionUri' Response: $response")
		}

		if ($responseError) {
			throw $responseError
		}

		$response = @{ ResponseHeaders	= $responseHeader
					   Body				= $response
					   StatusCode		= $StatusCode }

		$response
	}
}