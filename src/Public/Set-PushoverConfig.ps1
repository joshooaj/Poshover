function Set-PushoverConfig {
    <#
    .SYNOPSIS
        Sets the Pushover configuration in the Poshover module
    .DESCRIPTION
        The Pushover API URI can be modified for the purpose of test automation, and application
        and user tokens can be securely stored on disk so that you don't have to supply the tokens
        with every call to Send-Pushover in case you are always sending notifications from the same
        application and to the same user/group.
    .EXAMPLE
        PS C:\> Set-PushoverConfig -Token (Read-Host -AsSecureString)
        PS C:\> Set-PushoverConfig -User (Read-Host -AsSecureString)
        Reads the desired default application token and user token securely and persists it to disk in the %appdata%/Poshover/config.xml file.
    .EXAMPLE
        PS C:\> Set-PushoverConfig -ApiUri http://localhost:8888 -Temporary
        Sets the Pushover API URI to http://localhost:8888 for the duration of the PowerShell session
        or until the Poshover module is forcefully imported again.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Species the base URI to which all HTTP requests should be sent. Recommended to change this only for the purposes of test automation.
        [Parameter()]
        [uri]
        $ApiUri,

        # Specifies the default application api token. If the token parameter is omitted in any Pushover requests, the default will be used.
        [Parameter(ParameterSetName = 'AsPlainText')]
        [securestring]
        $Token,

        # Specifies the default user or group ID string. If the user parameter is omitted in any Pushover requests, the default will be used.
        [Parameter()]
        [securestring]
        $User,

        # Specifies that the new settings should only be temporary and should not be saved to disk.
        [Parameter()]
        [switch]
        $Temporary
    )

    process {
        if ($PSBoundParameters.ContainsKey('ApiUri')) {
            if ($PSCmdlet.ShouldProcess("Pushover ApiUri", "Set value to '$ApiUri'")) {
                $script:config.PushoverAPiUri = $ApiUri.ToString()
            }
        }
        if ($PSBoundParameters.ContainsKey('Token')) {
            if ($PSCmdlet.ShouldProcess("Pushover Default Application Token", "Set value")) {
                $script:config.DefaultAppToken = $Token
            }
        }
        if ($PSBoundParameters.ContainsKey('User')) {
            if ($PSCmdlet.ShouldProcess("Pushover Default User Key", "Set value")) {
                $script:config.DefaultUserToken = $User
            }
        }

        if (-not $Temporary) {
            Save-PushoverConfig
        }
    }
}