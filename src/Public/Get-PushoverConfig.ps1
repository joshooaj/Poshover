function Get-PushoverConfig {
    <#
    .SYNOPSIS
        Get the Pushover configuration from the Poshover module
    .DESCRIPTION
        Properties like the API URI and default application and user tokens can be read and written
        using Get-PushoverConfig and Set-PushoverConfig.
    #>
    [CmdletBinding()]
    param ()

    process {
        [pscustomobject]@{
            PSTypeName = 'Poshover.PushoverConfig'
            ApiUri = $script:config.PushoverApiUri
            Token = $script:config.DefaultAppToken
            User = $script:config.DefaultUserToken
            ConfigPath = $script:configPath
        }
    }
}