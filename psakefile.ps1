function Update-ModuleVersion {
    <#
    .SYNOPSIS
        Updates the ModuleVersion parameter for the module manifest
    .DESCRIPTION
        Takes a hashtable representing the module manifest parameters and updates the ModuleVersion
        parameter. The Major and Minor values remain the same, but the Patch value will be updated
        based on time since epoch.
    #>
    [CmdletBinding()]
    param(
        # Module manifest parameter hashtable
        [Parameter(Mandatory)]
        [hashtable]
        $ManifestParams,
        # Pass the version back into the pipeline
        [Parameter()]
        [switch]
        $PassThru
    )
    $lastVersion = [version]$ManifestParams.ModuleVersion
    $ManifestParams.ModuleVersion = [version]::new($lastVersion.Major, $lastVersion.Minor, [int]([datetimeoffset]::UtcNow.ToUnixTimeSeconds() / 60 / 60))
    if ($PassThru) {
        $ManifestParams.ModuleVersion
    }
}

function Expand-PSData {
    <#
    .SYNOPSIS
        Pulls the PrivateData.PSData keys and values and attaches them to the root of the ManifestParams hashtable
    #>
    [CmdletBinding()]
    param(
        # Module manifest parameter hashtable
        [Parameter(Mandatory)]
        [hashtable]
        $ManifestParams,
        # Remove the PrivateData parameter after extracting the PSData properties and attaching them to ManifestParams
        [Parameter()]
        [switch]
        $RemovePrivateData
    )

    foreach ($key in $manifestParams.PrivateData.PSData.Keys) {
        $manifestParams.$key = $manifestParams.PrivateData.PSData.$key
    }
    if ($RemovePrivateData) {
        $manifestParams.Remove('PrivateData')
    }
}

function Remove-EmptyParameters {
    <#
    .SYNOPSIS
        Removes any module manifest parameters with a null or empty value
    .DESCRIPTION
        Update-ModuleManifest or New-ModuleManifest doesn't like it when you supply an empty value
        for a parameter. When importing an existing manifest and using that to create or update a
        manifest, you need to remove these empty values.
    #>
    [CmdletBinding()]
    param(
        # Module manifest parameter hashtable
        [Parameter(Mandatory)]
        [hashtable]
        $ManifestParams
    )
    $propertyKeys = $ManifestParams.Keys | Sort-Object
    foreach ($key in $propertyKeys) {
        if ($null -eq $ManifestParams.$key -or $ManifestParams.$key.Count -eq 0) {
            $ManifestParams.Remove($key)
        }
    }
}

function Update-FunctionsToExport {
    <#
    .SYNOPSIS
        Updates the FunctionsToExport parameter for a module manifest
    .DESCRIPTION
        Finds all public functions to be exported based on the BaseName value of all .PS1 files in
        the Public folder, recursively, and updates the FunctionsToExport parameter value of the
        supplied hashtable.
    #>
    [CmdletBinding()]
    param(
        # Module manifest parameter hashtable
        [Parameter(Mandatory)]
        [hashtable]
        $ManifestParams
    )
    $manifestParams.FunctionsToExport = @( Get-ChildItem -Path $PSScriptRoot\src\Public\*.ps1 -Recurse | Select-Object -ExpandProperty BaseName )
}
function Update-ScriptsToProcess {
    <#
    .SYNOPSIS
        Updates the ScriptsToProcess parameter for a module manifest
    .DESCRIPTION
        Finds all ps1 files in the Classes folder, recursively, and adds them to the
        ScriptsToProcess parameter of the manifest to ensure those classes / models are available
        in the user's session.
    #>
    [CmdletBinding()]
    param(
        # Module manifest parameter hashtable
        [Parameter(Mandatory)]
        [hashtable]
        $ManifestParams
    )
    Push-Location -Path $PSScriptRoot\src
    $manifestParams.ScriptsToProcess = @( Get-ChildItem -Path $PSScriptRoot\src\Classes\*.ps1 -Recurse | Select-Object -ExpandProperty FullName | Resolve-Path -Relative )
    Pop-Location
}

properties {
	$script:ModuleName = 'PoshOver'
	$script:CompanyName = 'Milestone Systems'
    $script:ModuleVersion = [version]::new()
}

Task default -Depends Build

Task Build {
    $srcManifestFile = Get-Item -Path $PSScriptRoot\src\*.psd1 | Select-Object -First 1
    $manifestParams = Import-PowerShellDataFile -Path $srcManifestFile.FullName
    $script:ModuleVersion = Update-ModuleVersion $manifestParams -PassThru
    Update-FunctionsToExport $manifestParams
    Update-ScriptsToProcess $manifestParams
    Expand-PSData $manifestParams -RemovePrivateData
    Remove-EmptyParameters $manifestParams
    $manifestParams.Copyright = "(c) $((Get-Date).Year) $($script:CompanyName). All rights reserved."

    $outputDirectory = New-Item -Path "$PSScriptRoot\output\$($script:ModuleName)\$($manifestParams.ModuleVersion)" -ItemType Directory -Force
    $dstManifest = Join-Path $outputDirectory.FullName "$($script:ModuleName).psd1"
    Get-ChildItem -Path $PSScriptRoot\src | Copy-Item -Destination $outputDirectory.FullName -Recurse -Force
    New-ModuleManifest -Path $dstManifest -ModuleVersion $manifestParams.ModuleVersion
    Update-ModuleManifest -Path $dstManifest @manifestParams
}

Task Test -Depends Build {
    $manifestPath = "$PSScriptRoot\output\$($script:ModuleName)\$($script:ModuleVersion)\$($script:ModuleName).psd1"
    $moduleDirectory = ([IO.FileInfo]$manifestPath).DirectoryName
    try {
        Push-Location $moduleDirectory
        Import-Module -Name $manifestPath -Force
        $testResults = Invoke-Pester -Path .\Tests -PassThru
        if ($testResults.FailedCount -gt 0) {
            Write-Error "Failed $($testResults.FailedCount) tests. Build failed."
        }
        Invoke-ScriptAnalyzer -Path .\ -Recurse
    }
    finally {
        Pop-Location
    }
}
