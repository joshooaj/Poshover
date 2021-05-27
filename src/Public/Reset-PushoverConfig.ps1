function Reset-PushoverConfig {
    <#
    .SYNOPSIS
        Reset Poshover module's configuration to default values
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    process {
        if ($PSCmdlet.ShouldProcess("Poshover Module Configuration", "Reset to default")) {
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
}