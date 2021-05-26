function Reset-PushoverConfig {
    <#
    .SYNOPSIS
        Reset Poshover module's configuration to default values
    #>
    [CmdletBinding()]
    param ()

    process {
        Write-Verbose "Using the default module configuration"
        $script:config = @{
            PushoverApiDefaultUri = 'https://api.pushover.net/1'
            PushoverApiUri = 'https://api.pushover.net/1'
            DefaultApplicationToken = $null
            DefaultUserToken = $null
        }
        Save-PushoverConfig
    }
}