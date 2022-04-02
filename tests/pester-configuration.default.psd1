@{
    Filter = @{
        ExcludeTag = 'Acceptance', 'Integration'
    }
    Should = @{
        ErrorAction = 'Continue'
    }
    CodeCoverage = @{
        Enabled = $true
    }
}