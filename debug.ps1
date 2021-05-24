<#
    Used as a launch script in VSCode to...
    - Remove all previous builds sitting in the output folder
    - Build the module using the psakefile.ps1 build task
    - Find the module manifest and force import it

    This makes for a quick developer "inner loop"
#>

Get-ChildItem $PSScriptRoot\output -ErrorAction Ignore | Remove-Item -Recurse -Force
Invoke-psake build
$manifest = Get-ChildItem -Path $PSScriptRoot\output\*.psd1 -Recurse
Import-Module $manifest.FullName -Force