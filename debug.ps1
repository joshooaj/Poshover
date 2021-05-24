Get-ChildItem $PSScriptRoot\output -ErrorAction Ignore | Remove-Item -Recurse -Force
Invoke-psake build
$manifest = Get-ChildItem -Path $PSScriptRoot\output\*.psd1 -Recurse
Import-Module $manifest.FullName -Force