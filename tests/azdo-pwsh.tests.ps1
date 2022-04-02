BeforeAll {
	$moduleName = 'azdo-pwsh'
	$testDir = Get-Item (Split-Path -Parent $PSCommandPath)
	$modDir = $testDir.Parent
	$sourcePath = Join-Path -Path $modDir.FullName -ChildPath 'source'
	$distPath = Join-Path -Path $modDir.FullName -ChildPath (Join-Path -Path 'dist' -ChildPath $moduleName)
	$manifestPath = Join-Path -Path $distPath -ChildPath "$moduleName.psd1"
	$definitionPath = Join-Path -Path $sourcePath -ChildPath "$moduleName.definition.psd1"
}

Describe 'Module Manifest Tests' {
    It 'Test-ModuleManifest is successful' {
        Test-ModuleManifest -Path $manifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }

	Context 'The module manifest' {

		BeforeAll {
			$sut = Import-PowerShellDataFile -Path $manifestPath
			$definition = Import-PowerShellDataFile -Path $definitionPath
			$fileCount = (Get-ChildItem -Path $sourcePath -Include *.ps1, *.psm1, *.psd1 -Recurse -File).Length
		}

		It 'Has a valid version number' {
			$sut.ModuleVersion | Should -Match '\d+\.\d+.\d+'
		}

		It 'Has the correct GUID' {
			$sut.GUID | Should -BeExactly $definition.GUID
		}

		It 'Has the correct author' {
			$sut.Author | Should -BeExactly $definition.Author
		}

		It 'Has the correct company name' {
			$sut.CompanyName | Should -BeExactly $definition.CompanyName
		}

		It 'Has the correct copyright' {
			$sut.Copyright | Should -BeExactly $definition.Copyright
		}

		It 'Has the correct description' {
			$sut.Description | Should -BeExactly $definition.Description
		}

		It 'Has the correct file list' {
			$sut.FileList | Should -HaveCount $fileCount
		}

		It 'Has private data' {
			$sut.PrivateData | Should -Not -BeNullOrEmpty
		}
	}
}

