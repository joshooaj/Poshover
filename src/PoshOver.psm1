$Classes = @( Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction Ignore -Recurse )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction Ignore -Recurse )
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction Ignore -Recurse )

foreach ($import in $Classes + $Public + $Private) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import file $($import.FullName): $_"
    }
}

$script:PushoverApiDefaultUri = 'https://api.pushover.net/1'
$script:PushoverApiUri = $script:PushoverApiDefaultUri

Export-ModuleMember -Function ($Public.BaseName)